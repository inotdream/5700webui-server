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

  StreamSubscription<SignalData>? _signalSub;

  @override
  void onInit() {
    super.onInit();

    _signalSub = _tcpService.signalStream.listen((data) {
      signalData.value = data;

      if (data.rsrp != null) {
        rsrpHistory.add(data.rsrp!.toDouble());
        if (rsrpHistory.length > maxHistoryLength) {
          rsrpHistory.removeRange(0, rsrpHistory.length - maxHistoryLength);
        }
      }
    });

    _querySignalStrength();
  }

  @override
  void onClose() {
    _signalSub?.cancel();
    super.onClose();
  }

  Future<void> _querySignalStrength() async {
    try {
      await _tcpService.sendCommand('AT+CSQ');
    } catch (e) {
      print('查询信号强度失败: $e');
    }
  }

  void refresh() {
    _querySignalStrength();
  }
}
