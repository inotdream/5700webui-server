import 'package:get/get.dart';
import '../controllers/console_controller.dart';

class ConsoleBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ConsoleController>(() => ConsoleController());
  }
}

