import 'package:get/get.dart';
import '../controllers/sms_controller.dart';

class SmsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SmsController>(() => SmsController());
  }
}

