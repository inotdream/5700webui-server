import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../controllers/settings_controller.dart';
import '../../../core/theme/app_theme.dart';
import '../../../services/tcp_service.dart';
import '../../../services/websocket_server_service.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final tcpService = Get.find<TcpService>();
    final wsServer = Get.find<WebSocketServerService>();
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        children: [
          _buildSectionTitle(context, 'TCP直连设置'),
          Card(
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.cable_rounded, color: colorScheme.primary, size: 20.sp),
                      SizedBox(width: 8.w),
                      Text('AT设备地址', style: Theme.of(context).textTheme.titleMedium),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  TextField(
                    controller: controller.tcpHostController,
                    decoration: const InputDecoration(
                      hintText: '192.168.8.1',
                      labelText: '主机地址',
                    ),
                  ),
                  SizedBox(height: 12.h),
                  TextField(
                    controller: controller.tcpPortController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      hintText: '20249',
                      labelText: '端口',
                    ),
                  ),
                  SizedBox(height: 16.h),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: controller.saveTcpConfig,
                      icon: const Icon(Icons.save_rounded),
                      label: const Text('保存配置'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 4.h),
          Card(
            child: Column(
              children: [
                Obx(() => SwitchListTile(
                  secondary: Icon(Icons.autorenew_rounded, color: colorScheme.primary),
                  title: const Text('自动连接'),
                  subtitle: const Text('启动时自动连接到AT设备'),
                  value: controller.autoConnect.value,
                  onChanged: controller.toggleAutoConnect,
                )),
                const Divider(height: 1, indent: 16, endIndent: 16),
                ListTile(
                  leading: Icon(Icons.refresh_rounded, color: colorScheme.tertiary),
                  title: const Text('重新连接'),
                  subtitle: Obx(() => Text(
                    tcpService.connectionStatus.value,
                    style: TextStyle(
                      color: tcpService.isConnected.value
                          ? AppTheme.successColor
                          : AppTheme.errorColor,
                    ),
                  )),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: controller.reconnect,
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                ListTile(
                  leading: Icon(Icons.network_check_rounded, color: colorScheme.tertiary),
                  title: const Text('测试连接'),
                  subtitle: const Text('测试TCP连接是否正常'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: controller.testConnection,
                ),
              ],
            ),
          ),

          SizedBox(height: 24.h),
          _buildSectionTitle(context, 'WebSocket服务器'),
          Card(
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.dns_rounded, color: colorScheme.primary, size: 20.sp),
                      SizedBox(width: 8.w),
                      Text('端口配置', style: Theme.of(context).textTheme.titleMedium),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: controller.wsPortController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          decoration: const InputDecoration(
                            labelText: 'WebSocket端口',
                            hintText: '8765',
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      FilledButton.tonal(
                        onPressed: controller.saveWsConfig,
                        child: const Text('修改'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 4.h),
          Card(
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.wifi_rounded, color: colorScheme.primary, size: 20.sp),
                      SizedBox(width: 8.w),
                      Text('Web前端接口', style: Theme.of(context).textTheme.titleMedium),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  Obx(() {
                    if (wsServer.isRunning.value) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(12.w),
                            decoration: BoxDecoration(
                              color: AppTheme.successColor.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(
                                color: AppTheme.successColor.withOpacity(0.3),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.check_circle_rounded,
                                        color: AppTheme.successColor, size: 18.sp),
                                    SizedBox(width: 8.w),
                                    Text(
                                      '服务器运行中',
                                      style: TextStyle(
                                        color: AppTheme.successColor,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 8.h),
                                Text('端口: ${wsServer.serverPort.value}',
                                    style: Theme.of(context).textTheme.bodySmall),
                                Text('已连接客户端: ${wsServer.clientCount.value}',
                                    style: Theme.of(context).textTheme.bodySmall),
                                SizedBox(height: 8.h),
                                _buildAddressList(context, wsServer),
                              ],
                            ),
                          ),
                          SizedBox(height: 12.h),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton.icon(
                              onPressed: () => wsServer.stopServer(),
                              icon: const Icon(Icons.stop_rounded),
                              label: const Text('停止服务器'),
                              style: FilledButton.styleFrom(
                                backgroundColor: colorScheme.error,
                                foregroundColor: colorScheme.onError,
                              ),
                            ),
                          ),
                        ],
                      );
                    }
                    return SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () => wsServer.startServer(),
                        icon: const Icon(Icons.play_arrow_rounded),
                        label: const Text('启动服务器'),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),

          SizedBox(height: 24.h),
          _buildSectionTitle(context, '通知设置'),
          Card(
            child: Obx(() => SwitchListTile(
              secondary: Icon(Icons.notifications_rounded, color: colorScheme.primary),
              title: const Text('启用通知'),
              subtitle: const Text('接收短信和来电通知'),
              value: controller.enableNotification.value,
              onChanged: controller.toggleNotification,
            )),
          ),

          SizedBox(height: 24.h),
          _buildSectionTitle(context, '外观设置'),
          Card(
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.palette_rounded, color: colorScheme.primary, size: 20.sp),
                      SizedBox(width: 8.w),
                      Text('主题模式', style: Theme.of(context).textTheme.titleMedium),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  Obx(() => SizedBox(
                    width: double.infinity,
                    child: SegmentedButton<String>(
                      segments: const [
                        ButtonSegment(
                          value: 'system',
                          label: Text('跟随系统'),
                          icon: Icon(Icons.brightness_auto_rounded),
                        ),
                        ButtonSegment(
                          value: 'light',
                          label: Text('浅色'),
                          icon: Icon(Icons.light_mode_rounded),
                        ),
                        ButtonSegment(
                          value: 'dark',
                          label: Text('深色'),
                          icon: Icon(Icons.dark_mode_rounded),
                        ),
                      ],
                      selected: {controller.themeMode.value},
                      onSelectionChanged: (selection) {
                        controller.changeTheme(selection.first);
                      },
                    ),
                  )),
                ],
              ),
            ),
          ),

          SizedBox(height: 24.h),
          _buildSectionTitle(context, '关于'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.info_rounded, color: colorScheme.secondary),
                  title: const Text('版本'),
                  subtitle: const Text('v1.0.6'),
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                ListTile(
                  leading: Icon(Icons.code_rounded, color: colorScheme.secondary),
                  title: const Text('开发者'),
                  subtitle: const Text('www.lbu.cc'),
                ),
              ],
            ),
          ),
          SizedBox(height: 32.h),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: EdgeInsets.only(left: 4.w, bottom: 8.h, top: 4.h),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildAddressList(BuildContext context, WebSocketServerService wsServer) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FutureBuilder<List<String>>(
          future: wsServer.getLocalIPAddresses(),
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data!.isEmpty) return const SizedBox.shrink();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('WebSocket地址:',
                    style: Theme.of(context).textTheme.labelMedium),
                SizedBox(height: 4.h),
                ...snapshot.data!.map((addr) => _buildCopyableAddress(context, addr)),
              ],
            );
          },
        ),
        SizedBox(height: 8.h),
        FutureBuilder<List<String>>(
          future: wsServer.getHttpAddresses(),
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data!.isEmpty) return const SizedBox.shrink();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('HTTP访问地址 (点击复制):',
                    style: Theme.of(context).textTheme.labelMedium),
                SizedBox(height: 4.h),
                ...snapshot.data!.map((addr) => _buildCopyableAddress(context, addr,
                    icon: Icons.language_rounded, isPrimary: true)),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildCopyableAddress(BuildContext context, String addr,
      {IconData? icon, bool isPrimary = false}) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: () {
        Clipboard.setData(ClipboardData(text: addr));
        Get.snackbar('已复制', addr,
            snackPosition: SnackPosition.BOTTOM,
            duration: const Duration(seconds: 2));
      },
      child: Container(
        margin: EdgeInsets.only(top: 4.h),
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: isPrimary
              ? colorScheme.primaryContainer.withOpacity(0.5)
              : colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14.sp, color: colorScheme.primary),
              SizedBox(width: 6.w),
            ],
            Expanded(
              child: Text(
                addr,
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 11.sp,
                  color: isPrimary ? colorScheme.primary : colorScheme.onSurface,
                ),
              ),
            ),
            Icon(Icons.copy_rounded, size: 14.sp,
                color: colorScheme.onSurface.withOpacity(0.5)),
          ],
        ),
      ),
    );
  }
}
