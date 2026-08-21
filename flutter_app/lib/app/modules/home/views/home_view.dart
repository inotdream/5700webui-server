import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import '../../console/views/console_view.dart';
import '../../webview/views/webview_view.dart';
import '../../network/views/network_view.dart';
import '../../speedtest/views/speedtest_view.dart';
import '../../settings/views/settings_view.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  static const _pages = <Widget>[
    ConsoleView(),
    WebViewView(),
    NetworkView(),
    SpeedTestView(),
    SettingsView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        final index = controller.currentIndex.value;
        final visited = Set<int>.from(controller.visitedPages);
        return IndexedStack(
          index: index,
          children: [
            for (var i = 0; i < _pages.length; i++)
              visited.contains(i) ? _pages[i] : const SizedBox.shrink(),
          ],
        );
      }),
      bottomNavigationBar: Obx(() => NavigationBar(
        selectedIndex: controller.currentIndex.value,
        onDestinationSelected: controller.changePage,
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
