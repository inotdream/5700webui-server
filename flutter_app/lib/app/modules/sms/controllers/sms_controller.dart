import 'package:get/get.dart';
import '../../../services/tcp_service.dart';
import '../../../data/models/sms_model.dart';

class SmsController extends GetxController {
  final _tcpService = Get.find<TcpService>();
  
  final smsList = <SmsModel>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    
    // 监听新短信
    _tcpService.smsStream.listen((sms) {
      smsList.insert(0, sms);
    });
    
    // 加载短信列表
    loadSms();
  }

  Future<void> loadSms() async {
    try {
      isLoading.value = true;
      // 读取所有短信
      await _tcpService.sendCommand('AT+CMGL=4');
    } catch (e) {
      print('加载短信失败: $e');
      Get.snackbar('错误', '加载短信失败: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteSms(int index) async {
    try {
      final response = await _tcpService.sendCommand('AT+CMGD=$index');
      if (response.contains('OK')) {
        Get.snackbar('成功', '短信已删除');
        smsList.removeAt(index);
      } else {
        Get.snackbar('错误', '删除失败');
      }
    } catch (e) {
      Get.snackbar('错误', '删除短信失败: $e');
    }
  }

  Future<void> sendSms(String number, String content) async {
    try {
      isLoading.value = true;
      // 切换到文本模式
      await _tcpService.sendCommand('AT+CMGF=1');
      await Future.delayed(const Duration(milliseconds: 200));
      
      // 发送短信
      await _tcpService.sendCommand('AT+CMGS="$number"');
      await Future.delayed(const Duration(milliseconds: 500));
      await _tcpService.sendCommand('$content\x1A');
      
      // 切换回PDU模式
      await Future.delayed(const Duration(milliseconds: 500));
      await _tcpService.sendCommand('AT+CMGF=0');
      
      Get.back();
      Get.snackbar('成功', '短信已发送');
    } catch (e) {
      Get.snackbar('错误', '发送短信失败: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void refresh() {
    loadSms();
  }
}
