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

  static const _maxLogs = 300;
  static const _maxHistory = 50;

  StreamSubscription<String>? _consoleSub;
  StreamSubscription<String>? _rawSub;

  @override
  void onInit() {
    super.onInit();

    _consoleSub = _tcpService.consoleResponseStream.listen((response) {
      addLog('📥 $response', false);
    });

    _rawSub = _tcpService.rawDataStream.listen((data) {
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
    
    commandHistory.insert(0, command);
    if (commandHistory.length > _maxHistory) {
      commandHistory.removeRange(_maxHistory, commandHistory.length);
    }
    historyIndex.value = -1;
    
    addLog('📤 $command', true);
    commandController.clear();
    
    try {
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
    if (logs.length > _maxLogs) {
      logs.removeRange(0, logs.length - _maxLogs);
    }

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
    _consoleSub?.cancel();
    _rawSub?.cancel();
    commandController.dispose();
    scrollController.dispose();
    super.onClose();
  }
}
