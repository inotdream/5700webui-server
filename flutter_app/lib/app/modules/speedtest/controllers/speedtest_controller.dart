import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../utils/bandwidth_test.dart';

class SpeedTestController extends GetxController {
  final modeIndex = 0.obs; // 0=客户端, 1=服务端

  // ── 客户端配置 ──
  final hostCtrl = TextEditingController(text: '');
  final portCtrl = TextEditingController(text: '5201');
  final durationCtrl = TextEditingController(text: '10');
  final isUpload = true.obs;

  // ── 服务端配置 ──
  final serverPortCtrl = TextEditingController(text: '5201');

  // ── 运行状态 ──
  final isTesting = false.obs;
  final isServerRunning = false.obs;
  final serverConnections = 0.obs;
  final currentSpeed = 0.0.obs;
  final currentBytes = 0.obs;
  final elapsedSeconds = 0.0.obs;
  final testProgress = 0.0.obs;
  final statusText = ''.obs;

  // ── 日志 & 结果 ──
  final logs = <String>[].obs;
  final results = <BandwidthResult>[].obs;

  // ── 本地 IP ──
  final localIps = <String>[].obs;

  Iperf3Server? _server;
  Iperf3Client? _client;

  @override
  void onInit() {
    super.onInit();
    _fetchLocalIps();
    _log('纯 Dart 内置 iperf3 协议引擎就绪');
  }

  @override
  void onClose() {
    hostCtrl.dispose();
    portCtrl.dispose();
    durationCtrl.dispose();
    serverPortCtrl.dispose();
    _server?.stop();
    super.onClose();
  }

  void _log(String msg) {
    final ts = DateTime.now();
    final time = '${ts.hour.toString().padLeft(2, '0')}:'
        '${ts.minute.toString().padLeft(2, '0')}:'
        '${ts.second.toString().padLeft(2, '0')}';
    logs.insert(0, '[$time] $msg');
    if (logs.length > 500) logs.removeLast();
  }

  Future<void> _fetchLocalIps() async {
    try {
      final interfaces = await NetworkInterface.list(
        type: InternetAddressType.IPv4,
        includeLoopback: false,
      );
      final ips = <String>[];
      for (final iface in interfaces) {
        for (final addr in iface.addresses) {
          ips.add('${addr.address} (${iface.name})');
        }
      }
      localIps.value = ips;
    } catch (_) {}
  }

  // ── 客户端测试 ──

  Future<void> startClientTest() async {
    final host = hostCtrl.text.trim();
    if (host.isEmpty) {
      _log('请输入服务器地址');
      return;
    }
    final port = int.tryParse(portCtrl.text.trim()) ?? 5201;
    final dur = int.tryParse(durationCtrl.text.trim()) ?? 10;

    isTesting.value = true;
    currentSpeed.value = 0;
    currentBytes.value = 0;
    elapsedSeconds.value = 0;
    testProgress.value = 0;
    statusText.value = '连接中...';

    _client = Iperf3Client()
      ..onLog = _log
      ..onStats = (mbps, bytes, secs) {
        currentSpeed.value = mbps;
        currentBytes.value = bytes;
        elapsedSeconds.value = secs;
        testProgress.value = (secs / dur).clamp(0.0, 1.0);
        statusText.value = '测试中...';
      };

    final result = await _client!.runTest(
      host: host,
      port: port,
      duration: dur,
      upload: isUpload.value,
    );

    if (result != null) {
      results.insert(0, result);
      statusText.value = '完成: ${result.formattedSpeed}';
    } else {
      statusText.value = '测试失败';
    }

    testProgress.value = 1.0;
    isTesting.value = false;
    _client = null;
  }

  void cancelTest() {
    _client?.cancel();
    _log('测试已取消');
    statusText.value = '已取消';
    isTesting.value = false;
  }

  // ── 服务端 ──

  Future<void> startServer() async {
    if (isServerRunning.value) return;
    final port = int.tryParse(serverPortCtrl.text.trim()) ?? 5201;

    _server = Iperf3Server()
      ..onLog = _log
      ..onStats = (mbps, bytes, secs) {
        currentSpeed.value = mbps;
        currentBytes.value = bytes;
        elapsedSeconds.value = secs;
      }
      ..onConnectionCount = (count) {
        serverConnections.value = count;
        if (count > 0) statusText.value = '测试进行中...';
      };

    final ok = await _server!.start(port);
    if (ok) {
      isServerRunning.value = true;
      statusText.value = '等待连接 (兼容标准 iperf3 客户端)';
    } else {
      statusText.value = '启动失败';
    }
  }

  Future<void> stopServer() async {
    await _server?.stop();
    _server = null;
    isServerRunning.value = false;
    serverConnections.value = 0;
    currentSpeed.value = 0;
    currentBytes.value = 0;
    elapsedSeconds.value = 0;
    statusText.value = '';
  }

  // ── 本机回环测试 ──

  Future<void> runLoopbackTest() async {
    if (isTesting.value) return;

    isTesting.value = true;
    currentSpeed.value = 0;
    currentBytes.value = 0;
    elapsedSeconds.value = 0;
    testProgress.value = 0;
    statusText.value = '启动回环服务器...';

    Iperf3Server? loopServer;
    const loopPort = 15201;
    const dur = 5;

    try {
      loopServer = Iperf3Server()..onLog = _log;
      final ok = await loopServer.start(loopPort);
      if (!ok) {
        statusText.value = '回环服务器启动失败';
        isTesting.value = false;
        return;
      }

      await Future.delayed(const Duration(milliseconds: 300));

      statusText.value = '回环上传测试...';
      final uploadClient = Iperf3Client()
        ..onLog = _log
        ..onStats = (mbps, bytes, secs) {
          currentSpeed.value = mbps;
          currentBytes.value = bytes;
          elapsedSeconds.value = secs;
          testProgress.value = (secs / dur).clamp(0.0, 1.0) * 0.5;
        };

      final upResult = await uploadClient.runTest(
        host: '127.0.0.1',
        port: loopPort,
        duration: dur,
        upload: true,
      );
      if (upResult != null) {
        results.insert(0, upResult);
        _log('上传: ${upResult.formattedSpeed}');
      }

      await Future.delayed(const Duration(milliseconds: 500));

      statusText.value = '回环下载测试...';
      final downloadClient = Iperf3Client()
        ..onLog = _log
        ..onStats = (mbps, bytes, secs) {
          currentSpeed.value = mbps;
          currentBytes.value = bytes;
          elapsedSeconds.value = secs;
          testProgress.value = 0.5 + (secs / dur).clamp(0.0, 1.0) * 0.5;
        };

      final dlResult = await downloadClient.runTest(
        host: '127.0.0.1',
        port: loopPort,
        duration: dur,
        upload: false,
      );
      if (dlResult != null) {
        results.insert(0, dlResult);
        _log('下载: ${dlResult.formattedSpeed}');
      }

      statusText.value = '回环测试完成';
    } catch (e) {
      _log('回环测试失败: $e');
      statusText.value = '回环测试失败';
    } finally {
      await loopServer?.stop();
      testProgress.value = 1.0;
      isTesting.value = false;
    }
  }

  void clearLogs() => logs.clear();
  void clearResults() => results.clear();
}
