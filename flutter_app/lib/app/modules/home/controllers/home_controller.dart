import 'package:get/get.dart';

class HomeController extends GetxController {
  final currentIndex = 0.obs;

  // 已访问过的页签索引。IndexedStack保留所有页面状态（如WebView），
  // 未访问过的页签用占位符延迟构建，避免启动时初始化全部模块。
  final visitedPages = <int>{0}.obs;

  void changePage(int index) {
    visitedPages.add(index);
    currentIndex.value = index;
  }
}
