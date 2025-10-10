import 'dart:async';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../data/models/at_response.dart';
import '../data/models/sms_model.dart';
import '../data/models/call_info.dart';
import '../data/models/signal_data.dart';
import 'storage_service.dart';

class WebSocketService extends GetxService {
  WebSocketChannel? _channel;
  final _storageService = Get.find<StorageService>();
  
  // 响应流控制器
  final _responseController = StreamController<ATResponse>.broadcast();
  Stream<ATResponse> get responseStream => _responseController.stream;
  
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

  @override
  void onInit() {
    super.onInit();
    if (_storageService.autoConnect) {
      connect();
    }
  }

  // 连接WebSocket
  void connect() {
    try {
      final url = _storageService.serverUrl;
      _channel = WebSocketChannel.connect(Uri.parse(url));
      
      isConnected.value = true;
      connectionStatus.value = '已连接';
      
      // 监听消息
      _channel!.stream.listen(
        _handleMessage,
        onError: (error) {
          print('WebSocket错误: $error');
          isConnected.value = false;
          connectionStatus.value = '连接错误';
          _reconnect();
        },
        onDone: () {
          print('WebSocket连接断开');
          isConnected.value = false;
          connectionStatus.value = '连接断开';
          _reconnect();
        },
      );
      
      print('✅ 已连接到 $url');
    } catch (e) {
      print('❌ 连接失败: $e');
      isConnected.value = false;
      connectionStatus.value = '连接失败';
      _reconnect();
    }
  }

  // 处理收到的消息
  void _handleMessage(dynamic message) {
    try {
      final data = json.decode(message);
      
      // 判断是AT命令响应还是事件推送
      if (data.containsKey('success')) {
        // AT命令响应
        _responseController.add(ATResponse.fromJson(data));
      } else if (data.containsKey('type')) {
        // 事件推送
        final type = data['type'];
        final eventData = data['data'];
        
        switch (type) {
          case 'new_sms':
            _smsController.add(SmsModel.fromJson(eventData));
            break;
          case 'incoming_call':
            _callController.add(CallInfo.fromJson(eventData));
            break;
          case 'pdcp_data':
            _signalController.add(SignalData.fromJson(eventData));
            break;
          case 'raw_data':
            _rawDataController.add(eventData.toString());
            break;
        }
      }
    } catch (e) {
      print('消息解析错误: $e');
    }
  }

  // 发送AT命令
  Future<ATResponse> sendCommand(String command) async {
    if (!isConnected.value) {
      throw Exception('未连接到服务器');
    }
    
    final completer = Completer<ATResponse>();
    
    // 监听响应
    final subscription = responseStream.listen((response) {
      if (!completer.isCompleted) {
        completer.complete(response);
      }
    });
    
    // 发送命令
    _channel!.sink.add(command);
    
    // 设置超时
    final result = await completer.future.timeout(
      const Duration(seconds: 10),
      onTimeout: () {
        subscription.cancel();
        throw TimeoutException('命令超时');
      },
    );
    
    subscription.cancel();
    return result;
  }

  // 重连
  void _reconnect() {
    Future.delayed(const Duration(seconds: 5), () {
      if (!isConnected.value) {
        print('尝试重新连接...');
        connect();
      }
    });
  }

  // 断开连接
  void disconnect() {
    _channel?.sink.close();
    isConnected.value = false;
    connectionStatus.value = '未连接';
  }

  @override
  void onClose() {
    disconnect();
    _responseController.close();
    _smsController.close();
    _callController.close();
    _signalController.close();
    _rawDataController.close();
    super.onClose();
  }
}

