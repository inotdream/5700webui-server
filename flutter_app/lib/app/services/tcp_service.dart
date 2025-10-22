import 'dart:async';
import 'dart:collection';
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
  
  // AT控制台响应流（用于Flutter内部AT控制台显示）
  final _consoleResponseController = StreamController<String>.broadcast();
  Stream<String> get consoleResponseStream => _consoleResponseController.stream;
  
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
  
  // 命令队列和延迟控制
  final _commandQueue = Queue<_CommandTask>();
  bool _isProcessingQueue = false;
  static const _commandDelay = Duration(milliseconds: 100); // 每条命令之间间隔100ms

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
      
      print('🔗 尝试连接到 $host:$port');
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
      final host = _storageService.tcpHost;
      final port = _storageService.tcpPort;
      
      print('❌ TCP连接失败: $e');
      print('🔍 连接详情:');
      print('   - 主机: $host');
      print('   - 端口: $port');
      print('   - 超时: 10秒');
      print('   - 错误类型: ${e.runtimeType}');
      
      isConnected.value = false;
      connectionStatus.value = '连接失败: $e';
      _isReconnecting = false;
      
      // 如果启用了自动重连，则启动重连
      if (_storageService.autoConnect) {
        print('🔄 自动重连已启用，将在5秒后重试...');
        _reconnect();
      }
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
      
      // 清空命令队列
      while (_commandQueue.isNotEmpty) {
        final task = _commandQueue.removeFirst();
        if (!task.completer.isCompleted) {
          task.completer.completeError(Exception('连接已关闭'));
        }
      }
      
      // 清空缓冲区
      _responseBuffer.clear();
      
      // 重置队列处理标志
      _isProcessingQueue = false;
      
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
          
          // 完成响应
          _commandCompleter!.complete(response);
          _commandCompleter = null;
          
          // 广播到AT控制台响应流（用于Flutter内部AT控制台显示）
          _consoleResponseController.add(response);
          
          _responseBuffer.clear();
        }
      } else {
        // 非命令响应时，处理主动上报数据
        _responseBuffer.write(text);
        
        // 检查是否是完整的主动上报消息
        final buffered = _responseBuffer.toString();
        print('🔍 检查主动上报数据: $buffered');
        
        // 更宽松的检测条件 - 检测常见的主动上报消息
        if (buffered.contains('\r\n') || 
            buffered.contains('\n') || 
            buffered.contains('+CMTI:') ||
            buffered.contains('RING') ||
            buffered.contains('+CLIP:') ||
            buffered.contains('^CEND:') ||
            buffered.contains('^HCSQ:') ||
            buffered.contains('^CERSSI:') ||
            buffered.contains('+') ||  // 任何以+开头的消息
            buffered.contains('^')) {  // 任何以^开头的消息
          
          print('📡 检测到主动上报消息，广播到rawDataStream: $buffered');
          
          // 广播完整的主动上报消息
          _rawDataController.add(buffered);
          
          // 解析主动上报消息
          _parseUnsolicitedMessage(buffered);
          
          _responseBuffer.clear();
        }
        
        // 如果缓冲区太大，强制处理（防止内存泄漏）
        if (_responseBuffer.length > 1000) {
          print('⚠️ 缓冲区过大，强制处理数据');
          _rawDataController.add(buffered);
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
    print('🔍 解析主动上报消息: $message');
    
    // 尝试多种分割方式
    List<String> lines = [];
    if (message.contains('\r\n')) {
      lines = message.split('\r\n');
    } else if (message.contains('\n')) {
      lines = message.split('\n');
    } else {
      lines = [message];
    }
    
    for (var line in lines) {
      line = line.trim();
      if (line.isEmpty) continue;
      
      print('📝 处理行: $line');
      
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
      // 其他以+或^开头的主动上报消息
      else if (line.startsWith('+') || line.startsWith('^')) {
        print('📡 其他主动上报消息: $line');
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

  // 发送AT命令（公开接口，加入队列）
  Future<String> sendCommand(String command) async {
    if (!isConnected.value || _socket == null) {
      throw Exception('未连接到服务器');
    }
    
    // 创建命令任务
    final completer = Completer<String>();
    final task = _CommandTask(command, completer);
    
    // 加入队列
    _commandQueue.add(task);
    
    // 启动队列处理
    _processCommandQueue();
    
    // 等待命令完成
    return completer.future;
  }
  
  // 处理命令队列
  Future<void> _processCommandQueue() async {
    // 如果已经在处理队列，直接返回
    if (_isProcessingQueue) {
      return;
    }
    
    _isProcessingQueue = true;
    
    try {
      while (_commandQueue.isNotEmpty) {
        final task = _commandQueue.removeFirst();
        
        try {
          // 执行命令并等待响应
          final response = await _executeCommand(task.command);
          task.completer.complete(response);
          
          // 命令间隔延迟
          if (_commandQueue.isNotEmpty) {
            print('⏱️ 命令间隔控制：等待 ${_commandDelay.inMilliseconds}ms');
            await Future.delayed(_commandDelay);
          }
        } catch (e) {
          task.completer.completeError(e);
          // 出错也要延迟，避免快速重试
          if (_commandQueue.isNotEmpty) {
            await Future.delayed(_commandDelay);
          }
        }
      }
    } finally {
      _isProcessingQueue = false;
    }
  }
  
  // 执行单个命令
  Future<String> _executeCommand(String command) async {
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
  }

  // 测试网络连接
  Future<bool> testConnection() async {
    final host = _storageService.tcpHost;
    final port = _storageService.tcpPort;
    
    print('🧪 测试网络连接: $host:$port');
    
    try {
      final socket = await Socket.connect(
        host,
        port,
        timeout: const Duration(seconds: 5),
      );
      
      await socket.close();
      print('✅ 网络连接测试成功');
      return true;
    } catch (e) {
      print('❌ 网络连接测试失败: $e');
      return false;
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
    
    // 清空命令队列
    _commandQueue.clear();
    
    // 同步关闭socket
    _socket?.close();
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

// 命令任务类
class _CommandTask {
  final String command;
  final Completer<String> completer;
  
  _CommandTask(this.command, this.completer);
}
