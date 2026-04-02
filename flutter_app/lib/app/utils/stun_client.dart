import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

class MappedAddress {
  final String ip;
  final int port;
  MappedAddress(this.ip, this.port);

  @override
  String toString() => '$ip:$port';

  @override
  bool operator ==(Object other) =>
      other is MappedAddress && other.ip == ip && other.port == port;

  @override
  int get hashCode => ip.hashCode ^ port.hashCode;
}

enum NatType { open, fullCone, restrictedCone, portRestricted, symmetric, unknown }

class StunTestEntry {
  final String server;
  final MappedAddress address;
  StunTestEntry(this.server, this.address);
}

class NatTestResult {
  final NatType type;
  final String label;
  final String detail;
  final List<StunTestEntry> mappings;
  final String? serverInfo;

  NatTestResult({
    required this.type,
    required this.label,
    required this.detail,
    this.mappings = const [],
    this.serverInfo,
  });
}

class StunClient {
  static const int _magicCookie = 0x2112A442;
  static const int _minServersNeeded = 2;

  static const _servers = [
    // 国内优先
    _StunServer('stun.miwifi.com', 3478),
    _StunServer('stun.chat.bilibili.com', 3478),
    _StunServer('stun.hitv.com', 3478),
    _StunServer('stun.cdnbye.com', 3478),
    // 国际备用（从用户提供的列表中选取可靠性高的）
    _StunServer('stun.nextcloud.com', 3478),
    _StunServer('stun.moonlight-stream.org', 3478),
    _StunServer('stun.freeswitch.org', 3478),
    _StunServer('stun.siptrunk.com', 3478),
    _StunServer('stun.voip.blackberry.com', 3478),
    _StunServer('stun.sonetel.com', 3478),
    _StunServer('stun.antisip.com', 3478),
    _StunServer('stun.files.fm', 3478),
    _StunServer('stun.threema.ch', 3478),
    _StunServer('stun.signalwire.com', 3478),
  ];

  /// 回调：报告当前正在测试哪个服务器
  static Future<NatTestResult> detectNatType({
    void Function(String server, String status)? onProgress,
  }) async {
    RawDatagramSocket? socket;
    try {
      socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
      final localPort = socket.port;

      // 逐个尝试，收集足够的成功结果（至少2个，尽量3个）
      final successes = <StunTestEntry>[];
      final testedServers = <String>[];

      for (final server in _servers) {
        if (successes.length >= 3) break;

        final serverName = '${server.host}:${server.port}';
        testedServers.add(serverName);
        onProgress?.call(serverName, 'testing');

        final result = await _stunQuery(socket, server.host, server.port);

        if (result != null) {
          successes.add(StunTestEntry(serverName, result));
          onProgress?.call(serverName, 'ok');
        } else {
          onProgress?.call(serverName, 'fail');
        }

        if (successes.length < 3) {
          await Future.delayed(const Duration(milliseconds: 200));
        }
      }

      socket.close();

      if (successes.isEmpty) {
        return NatTestResult(
          type: NatType.unknown,
          label: '检测失败',
          detail: '所有 STUN 服务器均无响应\n'
              '可能被防火墙或安全软件阻止了 UDP 通信\n'
              '已测试: ${testedServers.length} 个服务器',
        );
      }

      if (successes.length == 1) {
        return NatTestResult(
          type: NatType.unknown,
          label: 'NAT (部分检测)',
          detail: '仅 ${successes.first.server} 响应，需要至少2个服务器才能判断类型\n'
              '外部地址: ${successes.first.address}',
          mappings: successes,
        );
      }

      // 有至少2个成功结果，分析映射行为
      final a = successes[0];
      final b = successes[1];

      // 检查是否公网直连
      final localIps = await _getLocalIps();
      if (localIps.contains(a.address.ip)) {
        return NatTestResult(
          type: NatType.open,
          label: 'NAT1 · 开放',
          detail: '设备直接拥有公网 IP，无 NAT 转换\n'
              '最理想的网络环境，完全不影响 P2P 和游戏',
          mappings: successes,
          serverInfo: '本地端口: $localPort',
        );
      }

      final sameIp = a.address.ip == b.address.ip;
      final samePort = a.address.port == b.address.port;

      if (sameIp && samePort) {
        // 用第三个结果做交叉验证
        if (successes.length >= 3) {
          final c = successes[2];
          if (c.address.ip != a.address.ip || c.address.port != a.address.port) {
            return NatTestResult(
              type: NatType.symmetric,
              label: 'NAT4 · 对称型',
              detail: 'Symmetric NAT\n'
                  '对不同目标使用不同的外部端口映射\n'
                  'P2P 连接和部分游戏联机将受到严重影响',
              mappings: successes,
              serverInfo: '本地端口: $localPort',
            );
          }
        }
        return NatTestResult(
          type: NatType.fullCone,
          label: 'NAT1 · 全锥形',
          detail: 'Full Cone NAT (Endpoint Independent Mapping)\n'
              '所有发往同一本地端口的流量映射到同一外部端口\n'
              '对 P2P 和游戏影响最小，NAT 穿透成功率高',
          mappings: successes,
          serverInfo: '本地端口: $localPort → 外部 ${a.address}',
        );
      } else if (sameIp && !samePort) {
        return NatTestResult(
          type: NatType.portRestricted,
          label: 'NAT3 · 端口受限',
          detail: 'Port Restricted Cone / Port Dependent Mapping\n'
              '对不同端口的目标使用不同的外部端口\n'
              '部分 P2P 应用可能受影响',
          mappings: successes,
          serverInfo: '本地端口: $localPort',
        );
      } else {
        return NatTestResult(
          type: NatType.symmetric,
          label: 'NAT4 · 对称型',
          detail: 'Symmetric NAT\n'
              '对每个不同目标使用不同的外部 IP:Port\n'
              '这是最严格的 NAT 类型，P2P 和游戏联机将受到严重影响',
          mappings: successes,
          serverInfo: '本地端口: $localPort',
        );
      }
    } catch (e) {
      socket?.close();
      return NatTestResult(
        type: NatType.unknown,
        label: '检测失败',
        detail: '${e.runtimeType}: $e',
      );
    }
  }

  static Future<List<String>> _getLocalIps() async {
    try {
      final interfaces = await NetworkInterface.list(
        type: InternetAddressType.IPv4,
        includeLoopback: false,
      );
      return interfaces
          .expand((i) => i.addresses)
          .map((a) => a.address)
          .toList();
    } catch (_) {
      return [];
    }
  }

  static Future<MappedAddress?> _stunQuery(
    RawDatagramSocket socket, String host, int port,
  ) async {
    try {
      final addrs = await InternetAddress.lookup(host)
          .timeout(const Duration(seconds: 3));
      if (addrs.isEmpty) return null;

      final txId = Uint8List.fromList(
        List.generate(12, (_) => Random.secure().nextInt(256)),
      );
      final request = _buildBindingRequest(txId);

      for (int attempt = 0; attempt < 2; attempt++) {
        socket.send(request, addrs.first, port);

        for (int i = 0; i < 30; i++) {
          await Future.delayed(const Duration(milliseconds: 50));

          Datagram? dg;
          while ((dg = socket.receive()) != null) {
            if (dg!.data.length >= 20) {
              final result = _parseResponse(dg.data, txId);
              if (result != null) return result;
            }
          }
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  static Uint8List _buildBindingRequest(Uint8List txId) {
    final data = ByteData(20);
    data.setUint16(0, 0x0001);
    data.setUint16(2, 0x0000);
    data.setUint32(4, _magicCookie);
    for (int i = 0; i < 12; i++) {
      data.setUint8(8 + i, txId[i]);
    }
    return data.buffer.asUint8List();
  }

  static MappedAddress? _parseResponse(Uint8List data, Uint8List txId) {
    if (data.length < 20) return null;
    final view = ByteData.sublistView(data);

    if (view.getUint16(0) != 0x0101) return null;
    if (view.getUint32(4) != _magicCookie) return null;
    for (int i = 0; i < 12; i++) {
      if (data[8 + i] != txId[i]) return null;
    }

    final msgLen = view.getUint16(2);
    int offset = 20;

    while (offset + 4 <= data.length && offset < 20 + msgLen) {
      final attrType = view.getUint16(offset);
      final attrLen = view.getUint16(offset + 2);

      if (offset + 4 + attrLen > data.length) break;

      if (attrType == 0x0020) {
        return _parseXorMappedAddress(view, offset + 4, attrLen);
      }
      if (attrType == 0x0001) {
        return _parseMappedAddress(view, offset + 4, attrLen);
      }

      offset += 4 + ((attrLen + 3) & ~3);
    }
    return null;
  }

  static MappedAddress? _parseXorMappedAddress(ByteData view, int offset, int length) {
    if (length < 8) return null;
    if (view.getUint8(offset + 1) != 0x01) return null;

    final xPort = view.getUint16(offset + 2);
    final port = xPort ^ (_magicCookie >> 16);

    final xAddr = view.getUint32(offset + 4);
    final addr = xAddr ^ _magicCookie;

    final ip = '${(addr >> 24) & 0xFF}.${(addr >> 16) & 0xFF}'
        '.${(addr >> 8) & 0xFF}.${addr & 0xFF}';

    return MappedAddress(ip, port);
  }

  static MappedAddress? _parseMappedAddress(ByteData view, int offset, int length) {
    if (length < 8) return null;
    if (view.getUint8(offset + 1) != 0x01) return null;

    final port = view.getUint16(offset + 2);
    final addr = view.getUint32(offset + 4);

    final ip = '${(addr >> 24) & 0xFF}.${(addr >> 16) & 0xFF}'
        '.${(addr >> 8) & 0xFF}.${addr & 0xFF}';

    return MappedAddress(ip, port);
  }
}

class _StunServer {
  final String host;
  final int port;
  const _StunServer(this.host, this.port);
}
