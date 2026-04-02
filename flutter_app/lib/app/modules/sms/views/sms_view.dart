import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../controllers/sms_controller.dart';
import '../../../data/models/sms_model.dart';

class SmsView extends GetView<SmsController> {
  const SmsView({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('短信管理'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: controller.refresh,
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.smsList.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inbox_rounded, size: 64.sp,
                    color: colorScheme.onSurface.withOpacity(0.25)),
                SizedBox(height: 16.h),
                Text('暂无短信',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.5),
                    )),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.all(16.w),
          itemCount: controller.smsList.length,
          itemBuilder: (context, index) {
            final sms = controller.smsList[index];
            return _buildSmsCard(context, sms, index);
          },
        );
      }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showSendSmsDialog(context),
        icon: const Icon(Icons.send_rounded),
        label: const Text('发送短信'),
      ),
    );
  }

  Widget _buildSmsCard(BuildContext context, SmsModel sms, int index) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: EdgeInsets.only(bottom: 8.h),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: colorScheme.primaryContainer,
                  foregroundColor: colorScheme.onPrimaryContainer,
                  child: Text(
                    sms.sender.isNotEmpty ? sms.sender[0] : '?',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(sms.sender,
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold)),
                      SizedBox(height: 2.h),
                      Text(sms.time, style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
                PopupMenuButton(
                  icon: Icon(Icons.more_vert_rounded,
                      color: colorScheme.onSurface.withOpacity(0.5)),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      child: const Row(
                        children: [
                          Icon(Icons.delete_rounded, color: Colors.red),
                          SizedBox(width: 8),
                          Text('删除'),
                        ],
                      ),
                      onTap: () => controller.deleteSms(index),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Text(sms.content,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5)),
          ],
        ),
      ),
    );
  }

  void _showSendSmsDialog(BuildContext context) {
    final numberController = TextEditingController();
    final contentController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: const Text('发送短信'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: numberController,
              decoration: const InputDecoration(
                labelText: '手机号码',
                prefixIcon: Icon(Icons.phone_rounded),
              ),
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: 16.h),
            TextField(
              controller: contentController,
              decoration: const InputDecoration(
                labelText: '短信内容',
                prefixIcon: Icon(Icons.message_rounded),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () {
              final number = numberController.text.trim();
              final content = contentController.text.trim();
              if (number.isEmpty || content.isEmpty) {
                Get.snackbar('错误', '请填写完整信息');
                return;
              }
              controller.sendSms(number, content);
            },
            child: const Text('发送'),
          ),
        ],
      ),
    );
  }
}
