import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:get/get.dart';
import '../data/models/sms_model.dart';
import '../data/models/call_info.dart';
import '../data/models/signal_data.dart';
import '../utils/app_log.dart';
import '../utils/at_protocol.dart';
import 'storage_service.dart';

class TcpService extends GetxService {
  Socket? _socket;
  StreamSubscription<List<int>>? _socketSub;
  final _storageService = Get.find<StorageService>();

  final _responseController = StreamController<String>.broadcast();
  Stream<String> get responseStream => _responseController.stream;

  final _consoleResponseController = StreamController<String>.broadcast();
  Stream<String> get consoleResponseStream => _consoleResponseController.stream;

  final _smsController = StreamController<SmsModel>.broadcast();
  Stream<SmsModel> get smsStream => _smsController.stream;

  final _callController = StreamController<CallInfo>.broadcast();
  Stream<CallInfo> get callStream => _callController.stream;

  final _signalController = StreamController<SignalData>.broadcast();
  Stream<SignalData> get signalStream => _signalController.stream;

  final _rawDataController = StreamController<String>.broadcast();
  Stream<String> get rawDataStream => _rawDataController.stream;

  final isConnected = false.obs;
  final connectionStatus = '未连接'.obs;

  final _assembler = AtLineAssembler();
  final _commandLines = <String>[];
  Completer<String>? _commandCompleter;
  Timer? _responseTimer;

  bool _isReconnecting = false;
  bool _userClosed = false;
  Timer? _reconnectTimer;
  int _reconnectAttempt = 0;

  final _commandQueue = Queue<_CommandTask>();
  bool _isProcessingQueue = false;
  static const _commandDelay = Duration(milliseconds: 100);

  @override
  void onInit() {
    super.onInit();
    if (_storageService.autoConnect) {
      connect();
    }
  }

  Future<void> connect() async {
    if (isConnected.value || _isReconnecting) {
      appLog('⚠️ 已有连接或正在重连中，跳过此次连接请求');
      return;
    }

    _userClosed = false;

    try {
      await _cleanupConnection(clearQueue: true);

      _isReconnecting = true;

      final host = _storageService.tcpHost;
      final port = _storageService.tcpPort;

      appLog('🔗 尝试连接到 $host:$port');
      connectionStatus.value = '连接中...';

      _socket = await Socket.connect(
        host,
        port,
        timeout: const Duration(seconds: 10),
      );

      isConnected.value = true;
      connectionStatus.value = '已连接';
      _isReconnecting = false;
      _reconnectAttempt = 0;

      appLog('✅ 已连接到 $host:$port');

      _socketSub = _socket!.listen(
        _handleData,
        onError: (error) {
          appLog('Socket错误: $error');
          isConnected.value = false;
          connectionStatus.value = '连接错误';
          _reconnect();
        },
        onDone: () {
          appLog('Socket连接断开');
          isConnected.value = false;
          connectionStatus.value = '连接断开';
          _reconnect();
        },
        cancelOnError: true,
      );

      await _initATConfig();
    } catch (e) {
      final host = _storageService.tcpHost;
      final port = _storageService.tcpPort;

      appLog('❌ TCP连接失败: $e');
      appLog('🔍 连接详情: $host:$port, 错误类型: ${e.runtimeType}');

      isConnected.value = false;
      connectionStatus.value = '连接失败: $e';
      _isReconnecting = false;

      if (_storageService.autoConnect && !_userClosed) {
        appLog('🔄 自动重连已启用，将稍后重试...');
        _reconnect();
      }
    }
  }

  Future<void> _cleanupConnection({bool clearQueue = true}) async {
    try {
      _responseTimer?.cancel();
      _responseTimer = null;

      _reconnectTimer?.cancel();
      _reconnectTimer = null;

      if (_commandCompleter != null && !_commandCompleter!.isCompleted) {
        _commandCompleter!.completeError(Exception('连接已关闭'));
        _commandCompleter = null;
      }

      if (clearQueue) {
        while (_commandQueue.isNotEmpty) {
          final task = _commandQueue.removeFirst();
          if (!task.completer.isCompleted) {
            task.completer.completeError(Exception('连接已关闭'));
          }
        }
        _isProcessingQueue = false;
      }

      _assembler.clear();
      _commandLines.clear();

      await _socketSub?.cancel();
      _socketSub = null;

      final socket = _socket;
      _socket = null;
      if (socket != null) {
        try {
          await socket.close().timeout(const Duration(seconds: 2));
        } catch (_) {
          socket.destroy();
        }
      }
    } catch (e) {
      appLog('清理连接时出错: $e');
    }
  }

  Future<void> _initATConfig() async {
    try {
      await Future.delayed(const Duration(milliseconds: 200));
      await sendCommand('AT+CMGF=0');
      await sendCommand('AT+CNMI=2,1,0,2,0');
      await sendCommand('AT+CLIP=1');
      appLog('✅ AT配置初始化完成');
    } catch (e) {
      appLog('AT配置初始化失败: $e');
    }
  }

  void _handleData(List<int> data) {
    try {
      final text = utf8.decode(data, allowMalformed: true);
      appLog('📥 收到数据: $text');

      final lines = _assembler.add(text);
      for (final line in lines) {
        _dispatchLine(line);
      }

      if (_commandCompleter != null &&
          !_commandCompleter!.isCompleted &&
          _assembler.hasSmsPrompt) {
        _assembler.clear();
        _finishCommand('>');
      }

      if (_assembler.isOverflowed) {
        final leftover = _assembler.leftover;
        _assembler.clear();
        if (_commandCompleter == null || _commandCompleter!.isCompleted) {
          _emitUrc(leftover);
        }
      }
    } catch (e) {
      appLog('数据处理错误: $e');
    }
  }

  void _dispatchLine(String line) {
    final trimmed = line.trim();
    final waiting =
        _commandCompleter != null && !_commandCompleter!.isCompleted;

    if (trimmed.isEmpty) {
      if (waiting) _commandLines.add(line);
      return;
    }

    if (AtFrameParser.isInterleavedUrc(trimmed)) {
      _emitUrc(trimmed);
      return;
    }

    if (waiting) {
      _commandLines.add(line);
      if (AtFrameParser.isFinalResultLine(trimmed)) {
        _finishCommand(_commandLines.join('\r\n'));
      }
      return;
    }

    _emitUrc(trimmed);
  }

  void _finishCommand(String response) {
    _responseTimer?.cancel();
    _responseTimer = null;
    _commandLines.clear();
    final completer = _commandCompleter;
    _commandCompleter = null;
    if (completer != null && !completer.isCompleted) {
      completer.complete(response);
      _consoleResponseController.add(response);
    }
  }

  void _emitUrc(String message) {
    if (message.trim().isEmpty) return;
    appLog('📡 主动上报: $message');
    _rawDataController.add(message);
    _parseUnsolicitedMessage(message);
  }

  void _parseUnsolicitedMessage(String message) {
    for (var line in message.split(RegExp(r'\r\n|\n'))) {
      line = line.trim();
      if (line.isEmpty) continue;

      if (line.contains('+CMTI:')) {
        _handleNewSms(line);
      } else if (line.contains('RING') || line.contains('+CLIP:')) {
        _handleIncomingCall(line);
      } else if (line.contains('^CEND:') || line.contains('NO CARRIER')) {
        _handleCallEnded();
      } else if (line.contains('^HCSQ:') || line.contains('^CERSSI:')) {
        _handleSignalData(line);
      }
    }
  }

  Future<void> _handleNewSms(String line) async {
    try {
      final match = RegExp(r'\+CMTI: "([^"]+)",(\d+)').firstMatch(line);
      if (match != null) {
        final index = match.group(2)!;
        appLog('收到新短信，索引: $index');

        await sendCommand('AT+CMGR=$index');

        _smsController.add(SmsModel(
          sender: '未知',
          content: '收到新短信（索引：$index）',
          time: DateTime.now().toString(),
        ));
      }
    } catch (e) {
      appLog('处理新短信失败: $e');
    }
  }

  void _handleIncomingCall(String line) {
    try {
      if (line.contains('+CLIP:')) {
        final match = RegExp(r'\+CLIP: "([^"]+)"').firstMatch(line);
        if (match != null) {
          final number = match.group(1)!;
          _callController.add(CallInfo(
            time: DateTime.now().toString(),
            number: number,
            state: 'ringing',
          ));
        }
      }
    } catch (e) {
      appLog('处理来电失败: $e');
    }
  }

  void _handleCallEnded() {
    _callController.add(CallInfo(
      time: DateTime.now().toString(),
      number: '',
      state: 'ended',
    ));
  }

  void _handleSignalData(String line) {
    try {
      if (line.contains('^HCSQ:')) {
        final parts = line.split(',');
        if (parts.length >= 4) {
          final rsrpRaw = int.tryParse(parts[1]) ?? 0;
          final rsrp = -140 + rsrpRaw;

          _signalController.add(SignalData(
            rsrp: rsrp,
            rsrq: -10.0,
            sinr: 15.0,
          ));
        }
      }
    } catch (e) {
      appLog('处理信号数据失败: $e');
    }
  }

  Future<String> sendCommand(String command) async {
    if (!isConnected.value || _socket == null) {
      throw Exception('未连接到服务器');
    }

    final completer = Completer<String>();
    _commandQueue.add(_CommandTask(command, completer));
    _processCommandQueue();
    return completer.future;
  }

  Future<void> _processCommandQueue() async {
    if (_isProcessingQueue) return;
    _isProcessingQueue = true;

    try {
      while (_commandQueue.isNotEmpty) {
        final task = _commandQueue.removeFirst();
        try {
          final response = await _executeCommand(task.command);
          if (!task.completer.isCompleted) {
            task.completer.complete(response);
          }
          if (_commandQueue.isNotEmpty) {
            await Future.delayed(_commandDelay);
          }
        } catch (e) {
          if (!task.completer.isCompleted) {
            task.completer.completeError(e);
          }
          if (_commandQueue.isNotEmpty) {
            await Future.delayed(_commandDelay);
          }
        }
      }
    } finally {
      _isProcessingQueue = false;
    }
  }

  Future<String> _executeCommand(String command) async {
    if (!command.endsWith('\r\n')) {
      command += '\r\n';
    }

    appLog('📤 发送命令: ${command.trim()}');

    _commandCompleter = Completer<String>();
    _commandLines.clear();

    _responseTimer = Timer(const Duration(seconds: 10), () {
      if (_commandCompleter != null && !_commandCompleter!.isCompleted) {
        _commandCompleter!.completeError(TimeoutException('命令超时'));
        _commandCompleter = null;
        _commandLines.clear();
        final leftover = _assembler.leftover;
        _assembler.clear();
        if (leftover.trim().isNotEmpty) {
          _emitUrc(leftover);
        }
      }
    });

    try {
      _socket!.write(command);
      await _socket!.flush();
    } catch (e) {
      _responseTimer?.cancel();
      _commandCompleter = null;
      rethrow;
    }

    return _commandCompleter!.future;
  }

  Future<bool> testConnection() async {
    final host = _storageService.tcpHost;
    final port = _storageService.tcpPort;

    appLog('🧪 测试网络连接: $host:$port');

    try {
      final socket = await Socket.connect(
        host,
        port,
        timeout: const Duration(seconds: 5),
      );
      socket.destroy();
      appLog('✅ 网络连接测试成功');
      return true;
    } catch (e) {
      appLog('❌ 网络连接测试失败: $e');
      return false;
    }
  }

  Duration get _reconnectDelay {
    final seconds = min(30, 2 * pow(2, _reconnectAttempt).toInt());
    return Duration(seconds: seconds);
  }

  void _reconnect() {
    if (_userClosed || _isReconnecting || isConnected.value) {
      return;
    }

    _reconnectTimer?.cancel();
    final delay = _reconnectDelay;
    appLog('🔄 ${delay.inSeconds}s 后尝试重连 (第 ${_reconnectAttempt + 1} 次)');
    _reconnectTimer = Timer(delay, () {
      if (!isConnected.value && !_isReconnecting && !_userClosed) {
        _reconnectAttempt++;
        connect();
      }
    });
  }

  Future<void> disconnect() async {
    _userClosed = true;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    await _cleanupConnection(clearQueue: true);
    isConnected.value = false;
    connectionStatus.value = '未连接';
    _isReconnecting = false;
    _reconnectAttempt = 0;
  }

  @override
  void onClose() {
    _userClosed = true;
    _reconnectTimer?.cancel();
    _responseTimer?.cancel();
    _commandQueue.clear();
    _socketSub?.cancel();
    _socket?.destroy();
    _socket = null;

    _responseController.close();
    _consoleResponseController.close();
    _smsController.close();
    _callController.close();
    _signalController.close();
    _rawDataController.close();

    super.onClose();
  }
}

class _CommandTask {
  final String command;
  final Completer<String> completer;

  _CommandTask(this.command, this.completer);
}
