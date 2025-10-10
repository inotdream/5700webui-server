import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart' as wv;
import '../controllers/webview_controller.dart';
import '../../../core/theme/app_theme.dart';

class WebViewView extends GetView<WebViewController> {
  const WebViewView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Web 管理界面'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          Obx(() => controller.isServerReady.value
              ? PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  onSelected: (value) async {
                    switch (value) {
                      case 'refresh':
                        await controller.reload();
                        break;
                      case 'clear_cache':
                        await controller.clearCache();
                        break;
                      case 'clear_all':
                        await controller.clearAllData();
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'refresh',
                      child: Row(
                        children: [
                          Icon(Icons.refresh),
                          SizedBox(width: 8),
                          Text('刷新页面'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'clear_cache',
                      child: Row(
                        children: [
                          Icon(Icons.cached),
                          SizedBox(width: 8),
                          Text('清理缓存'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'clear_all',
                      child: Row(
                        children: [
                          Icon(Icons.delete_sweep),
                          SizedBox(width: 8),
                          Text('清理所有数据'),
                        ],
                      ),
                    ),
                  ],
                )
              : const SizedBox()),
        ],
      ),
      body: Obx(() {
        // 显示错误信息
        if (controller.errorMessage.value.isNotEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '加载失败',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    controller.errorMessage.value,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      controller.errorMessage.value = '';
                      controller.onInit();
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('重试'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        
        // 显示加载中
        if (!controller.isServerReady.value) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                const Text('正在启动 Web 服务器...'),
              ],
            ),
          );
        }
        
        // 显示WebView
        return Stack(
          children: [
            wv.WebViewWidget(
              controller: controller.webViewController,
            ),
            if (controller.isLoading.value)
              Container(
                color: Colors.white.withOpacity(0.8),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        );
      }),
    );
  }
}

