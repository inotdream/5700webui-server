import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'package:get/get.dart';
import '../data/models/sms_model.dart';
import '../data/models/call_info.dart';
import '../data/models/signal_data.dart';
import '../utils/pdu_codec.dart';
import 'storage_service.dart';

class TcpService extends GetxService {
  Socket? _socket;
  final _storageService = Get.find<StorageService>();

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

  // 接收缓冲（可能包含不完整的行）与当前命令状态
  final _rxBuffer = StringBuffer();
  final _responseLines = <String>[];
  Completer<String>? _commandCompleter;
  Completer<void>? _promptCompleter;
  String? _currentResponsePrefix;
  Timer? _responseTimer;

  // 连接/重连控制
  bool _isConnecting = false;
  bool _manualDisconnect = false;
  Timer? _reconnectTimer;

  // 命令队列和延迟控制
  final _commandQueue = Queue<_CommandTask>();
  bool _isProcessingQueue = false;
  static const _commandDelay = Duration(milliseconds: 100); // 每条命令之间间隔100ms

  // 已知主动上报（URC）前缀。命令执行期间收到这些行时不计入命令响应，
  // 避免URC污染响应或被丢弃。
  static const _urcPrefixes = [
    '+CMTI:',
    '+CLIP:',
    '+CRING:',
    'RING',
    'NO CARRIER',
    '^CEND:',
    '^ORIG:',
    '^CONN:',
    '^HCSQ:',
    '^CERSSI:',
    '^MODE:',
    '^SRVST:',
    '^SIMST:',
  ];

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
    if (isConnected.value || _isConnecting) {
      print('⚠️ 已有连接或正在连接中，跳过此次连接请求');
      return;
    }

    _isConnecting = true;
    _manualDisconnect = false;

    try {
      // 清理旧连接
      await _cleanupConnection();

      final host = _storageService.tcpHost;
      final port = _storageService.tcpPort;

      print('🔗 尝试连接到 $host:$port');
      connectionStatus.value = '连接中...';

      final socket = await Socket.connect(
        host,
        port,
        timeout: const Duration(seconds: 10),
      );

      _socket = socket;
      isConnected.value = true;
      connectionStatus.value = '已连接';

      print('✅ 已连接到 $host:$port');

      // 监听数据。回调中校验socket身份，避免旧socket被关闭时
      // 触发onDone误判为断线并与新连接的建立产生竞争。
      socket.listen(
        (data) {
          if (identical(socket, _socket)) _handleData(data);
        },
        onError: (error) {
          print('Socket错误: $error');
          _onSocketClosed(socket, '连接错误');
        },
        onDone: () {
          print('Socket连接断开');
          _onSocketClosed(socket, '连接断开');
        },
      );

      _isConnecting = false;

      // 初始化AT配置
      await _initATConfig();
    } catch (e) {
      print('❌ TCP连接失败: $e');

      isConnected.value = false;
      connectionStatus.value = '连接失败: $e';
      _isConnecting = false;

      // 如果启用了自动重连，则启动重连
      if (_storageService.autoConnect && !_manualDisconnect) {
        print('🔄 自动重连已启用，将在5秒后重试...');
        _scheduleReconnect();
      }
    }
  }

  // 当前socket意外关闭（仅处理当前socket的事件，忽略已被替换的旧socket）
  void _onSocketClosed(Socket socket, String status) {
    if (!identical(socket, _socket)) return;
    _socket = null;
    isConnected.value = false;
    connectionStatus.value = status;
    _failPendingCommands('连接已断开');
    if (!_manualDisconnect) {
      _scheduleReconnect();
    }
  }

  // 使所有待处理命令失败
  void _failPendingCommands(String reason) {
    _responseTimer?.cancel();
    _responseTimer = null;

    if (_commandCompleter != null && !_commandCompleter!.isCompleted) {
      _commandCompleter!.completeError(Exception(reason));
    }
    _commandCompleter = null;
    _promptCompleter = null;
    _currentResponsePrefix = null;
    _responseLines.clear();
    _rxBuffer.clear();

    while (_commandQueue.isNotEmpty) {
      final task = _commandQueue.removeFirst();
      if (!task.completer.isCompleted) {
        task.completer.completeError(Exception(reason));
      }
    }
    // 注意：不在此处重置_isProcessingQueue，
    // 正在运行的队列循环会在排空后自行复位，避免出现两个并发队列循环
  }

  // 清理连接
  Future<void> _cleanupConnection() async {
    try {
      _reconnectTimer?.cancel();
      _reconnectTimer = null;

      _failPendingCommands('连接已关闭');

      // 先解除引用再销毁，使旧socket的onDone/onError回调被忽略
      final oldSocket = _socket;
      _socket = null;
      oldSocket?.destroy();
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

      // 设置新短信通知
      await sendCommand('AT+CNMI=2,1,0,2,0');

      // 设置来电号码显示
      await sendCommand('AT+CLIP=1');

      print('✅ AT配置初始化完成');
    } catch (e) {
      print('AT配置初始化失败: $e');
    }
  }

  // 处理接收的数据：按行切分，区分命令响应、'>'提示符和主动上报（URC）
  void _handleData(List<int> data) {
    try {
      final text = utf8.decode(data, allowMalformed: true);
      print('📥 收到数据: $text');

      _rxBuffer.write(text);
      var buffered = _rxBuffer.toString();

      // 逐行处理完整的行
      while (true) {
        final newlineIndex = buffered.indexOf('\n');
        if (newlineIndex < 0) break;
        final line = buffered.substring(0, newlineIndex).replaceAll('\r', '').trim();
        buffered = buffered.substring(newlineIndex + 1);
        if (line.isNotEmpty) {
          _handleLine(line);
        }
      }

      // '>' 提示符（CMGS等待输入正文）不带行结束符，需单独检测
      if (_promptCompleter != null &&
          !_promptCompleter!.isCompleted &&
          buffered.trimLeft().startsWith('>')) {
        buffered = '';
        _promptCompleter!.complete();
      }

      _rxBuffer.clear();
      _rxBuffer.write(buffered);
    } catch (e) {
      print('数据处理错误: $e');
    }
  }

  // 判断某行是否为主动上报（URC）。
  // 当前命令的预期响应前缀不视为URC（如 AT^HCSQ? 的 ^HCSQ: 响应行）。
  bool _isUrcLine(String line) {
    if (_commandCompleter != null &&
        _currentResponsePrefix != null &&
        _currentResponsePrefix!.isNotEmpty &&
        line.startsWith(_currentResponsePrefix!)) {
      return false;
    }
    return _urcPrefixes.any(line.startsWith);
  }

  // 判断是否为命令的最终结果码
  bool _isFinalResultLine(String line) {
    return line == 'OK' ||
        line == 'ERROR' ||
        line.startsWith('+CME ERROR') ||
        line.startsWith('+CMS ERROR') ||
        line == 'COMMAND NOT SUPPORT';
  }

  void _handleLine(String line) {
    // 信号数据不论是URC还是查询响应都进行解析
    if (line.startsWith('^HCSQ:') || line.startsWith('^CERSSI:')) {
      _handleSignalData(line);
    }

    if (_isUrcLine(line)) {
      print('📡 检测到主动上报消息: $line');
      _rawDataController.add(line);
      _parseUnsolicitedLine(line);
      return;
    }

    if (_commandCompleter != null && !_commandCompleter!.isCompleted) {
      _responseLines.add(line);
      if (_isFinalResultLine(line)) {
        _responseTimer?.cancel();
        _responseTimer = null;
        final response = _responseLines.join('\r\n');
        _responseLines.clear();
        final completer = _commandCompleter!;
        _commandCompleter = null;

        // 广播到AT控制台响应流
        _consoleResponseController.add(response);
        completer.complete(response);
      }
      return;
    }

    // 无命令进行中且不是已知URC：仍作为原始上报数据广播
    _rawDataController.add(line);
    _parseUnsolicitedLine(line);
  }

  // 解析主动上报消息（单行）
  void _parseUnsolicitedLine(String line) {
    // 新短信通知
    if (line.startsWith('+CMTI:')) {
      _handleNewSms(line);
    }
    // 来电通知
    else if (line.startsWith('RING') || line.startsWith('+CLIP:')) {
      _handleIncomingCall(line);
    }
    // 通话结束
    else if (line.startsWith('^CEND:') || line == 'NO CARRIER') {
      _handleCallEnded();
    }
  }

  // 处理新短信：读取并解析PDU
  Future<void> _handleNewSms(String line) async {
    try {
      final match = RegExp(r'\+CMTI: "([^"]+)",(\d+)').firstMatch(line);
      if (match == null) return;

      final index = int.parse(match.group(2)!);
      print('收到新短信，索引: $index');

      final response = await sendCommand('AT+CMGR=$index');
      final sms = PduCodec.parseCmgrResponse(response, index: index);
      if (sms != null) {
        _smsController.add(sms);
      } else {
        print('⚠️ 短信PDU解析失败，索引: $index');
      }
    } catch (e) {
      print('处理新短信失败: $e');
    }
  }

  // 处理来电
  void _handleIncomingCall(String line) {
    try {
      if (line.startsWith('+CLIP:')) {
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
  // 华为格式: ^HCSQ:"LTE",<rssi>,<rsrp>,<sinr>,<rsrq>（原始编码值，255表示未知）
  // 换算: RSRP = -141 + n (dBm), SINR = -20.2 + 0.2n (dB), RSRQ = -20 + 0.5n (dB)
  void _handleSignalData(String line) {
    try {
      if (!line.startsWith('^HCSQ:')) return;

      final body = line.substring(line.indexOf(':') + 1).trim();
      final parts = body.split(',');
      if (parts.length < 3) return;

      final mode = parts[0].replaceAll('"', '').trim().toUpperCase();

      int? rawValue(int i) {
        if (i >= parts.length) return null;
        final v = int.tryParse(parts[i].trim());
        return (v == null || v == 255) ? null : v;
      }

      if (mode == 'LTE' || mode == 'NR') {
        final rsrpRaw = rawValue(2);
        final sinrRaw = rawValue(3);
        final rsrqRaw = rawValue(4);

        _signalController.add(SignalData(
          rsrp: rsrpRaw != null ? -141 + rsrpRaw : null,
          sinr: sinrRaw != null ? -20.2 + 0.2 * sinrRaw : null,
          rsrq: rsrqRaw != null ? -20.0 + 0.5 * rsrqRaw : null,
        ));
      }
    } catch (e) {
      print('处理信号数据失败: $e');
    }
  }

  // 发送AT命令（公开接口，加入队列）
  Future<String> sendCommand(
    String command, {
    Duration timeout = const Duration(seconds: 10),
  }) {
    return _enqueueTask(_CommandTask(command, timeout: timeout));
  }

  // 发送两阶段命令（如AT+CMGS）：等待'>'提示符后发送正文+Ctrl+Z，再等待最终结果
  Future<String> sendCommandWithPayload(
    String command,
    String payload, {
    Duration timeout = const Duration(seconds: 30),
  }) {
    return _enqueueTask(_CommandTask(command, payload: payload, timeout: timeout));
  }

  Future<String> _enqueueTask(_CommandTask task) {
    if (!isConnected.value || _socket == null) {
      return Future.error(Exception('未连接到服务器'));
    }

    _commandQueue.add(task);
    _processCommandQueue();
    return task.completer.future;
  }

  // 处理命令队列
  Future<void> _processCommandQueue() async {
    if (_isProcessingQueue) {
      return;
    }

    _isProcessingQueue = true;

    try {
      while (_commandQueue.isNotEmpty) {
        final task = _commandQueue.removeFirst();
        if (task.completer.isCompleted) continue;

        try {
          final response = await _executeCommand(task);
          if (!task.completer.isCompleted) {
            task.completer.complete(response);
          }
        } catch (e) {
          if (!task.completer.isCompleted) {
            task.completer.completeError(e);
          }
        }

        // 命令间隔延迟，避免设备处理不过来
        if (_commandQueue.isNotEmpty) {
          await Future.delayed(_commandDelay);
        }
      }
    } finally {
      _isProcessingQueue = false;
    }
  }

  // 从命令推导预期响应前缀，如 AT+CMGL=4 -> +CMGL:，AT^HCSQ? -> ^HCSQ:
  static String? _expectedResponsePrefix(String command) {
    final match =
        RegExp(r'^AT([+^][A-Za-z]+)', caseSensitive: false).firstMatch(command.trim());
    if (match == null) return null;
    return '${match.group(1)!.toUpperCase()}:';
  }

  // 执行单个命令
  Future<String> _executeCommand(_CommandTask task) async {
    final socket = _socket;
    if (socket == null || !isConnected.value) {
      throw Exception('未连接到服务器');
    }

    var commandLine = task.command;
    if (!commandLine.endsWith('\r\n')) {
      commandLine += '\r\n';
    }

    print('📤 发送命令: ${task.command.trim()}');

    _responseLines.clear();
    _commandCompleter = Completer<String>();
    _currentResponsePrefix = _expectedResponsePrefix(task.command);
    if (task.payload != null) {
      _promptCompleter = Completer<void>();
    }

    // 设置超时定时器
    _responseTimer = Timer(task.timeout, () {
      if (_commandCompleter != null && !_commandCompleter!.isCompleted) {
        _commandCompleter!.completeError(TimeoutException('命令超时: ${task.command}'));
      }
    });

    try {
      socket.write(commandLine);
      await socket.flush();

      if (task.payload != null) {
        // 等待'>'提示符；若设备直接返回错误则命令future先完成
        await Future.any([
          _promptCompleter!.future,
          _commandCompleter!.future,
        ]);

        if (!_commandCompleter!.isCompleted) {
          // \x1A (Ctrl+Z) 表示正文结束
          socket.write('${task.payload}\x1A');
          await socket.flush();
        }
      }

      return await _commandCompleter!.future;
    } finally {
      _responseTimer?.cancel();
      _responseTimer = null;
      _commandCompleter = null;
      _promptCompleter = null;
      _currentResponsePrefix = null;
      _responseLines.clear();
    }
  }

  // 测试网络连接：优先复用现有连接发送AT探测，
  // 避免向AT端口建立第二条TCP连接导致现有会话被设备踢掉
  Future<bool> testConnection() async {
    if (isConnected.value && _socket != null) {
      try {
        final response = await sendCommand('AT', timeout: const Duration(seconds: 5));
        final ok = response.contains('OK');
        print(ok ? '✅ 网络连接测试成功' : '❌ 网络连接测试失败: $response');
        return ok;
      } catch (e) {
        print('❌ 网络连接测试失败: $e');
        return false;
      }
    }

    // 未连接时才允许临时建立探测连接
    final host = _storageService.tcpHost;
    final port = _storageService.tcpPort;
    print('🧪 测试网络连接: $host:$port');
    try {
      final socket = await Socket.connect(
        host,
        port,
        timeout: const Duration(seconds: 5),
      );
      socket.destroy();
      print('✅ 网络连接测试成功');
      return true;
    } catch (e) {
      print('❌ 网络连接测试失败: $e');
      return false;
    }
  }

  // 安排重连
  void _scheduleReconnect() {
    if (isConnected.value || _isConnecting) {
      return;
    }

    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 5), () {
      if (!isConnected.value && !_isConnecting && !_manualDisconnect) {
        print('🔄 尝试重新连接...');
        connect();
      }
    });
  }

  // 断开连接（手动断开，不触发自动重连）
  Future<void> disconnect() async {
    _manualDisconnect = true;
    await _cleanupConnection();
    isConnected.value = false;
    connectionStatus.value = '未连接';
  }

  @override
  void onClose() {
    _manualDisconnect = true;
    _reconnectTimer?.cancel();
    _responseTimer?.cancel();

    _commandQueue.clear();

    _socket?.destroy();
    _socket = null;

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
  final String? payload;
  final Duration timeout;
  final Completer<String> completer = Completer<String>();

  _CommandTask(this.command, {this.payload, this.timeout = const Duration(seconds: 10)});
}
