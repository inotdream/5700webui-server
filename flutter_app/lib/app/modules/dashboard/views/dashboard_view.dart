import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fl_chart/fl_chart.dart';
import '../controllers/dashboard_controller.dart';
import '../../../services/tcp_service.dart';
import '../../../core/theme/app_theme.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final tcpService = Get.find<TcpService>();
    
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
          child: CustomScrollView(
            slivers: [
              // AppBar
              SliverAppBar(
                floating: true,
                backgroundColor: Colors.transparent,
                elevation: 0,
                title: Text(
                  'AT网关监控',
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                actions: [
                  Obx(() => Icon(
                    tcpService.isConnected.value
                        ? Icons.cloud_done_rounded
                        : Icons.cloud_off_rounded,
                    color: tcpService.isConnected.value
                        ? Colors.greenAccent
                        : Colors.redAccent,
                  )),
                  SizedBox(width: 16.w),
                ],
              ),
              
              // 内容
              SliverPadding(
                padding: EdgeInsets.all(16.w),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // 连接状态卡片
                    _buildConnectionCard(tcpService),
                    SizedBox(height: 16.h),
                    
                    // 信号强度卡片
                    Obx(() => _buildSignalCard()),
                    SizedBox(height: 16.h),
                    
                    // 网络速率卡片
                    Obx(() => _buildSpeedCard()),
                    SizedBox(height: 16.h),
                    
                    // RSRP趋势图
                    Obx(() => _buildRsrpChart()),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConnectionCard(TcpService tcpService) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              Icons.cable_rounded,
              color: Colors.white,
              size: 32.sp,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '连接状态',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14.sp,
                  ),
                ),
                SizedBox(height: 4.h),
                Obx(() => Text(
                  tcpService.connectionStatus.value,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                  ),
                )),
              ],
            ),
          ),
          Obx(() => Text(
            controller.connectionType.value,
            style: TextStyle(
              color: Colors.white,
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildSignalCard() {
    final signal = controller.signalData.value;
    
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.signal_cellular_alt_rounded,
                color: AppTheme.primaryColor,
                size: 24.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                '信号强度',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: _getSignalColor(signal?.rsrp).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  signal?.signalQuality ?? '未知',
                  style: TextStyle(
                    color: _getSignalColor(signal?.rsrp),
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          Row(
            children: [
              Expanded(
                child: _buildSignalItem(
                  'RSRP',
                  '${signal?.rsrp ?? '--'} dBm',
                ),
              ),
              Expanded(
                child: _buildSignalItem(
                  'RSRQ',
                  '${signal?.rsrq?.toStringAsFixed(1) ?? '--'} dB',
                ),
              ),
              Expanded(
                child: _buildSignalItem(
                  'SINR',
                  '${signal?.sinr?.toStringAsFixed(1) ?? '--'} dB',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSignalItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white60,
            fontSize: 12.sp,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildSpeedCard() {
    final signal = controller.signalData.value;
    
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.speed_rounded,
                color: AppTheme.accentColor,
                size: 24.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                '网络速率',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          Row(
            children: [
              Expanded(
                child: _buildSpeedItem(
                  Icons.upload_rounded,
                  '上行',
                  signal?.uploadSpeedFormatted ?? '0 Kbps',
                  Colors.greenAccent,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: _buildSpeedItem(
                  Icons.download_rounded,
                  '下行',
                  signal?.downloadSpeedFormatted ?? '0 Kbps',
                  Colors.blueAccent,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSpeedItem(IconData icon, String label, String value, Color color) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24.sp),
          SizedBox(height: 8.h),
          Text(
            label,
            style: TextStyle(
              color: Colors.white60,
              fontSize: 12.sp,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRsrpChart() {
    if (controller.rsrpHistory.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'RSRP趋势',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 20.h),
          SizedBox(
            height: 150.h,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: controller.rsrpHistory
                        .asMap()
                        .entries
                        .map((e) => FlSpot(e.key.toDouble(), e.value))
                        .toList(),
                    isCurved: true,
                    color: AppTheme.primaryColor,
                    barWidth: 3,
                    dotData: FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppTheme.primaryColor.withOpacity(0.2),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getSignalColor(int? rsrp) {
    if (rsrp == null) return Colors.grey;
    if (rsrp >= -85) return Colors.greenAccent;
    if (rsrp >= -95) return Colors.lightGreenAccent;
    if (rsrp >= -105) return Colors.orangeAccent;
    return Colors.redAccent;
  }
}
