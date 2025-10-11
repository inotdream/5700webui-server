import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../services/tcp_service.dart';

class ConsoleController extends GetxController {
  final _tcpService = Get.find<TcpService>();
  final commandController = TextEditingController();
  final scrollController = ScrollController();
  
  final logs = <Map<String, dynamic>>[].obs;
  final commandHistory = <String>[].obs;
  final historyIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    
    // 监听AT命令响应（用于AT控制台显示）
    _tcpService.consoleResponseStream.listen((response) {
      print('🎯 AT控制台收到命令响应: $response');
      addLog('📥 $response', false);
    });
    
    // 监听主动上报数据
    _tcpService.rawDataStream.listen((data) {
      print('🎯 AT控制台收到主动上报: $data');
      addLog('📡 $data', false);
    });
    
    _addWelcomeMessage();
  }

  void _addWelcomeMessage() {
    addLog('========================================', false);
    addLog('AT命令控制台 v1.0 (TCP直连模式)', false);
    addLog('直接连接到 AT设备端口', false);
    addLog('输入AT命令并按回车发送', false);
    addLog('========================================', false);
  }

  Future<void> sendCommand() async {
    final command = commandController.text.trim();
    if (command.isEmpty) return;
    
    // 添加到历史记录
    commandHistory.insert(0, command);
    historyIndex.value = -1;
    
    addLog('📤 $command', true);
    commandController.clear();
    
    try {
      final response = await _tcpService.sendCommand(command);
      // 响应会通过rawDataStream自动显示
    } catch (e) {
      addLog('❌ 错误: $e', false);
    }
  }

  void addLog(String message, bool isSent) {
    logs.add({
      'message': message,
      'isSent': isSent,
      'time': DateTime.now(),
    });
    
    // 自动滚动到底部
    Future.delayed(const Duration(milliseconds: 100), () {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void clearLogs() {
    logs.clear();
    _addWelcomeMessage();
  }

  void previousCommand() {
    if (commandHistory.isEmpty) return;
    if (historyIndex.value < commandHistory.length - 1) {
      historyIndex.value++;
      commandController.text = commandHistory[historyIndex.value];
    }
  }

  void nextCommand() {
    if (historyIndex.value > 0) {
      historyIndex.value--;
      commandController.text = commandHistory[historyIndex.value];
    } else if (historyIndex.value == 0) {
      historyIndex.value = -1;
      commandController.clear();
    }
  }

  @override
  void onClose() {
    commandController.dispose();
    scrollController.dispose();
    super.onClose();
  }
}
