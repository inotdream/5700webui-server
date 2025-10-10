import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:get/get.dart';
import '../data/models/at_response.dart';
import '../data/models/sms_model.dart';
import '../data/models/call_info.dart';
import '../data/models/signal_data.dart';
import 'storage_service.dart';

class TcpService extends GetxService {
  Socket? _socket;
  final _storageService = Get.find<StorageService>();
  
  // 响应流控制器
  final _responseController = StreamController<String>.broadcast();
  Stream<String> get responseStream => _responseController.stream;
  
  // 各类事件流
  final _smsController = StreamController<SmsModel>.broadcast();
  Stream<SmsModel> get smsStream => _smsController.stream;
  
  final _callController = StreamController<CallInfo>.broadcast();
  Stream<CallInfo> get callStream => _callController.stream;
  
  final _signalController = StreamController<SignalData>.broadcast();
  Stream<SignalData> get signalStream => _signalController.stream;
  
  final _rawDataController = StreamController<String>.broadcast();
  Stream<String> get rawDataStream => _rawDataController.stream;
  
  // 连接状态
  final isConnected = false.obs;
  final connectionStatus = '未连接'.obs;
  
  // 命令响应缓冲
  final _responseBuffer = StringBuffer();
  Completer<String>? _commandCompleter;
  Timer? _responseTimer;
  
  // 重连控制
  bool _isReconnecting = false;
  Timer? _reconnectTimer;

  @override
  void onInit() {
    super.onInit();
    if (_storageService.autoConnect) {
      connect();
    }
  }

  // 连接TCP
  Future<void> connect() async {
    // 防止重复连接
    if (isConnected.value || _isReconnecting) {
      print('⚠️ 已有连接或正在重连中，跳过此次连接请求');
      return;
    }
    
    try {
      // 清理旧连接
      await _cleanupConnection();
      
      _isReconnecting = true;
      
      // 从配置中获取主机和端口
      final host = _storageService.tcpHost;
      final port = _storageService.tcpPort;
      
      connectionStatus.value = '连接中...';
      
      _socket = await Socket.connect(
        host,
        port,
        timeout: const Duration(seconds: 10),
      );
      
      isConnected.value = true;
      connectionStatus.value = '已连接';
      _isReconnecting = false;
      
      print('✅ 已连接到 $host:$port');
      
      // 监听数据
      _socket!.listen(
        _handleData,
        onError: (error) {
          print('Socket错误: $error');
          isConnected.value = false;
          connectionStatus.value = '连接错误';
          _reconnect();
        },
        onDone: () {
          print('Socket连接断开');
          isConnected.value = false;
          connectionStatus.value = '连接断开';
          _reconnect();
        },
      );
      
      // 初始化AT配置
      await _initATConfig();
      
    } catch (e) {
      print('❌ TCP连接失败: $e');
      isConnected.value = false;
      connectionStatus.value = '连接失败';
      _isReconnecting = false;
      _reconnect();
    }
  }
  
  // 清理连接
  Future<void> _cleanupConnection() async {
    try {
      // 取消响应定时器
      _responseTimer?.cancel();
      _responseTimer = null;
      
      // 取消重连定时器
      _reconnectTimer?.cancel();
      _reconnectTimer = null;
      
      // 完成待处理的命令
      if (_commandCompleter != null && !_commandCompleter!.isCompleted) {
        _commandCompleter!.completeError(Exception('连接已关闭'));
        _commandCompleter = null;
      }
      
      // 清空缓冲区
      _responseBuffer.clear();
      
      // 关闭旧socket
      if (_socket != null) {
        await _socket!.close();
        _socket = null;
      }
    } catch (e) {
      print('清理连接时出错: $e');
    }
  }

  // 初始化AT配置
  Future<void> _initATConfig() async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      
      // 设置PDU模式
      await sendCommand('AT+CMGF=0');
      await Future.delayed(const Duration(milliseconds: 200));
      
      // 设置新短信通知
      await sendCommand('AT+CNMI=2,1,0,2,0');
      await Future.delayed(const Duration(milliseconds: 200));
      
      // 设置来电号码显示
      await sendCommand('AT+CLIP=1');
      await Future.delayed(const Duration(milliseconds: 200));
      
      print('✅ AT配置初始化完成');
    } catch (e) {
      print('AT配置初始化失败: $e');
    }
  }

  // 处理接收的数据
  void _handleData(List<int> data) {
    try {
      final text = utf8.decode(data, allowMalformed: true);
      print('📥 收到数据: $text');
      
      // 处理命令响应
      if (_commandCompleter != null && !_commandCompleter!.isCompleted) {
        _responseBuffer.write(text);
        
        // 检查是否收到完整响应
        final response = _responseBuffer.toString();
        if (response.contains('OK') || 
            response.contains('ERROR') || 
            response.contains('+CMS ERROR') ||
            response.contains('+CME ERROR')) {
          
          // 取消超时定时器
          _responseTimer?.cancel();
          
          // 完成响应并广播完整的响应数据
          _commandCompleter!.complete(response);
          _rawDataController.add(response); // 广播完整响应
          _commandCompleter = null;
          _responseBuffer.clear();
        }
      } else {
        // 非命令响应时，累积数据直到收到完整消息
        _responseBuffer.write(text);
        
        // 检查是否是完整的主动上报消息
        final buffered = _responseBuffer.toString();
        if (buffered.contains('\n')) {
          // 广播完整的主动上报消息
          _rawDataController.add(buffered);
          
          // 解析主动上报消息
          _parseUnsolicitedMessage(buffered);
          
          _responseBuffer.clear();
        }
      }
      
    } catch (e) {
      print('数据处理错误: $e');
    }
  }

  // 解析主动上报消息
  void _parseUnsolicitedMessage(String message) {
    final lines = message.split('\r\n');
    
    for (var line in lines) {
      line = line.trim();
      if (line.isEmpty) continue;
      
      // 新短信通知
      if (line.contains('+CMTI:')) {
        _handleNewSms(line);
      }
      // 来电通知
      else if (line.contains('RING') || line.contains('+CLIP:')) {
        _handleIncomingCall(line);
      }
      // 通话结束
      else if (line.contains('^CEND:') || line.contains('NO CARRIER')) {
        _handleCallEnded();
      }
      // 信号数据
      else if (line.contains('^HCSQ:') || line.contains('^CERSSI:')) {
        _handleSignalData(line);
      }
    }
  }

  // 处理新短信
  Future<void> _handleNewSms(String line) async {
    try {
      final match = RegExp(r'\+CMTI: "([^"]+)",(\d+)').firstMatch(line);
      if (match != null) {
        final index = match.group(2)!;
        print('收到新短信，索引: $index');
        
        // 读取短信
        final response = await sendCommand('AT+CMGR=$index');
        
        // 这里需要解析PDU格式的短信
        // 暂时简单处理
        _smsController.add(SmsModel(
          sender: '未知',
          content: '收到新短信（索引：$index）',
          time: DateTime.now().toString(),
        ));
      }
    } catch (e) {
      print('处理新短信失败: $e');
    }
  }

  // 处理来电
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
      print('处理来电失败: $e');
    }
  }

  // 处理通话结束
  void _handleCallEnded() {
    _callController.add(CallInfo(
      time: DateTime.now().toString(),
      number: '',
      state: 'ended',
    ));
  }

  // 处理信号数据
  void _handleSignalData(String line) {
    try {
      // 解析信号强度
      // 这里简化处理，实际需要解析具体格式
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
      print('处理信号数据失败: $e');
    }
  }

  // 发送AT命令
  Future<String> sendCommand(String command) async {
    if (!isConnected.value || _socket == null) {
      throw Exception('未连接到服务器');
    }
    
    try {
      // 确保命令以\r\n结尾
      if (!command.endsWith('\r\n')) {
        command += '\r\n';
      }
      
      print('📤 发送命令: ${command.trim()}');
      
      // 创建响应完成器
      _commandCompleter = Completer<String>();
      _responseBuffer.clear();
      
      // 设置超时定时器
      _responseTimer = Timer(const Duration(seconds: 10), () {
        if (_commandCompleter != null && !_commandCompleter!.isCompleted) {
          _commandCompleter!.completeError(TimeoutException('命令超时'));
          _commandCompleter = null;
          _responseBuffer.clear();
        }
      });
      
      // 发送命令
      _socket!.write(command);
      await _socket!.flush();
      
      // 等待响应
      final response = await _commandCompleter!.future;
      
      return response;
      
    } catch (e) {
      print('发送命令失败: $e');
      rethrow;
    }
  }

  // 重连
  void _reconnect() {
    // 如果已在重连中或已连接，则不重复触发
    if (_isReconnecting || isConnected.value) {
      return;
    }
    
    // 取消之前的重连定时器
    _reconnectTimer?.cancel();
    
    // 设置新的重连定时器
    _reconnectTimer = Timer(const Duration(seconds: 5), () {
      if (!isConnected.value && !_isReconnecting) {
        print('🔄 尝试重新连接...');
        connect();
      }
    });
  }

  // 断开连接
  Future<void> disconnect() async {
    await _cleanupConnection();
    isConnected.value = false;
    connectionStatus.value = '未连接';
    _isReconnecting = false;
  }

  @override
  void onClose() {
    _reconnectTimer?.cancel();
    _responseTimer?.cancel();
    
    // 同步关闭socket
    _socket?.close();
    _socket = null;
    
    _responseController.close();
    _smsController.close();
    _callController.close();
    _signalController.close();
    _rawDataController.close();
    
    super.onClose();
  }
}

