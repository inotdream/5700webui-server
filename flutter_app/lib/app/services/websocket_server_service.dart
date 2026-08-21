import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:get/get.dart';
import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_web_socket/shelf_web_socket.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:mime/mime.dart';
import '../utils/app_log.dart';
import 'tcp_service.dart';
import 'storage_service.dart';

/// WebSocket服务器服务
/// 为Web前端提供WebSocket接口,转发TCP AT设备的数据
class WebSocketServerService extends GetxService {
  HttpServer? _server;
  final _clients = <WebSocketChannel>{};
  final _tcpService = Get.find<TcpService>();
  late final StorageService _storageService;
  
  final isRunning = false.obs;
  final serverPort = 8765.obs;
  final clientCount = 0.obs;
  Future<void>? _startFuture;
  
  StreamSubscription? _smsSubscription;
  StreamSubscription? _callSubscription;
  StreamSubscription? _signalSubscription;
  StreamSubscription? _rawDataSubscription;

  final _assetCache = <String, _CachedAsset>{};
  List<InternetAddress>? _cachedLanIps;
  DateTime? _lanIpsCachedAt;
  static const _lanIpTtl = Duration(seconds: 30);

  @override
  void onInit() {
    super.onInit();
    _storageService = Get.find<StorageService>();
    _setupEventListeners();
  }

  /// 设置事件监听器
  void _setupEventListeners() {
    // 监听原始数据流（主动上报数据）- 广播给所有客户端
    _rawDataSubscription = _tcpService.rawDataStream.listen((data) {
      _broadcastToClients({
        'type': 'raw_data',
        'data': data,
      });
    });

    // 注意：AT命令响应不在这里广播，而是在 _handleClientMessage 中直接返回给发送命令的客户端
    // 这样可以避免重复响应，并且保持点对点通信
    
    // 监听短信事件
    _smsSubscription = _tcpService.smsStream.listen((sms) {
      _broadcastToClients({
        'type': 'new_sms',
        'success': true,
        'data': {
          'sender': sms.sender,
          'content': sms.content,
          'time': sms.time,
        },
      });
    });

    // 监听来电事件
    _callSubscription = _tcpService.callStream.listen((call) {
      _broadcastToClients({
        'type': 'incoming_call',
        'success': true,
        'data': {
          'number': call.number,
          'state': call.state,
          'time': call.time,
        },
      });
    });

    // 监听信号数据事件
    _signalSubscription = _tcpService.signalStream.listen((signal) {
      _broadcastToClients({
        'type': 'signal_data',
        'success': true,
        'data': {
          'rsrp': signal.rsrp,
          'rsrq': signal.rsrq,
          'sinr': signal.sinr,
          'ulPdcpRate': signal.ulPdcpRate,
          'dlPdcpRate': signal.dlPdcpRate,
        },
      });
    });
  }

  /// HTTP静态文件处理器
  Future<shelf.Response> _staticFileHandler(shelf.Request request) async {
    try {
      // 获取请求路径
      var path = request.url.path;
      
      // 如果是根路径，返回index.html
      if (path.isEmpty || path == '/') {
        path = 'index.html';
      }
      
      // 特殊处理config.json和cgi-bin/at-ws-info，动态生成配置
      if (path == 'config.json' || path == 'cgi-bin/at-ws-info') {
        return await _generateConfigJson();
      }
      
      final assetPath = 'assets/web/$path';
      appLog('📄 请求文件: $path -> $assetPath');

      try {
        final cached = await _loadAsset(assetPath, path);
        return shelf.Response.ok(
          cached.bytes,
          headers: {
            'Content-Type': cached.mimeType,
            'Cache-Control': 'public, max-age=3600',
          },
        );
      } catch (e) {
        appLog('❌ 文件未找到: $assetPath');
        try {
          final index = await _loadAsset('assets/web/index.html', 'index.html');
          return shelf.Response.ok(
            index.bytes,
            headers: {'Content-Type': 'text/html'},
          );
        } catch (e2) {
          return shelf.Response.notFound('File not found: $path');
        }
      }
    } catch (e) {
      appLog('❌ 处理静态文件请求失败: $e');
      return shelf.Response.internalServerError(body: 'Internal server error');
    }
  }
  
  Future<_CachedAsset> _loadAsset(String assetPath, String requestPath) async {
    final hit = _assetCache[assetPath];
    if (hit != null) return hit;

    final data = await rootBundle.load(assetPath);
    final bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    final mimeType = lookupMimeType(requestPath) ?? 'application/octet-stream';
    final cached = _CachedAsset(bytes: Uint8List.fromList(bytes), mimeType: mimeType);
    _assetCache[assetPath] = cached;
    return cached;
  }

  Future<List<InternetAddress>> _lanIpv4Addresses() async {
    final now = DateTime.now();
    if (_cachedLanIps != null &&
        _lanIpsCachedAt != null &&
        now.difference(_lanIpsCachedAt!) < _lanIpTtl) {
      return _cachedLanIps!;
    }

    final addresses = <InternetAddress>[];
    try {
      final interfaces = await NetworkInterface.list(
        type: InternetAddressType.IPv4,
        includeLoopback: false,
      );
      for (final interface in interfaces) {
        addresses.addAll(interface.addresses);
      }
    } catch (e) {
      appLog('⚠️ 获取网络接口失败: $e');
    }
    _cachedLanIps = addresses;
    _lanIpsCachedAt = now;
    return addresses;
  }

  /// 动态生成config.json
  Future<shelf.Response> _generateConfigJson() async {
    try {
      String host = '127.0.0.1';
      try {
        for (final addr in await _lanIpv4Addresses()) {
          final ip = addr.address;
          if (ip.startsWith('192.168.') || ip.startsWith('10.')) {
            host = ip;
            break;
          }
        }
      } catch (e) {
        appLog('⚠️ 获取网络接口失败: $e');
      }
      
      final config = {
        'status': 'false',  // 修改为你想要的值
        'at': {
          'host': host,
          'port': serverPort.value,
        },
      };
      
      final configJson = jsonEncode(config);
      appLog('📄 动态生成 config.json: $configJson');
      
      return shelf.Response.ok(
        configJson,
        headers: {
          'Content-Type': 'application/json',
          'Cache-Control': 'no-cache, no-store, must-revalidate',
        },
      );
    } catch (e) {
      appLog('❌ 生成config.json失败: $e');
      // 返回默认配置
      final defaultConfig = {
        'status': 'false',  // 修改为你想要的值
        'at': {
          'host': '127.0.0.1',
          'port': serverPort.value,
        },
      };
      return shelf.Response.ok(
        jsonEncode(defaultConfig),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  /// 启动WebSocket服务器
  Future<void> startServer({int? port}) async {
    if (isRunning.value) {
      appLog('WebSocket服务器已在运行');
      return;
    }
    if (_startFuture != null) {
      await _startFuture;
      return;
    }

    final started = _startServerInternal(port);
    _startFuture = started;
    try {
      await started;
    } finally {
      _startFuture = null;
    }
  }

  Future<void> _startServerInternal(int? port) async {
    try {
      serverPort.value = port ?? _storageService.wsPort;

      final wsHandler = webSocketHandler((WebSocketChannel webSocket) {
        appLog('新的WebSocket客户端连接');
        _clients.add(webSocket);
        clientCount.value = _clients.length;

        // 监听客户端消息（不发送欢迎消息，和 Python 网关保持一致）
        webSocket.stream.listen(
          (message) {
            _handleClientMessage(webSocket, message);
          },
          onDone: () {
            appLog('WebSocket客户端断开连接');
            _clients.remove(webSocket);
            clientCount.value = _clients.length;
          },
          onError: (error) {
            appLog('WebSocket客户端错误: $error');
            _clients.remove(webSocket);
            clientCount.value = _clients.length;
          },
        );
      });

      // 组合HTTP和WebSocket处理器
      final handler = (shelf.Request request) async {
        // 检查是否是WebSocket升级请求
        final upgradeHeader = request.headers['upgrade'];
        if (upgradeHeader != null && upgradeHeader.toLowerCase() == 'websocket') {
          return wsHandler(request);
        }
        // 否则返回静态文件
        return await _staticFileHandler(request);
      };

      _server = await shelf_io.serve(
        handler,
        InternetAddress.anyIPv4,
        serverPort.value,
      );

      isRunning.value = true;
      appLog('✅ WebSocket服务器启动成功: ws://0.0.0.0:${serverPort.value}');
    } catch (e) {
      appLog('❌ WebSocket服务器启动失败: $e');
      isRunning.value = false;
      rethrow;
    }
  }

  /// 停止WebSocket服务器
  Future<void> stopServer() async {
    if (!isRunning.value) return;

    try {
      // 关闭所有客户端连接
      for (var client in _clients) {
        await client.sink.close();
      }
      _clients.clear();
      clientCount.value = 0;

      // 关闭服务器
      await _server?.close(force: true);
      _server = null;

      isRunning.value = false;
      appLog('WebSocket服务器已停止');
    } catch (e) {
      appLog('停止WebSocket服务器时出错: $e');
    }
  }

  /// 处理客户端消息
  void _handleClientMessage(WebSocketChannel client, dynamic message) async {
    try {
      if (message == 'ping') {
        client.sink.add('pong');
        return;
      }

      final String command = message.toString().trim();
      appLog('📥 收到WebSocket命令: $command');

      // 通过TCP发送AT命令
      if (_tcpService.isConnected.value) {
        try {
          final response = await _tcpService.sendCommand(command);
          
          // 过滤响应：移除命令回显
          final lines = response.split('\r\n');
          final filteredLines = lines.where((line) {
            final trimmedLine = line.trim();
            final trimmedCommand = command.trim();
            return trimmedLine.isNotEmpty && trimmedLine != trimmedCommand;
          }).toList();
          
          final filteredResponse = filteredLines.join('\r\n');
          
          // 检查是否包含错误
          final hasError = filteredResponse.toUpperCase().contains('ERROR');
          
          // 发送响应给客户端（和 Python 格式完全一致）
          client.sink.add(jsonEncode({
            'success': !hasError,
            'data': hasError ? null : filteredResponse,
            'error': hasError ? filteredResponse : null,
          }));
        } catch (e) {
          client.sink.add(jsonEncode({
            'success': false,
            'data': null,
            'error': e.toString(),
          }));
        }
      } else {
        client.sink.add(jsonEncode({
          'success': false,
          'data': null,
          'error': '未连接到AT设备',
        }));
      }
    } catch (e) {
      appLog('处理WebSocket消息失败: $e');
      client.sink.add(jsonEncode({
        'success': false,
        'data': null,
        'error': e.toString(),
      }));
    }
  }

  /// 广播消息给所有客户端
  void _broadcastToClients(Map<String, dynamic> data) {
    if (_clients.isEmpty) return;

    final message = jsonEncode(data);
    final deadClients = <WebSocketChannel>[];

    for (var client in _clients) {
      try {
        client.sink.add(message);
      } catch (e) {
        appLog('发送消息到客户端失败: $e');
        deadClients.add(client);
      }
    }

    // 移除失效的客户端
    for (var client in deadClients) {
      _clients.remove(client);
    }
    clientCount.value = _clients.length;
  }

  /// 修改WebSocket服务器端口
  Future<bool> changePort(int newPort) async {
    if (newPort < 1024 || newPort > 65535) {
      appLog('❌ 端口号必须在1024-65535之间');
      return false;
    }

    try {
      // 停止当前服务器
      await stopServer();
      
      // 保存新端口到存储
      _storageService.wsPort = newPort;
      
      // 使用新端口重新启动服务器
      await startServer(port: newPort);
      
      appLog('✅ WebSocket端口已修改为: $newPort');
      return true;
    } catch (e) {
      appLog('❌ 修改WebSocket端口失败: $e');
      return false;
    }
  }

  /// 获取当前端口
  int getCurrentPort() {
    return serverPort.value;
  }

  /// 检查端口是否可用
  Future<bool> isPortAvailable(int port) async {
    try {
      final server = await ServerSocket.bind(InternetAddress.anyIPv4, port);
      await server.close();
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  void onClose() {
    _smsSubscription?.cancel();
    _callSubscription?.cancel();
    _signalSubscription?.cancel();
    _rawDataSubscription?.cancel();
    stopServer();
    super.onClose();
  }

  /// 获取服务器地址
  String getServerAddress() {
    if (!isRunning.value) return '未运行';
    
    // 获取本地IP地址
    return 'ws://0.0.0.0:${serverPort.value}';
  }

  /// 获取所有网络接口的IP地址（WebSocket）
  Future<List<String>> getLocalIPAddresses() async {
    try {
      return [
        for (final addr in await _lanIpv4Addresses())
          'ws://${addr.address}:${serverPort.value}',
      ];
    } catch (e) {
      appLog('获取IP地址失败: $e');
      return const [];
    }
  }

  /// 获取所有网络接口的HTTP地址
  Future<List<String>> getHttpAddresses() async {
    try {
      return [
        for (final addr in await _lanIpv4Addresses())
          'http://${addr.address}:${serverPort.value}',
      ];
    } catch (e) {
      appLog('获取HTTP地址失败: $e');
      return const [];
    }
  }
}

class _CachedAsset {
  final Uint8List bytes;
  final String mimeType;
  const _CachedAsset({required this.bytes, required this.mimeType});
}

