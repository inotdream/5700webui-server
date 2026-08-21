import 'package:get/get.dart';

class HomeController extends GetxController {
  final currentIndex = 0.obs;
  final visitedPages = <int>{0}.obs;

  bool isPageVisited(int index) => visitedPages.contains(index);

  void changePage(int index) {
    if (!visitedPages.contains(index)) {
      visitedPages.add(index);
    }
    currentIndex.value = index;
  }
}

