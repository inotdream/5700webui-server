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
      appBar: AppBar(
        title: const Text('AT网关监控'),
        actions: [
          Obx(() => Padding(
            padding: EdgeInsets.only(right: 16.w),
            child: Icon(
              tcpService.isConnected.value
                  ? Icons.cloud_done_rounded
                  : Icons.cloud_off_rounded,
              color: tcpService.isConnected.value
                  ? AppTheme.successColor
                  : AppTheme.errorColor,
            ),
          )),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(16.w),
        children: [
          _buildConnectionCard(context, tcpService),
          SizedBox(height: 12.h),
          Obx(() => _buildSignalCard(context)),
          SizedBox(height: 12.h),
          Obx(() => _buildSpeedCard(context)),
          SizedBox(height: 12.h),
          Obx(() => _buildRsrpChart(context)),
        ],
      ),
    );
  }

  Widget _buildConnectionCard(BuildContext context, TcpService tcpService) {
    return Card(
      child: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
          borderRadius: BorderRadius.circular(16.r),
        ),
        padding: EdgeInsets.all(20.w),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(Icons.cable_rounded, color: Colors.white, size: 28.sp),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('连接状态',
                      style: TextStyle(color: Colors.white70, fontSize: 13.sp)),
                  SizedBox(height: 4.h),
                  Obx(() => Text(
                    tcpService.connectionStatus.value,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  )),
                ],
              ),
            ),
            Obx(() => Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Text(
                controller.connectionType.value,
                style: TextStyle(color: Colors.white, fontSize: 13.sp, fontWeight: FontWeight.w600),
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildSignalCard(BuildContext context) {
    final signal = controller.signalData.value;
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.signal_cellular_alt_rounded, color: colorScheme.primary, size: 22.sp),
                SizedBox(width: 8.w),
                Text('信号强度', style: Theme.of(context).textTheme.titleMedium),
                const Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: _getSignalColor(signal?.rsrp).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20.r),
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
                Expanded(child: _buildMetric(context, 'RSRP', '${signal?.rsrp ?? '--'} dBm')),
                Expanded(child: _buildMetric(context, 'RSRQ', '${signal?.rsrq?.toStringAsFixed(1) ?? '--'} dB')),
                Expanded(child: _buildMetric(context, 'SINR', '${signal?.sinr?.toStringAsFixed(1) ?? '--'} dB')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetric(BuildContext context, String label, String value) {
    return Column(
      children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        SizedBox(height: 4.h),
        Text(value, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildSpeedCard(BuildContext context) {
    final signal = controller.signalData.value;
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.speed_rounded, color: colorScheme.tertiary, size: 22.sp),
                SizedBox(width: 8.w),
                Text('网络速率', style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            SizedBox(height: 20.h),
            Row(
              children: [
                Expanded(child: _buildSpeedItem(context,
                    Icons.upload_rounded, '上行',
                    signal?.uploadSpeedFormatted ?? '0 Kbps',
                    colorScheme.secondary)),
                SizedBox(width: 12.w),
                Expanded(child: _buildSpeedItem(context,
                    Icons.download_rounded, '下行',
                    signal?.downloadSpeedFormatted ?? '0 Kbps',
                    colorScheme.primary)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpeedItem(BuildContext context, IconData icon, String label, String value, Color color) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24.sp),
          SizedBox(height: 8.h),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          SizedBox(height: 4.h),
          Text(value, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildRsrpChart(BuildContext context) {
    if (controller.rsrpHistory.isEmpty) return const SizedBox.shrink();
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('RSRP趋势', style: Theme.of(context).textTheme.titleMedium),
            SizedBox(height: 20.h),
            SizedBox(
              height: 150.h,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: const FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: controller.rsrpHistory
                          .asMap()
                          .entries
                          .map((e) => FlSpot(e.key.toDouble(), e.value))
                          .toList(),
                      isCurved: true,
                      color: colorScheme.primary,
                      barWidth: 3,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: colorScheme.primary.withOpacity(0.15),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getSignalColor(int? rsrp) {
    if (rsrp == null) return Colors.grey;
    if (rsrp >= -85) return AppTheme.successColor;
    if (rsrp >= -95) return Colors.lightGreen;
    if (rsrp >= -105) return AppTheme.warningColor;
    return AppTheme.errorColor;
  }
}
