import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import '../../console/views/console_view.dart';
import '../../webview/views/webview_view.dart';
import '../../dashboard/views/dashboard_view.dart';
import '../../sms/views/sms_view.dart';
import '../../network/views/network_view.dart';
import '../../speedtest/views/speedtest_view.dart';
import '../../settings/views/settings_view.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final pages = [
      const ConsoleView(),
      const WebViewView(),
      const DashboardView(),
      const SmsView(),
      const NetworkView(),
      const SpeedTestView(),
      const SettingsView(),
    ];

    return Scaffold(
      // IndexedStack保留页面状态（WebView切换页签不重建）；
      // 未访问过的页签用占位符，避免启动时构建全部页面
      body: Obx(() => IndexedStack(
        index: controller.currentIndex.value,
        children: [
          for (var i = 0; i < pages.length; i++)
            controller.visitedPages.contains(i)
                ? pages[i]
                : const SizedBox.shrink(),
        ],
      )),
      bottomNavigationBar: Obx(() => NavigationBar(
        selectedIndex: controller.currentIndex.value,
        onDestinationSelected: controller.changePage,
        // 7个页签空间有限，仅显示选中项的文字标签
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.terminal_outlined),
            selectedIcon: Icon(Icons.terminal_rounded),
            label: 'AT控制台',
          ),
          NavigationDestination(
            icon: Icon(Icons.web_outlined),
            selectedIcon: Icon(Icons.web_rounded),
            label: 'Web界面',
          ),
          NavigationDestination(
            icon: Icon(Icons.monitor_heart_outlined),
            selectedIcon: Icon(Icons.monitor_heart_rounded),
            label: '监控',
          ),
          NavigationDestination(
            icon: Icon(Icons.sms_outlined),
            selectedIcon: Icon(Icons.sms_rounded),
            label: '短信',
          ),
          NavigationDestination(
            icon: Icon(Icons.travel_explore_outlined),
            selectedIcon: Icon(Icons.travel_explore_rounded),
            label: '网络检测',
          ),
          NavigationDestination(
            icon: Icon(Icons.swap_vert_rounded),
            selectedIcon: Icon(Icons.swap_vert_rounded),
            label: '带宽测试',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings_rounded),
            label: '设置',
          ),
        ],
      )),
    );
  }
}
