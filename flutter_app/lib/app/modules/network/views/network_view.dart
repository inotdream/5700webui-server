import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';
import '../controllers/network_controller.dart';
import '../../../core/theme/app_theme.dart';
import '../../../utils/stun_client.dart';

class NetworkView extends GetView<NetworkController> {
  const NetworkView({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('网络检测'),
        actions: [
          Obx(() => controller.isLoading.value
              ? Padding(
                  padding: EdgeInsets.only(right: 16.w),
                  child: SizedBox(
                    width: 20.w, height: 20.w,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: colorScheme.primary),
                  ),
                )
              : IconButton(
                  icon: const Icon(Icons.refresh_rounded),
                  onPressed: controller.runAllTests,
                  tooltip: '重新检测',
                )),
        ],
      ),
      body: Obx(() => RefreshIndicator(
        onRefresh: controller.runAllTests,
        child: ListView(
          padding: EdgeInsets.all(16.w),
          children: [
            _buildIpInfoCard(context),
            SizedBox(height: 12.h),
            _buildNatTypeCard(context),
            SizedBox(height: 12.h),
            _buildLocalIpCard(context),
            SizedBox(height: 12.h),
            _buildConnectivityCard(context),
            SizedBox(height: 12.h),
            _buildIpCheckingCard(context),
            SizedBox(height: 32.h),
          ],
        ),
      )),
    );
  }

  // ── 出口信息 ──
  Widget _buildIpInfoCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16.w),
            decoration: const BoxDecoration(gradient: AppTheme.primaryGradient),
            child: Row(
              children: [
                Icon(Icons.public_rounded, color: Colors.white, size: 24.sp),
                SizedBox(width: 10.w),
                Text('出口信息',
                    style: TextStyle(color: Colors.white, fontSize: 16.sp,
                        fontWeight: FontWeight.bold)),
                const Spacer(),
                if (controller.publicIp.value.isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      Clipboard.setData(
                          ClipboardData(text: controller.publicIp.value));
                      Get.snackbar('已复制', controller.publicIp.value,
                          snackPosition: SnackPosition.BOTTOM,
                          duration: const Duration(seconds: 2));
                    },
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(controller.publicIp.value,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12.sp,
                                  fontFamily: 'monospace')),
                          SizedBox(width: 4.w),
                          Icon(Icons.copy_rounded,
                              color: Colors.white70, size: 14.sp),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (controller.ipInfoError.value.isNotEmpty)
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Row(children: [
                Icon(Icons.error_outline,
                    color: colorScheme.error, size: 20.sp),
                SizedBox(width: 8.w),
                Expanded(
                    child: Text(controller.ipInfoError.value,
                        style: TextStyle(color: colorScheme.error))),
              ]),
            )
          else if (controller.publicIp.value.isEmpty)
            Padding(
              padding: EdgeInsets.all(20.w),
              child: const Center(child: CircularProgressIndicator()),
            )
          else
            Padding(
              padding: EdgeInsets.all(4.w),
              child: Column(children: [
                _infoTile(context, Icons.business_rounded, 'ISP 运营商',
                    controller.isp.value),
                _infoTile(context, Icons.corporate_fare_rounded, '组织',
                    controller.org.value),
                _infoTile(context, Icons.tag_rounded, 'AS 编号',
                    controller.asNumber.value),
                _infoTile(
                    context,
                    Icons.location_on_rounded,
                    '位置',
                    '${controller.city.value}, ${controller.region.value}, ${controller.country.value}'),
                _infoTile(context, Icons.schedule_rounded, '时区',
                    controller.timezone.value),
              ]),
            ),
        ],
      ),
    );
  }

  Widget _infoTile(
      BuildContext context, IconData icon, String label, String value) {
    final colorScheme = Theme.of(context).colorScheme;
    return ListTile(
      dense: true,
      leading: Icon(icon, size: 20.sp, color: colorScheme.primary),
      title: Text(label, style: Theme.of(context).textTheme.bodySmall),
      trailing: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 200.w),
        child: Text(value.isNotEmpty ? value : '--',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(fontWeight: FontWeight.w600),
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis),
      ),
    );
  }

  // ── NAT 类型检测 (STUN) ──
  Widget _buildNatTypeCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final result = controller.natResult.value;
    final isTesting = controller.isTestingNat.value;

    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.router_rounded,
                    color: colorScheme.primary, size: 22.sp),
                SizedBox(width: 8.w),
                Text('NAT 类型检测',
                    style: Theme.of(context).textTheme.titleMedium),
                const Spacer(),
                if (!isTesting && !controller.isLoading.value)
                  TextButton.icon(
                    onPressed: controller.detectNatType,
                    icon: Icon(Icons.replay_rounded, size: 18.sp),
                    label: const Text('重测'),
                  ),
              ],
            ),
            SizedBox(height: 6.h),
            Text('基于 STUN 协议 (RFC 5389) 检测 NAT 映射行为',
                style: Theme.of(context).textTheme.bodySmall),
            SizedBox(height: 16.h),
            if (isTesting || result == null)
              _buildNatTestingState(context)
            else
              _buildNatResult(context, result),
          ],
        ),
      ),
    );
  }

  Widget _buildNatTestingState(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        children: [
          SizedBox(
            width: 32.w, height: 32.w,
            child: const CircularProgressIndicator(strokeWidth: 3),
          ),
          SizedBox(height: 12.h),
          Text('正在通过 STUN 服务器检测 NAT 类型...',
              style: Theme.of(context).textTheme.bodySmall),
          SizedBox(height: 6.h),
          Obx(() => Text(
              controller.stunProgress.value.isNotEmpty
                  ? controller.stunProgress.value
                  : '准备中...',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontFamily: 'monospace',
                  ))),
        ],
      ),
    );
  }

  Widget _buildNatResult(BuildContext context, NatTestResult result) {
    final natColor = _getNatColor(result.type);
    final natIcon = _getNatIcon(result.type);
    final natGrade = _getNatGrade(result.type);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // NAT 类型标签
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: natColor.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: natColor.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(natIcon, color: natColor, size: 24.sp),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Text(
                      result.label,
                      style: TextStyle(
                        color: natColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 18.sp,
                      ),
                    ),
                  ),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: natColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Text(natGrade,
                        style: TextStyle(
                            color: natColor,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              Text(result.detail,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        height: 1.6,
                      )),
            ],
          ),
        ),

        // STUN 映射详情
        if (result.mappings.isNotEmpty) ...[
          SizedBox(height: 12.h),
          Text('STUN 映射详情',
              style: Theme.of(context).textTheme.labelMedium),
          SizedBox(height: 8.h),
          ...result.mappings.map((entry) => Padding(
                padding: EdgeInsets.only(bottom: 4.h),
                child:
                    _buildMappingRow(context, entry.server, entry.address),
              )),
          if (result.serverInfo != null) ...[
            SizedBox(height: 8.h),
            Text(result.serverInfo!,
                style: Theme.of(context).textTheme.labelSmall),
          ],
        ],
      ],
    );
  }

  Widget _buildMappingRow(
      BuildContext context, String server, MappedAddress addr) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        children: [
          Icon(Icons.dns_rounded,
              size: 16.sp, color: colorScheme.onSurface.withOpacity(0.5)),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(server,
                style: Theme.of(context).textTheme.bodySmall,
                overflow: TextOverflow.ellipsis),
          ),
          SizedBox(width: 8.w),
          Text(
            addr.toString(),
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Color _getNatColor(NatType type) {
    switch (type) {
      case NatType.open:
        return AppTheme.successColor;
      case NatType.fullCone:
        return AppTheme.successColor;
      case NatType.restrictedCone:
        return Colors.lightGreen;
      case NatType.portRestricted:
        return AppTheme.warningColor;
      case NatType.symmetric:
        return AppTheme.errorColor;
      case NatType.unknown:
        return Colors.grey;
    }
  }

  IconData _getNatIcon(NatType type) {
    switch (type) {
      case NatType.open:
        return Icons.lock_open_rounded;
      case NatType.fullCone:
        return Icons.check_circle_rounded;
      case NatType.restrictedCone:
        return Icons.check_circle_outline_rounded;
      case NatType.portRestricted:
        return Icons.warning_rounded;
      case NatType.symmetric:
        return Icons.block_rounded;
      case NatType.unknown:
        return Icons.help_outline_rounded;
    }
  }

  String _getNatGrade(NatType type) {
    switch (type) {
      case NatType.open:
        return '最佳';
      case NatType.fullCone:
        return '优秀';
      case NatType.restrictedCone:
        return '良好';
      case NatType.portRestricted:
        return '一般';
      case NatType.symmetric:
        return '较差';
      case NatType.unknown:
        return '未知';
    }
  }

  // ── 本地网络 ──
  Widget _buildLocalIpCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(Icons.lan_rounded, color: colorScheme.primary, size: 22.sp),
              SizedBox(width: 8.w),
              Text('本地网络', style: Theme.of(context).textTheme.titleMedium),
            ]),
            SizedBox(height: 12.h),
            if (controller.localIps.isEmpty)
              const Center(child: CircularProgressIndicator())
            else
              Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children: controller.localIps
                    .map((ip) => Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 12.w, vertical: 8.h),
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.computer_rounded,
                                  size: 16.sp,
                                  color:
                                      colorScheme.onSurface.withOpacity(0.6)),
                              SizedBox(width: 6.w),
                              Text(ip,
                                  style: TextStyle(
                                      fontFamily: 'monospace',
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ))
                    .toList(),
              ),
          ],
        ),
      ),
    );
  }

  // ── 连通性测试 ──
  Widget _buildConnectivityCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(Icons.speed_rounded,
                  color: colorScheme.primary, size: 22.sp),
              SizedBox(width: 8.w),
              Text('连通性测试',
                  style: Theme.of(context).textTheme.titleMedium),
              const Spacer(),
              if (!controller.isLoading.value)
                TextButton.icon(
                  onPressed: controller.testConnectivity,
                  icon: Icon(Icons.replay_rounded, size: 18.sp),
                  label: const Text('重测'),
                ),
            ]),
            SizedBox(height: 8.h),
            if (controller.connectivityResults.isEmpty)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 20.h),
                child: const Center(child: CircularProgressIndicator()),
              )
            else
              ...controller.connectivityResults
                  .map((r) => _buildConnectivityItem(context, r)),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectivityItem(
      BuildContext context, ConnectivityResult result) {
    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (result.status) {
      case TestStatus.testing:
        statusColor = Colors.grey;
        statusIcon = Icons.hourglass_top_rounded;
        statusText = '测试中';
        break;
      case TestStatus.success:
        statusColor = AppTheme.successColor;
        statusIcon = Icons.check_circle_rounded;
        statusText = '${result.latencyMs}ms';
        break;
      case TestStatus.warning:
        statusColor = AppTheme.warningColor;
        statusIcon = Icons.warning_rounded;
        statusText = 'HTTP ${result.statusCode}';
        break;
      case TestStatus.failed:
        statusColor = AppTheme.errorColor;
        statusIcon = Icons.cancel_rounded;
        statusText = result.error ?? '失败';
        break;
    }

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        children: [
          Icon(statusIcon, color: statusColor, size: 20.sp),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(result.name,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(fontWeight: FontWeight.w600)),
                Text(result.description,
                    style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: result.status == TestStatus.testing
                ? SizedBox(
                    width: 14.w,
                    height: 14.w,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: statusColor))
                : Text(statusText,
                    style: TextStyle(
                        color: statusColor,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  // ── IPCheck.ing 集成 ──
  Widget _buildIpCheckingCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _openIpChecking(),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Icon(Icons.travel_explore_rounded,
                        color: colorScheme.onPrimaryContainer, size: 20.sp),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('IPCheck.ing',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold)),
                        Text('综合网络检测工具',
                            style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ),
                  ),
                  Icon(Icons.open_in_new_rounded,
                      color: colorScheme.primary, size: 20.sp),
                ],
              ),
              SizedBox(height: 12.h),
              Wrap(
                spacing: 6.w,
                runSpacing: 6.h,
                children: [
                  _featureChip(context, 'WebRTC 检测'),
                  _featureChip(context, 'DNS 泄露检测'),
                  _featureChip(context, '网速测试'),
                  _featureChip(context, '全球延迟'),
                  _featureChip(context, 'MTR 路由追踪'),
                  _featureChip(context, '代理规则测试'),
                ],
              ),
              SizedBox(height: 12.h),
              Text(
                '开源项目 jason5ng32/MyIP · 提供 WebRTC 检测、DNS 泄露、'
                '网速测试、全球延迟、MTR 追踪等高级功能',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.6),
                      height: 1.5,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _featureChip(BuildContext context, String label) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 11.sp,
              color: colorScheme.onSecondaryContainer,
              fontWeight: FontWeight.w500)),
    );
  }

  Future<void> _openIpChecking() async {
    final uri = Uri.parse('https://ipcheck.ing');
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      Get.snackbar('提示', '无法打开浏览器，请手动访问 https://ipcheck.ing',
          snackPosition: SnackPosition.BOTTOM);
    }
  }
}
