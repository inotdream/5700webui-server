import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../controllers/sms_controller.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/sms_model.dart';

class SmsView extends GetView<SmsController> {
  const SmsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
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
                      '短信管理',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: Icon(Icons.refresh_rounded, color: Colors.white),
                      onPressed: controller.refresh,
                    ),
                  ],
                ),
              ),
              
              // 短信列表
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: AppTheme.primaryColor,
                      ),
                    );
                  }
                  
                  if (controller.smsList.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.inbox_rounded,
                            size: 64.sp,
                            color: Colors.white30,
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            '暂无短信',
                            style: TextStyle(
                              color: Colors.white60,
                              fontSize: 16.sp,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  
                  return ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    itemCount: controller.smsList.length,
                    itemBuilder: (context, index) {
                      final sms = controller.smsList[index];
                      return _buildSmsCard(sms, index);
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showSendSmsDialog(),
        backgroundColor: AppTheme.primaryColor,
        icon: const Icon(Icons.send_rounded),
        label: const Text('发送短信'),
      ),
    );
  }

  Widget _buildSmsCard(SmsModel sms, int index) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: AppTheme.primaryColor.withOpacity(0.2),
                child: Text(
                  sms.sender.isNotEmpty ? sms.sender[0] : '?',
                  style: TextStyle(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sms.sender,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      sms.time,
                      style: TextStyle(
                        color: Colors.white60,
                        fontSize: 12.sp,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton(
                icon: Icon(Icons.more_vert_rounded, color: Colors.white60),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    child: Row(
                      children: [
                        const Icon(Icons.delete_rounded, color: Colors.red),
                        SizedBox(width: 8.w),
                        const Text('删除'),
                      ],
                    ),
                    onTap: () => controller.deleteSms(index),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            sms.content,
            style: TextStyle(
              color: Colors.white,
              fontSize: 14.sp,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  void _showSendSmsDialog() {
    final numberController = TextEditingController();
    final contentController = TextEditingController();
    
    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        title: Text(
          '发送短信',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: numberController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: '手机号码',
                labelStyle: const TextStyle(color: Colors.white60),
                prefixIcon: const Icon(Icons.phone_rounded, color: Colors.white60),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: const BorderSide(color: Colors.white30),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(color: AppTheme.primaryColor),
                ),
              ),
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: 16.h),
            TextField(
              controller: contentController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: '短信内容',
                labelStyle: const TextStyle(color: Colors.white60),
                prefixIcon: const Icon(Icons.message_rounded, color: Colors.white60),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: const BorderSide(color: Colors.white30),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(color: AppTheme.primaryColor),
                ),
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
          ElevatedButton(
            onPressed: () {
              final number = numberController.text.trim();
              final content = contentController.text.trim();
              
              if (number.isEmpty || content.isEmpty) {
                Get.snackbar('错误', '请填写完整信息');
                return;
              }
              
              controller.sendSms(number, content);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
            ),
            child: const Text('发送'),
          ),
        ],
      ),
    );
  }
}

