import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../controllers/console_controller.dart';

class ConsoleView extends GetView<ConsoleController> {
  const ConsoleView({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('AT控制台'),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear_all_rounded),
            onPressed: controller.clearLogs,
            tooltip: '清空日志',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Card(
              margin: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 0),
              color: colorScheme.surfaceContainerHighest,
              child: Obx(() => ListView.builder(
                controller: controller.scrollController,
                padding: EdgeInsets.all(16.w),
                itemCount: controller.logs.length,
                itemBuilder: (context, index) {
                  final log = controller.logs[index];
                  return Padding(
                    padding: EdgeInsets.only(bottom: 4.h),
                    child: SelectableText(
                      log['message'],
                      style: TextStyle(
                        color: log['isSent']
                            ? colorScheme.primary
                            : colorScheme.secondary,
                        fontFamily: 'monospace',
                        fontSize: 13.sp,
                        height: 1.6,
                      ),
                    ),
                  );
                },
              )),
            ),
          ),

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
            child: Row(
              children: [
                _buildQuickChip(context, 'AT+CSQ', '信号强度'),
                SizedBox(width: 8.w),
                _buildQuickChip(context, 'AT+COPS?', '运营商'),
                SizedBox(width: 8.w),
                _buildQuickChip(context, 'AT^MONSC', '小区信息'),
                SizedBox(width: 8.w),
                _buildQuickChip(context, 'AT+CPIN?', 'SIM状态'),
                SizedBox(width: 8.w),
                _buildQuickChip(context, 'AT+CREG?', '网络注册'),
              ],
            ),
          ),

          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller.commandController,
                    decoration: const InputDecoration(
                      hintText: '输入AT命令...',
                      prefixIcon: Icon(Icons.terminal_rounded),
                    ),
                    onSubmitted: (_) => controller.sendCommand(),
                  ),
                ),
                SizedBox(width: 8.w),
                FilledButton(
                  onPressed: controller.sendCommand,
                  style: FilledButton.styleFrom(
                    padding: EdgeInsets.all(16.w),
                  ),
                  child: const Icon(Icons.send_rounded),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickChip(BuildContext context, String command, String label) {
    return ActionChip(
      avatar: Icon(Icons.bolt_rounded, size: 16.sp),
      label: Text(label),
      onPressed: () {
        controller.commandController.text = command;
        controller.sendCommand();
      },
    );
  }
}
