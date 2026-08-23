import 'dart:async';
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

  StreamSubscription<String>? _responseSubscription;
  StreamSubscription<String>? _rawDataSubscription;

  @override
  void onInit() {
    super.onInit();
    
    // 监听AT命令响应（用于AT控制台显示）
    _responseSubscription = _tcpService.consoleResponseStream.listen((response) {
      addLog('📥 $response', false);
    });
    
    // 监听主动上报数据
    _rawDataSubscription = _tcpService.rawDataStream.listen((data) {
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
      // 响应会通过consoleResponseStream自动显示
      await _tcpService.sendCommand(command);
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
    _responseSubscription?.cancel();
    _rawDataSubscription?.cancel();
    commandController.dispose();
    scrollController.dispose();
    super.onClose();
  }
}
