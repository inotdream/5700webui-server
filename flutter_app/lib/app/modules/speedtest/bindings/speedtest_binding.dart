import 'package:get/get.dart';
import '../controllers/speedtest_controller.dart';

class SpeedTestBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SpeedTestController>(() => SpeedTestController());
  }
}
