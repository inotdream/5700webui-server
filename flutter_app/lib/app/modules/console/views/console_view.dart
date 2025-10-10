import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../controllers/console_controller.dart';
import '../../../core/theme/app_theme.dart';

class ConsoleView extends GetView<ConsoleController> {
  const ConsoleView({super.key});

  @override
  Widget build(BuildContext context) {
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
          child: Column(
            children: [
              // AppBar
              Padding(
                padding: EdgeInsets.all(16.w),
                child: Row(
                  children: [
                    Text(
                      'AT控制台',
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: Icon(Icons.clear_all_rounded, color: Theme.of(context).textTheme.bodyLarge?.color),
                      onPressed: controller.clearLogs,
                      tooltip: '清空日志',
                    ),
                  ],
                ),
              ),
              
              // 日志区域
              Expanded(
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 16.w),
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: AppTheme.primaryColor.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Obx(() => ListView.builder(
                    controller: controller.scrollController,
                    itemCount: controller.logs.length,
                    itemBuilder: (context, index) {
                      final log = controller.logs[index];
                      return Padding(
                        padding: EdgeInsets.only(bottom: 4.h),
                        child: SelectableText(
                          log['message'],
                          style: TextStyle(
                            color: log['isSent']
                                ? AppTheme.primaryColor
                                : AppTheme.successColor,
                            fontFamily: 'Courier',
                            fontSize: 13.sp,
                            height: 1.5,
                          ),
                        ),
                      );
                    },
                  )),
                ),
              ),
              
              // 快捷命令按钮
              Container(
                height: 50.h,
                margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildQuickCommand(context, 'AT+CSQ', '信号强度'),
                    _buildQuickCommand(context, 'AT+COPS?', '运营商'),
                    _buildQuickCommand(context, 'AT^MONSC', '小区信息'),
                    _buildQuickCommand(context, 'AT+CPIN?', 'SIM状态'),
                    _buildQuickCommand(context, 'AT+CREG?', '网络注册'),
                  ],
                ),
              ),
              
              // 命令输入区域
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: controller.commandController,
                        style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
                        decoration: InputDecoration(
                          hintText: '输入AT命令...',
                          hintStyle: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.3)),
                          prefixIcon: Icon(
                            Icons.terminal_rounded,
                            color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.6),
                          ),
                          filled: true,
                          fillColor: Theme.of(context).cardColor,
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
                        onSubmitted: (_) => controller.sendCommand(),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Container(
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.send_rounded, color: Colors.white),
                        onPressed: controller.sendCommand,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickCommand(BuildContext context, String command, String label) {
    return Container(
      margin: EdgeInsets.only(right: 8.w),
      child: ElevatedButton(
        onPressed: () {
          controller.commandController.text = command;
          controller.sendCommand();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).cardColor,
          foregroundColor: Theme.of(context).textTheme.bodyLarge?.color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
            side: BorderSide(
              color: AppTheme.primaryColor.withOpacity(0.5),
            ),
          ),
        ),
        child: Text(label),
      ),
    );
  }
}

