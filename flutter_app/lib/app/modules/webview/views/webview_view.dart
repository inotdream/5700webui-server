import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart' as wv;
import '../controllers/webview_controller.dart';

class WebViewView extends GetView<WebViewController> {
  const WebViewView({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Web 管理界面'),
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
                  itemBuilder: (context) => const [
                    PopupMenuItem(
                      value: 'refresh',
                      child: Row(children: [
                        Icon(Icons.refresh), SizedBox(width: 8), Text('刷新页面'),
                      ]),
                    ),
                    PopupMenuItem(
                      value: 'clear_cache',
                      child: Row(children: [
                        Icon(Icons.cached), SizedBox(width: 8), Text('清理缓存'),
                      ]),
                    ),
                    PopupMenuItem(
                      value: 'clear_all',
                      child: Row(children: [
                        Icon(Icons.delete_sweep), SizedBox(width: 8), Text('清理所有数据'),
                      ]),
                    ),
                  ],
                )
              : const SizedBox()),
        ],
      ),
      body: Obx(() {
        if (controller.shouldUseBrowser.value) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.language_rounded, size: 72,
                      color: colorScheme.primary),
                  const SizedBox(height: 24),
                  Text('macOS 浏览器模式',
                      style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 12),
                  Text('由于macOS平台限制，Web界面将在外部浏览器中打开',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.6),
                      )),
                  const SizedBox(height: 24),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Text('访问地址',
                              style: Theme.of(context).textTheme.labelLarge),
                          const SizedBox(height: 8),
                          SelectableText(
                            controller.currentUrl.value,
                            style: TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 16,
                              color: colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FilledButton.icon(
                        onPressed: controller.openInBrowser,
                        icon: const Icon(Icons.open_in_browser),
                        label: const Text('在浏览器中打开'),
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton.icon(
                        onPressed: controller.retryInit,
                        icon: const Icon(Icons.refresh),
                        label: const Text('重试内嵌'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }

        if (controller.errorMessage.value.isNotEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: colorScheme.error),
                  const SizedBox(height: 16),
                  Text('加载失败',
                      style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 8),
                  Text(controller.errorMessage.value,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.6),
                      )),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: controller.retryInit,
                    icon: const Icon(Icons.refresh),
                    label: const Text('重试'),
                  ),
                ],
              ),
            ),
          );
        }

        if (!controller.isServerReady.value) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('正在启动 Web 服务器...'),
              ],
            ),
          );
        }

        return Stack(
          children: [
            wv.WebViewWidget(controller: controller.webViewController),
            if (controller.isLoading.value)
              const Center(child: CircularProgressIndicator()),
          ],
        );
      }),
    );
  }
}
