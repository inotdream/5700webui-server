import 'dart:async';
import 'package:get/get.dart';
import '../../../services/tcp_service.dart';
import '../../../data/models/signal_data.dart';

class DashboardController extends GetxController {
  final _tcpService = Get.find<TcpService>();

  final Rx<SignalData?> signalData = Rx<SignalData?>(null);
  final connectionType = 'TCP'.obs;
  final rsrpHistory = <double>[].obs;
  final maxHistoryLength = 50;

  StreamSubscription<SignalData>? _signalSubscription;

  @override
  void onInit() {
    super.onInit();

    // 监听信号数据（来自^HCSQ主动上报或查询响应）
    _signalSubscription = _tcpService.signalStream.listen((data) {
      signalData.value = data;

      if (data.rsrp != null) {
        rsrpHistory.add(data.rsrp!.toDouble());
        if (rsrpHistory.length > maxHistoryLength) {
          rsrpHistory.removeAt(0);
        }
      }
    });

    // 查询信号强度
    _querySignalStrength();
  }

  Future<void> _querySignalStrength() async {
    if (!_tcpService.isConnected.value) return;
    try {
      // 华为模块信号查询，响应^HCSQ行由TcpService解析后进入signalStream
      await _tcpService.sendCommand('AT^HCSQ?');
    } catch (e) {
      print('查询信号强度失败: $e');
    }
  }

  void refresh() {
    _querySignalStrength();
  }

  @override
  void onClose() {
    _signalSubscription?.cancel();
    super.onClose();
  }
}
