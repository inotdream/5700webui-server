import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'app/routes/app_pages.dart';
import 'app/core/theme/app_theme.dart';
import 'app/services/storage_service.dart';
import 'app/services/tcp_service.dart';
import 'app/services/websocket_server_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 设置状态栏样式
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  
  // 初始化服务
  await Get.putAsync(() => StorageService().init());
  Get.put(TcpService());  // TCP服务连接到AT设备
  Get.put(WebSocketServerService());  // WebSocket服务器为Web前端提供服务
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, child) {
        return GetMaterialApp(
          title: '5700Webui',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.system,
          initialRoute: AppPages.INITIAL,
          getPages: AppPages.routes,
          defaultTransition: Transition.fadeIn,
        );
      },
    );
  }
}
