import 'package:get/get.dart';
import '../../../services/tcp_service.dart';
import '../../../data/models/signal_data.dart';

class DashboardController extends GetxController {
  final _tcpService = Get.find<TcpService>();
  
  final Rx<SignalData?> signalData = Rx<SignalData?>(null);
  final connectionType = 'TCP'.obs;
  final rsrpHistory = <double>[].obs;
  final maxHistoryLength = 50;

  @override
  void onInit() {
    super.onInit();
    
    // 监听信号数据
    _tcpService.signalStream.listen((data) {
      signalData.value = data;
      
      // 添加到历史记录
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
