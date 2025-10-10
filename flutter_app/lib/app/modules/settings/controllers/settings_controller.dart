import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../services/storage_service.dart';
import '../../../services/tcp_service.dart';

class SettingsController extends GetxController {
  final _storageService = Get.find<StorageService>();
  final _tcpService = Get.find<TcpService>();
  
  final tcpHostController = TextEditingController();
  final tcpPortController = TextEditingController();
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

  Future<void> reconnect() async {
    await _tcpService.disconnect();
    await Future.delayed(const Duration(milliseconds: 500));
    await _tcpService.connect();
  }

  @override
  void onClose() {
    tcpHostController.dispose();
    tcpPortController.dispose();
    super.onClose();
  }
}
