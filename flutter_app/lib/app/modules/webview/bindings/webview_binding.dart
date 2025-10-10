import 'package:get/get.dart';
import '../controllers/webview_controller.dart';

class WebViewBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<WebViewController>(() => WebViewController());
  }
}

