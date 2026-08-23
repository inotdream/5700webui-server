import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:get/get.dart';
import '../../../utils/stun_client.dart';

class NetworkController extends GetxController {
  final isLoading = false.obs;
  final isTestingNat = false.obs;
  final isTestingConnectivity = false.obs;

  // 出口 IP 信息
  final publicIp = ''.obs;
  final isp = ''.obs;
  final org = ''.obs;
  final asNumber = ''.obs;
  final country = ''.obs;
  final city = ''.obs;
  final region = ''.obs;
  final timezone = ''.obs;
  final ipInfoError = ''.obs;

  // 本地 IP
  final localIps = <String>[].obs;

  // STUN NAT 检测
  final natResult = Rxn<NatTestResult>();
  final stunProgress = ''.obs;

  // 连通性测试
  final connectivityResults = <ConnectivityResult>[].obs;

  static const _testTargets = [
    _TestTarget('GitHub API', 'https://api.github.com', 'GitHub 接口连通'),
    _TestTarget('GitHub Raw', 'https://raw.githubusercontent.com', 'GitHub 原始内容'),
    _TestTarget('Cloudflare', 'https://1.1.1.1/cdn-cgi/trace', 'Cloudflare CDN'),
    _TestTarget('Google', 'https://www.google.com/generate_204', 'Google 连通性'),
    _TestTarget('百度', 'https://www.baidu.com', '百度搜索'),
    _TestTarget('阿里云', 'https://www.aliyun.com', '阿里云'),
  ];

  @override
  void onInit() {
    super.onInit();
    runAllTests();
  }

  Future<void> runAllTests() async {
    isLoading.value = true;
    ipInfoError.value = '';
    natResult.value = null;
    connectivityResults.clear();

    await Future.wait([
      fetchPublicIpInfo(),
      fetchLocalIps(),
      detectNatType(),
    ]);

    await testConnectivity();
    isLoading.value = false;
  }

  Future<void> fetchPublicIpInfo() async {
    final client = HttpClient();
    try {
      client.connectionTimeout = const Duration(seconds: 10);
      final request = await client.getUrl(Uri.parse(
        'http://ip-api.com/json/?lang=zh-CN&fields=status,message,query,isp,org,as,country,regionName,city,timezone',
      ));
      final response = await request.close();
      final body = await response.transform(utf8.decoder).join();
      final data = jsonDecode(body) as Map<String, dynamic>;

      if (data['status'] == 'success') {
        publicIp.value = data['query'] ?? '';
        isp.value = data['isp'] ?? '';
        org.value = data['org'] ?? '';
        asNumber.value = data['as'] ?? '';
        country.value = data['country'] ?? '';
        city.value = data['city'] ?? '';
        region.value = data['regionName'] ?? '';
        timezone.value = data['timezone'] ?? '';
      } else {
        ipInfoError.value = data['message'] ?? '获取失败';
      }
    } catch (e) {
      ipInfoError.value = '网络请求失败';
    } finally {
      client.close(force: true);
    }
  }

  Future<void> fetchLocalIps() async {
    try {
      final interfaces = await NetworkInterface.list(
        type: InternetAddressType.IPv4,
        includeLoopback: false,
      );
      localIps.value = interfaces
          .expand((iface) => iface.addresses)
          .map((addr) => addr.address)
          .toList();
    } catch (_) {
      localIps.value = ['获取失败'];
    }
  }

  Future<void> detectNatType() async {
    isTestingNat.value = true;
    natResult.value = null;
    stunProgress.value = '';

    try {
      final result = await StunClient.detectNatType(
        onProgress: (server, status) {
          final icon = status == 'testing' ? '🔍' : status == 'ok' ? '✅' : '❌';
          stunProgress.value = '$icon $server';
        },
      );
      natResult.value = result;
    } catch (e) {
      natResult.value = NatTestResult(
        type: NatType.unknown,
        label: '检测失败',
        detail: e.toString(),
      );
    }

    stunProgress.value = '';
    isTestingNat.value = false;
  }

  Future<void> testConnectivity() async {
    isTestingConnectivity.value = true;
    connectivityResults.clear();

    for (final target in _testTargets) {
      connectivityResults.add(ConnectivityResult(
        name: target.name,
        description: target.description,
        status: TestStatus.testing,
      ));
    }

    final futures = <Future>[];
    for (int i = 0; i < _testTargets.length; i++) {
      futures.add(_testSingleTarget(_testTargets[i], i));
    }
    await Future.wait(futures);

    isTestingConnectivity.value = false;
  }

  Future<void> _testSingleTarget(_TestTarget target, int index) async {
    final stopwatch = Stopwatch()..start();
    final client = HttpClient();
    try {
      client.connectionTimeout = const Duration(seconds: 8);
      final request = await client.getUrl(Uri.parse(target.url));
      final response = await request.close();
      await response.drain();
      stopwatch.stop();

      connectivityResults[index] = ConnectivityResult(
        name: target.name,
        description: target.description,
        status: (response.statusCode >= 200 && response.statusCode < 400)
            ? TestStatus.success
            : TestStatus.warning,
        latencyMs: stopwatch.elapsedMilliseconds,
        statusCode: response.statusCode,
      );
    } catch (e) {
      stopwatch.stop();
      connectivityResults[index] = ConnectivityResult(
        name: target.name,
        description: target.description,
        status: TestStatus.failed,
        error: _formatError(e),
      );
    } finally {
      client.close(force: true);
    }
  }

  String _formatError(dynamic e) {
    if (e is SocketException) return '连接超时';
    if (e is HandshakeException) return 'TLS握手失败';
    if (e is HttpException) return 'HTTP错误';
    return '连接失败';
  }
}

class _TestTarget {
  final String name;
  final String url;
  final String description;
  const _TestTarget(this.name, this.url, this.description);
}

enum TestStatus { testing, success, warning, failed }

class ConnectivityResult {
  final String name;
  final String description;
  final TestStatus status;
  final int? latencyMs;
  final int? statusCode;
  final String? error;

  ConnectivityResult({
    required this.name,
    required this.description,
    required this.status,
    this.latencyMs,
    this.statusCode,
    this.error,
  });
}
