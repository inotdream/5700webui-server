import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart' as wv;
import 'package:url_launcher/url_launcher.dart';
import '../../../services/websocket_server_service.dart';

class WebViewController extends GetxController {
  final _wsService = Get.find<WebSocketServerService>();
  
  wv.WebViewController? _webViewController;
  wv.WebViewController get webViewController => _webViewController!;
  
  final isLoading = true.obs;
  final currentUrl = ''.obs;
  final errorMessage = ''.obs;
  final isServerReady = false.obs;
  final isMacOS = false.obs;
  final shouldUseBrowser = false.obs;
  
  @override
  void onInit() {
    super.onInit();
    isMacOS.value = Platform.isMacOS;
    _initWebView();
  }
  
  Future<void> _initWebView() async {
    try {
      errorMessage.value = '';
      
      // 等待WebSocket服务器启动
      if (!_wsService.isRunning.value) {
        print('WebSocket服务器未运行，正在启动...');
        await _wsService.startServer();
        // 等待服务器完全启动
        await Future.delayed(const Duration(milliseconds: 500));
      }
      
      isServerReady.value = true;
      await _createWebView();
      
    } catch (e) {
      print('初始化WebView失败: $e');
      errorMessage.value = '无法启动Web服务器: $e';
      Get.snackbar('错误', '无法启动Web服务器，请检查网络设置');
    }
  }
  
  Future<void> _createWebView() async {
    try {
      final port = _wsService.serverPort.value;
      final url = 'http://127.0.0.1:$port';
      currentUrl.value = url;
      
      print('创建WebView，URL: $url');
      
      // 在macOS上，如果WebView创建失败，直接使用浏览器
      if (isMacOS.value) {
        print('macOS平台，检测WebView支持...');
        try {
          _webViewController = wv.WebViewController()
            ..setJavaScriptMode(wv.JavaScriptMode.unrestricted)
            ..setBackgroundColor(const Color(0x00000000))
            ..setNavigationDelegate(
              wv.NavigationDelegate(
                onPageStarted: (String url) {
                  print('开始加载页面: $url');
                  isLoading.value = true;
                  errorMessage.value = '';
                },
                onPageFinished: (String url) {
                  print('页面加载完成: $url');
                  isLoading.value = false;
                },
                onWebResourceError: (wv.WebResourceError error) {
                  print('WebView资源错误: ${error.description}, 类型: ${error.errorType}');
                  errorMessage.value = '加载失败: ${error.description}';
                },
                onNavigationRequest: (wv.NavigationRequest request) {
                  print('导航请求: ${request.url}');
                  return wv.NavigationDecision.navigate;
                },
              ),
            );
          
          // 延迟加载页面，确保WebView完全初始化
          await Future.delayed(const Duration(milliseconds: 300));
          await _webViewController!.loadRequest(Uri.parse(url));
          
        } catch (e) {
          print('macOS WebView创建失败，使用浏览器模式: $e');
          shouldUseBrowser.value = true;
          isLoading.value = false;
        }
      } else {
        // 非macOS平台，正常创建WebView
        _webViewController = wv.WebViewController()
          ..setJavaScriptMode(wv.JavaScriptMode.unrestricted)
          ..setBackgroundColor(const Color(0x00000000))
          ..setNavigationDelegate(
            wv.NavigationDelegate(
              onPageStarted: (String url) {
                print('开始加载页面: $url');
                isLoading.value = true;
                errorMessage.value = '';
              },
              onPageFinished: (String url) {
                print('页面加载完成: $url');
                isLoading.value = false;
              },
              onWebResourceError: (wv.WebResourceError error) {
                print('WebView资源错误: ${error.description}, 类型: ${error.errorType}');
                errorMessage.value = '加载失败: ${error.description}';
              },
              onNavigationRequest: (wv.NavigationRequest request) {
                print('导航请求: ${request.url}');
                return wv.NavigationDecision.navigate;
              },
            ),
          );
        
        // 延迟加载页面，确保WebView完全初始化
        await Future.delayed(const Duration(milliseconds: 300));
        await _webViewController!.loadRequest(Uri.parse(url));
      }
      
    } catch (e) {
      print('创建WebView失败: $e');
      if (isMacOS.value) {
        shouldUseBrowser.value = true;
        isLoading.value = false;
      } else {
        errorMessage.value = '创建WebView失败: $e';
      }
    }
  }
  
  Future<void> reload() async {
    await webViewController.reload();
  }
  
  void goBack() {
    webViewController.goBack();
  }
  
  void goForward() {
    webViewController.goForward();
  }
  
  /// 在浏览器中打开Web界面
  Future<void> openInBrowser() async {
    final port = _wsService.serverPort.value;
    final url = 'http://127.0.0.1:$port';
    
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        print('已在浏览器中打开: $url');
      } else {
        Get.snackbar('错误', '无法打开浏览器，请手动访问: $url');
      }
    } catch (e) {
      print('打开浏览器失败: $e');
      Get.snackbar('错误', '打开浏览器失败: $e');
    }
  }
  
  /// 清理WebView缓存
  Future<void> clearCache() async {
    try {
      print('🧹 清理WebView缓存...');
      
      // 清理WebView缓存
      await webViewController.clearCache();
      
      // 重新加载页面
      await reload();
      
      Get.snackbar('成功', '缓存已清理，页面已刷新');
    } catch (e) {
      print('❌ 清理缓存失败: $e');
      Get.snackbar('错误', '清理缓存失败: $e');
    }
  }
  
  /// 清理所有数据（缓存、Cookie、存储等）
  Future<void> clearAllData() async {
    try {
      print('🧹 清理WebView所有数据...');
      
      // 清理缓存
      await webViewController.clearCache();
      
      // 清理本地存储（如果支持）
      await webViewController.runJavaScript('''
        try {
          localStorage.clear();
          sessionStorage.clear();
          if (window.indexedDB) {
            indexedDB.databases().then(databases => {
              databases.forEach(db => {
                indexedDB.deleteDatabase(db.name);
              });
            });
          }
        } catch(e) {
          console.log('清理存储失败:', e);
        }
      ''');
      
      // 重新加载页面
      await Future.delayed(const Duration(milliseconds: 500));
      await reload();
      
      Get.snackbar('成功', '所有数据已清理，页面已刷新');
    } catch (e) {
      print('❌ 清理数据失败: $e');
      Get.snackbar('错误', '清理数据失败: $e');
    }
  }
}

