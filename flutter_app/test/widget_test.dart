import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webui_5700/main.dart';
import 'package:webui_5700/app/services/storage_service.dart';
import 'package:webui_5700/app/services/tcp_service.dart';
import 'package:webui_5700/app/services/websocket_server_service.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // 注册最小化服务（关闭自动连接，避免测试中发起真实TCP连接）
    SharedPreferences.setMockInitialValues({'auto_connect': false});
    await Get.putAsync(() => StorageService().init());
    Get.put(TcpService());
    Get.put(WebSocketServerService());

    await tester.pumpWidget(const MyApp());
    // 等待路由过渡动画与控制台日志的延迟滚动任务完成
    await tester.pumpAndSettle();

    expect(find.byType(GetMaterialApp), findsOneWidget);

    Get.reset();
  });
}
