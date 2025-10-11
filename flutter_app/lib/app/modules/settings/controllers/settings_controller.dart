import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../services/storage_service.dart';
import '../../../services/tcp_service.dart';
import '../../../services/websocket_server_service.dart';

class SettingsController extends GetxController {
  final _storageService = Get.find<StorageService>();
  final _tcpService = Get.find<TcpService>();
  late final _wsServer = Get.find<WebSocketServerService>();
  
  final tcpHostController = TextEditingController();
  final tcpPortController = TextEditingController();
  final wsPortController = TextEditingController();
  final autoConnect = true.obs;
  final enableNotification = true.obs;
  final themeMode = 'system'.obs;

  @override
  void onInit() {
    super.onInit();
    _loadSettings();
  }

  void _loadSettings() {
    tcpHostController.text = _storageService.tcpHost;
    tcpPortController.text = _storageService.tcpPort.toString();
    wsPortController.text = _storageService.wsPort.toString();
    autoConnect.value = _storageService.autoConnect;
    enableNotification.value = _storageService.enableNotification;
    themeMode.value = _storageService.themeMode;
  }

  Future<void> saveTcpConfig() async {
    final host = tcpHostController.text.trim();
    final portStr = tcpPortController.text.trim();
    
    if (host.isEmpty || portStr.isEmpty) {
      Get.snackbar('错误', '主机地址和端口不能为空');
      return;
    }
    
    final port = int.tryParse(portStr);
    if (port == null || port < 1 || port > 65535) {
      Get.snackbar('错误', '端口号必须在1-65535之间');
      return;
    }
    
    _storageService.tcpHost = host;
    _storageService.tcpPort = port;
    Get.snackbar('成功', 'TCP配置已保存');
    
    // 重新连接
    await _tcpService.disconnect();
    await _tcpService.connect();
  }

  void toggleAutoConnect(bool value) {
    autoConnect.value = value;
    _storageService.autoConnect = value;
  }

  void toggleNotification(bool value) {
    enableNotification.value = value;
    _storageService.enableNotification = value;
  }

  void changeTheme(String mode) {
    themeMode.value = mode;
    _storageService.themeMode = mode;
    
    switch (mode) {
      case 'light':
        Get.changeThemeMode(ThemeMode.light);
        break;
      case 'dark':
        Get.changeThemeMode(ThemeMode.dark);
        break;
      default:
        Get.changeThemeMode(ThemeMode.system);
    }
  }

  Future<void> saveWsConfig() async {
    final portStr = wsPortController.text.trim();
    
    if (portStr.isEmpty) {
      Get.snackbar('错误', 'WebSocket端口不能为空');
      return;
    }
    
    final port = int.tryParse(portStr);
    if (port == null || port < 1024 || port > 65535) {
      Get.snackbar('错误', 'WebSocket端口号必须在1024-65535之间');
      return;
    }
    
    try {
      final success = await _wsServer.changePort(port);
      if (success) {
        Get.snackbar('成功', 'WebSocket端口已修改为: $port');
      } else {
        Get.snackbar('错误', 'WebSocket端口修改失败');
      }
    } catch (e) {
      Get.snackbar('错误', 'WebSocket端口修改失败: $e');
    }
  }

  Future<void> reconnect() async {
    await _tcpService.disconnect();
    await Future.delayed(const Duration(milliseconds: 500));
    await _tcpService.connect();
  }

  Future<void> testConnection() async {
    Get.snackbar('测试中', '正在测试网络连接...', duration: const Duration(seconds: 1));
    
    final success = await _tcpService.testConnection();
    
    if (success) {
      Get.snackbar('测试成功', '网络连接正常', 
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } else {
      Get.snackbar('测试失败', '无法连接到AT设备，请检查：\n1. 设备IP地址是否正确\n2. 端口号是否正确\n3. 设备是否开机\n4. 网络是否正常', 
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
      );
    }
  }

  @override
  void onClose() {
    tcpHostController.dispose();
    tcpPortController.dispose();
    wsPortController.dispose();
    super.onClose();
  }
}
