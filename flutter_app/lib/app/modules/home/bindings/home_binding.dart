import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import '../../dashboard/controllers/dashboard_controller.dart';
import '../../sms/controllers/sms_controller.dart';
import '../../console/controllers/console_controller.dart';
import '../../webview/controllers/webview_controller.dart';
import '../../settings/controllers/settings_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(() => HomeController());
    Get.lazyPut<DashboardController>(() => DashboardController());
    Get.lazyPut<SmsController>(() => SmsController());
    Get.lazyPut<ConsoleController>(() => ConsoleController());
    Get.lazyPut<WebViewController>(() => WebViewController());
    Get.lazyPut<SettingsController>(() => SettingsController());
  }
}

