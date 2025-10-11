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
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).scaffoldBackgroundColor,
              Theme.of(context).scaffoldBackgroundColor.withOpacity(0.8),
            ],
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: EdgeInsets.all(16.w),
            children: [
              Text(
                '设置',
                style: TextStyle(
                  color: Theme.of(context).textTheme.headlineLarge?.color,
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 24.h),
              
              // 连接设置
              _buildSectionTitle(context, 'TCP直连设置'),
              _buildSettingCard(context, [
                _buildTcpConfigFields(context),
                Divider(color: Theme.of(context).dividerColor),
                Obx(() => _buildSwitchTile(context,
                  icon: Icons.autorenew_rounded,
                  title: '自动连接',
                  subtitle: '启动时自动连接到AT设备',
                  value: controller.autoConnect.value,
                  onChanged: controller.toggleAutoConnect,
                )),
                Divider(color: Theme.of(context).dividerColor),
                _buildActionTile(context, 
                  icon: Icons.refresh_rounded,
                  title: '重新连接',
                  subtitle: Obx(() => Text(
                    tcpService.connectionStatus.value,
                    style: TextStyle(
                      color: tcpService.isConnected.value
                          ? AppTheme.successColor
                          : AppTheme.errorColor,
                      fontSize: 12.sp,
                    ),
                  )),
                  onTap: controller.reconnect,
                ),
                Divider(color: Theme.of(context).dividerColor),
                _buildActionTile(context, 
                  icon: Icons.network_check_rounded,
                  title: '测试连接',
                  subtitle: const Text('测试TCP连接是否正常'),
                  onTap: controller.testConnection,
                ),
              ]),
              SizedBox(height: 24.h),
              
              // WebSocket 服务器设置
              _buildSectionTitle(context, 'WebSocket服务器'),
              _buildSettingCard(context,[
                // 端口配置
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: Theme.of(context).dividerColor,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '端口配置',
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: controller.wsPortController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              decoration: InputDecoration(
                                labelText: 'WebSocket端口',
                                hintText: '8765',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12.w,
                                  vertical: 8.h,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 8.w),
                          ElevatedButton(
                            onPressed: controller.saveWsConfig,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor,
                              padding: EdgeInsets.symmetric(
                                horizontal: 16.w,
                                vertical: 8.h,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                            ),
                            child: const Text('修改'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 12.h),
                Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.wifi_rounded,
                            color: AppTheme.primaryColor,
                            size: 20.sp,
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            'Web前端接口',
                            style: TextStyle(
                              color: Theme.of(context).textTheme.bodyLarge?.color,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),
                      Obx(() {
                        if (wsServer.isRunning.value) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: EdgeInsets.all(12.w),
                                decoration: BoxDecoration(
                                  color: AppTheme.successColor.withOpacity(0.1),
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
                                        Icon(
                                          Icons.check_circle_rounded,
                                          color: AppTheme.successColor,
                                          size: 16.sp,
                                        ),
                                        SizedBox(width: 8.w),
                                        Text(
                                          '服务器运行中',
                                          style: TextStyle(
                                            color: AppTheme.successColor,
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 8.h),
                                    Text(
                                      '端口: ${wsServer.serverPort.value}',
                                      style: TextStyle(
                                        color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.7),
                                        fontSize: 12.sp,
                                      ),
                                    ),
                                    Text(
                                      '已连接客户端: ${wsServer.clientCount.value}',
                                      style: TextStyle(
                                        color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.7),
                                        fontSize: 12.sp,
                                      ),
                                    ),
                                    SizedBox(height: 8.h),
                                    FutureBuilder<List<String>>(
                                      future: wsServer.getLocalIPAddresses(),
                                      builder: (context, snapshot) {
                                        if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                                          return Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'WebSocket地址:',
                                                style: TextStyle(
                                                  color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.7),
                                                  fontSize: 12.sp,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              SizedBox(height: 4.h),
                                              ...snapshot.data!.map((addr) => 
                                                GestureDetector(
                                                  onTap: () {
                                                    Clipboard.setData(ClipboardData(text: addr));
                                                    Get.snackbar(
                                                      '已复制',
                                                      addr,
                                                      snackPosition: SnackPosition.BOTTOM,
                                                      duration: const Duration(seconds: 2),
                                                    );
                                                  },
                                                  child: Container(
                                                    margin: EdgeInsets.only(top: 4.h),
                                                    padding: EdgeInsets.symmetric(
                                                      horizontal: 8.w,
                                                      vertical: 4.h,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: Colors.black.withOpacity(0.2),
                                                      borderRadius: BorderRadius.circular(6.r),
                                                    ),
                                                    child: Row(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        Expanded(
                                                          child: Text(
                                                            addr,
                                                            style: TextStyle(
                                                              color: Theme.of(context).textTheme.bodyLarge?.color,
                                                              fontSize: 11.sp,
                                                              fontFamily: 'monospace',
                                                            ),
                                                          ),
                                                        ),
                                                        Icon(
                                                          Icons.copy_rounded,
                                                          size: 12.sp,
                                                          color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.6),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          );
                                        }
                                        return const SizedBox.shrink();
                                      },
                                    ),
                                    SizedBox(height: 12.h),
                                    FutureBuilder<List<String>>(
                                      future: wsServer.getHttpAddresses(),
                                      builder: (context, snapshot) {
                                        if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                                          return Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'HTTP访问地址 (点击复制):',
                                                style: TextStyle(
                                                  color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.7),
                                                  fontSize: 12.sp,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              SizedBox(height: 4.h),
                                              ...snapshot.data!.map((addr) => 
                                                GestureDetector(
                                                  onTap: () {
                                                    Clipboard.setData(ClipboardData(text: addr));
                                                    Get.snackbar(
                                                      '已复制',
                                                      '可在浏览器中打开: $addr',
                                                      snackPosition: SnackPosition.BOTTOM,
                                                      duration: const Duration(seconds: 2),
                                                    );
                                                  },
                                                  child: Container(
                                                    margin: EdgeInsets.only(top: 4.h),
                                                    padding: EdgeInsets.symmetric(
                                                      horizontal: 8.w,
                                                      vertical: 6.h,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: AppTheme.primaryColor.withOpacity(0.15),
                                                      borderRadius: BorderRadius.circular(6.r),
                                                      border: Border.all(
                                                        color: AppTheme.primaryColor.withOpacity(0.3),
                                                      ),
                                                    ),
                                                    child: Row(
                                                      children: [
                                                        Icon(
                                                          Icons.language_rounded,
                                                          size: 14.sp,
                                                          color: AppTheme.primaryColor,
                                                        ),
                                                        SizedBox(width: 8.w),
                                                        Expanded(
                                                          child: Text(
                                                            addr,
                                                            style: TextStyle(
                                                              color: AppTheme.primaryColor,
                                                              fontSize: 12.sp,
                                                              fontWeight: FontWeight.w600,
                                                              fontFamily: 'monospace',
                                                            ),
                                                          ),
                                                        ),
                                                        Icon(
                                                          Icons.copy_rounded,
                                                          size: 14.sp,
                                                          color: AppTheme.primaryColor,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          );
                                        }
                                        return const SizedBox.shrink();
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 12.h),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: () => wsServer.stopServer(),
                                  icon: Icon(Icons.stop_rounded),
                                  label: const Text('停止服务器'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.errorColor,
                                    padding: EdgeInsets.symmetric(vertical: 12.h),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12.r),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        } else {
                          return SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () => wsServer.startServer(),
                              icon: Icon(Icons.play_arrow_rounded),
                              label: const Text('启动服务器'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryColor,
                                padding: EdgeInsets.symmetric(vertical: 12.h),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                              ),
                            ),
                          );
                        }
                      }),
                    ],
                  ),
                ),
              ]),
              SizedBox(height: 24.h),
              
              // 通知设置
              _buildSectionTitle(context, '通知设置'),
              _buildSettingCard(context,[
                Obx(() => _buildSwitchTile(context,
                  icon: Icons.notifications_rounded,
                  title: '启用通知',
                  subtitle: '接收短信和来电通知',
                  value: controller.enableNotification.value,
                  onChanged: controller.toggleNotification,
                )),
              ]),
              SizedBox(height: 24.h),
              
              // 外观设置
              _buildSectionTitle(context, '外观设置'),
              _buildSettingCard(context,[
                _buildThemeSelector(context),
              ]),
              SizedBox(height: 24.h),
              
              // 关于
              _buildSectionTitle(context, '关于'),
              _buildSettingCard(context,[
                _buildInfoTile(context, 
                  icon: Icons.info_rounded,
                  title: '版本',
                  subtitle: 'v1.0.0',
                ),
                Divider(color: Theme.of(context).dividerColor),
                _buildInfoTile(context, 
                  icon: Icons.code_rounded,
                  title: '开发者',
                  subtitle: 'AT Gateway Team',
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: EdgeInsets.only(left: 4.w, bottom: 12.h),
      child: Text(
        title,
        style: TextStyle(
          color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.7),
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildSettingCard(BuildContext context, List<Widget> children) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withOpacity(0.3) : Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildTcpConfigFields(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.cable_rounded,
                color: AppTheme.primaryColor,
                size: 20.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                'AT设备地址',
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          TextField(
            controller: controller.tcpHostController,
            style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
            decoration: InputDecoration(
              hintText: '192.168.8.1',
              hintStyle: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.3)),
              labelText: '主机地址',
              labelStyle: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.6)),
              filled: true,
              fillColor: Theme.of(context).cardColor.withOpacity(0.5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(
                  color: AppTheme.primaryColor,
                  width: 2,
                ),
              ),
            ),
          ),
          SizedBox(height: 12.h),
          TextField(
            controller: controller.tcpPortController,
            style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: '20249',
              hintStyle: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.3)),
              labelText: '端口',
              labelStyle: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.6)),
              filled: true,
              fillColor: Theme.of(context).cardColor.withOpacity(0.5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(
                  color: AppTheme.primaryColor,
                  width: 2,
                ),
              ),
            ),
          ),
          SizedBox(height: 12.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: controller.saveTcpConfig,
              icon: Icon(Icons.save_rounded),
              label: const Text('保存配置'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                padding: EdgeInsets.symmetric(vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile(BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primaryColor),
      title: Text(
        title,
        style: TextStyle(
          color: Theme.of(context).textTheme.bodyLarge?.color,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.6)),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppTheme.primaryColor,
      ),
    );
  }

  Widget _buildActionTile(BuildContext context, {
    required IconData icon,
    required String title,
    required Widget subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.accentColor),
      title: Text(
        title,
        style: TextStyle(
          color: Theme.of(context).textTheme.bodyLarge?.color,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: subtitle,
      trailing: Icon(Icons.chevron_right_rounded, color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.6)),
      onTap: onTap,
    );
  }

  Widget _buildInfoTile(BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.secondaryColor),
      title: Text(
        title,
        style: TextStyle(
          color: Theme.of(context).textTheme.bodyLarge?.color,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.6)),
      ),
    );
  }

  Widget _buildThemeSelector(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.palette_rounded,
                color: AppTheme.primaryColor,
                size: 20.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                '主题模式',
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Obx(() => Row(
            children: [
              Expanded(
                child: _buildThemeOption(context, '跟随系统', 'system'),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: _buildThemeOption(context, '浅色', 'light'),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: _buildThemeOption(context, '深色', 'dark'),
              ),
            ],
          )),
        ],
      ),
    );
  }

  Widget _buildThemeOption(BuildContext context, String label, String mode) {
    final isSelected = controller.themeMode.value == mode;
    
    return GestureDetector(
      onTap: () => controller.changeTheme(mode),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryColor
              : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected
                ? AppTheme.primaryColor
                : Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected 
                  ? Theme.of(context).textTheme.bodyLarge?.color 
                  : Theme.of(context).textTheme.bodyLarge?.color,
              fontSize: 14.sp,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}

