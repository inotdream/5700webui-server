import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../controllers/speedtest_controller.dart';
import '../../../utils/bandwidth_test.dart';

class SpeedTestView extends GetView<SpeedTestController> {
  const SpeedTestView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('带宽测试'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded),
            tooltip: '清除日志',
            onPressed: controller.clearLogs,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildIperf3Status(context),
            SizedBox(height: 12.h),
            _buildModeSwitch(context),
            SizedBox(height: 16.h),
            Obx(() => controller.modeIndex.value == 0
                ? _buildClientPanel(context)
                : _buildServerPanel(context)),
            SizedBox(height: 16.h),
            _buildRealtimeStats(context),
            SizedBox(height: 16.h),
            _buildLogPanel(context),
            SizedBox(height: 16.h),
            Obx(() => controller.results.isNotEmpty
                ? _buildResultsPanel(context)
                : const SizedBox.shrink()),
          ],
        ),
      ),
    );
  }

  // ── iperf3 状态 ──

  Widget _buildIperf3Status(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: Colors.green.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle_rounded,
              size: 16.w, color: Colors.green),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              '内置 iperf3 协议引擎 — 兼容标准 iperf3 客户端/服务端，无需安装',
              style: TextStyle(
                fontSize: 11.sp,
                color: Colors.green.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── 模式切换 ──

  Widget _buildModeSwitch(BuildContext context) {
    return Obx(() => SegmentedButton<int>(
          segments: const [
            ButtonSegment(
              value: 0,
              icon: Icon(Icons.upload_rounded),
              label: Text('客户端'),
            ),
            ButtonSegment(
              value: 1,
              icon: Icon(Icons.dns_rounded),
              label: Text('服务端'),
            ),
          ],
          selected: {controller.modeIndex.value},
          onSelectionChanged: (v) => controller.modeIndex.value = v.first,
        ));
  }

  // ── 客户端面板 ──

  Widget _buildClientPanel(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.send_rounded, size: 20.w, color: cs.primary),
                SizedBox(width: 8.w),
                Text('客户端模式',
                    style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            SizedBox(height: 16.h),

            TextField(
              controller: controller.hostCtrl,
              decoration: InputDecoration(
                labelText: '服务器地址',
                hintText: '例: 192.168.1.100',
                prefixIcon: const Icon(Icons.computer_rounded),
                suffixIcon: Obx(() => controller.localIps.isNotEmpty
                    ? PopupMenuButton<String>(
                        icon: const Icon(Icons.wifi_rounded),
                        tooltip: '本机 IP',
                        itemBuilder: (_) => controller.localIps
                            .map((ip) => PopupMenuItem(
                                  value: ip.split(' ').first,
                                  child:
                                      Text(ip, style: TextStyle(fontSize: 13.sp)),
                                ))
                            .toList(),
                        onSelected: (ip) => controller.hostCtrl.text = ip,
                      )
                    : const SizedBox.shrink()),
              ),
            ),
            SizedBox(height: 12.h),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller.portCtrl,
                    decoration: const InputDecoration(
                      labelText: '端口',
                      prefixIcon: Icon(Icons.lan_rounded),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: TextField(
                    controller: controller.durationCtrl,
                    decoration: const InputDecoration(
                      labelText: '时长 (秒)',
                      prefixIcon: Icon(Icons.timer_rounded),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),

            Obx(() => SegmentedButton<bool>(
                  segments: const [
                    ButtonSegment(
                      value: true,
                      icon: Icon(Icons.arrow_upward_rounded),
                      label: Text('上传'),
                    ),
                    ButtonSegment(
                      value: false,
                      icon: Icon(Icons.arrow_downward_rounded),
                      label: Text('下载'),
                    ),
                  ],
                  selected: {controller.isUpload.value},
                  onSelectionChanged: (v) =>
                      controller.isUpload.value = v.first,
                )),
            SizedBox(height: 16.h),

            Obx(() => SizedBox(
                  width: double.infinity,
                  child: controller.isTesting.value
                      ? OutlinedButton.icon(
                          onPressed: controller.cancelTest,
                          icon: const Icon(Icons.stop_rounded),
                          label: const Text('停止测试'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: cs.error,
                          ),
                        )
                      : FilledButton.icon(
                          onPressed: controller.startClientTest,
                          icon: const Icon(Icons.play_arrow_rounded),
                          label: const Text('开始测试'),
                        ),
                )),

            SizedBox(height: 8.h),
            Divider(height: 24.h),

            // 本机回环测试
            Obx(() => SizedBox(
                  width: double.infinity,
                  child: controller.isTesting.value
                      ? const SizedBox.shrink()
                      : OutlinedButton.icon(
                          onPressed: controller.runLoopbackTest,
                          icon: const Icon(Icons.loop_rounded),
                          label: const Text('本机回环测试 (自动)'),
                        ),
                )),
          ],
        ),
      ),
    );
  }

  // ── 服务端面板 ──

  Widget _buildServerPanel(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.dns_rounded, size: 20.w, color: cs.primary),
                SizedBox(width: 8.w),
                Text('服务端模式',
                    style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            SizedBox(height: 16.h),

            Obx(() {
              if (controller.localIps.isEmpty) return const SizedBox.shrink();
              return Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('本机 IP (客户端连接用)',
                        style:
                            Theme.of(context).textTheme.labelMedium?.copyWith(
                                  color: cs.onSurfaceVariant,
                                )),
                    SizedBox(height: 4.h),
                    ...controller.localIps.map((ip) => Padding(
                          padding: EdgeInsets.symmetric(vertical: 2.h),
                          child: Row(
                            children: [
                              Icon(Icons.circle,
                                  size: 6.w, color: cs.primary),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: SelectableText(
                                  ip,
                                  style: TextStyle(
                                    fontFamily: 'monospace',
                                    fontSize: 13.sp,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )),
                  ],
                ),
              );
            }),
            SizedBox(height: 12.h),

            TextField(
              controller: controller.serverPortCtrl,
              decoration: const InputDecoration(
                labelText: '监听端口',
                prefixIcon: Icon(Icons.lan_rounded),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            SizedBox(height: 12.h),

            Obx(() {
              if (!controller.isServerRunning.value) {
                return const SizedBox.shrink();
              }
              return Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: cs.primaryContainer,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  children: [
                    Icon(Icons.people_alt_rounded,
                        size: 18.w, color: cs.onPrimaryContainer),
                    SizedBox(width: 8.w),
                    Text(
                      '当前连接: ${controller.serverConnections.value}',
                      style: TextStyle(
                        color: cs.onPrimaryContainer,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    Icon(Icons.fiber_manual_record,
                        size: 10.w, color: Colors.green),
                    SizedBox(width: 4.w),
                    Text('运行中',
                        style: TextStyle(
                          color: cs.onPrimaryContainer,
                          fontSize: 12.sp,
                        )),
                  ],
                ),
              );
            }),
            SizedBox(height: 16.h),

            Obx(() => SizedBox(
                  width: double.infinity,
                  child: controller.isServerRunning.value
                      ? OutlinedButton.icon(
                          onPressed: controller.stopServer,
                          icon: const Icon(Icons.stop_rounded),
                          label: const Text('停止服务器'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: cs.error,
                          ),
                        )
                      : FilledButton.icon(
                          onPressed: controller.startServer,
                          icon: const Icon(Icons.play_arrow_rounded),
                          label: const Text('启动服务器'),
                        ),
                )),

            SizedBox(height: 12.h),
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline_rounded,
                      size: 16.w, color: cs.onSurfaceVariant),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      '启动后，其他设备的客户端可连接本机 IP 进行测速',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── 实时速率 ──

  Widget _buildRealtimeStats(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Obx(() {
      final speed = controller.currentSpeed.value;
      final bytes = controller.currentBytes.value;
      final elapsed = controller.elapsedSeconds.value;
      final progress = controller.testProgress.value;
      final status = controller.statusText.value;

      final isActive = controller.isTesting.value ||
          controller.isServerRunning.value;

      if (!isActive && speed == 0 && bytes == 0 && status.isEmpty) {
        return const SizedBox.shrink();
      }

      String speedStr;
      if (speed >= 1000) {
        speedStr = '${(speed / 1000).toStringAsFixed(2)} Gbps';
      } else {
        speedStr = '${speed.toStringAsFixed(2)} Mbps';
      }

      String bytesStr;
      if (bytes < 1048576) {
        bytesStr = '${(bytes / 1024).toStringAsFixed(1)} KB';
      } else if (bytes < 1073741824) {
        bytesStr = '${(bytes / 1048576).toStringAsFixed(1)} MB';
      } else {
        bytesStr = '${(bytes / 1073741824).toStringAsFixed(2)} GB';
      }

      return Card(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(Icons.speed_rounded, size: 20.w, color: cs.primary),
                  SizedBox(width: 8.w),
                  Text('实时速率',
                      style: Theme.of(context).textTheme.titleMedium),
                  const Spacer(),
                  if (isActive && (controller.isTesting.value ||
                      controller.serverConnections.value > 0))
                    SizedBox(
                      width: 16.w,
                      height: 16.w,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: cs.primary),
                    ),
                ],
              ),
              SizedBox(height: 16.h),

              Text(
                speedStr,
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: cs.primary,
                      fontWeight: FontWeight.bold,
                    ),
              ),

              if (status.isNotEmpty) ...[
                SizedBox(height: 4.h),
                Text(status,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: cs.onSurfaceVariant,
                        )),
              ],

              SizedBox(height: 12.h),

              if (progress > 0)
                ClipRRect(
                  borderRadius: BorderRadius.circular(4.r),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6.h,
                    backgroundColor: cs.surfaceContainerHighest,
                    valueColor: AlwaysStoppedAnimation(cs.primary),
                  ),
                ),
              SizedBox(height: 12.h),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _statChip(
                      context, Icons.data_usage_rounded, '已传输', bytesStr),
                  _statChip(context, Icons.timer_outlined, '耗时',
                      '${elapsed.toStringAsFixed(1)}s'),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _statChip(
      BuildContext context, IconData icon, String label, String value) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      children: [
        Icon(icon, size: 18.w, color: cs.onSurfaceVariant),
        SizedBox(height: 4.h),
        Text(label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: cs.onSurfaceVariant,
                )),
        Text(value,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                )),
      ],
    );
  }

  // ── 日志 ──

  Widget _buildLogPanel(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.article_outlined, size: 20.w, color: cs.primary),
                SizedBox(width: 8.w),
                Text('日志', style: Theme.of(context).textTheme.titleMedium),
                const Spacer(),
                Obx(() => Text(
                      '${controller.logs.length} 条',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                    )),
              ],
            ),
            SizedBox(height: 8.h),
            Container(
              height: 180.h,
              width: double.infinity,
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest.withOpacity(0.4),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Obx(() {
                if (controller.logs.isEmpty) {
                  return Center(
                    child: Text('暂无日志',
                        style: TextStyle(
                            color: cs.onSurfaceVariant, fontSize: 13.sp)),
                  );
                }
                return ListView.builder(
                  padding: EdgeInsets.all(8.w),
                  reverse: false,
                  itemCount: controller.logs.length,
                  itemBuilder: (_, i) => Padding(
                    padding: EdgeInsets.symmetric(vertical: 1.h),
                    child: Text(
                      controller.logs[i],
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 11.sp,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  // ── 历史结果 ──

  Widget _buildResultsPanel(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.history_rounded, size: 20.w, color: cs.primary),
                SizedBox(width: 8.w),
                Text('测试历史',
                    style: Theme.of(context).textTheme.titleMedium),
                const Spacer(),
                TextButton(
                  onPressed: controller.clearResults,
                  child: const Text('清除'),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Obx(() => Column(
                  children: controller.results
                      .take(10)
                      .map((r) => _buildResultTile(context, r))
                      .toList(),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildResultTile(BuildContext context, BandwidthResult r) {
    final cs = Theme.of(context).colorScheme;
    final time = '${r.timestamp.hour.toString().padLeft(2, '0')}:'
        '${r.timestamp.minute.toString().padLeft(2, '0')}:'
        '${r.timestamp.second.toString().padLeft(2, '0')}';

    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        children: [
          Icon(
            r.isUpload
                ? Icons.arrow_upward_rounded
                : Icons.arrow_downward_rounded,
            color: r.isUpload ? cs.tertiary : cs.primary,
            size: 20.w,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${r.host}:${r.port}',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 2.h),
                Text(
                  '${r.isUpload ? "上传" : "下载"} · '
                  '${r.formattedBytes} · '
                  '${r.duration.toStringAsFixed(1)}s',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                r.formattedSpeed,
                style: TextStyle(
                  color: cs.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 14.sp,
                ),
              ),
              Text(time,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: cs.onSurfaceVariant,
                        fontSize: 10.sp,
                      )),
            ],
          ),
        ],
      ),
    );
  }
}
