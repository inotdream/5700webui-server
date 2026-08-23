import 'dart:async';
import 'package:get/get.dart';
import '../../../services/tcp_service.dart';
import '../../../data/models/sms_model.dart';
import '../../../utils/pdu_codec.dart';

class SmsController extends GetxController {
  final _tcpService = Get.find<TcpService>();

  final smsList = <SmsModel>[].obs;
  final isLoading = false.obs;

  StreamSubscription<SmsModel>? _smsSubscription;

  @override
  void onInit() {
    super.onInit();

    // 监听新短信
    _smsSubscription = _tcpService.smsStream.listen((sms) {
      smsList.insert(0, sms);
    });

    // 加载短信列表
    loadSms();
  }

  Future<void> loadSms() async {
    if (!_tcpService.isConnected.value) return;
    try {
      isLoading.value = true;
      // 读取所有短信（PDU模式）并解析
      final response = await _tcpService.sendCommand(
        'AT+CMGL=4',
        timeout: const Duration(seconds: 20),
      );
      final messages = PduCodec.parseCmglResponse(response);
      // 新短信（存储索引大）在前
      messages.sort((a, b) => (b.index ?? 0).compareTo(a.index ?? 0));
      smsList.assignAll(messages);
    } catch (e) {
      print('加载短信失败: $e');
      Get.snackbar('错误', '加载短信失败: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteSms(int listIndex) async {
    if (listIndex < 0 || listIndex >= smsList.length) return;

    final sms = smsList[listIndex];
    final storageIndex = sms.index;
    if (storageIndex == null) {
      // 没有模块存储索引（如未解析出索引的推送短信），仅从界面移除
      smsList.removeAt(listIndex);
      return;
    }

    try {
      final response = await _tcpService.sendCommand('AT+CMGD=$storageIndex');
      if (response.contains('OK')) {
        smsList.removeAt(listIndex);
        Get.snackbar('成功', '短信已删除');
      } else {
        Get.snackbar('错误', '删除失败: $response');
      }
    } catch (e) {
      Get.snackbar('错误', '删除短信失败: $e');
    }
  }

  Future<void> sendSms(String number, String content) async {
    try {
      isLoading.value = true;

      // PDU模式发送：编码PDU，AT+CMGS=<TPDU字节数>，
      // 等待'>'提示符后发送PDU正文+Ctrl+Z（由TcpService两阶段处理）
      final encoded = PduCodec.encodeSubmit(number, content);
      final response = await _tcpService.sendCommandWithPayload(
        'AT+CMGS=${encoded.tpduLength}',
        encoded.pdu,
      );

      if (response.contains('OK')) {
        Get.back();
        Get.snackbar('成功', '短信已发送');
      } else {
        Get.snackbar('错误', '发送失败: $response');
      }
    } on ArgumentError catch (e) {
      Get.snackbar('错误', e.message.toString());
    } catch (e) {
      Get.snackbar('错误', '发送短信失败: $e');
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void refresh() {
    loadSms();
  }

  @override
  void onClose() {
    _smsSubscription?.cancel();
    super.onClose();
  }
}
