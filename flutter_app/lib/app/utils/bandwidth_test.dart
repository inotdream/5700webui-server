import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

typedef BwStatsCallback = void Function(double mbps, int bytes, double seconds);
typedef BwLogCallback = void Function(String message);

// ════════════════════════════════════════════
//  BandwidthResult
// ════════════════════════════════════════════

class BandwidthResult {
  final double mbps;
  final int totalBytes;
  final double duration;
  final bool isUpload;
  final String host;
  final int port;
  final DateTime timestamp;

  BandwidthResult({
    required this.mbps,
    required this.totalBytes,
    required this.duration,
    required this.isUpload,
    required this.host,
    required this.port,
    required this.timestamp,
  });

  String get formattedSpeed {
    if (mbps >= 1000) return '${(mbps / 1000).toStringAsFixed(2)} Gbps';
    return '${mbps.toStringAsFixed(2)} Mbps';
  }

  String get formattedBytes {
    if (totalBytes < 1024) return '$totalBytes B';
    if (totalBytes < 1048576) {
      return '${(totalBytes / 1024).toStringAsFixed(1)} KB';
    }
    if (totalBytes < 1073741824) {
      return '${(totalBytes / 1048576).toStringAsFixed(1)} MB';
    }
    return '${(totalBytes / 1073741824).toStringAsFixed(2)} GB';
  }
}

// ════════════════════════════════════════════
//  iperf3 协议常量
// ════════════════════════════════════════════

class _Proto {
  static const cookieSize = 37;
  static const defaultBlkSize = 131072;

  static const paramExchange = 9;
  static const createStreams = 10;
  static const testStart = 1;
  static const testRunning = 2;
  static const testEnd = 4;
  static const exchangeResults = 13;
  static const displayResults = 14;
  static const iperfDone = 16;

  static String makeCookie() {
    final r = Random.secure();
    return String.fromCharCodes(
        List.generate(cookieSize - 1, (_) => r.nextInt(26) + 97));
  }
}

// ════════════════════════════════════════════
//  _StreamReader – 带缓冲的 socket 读取器
// ════════════════════════════════════════════

class _StreamReader {
  final Socket socket;
  final _buf = <int>[];
  late StreamSubscription<Uint8List> _sub;
  Completer<void>? _waiter;
  bool done = false;
  int totalRead = 0;
  bool _countOnly = false;

  _StreamReader(this.socket) {
    _sub = socket.listen(
      (data) {
        totalRead += data.length;
        if (!_countOnly) _buf.addAll(data);
        _waiter?.complete();
        _waiter = null;
      },
      onDone: () {
        done = true;
        _waiter?.complete();
        _waiter = null;
      },
      onError: (_) {
        done = true;
        _waiter?.complete();
        _waiter = null;
      },
    );
  }

  void switchToCountOnly() {
    _countOnly = true;
    _buf.clear();
  }

  Future<Uint8List?> read(int n, {Duration? timeout}) async {
    if (_countOnly) return null;
    final deadline = timeout != null ? DateTime.now().add(timeout) : null;
    while (_buf.length < n && !done) {
      _waiter = Completer<void>();
      try {
        if (deadline != null) {
          final rem = deadline.difference(DateTime.now());
          if (rem.isNegative) return null;
          await _waiter!.future.timeout(rem, onTimeout: () {});
        } else {
          await _waiter!.future;
        }
      } catch (_) {
        return null;
      }
    }
    if (_buf.length < n) return null;
    final out = Uint8List.fromList(_buf.sublist(0, n));
    _buf.removeRange(0, n);
    return out;
  }

  Future<int?> readSignedByte({Duration? timeout}) async {
    final d = await read(1, timeout: timeout);
    if (d == null) return null;
    return d[0] > 127 ? d[0] - 256 : d[0];
  }

  Future<Map<String, dynamic>?> readJson({Duration? timeout}) async {
    final lb = await read(4, timeout: timeout);
    if (lb == null) return null;
    final len = ByteData.sublistView(lb).getUint32(0, Endian.big);
    if (len == 0 || len > 10 * 1024 * 1024) return null;
    final jb = await read(len, timeout: timeout);
    if (jb == null) return null;
    try {
      return jsonDecode(utf8.decode(jb)) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  void dispose() {
    _sub.cancel();
  }
}

// ════════════════════════════════════════════
//  Socket 写入辅助
// ════════════════════════════════════════════

Future<void> _sendState(Socket s, int state) async {
  s.add([state & 0xFF]);
  await s.flush();
}

Future<void> _sendJson(Socket s, Map<String, dynamic> data) async {
  final bytes = utf8.encode(jsonEncode(data));
  final hdr = ByteData(4)..setUint32(0, bytes.length, Endian.big);
  s.add(hdr.buffer.asUint8List());
  s.add(bytes);
  await s.flush();
}

// ════════════════════════════════════════════
//  Iperf3Server – iperf3 v3.x 协议兼容服务端
// ════════════════════════════════════════════

class Iperf3Server {
  ServerSocket? _serverSocket;
  bool _running = false;
  bool _busy = false;

  String? _cookie;
  Socket? _ctrlSocket;
  _StreamReader? _ctrlReader;
  Socket? _dataSocket;
  _StreamReader? _dataReader;
  Map<String, dynamic>? _params;

  BwLogCallback? onLog;
  BwStatsCallback? onStats;
  void Function(int)? onConnectionCount;

  bool get isRunning => _running;

  Future<bool> start(int port) async {
    try {
      _serverSocket = await ServerSocket.bind(InternetAddress.anyIPv4, port);
      _running = true;
      onLog?.call('iperf3 服务器启动，端口 $port');
      _serverSocket!.listen(
        _onConnection,
        onError: (e) => onLog?.call('错误: $e'),
        onDone: () {
          if (_running) onLog?.call('服务器关闭');
        },
      );
      return true;
    } catch (e) {
      onLog?.call('启动失败: $e');
      return false;
    }
  }

  Future<void> stop() async {
    _running = false;
    _cleanup();
    await _serverSocket?.close();
    _serverSocket = null;
    onLog?.call('服务器已停止');
    onConnectionCount?.call(0);
  }

  void _cleanup() {
    _ctrlReader?.dispose();
    _dataReader?.dispose();
    try { _ctrlSocket?.destroy(); } catch (_) {}
    try { _dataSocket?.destroy(); } catch (_) {}
    _ctrlSocket = null;
    _ctrlReader = null;
    _dataSocket = null;
    _dataReader = null;
    _cookie = null;
    _params = null;
    _busy = false;
    onConnectionCount?.call(0);
  }

  void _onConnection(Socket socket) {
    if (!_running) {
      socket.destroy();
      return;
    }

    if (!_busy) {
      _busy = true;
      _handleControl(socket);
    } else if (_cookie != null && _dataSocket == null) {
      _handleData(socket);
    } else {
      onLog?.call('忙碌中，拒绝额外连接');
      socket.destroy();
    }
  }

  Future<void> _handleControl(Socket ctrl) async {
    final addr = '${ctrl.remoteAddress.address}:${ctrl.remotePort}';
    onLog?.call('控制连接: $addr');
    _ctrlSocket = ctrl;
    _ctrlReader = _StreamReader(ctrl);

    try {
      final cookieBytes = await _ctrlReader!.read(
          _Proto.cookieSize, timeout: const Duration(seconds: 10));
      if (cookieBytes == null) {
        onLog?.call('cookie 读取失败');
        _cleanup();
        return;
      }
      int end = cookieBytes.indexOf(0);
      if (end < 0) end = cookieBytes.length;
      _cookie = utf8.decode(cookieBytes.sublist(0, end));
      onLog?.call('收到 cookie (${_cookie!.length} chars)');

      await _sendState(ctrl, _Proto.paramExchange);

      _params = await _ctrlReader!.readJson(
          timeout: const Duration(seconds: 30));
      if (_params == null) {
        onLog?.call('参数读取失败');
        _cleanup();
        return;
      }

      final duration = _params!['time'] as int? ?? 10;
      final reverse = _params!['reverse'] == true;
      final blkSize = _params!['len'] as int? ?? _Proto.defaultBlkSize;
      onLog?.call('参数: ${duration}s, ${reverse ? "反向(下载)" : "正向(上传)"}, blk=$blkSize');

      await _sendState(ctrl, _Proto.createStreams);

      for (int i = 0; i < 100 && _dataSocket == null && _running; i++) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
      if (_dataSocket == null) {
        onLog?.call('等待数据连接超时');
        _cleanup();
        return;
      }

      onConnectionCount?.call(1);

      await _sendState(ctrl, _Proto.testStart);
      await _sendState(ctrl, _Proto.testRunning);

      final sw = Stopwatch()..start();
      // 用列表包装实现可变引用，解决反向模式下 stats 无法实时读取的问题
      final liveBytes = [0];
      int lastBytes = 0;
      int lastMs = 0;
      final statsTimer =
          Timer.periodic(const Duration(milliseconds: 500), (_) {
        try {
          final nowMs = sw.elapsedMilliseconds;
          final elapsed = nowMs / 1000.0;
          final dtSec = (nowMs - lastMs) / 1000.0;
          int nowBytes = reverse
              ? liveBytes[0]
              : (_dataReader!.totalRead - _Proto.cookieSize).clamp(0, 1 << 62);
          final interval = nowBytes - lastBytes;
          final mbps = dtSec > 0 && interval > 0
              ? (interval * 8) / (dtSec * 1000000)
              : 0.0;
          lastBytes = nowBytes;
          lastMs = nowMs;
          onStats?.call(mbps, nowBytes, elapsed);
        } catch (_) {}
      });

      int totalBytes;
      if (reverse) {
        totalBytes = await _serverSendData(
            _dataSocket!, duration, blkSize, _ctrlReader!, liveBytes);
      } else {
        await _serverReceiveData(duration, _ctrlReader!);
        totalBytes = (_dataReader!.totalRead - _Proto.cookieSize).clamp(0, 1 << 62);
      }

      sw.stop();
      statsTimer.cancel();

      final elapsed = sw.elapsedMilliseconds / 1000.0;
      final avgMbps = elapsed > 0 ? (totalBytes * 8) / (elapsed * 1000000) : 0.0;
      onLog?.call('完成: ${BandwidthResult(
        mbps: avgMbps, totalBytes: totalBytes, duration: elapsed,
        isUpload: !reverse, host: addr, port: 0, timestamp: DateTime.now(),
      ).formattedBytes}, ${avgMbps.toStringAsFixed(2)} Mbps');
      onStats?.call(avgMbps, totalBytes, elapsed);

      await _sendState(ctrl, _Proto.exchangeResults);
      await _ctrlReader!.readJson(timeout: const Duration(seconds: 5));
      await _sendJson(ctrl, _buildServerResults(totalBytes, elapsed));

      await _sendState(ctrl, _Proto.displayResults);
      await _ctrlReader!.readJson(timeout: const Duration(seconds: 5));
      await _sendJson(ctrl, {'server_output_text': ''});

      await _sendState(ctrl, _Proto.iperfDone);
      await Future.delayed(const Duration(milliseconds: 200));
    } catch (e) {
      onLog?.call('错误: $e');
    } finally {
      _cleanup();
    }
  }

  Future<void> _handleData(Socket data) async {
    _dataReader = _StreamReader(data);
    final cookieBytes = await _dataReader!.read(
        _Proto.cookieSize, timeout: const Duration(seconds: 5));
    if (cookieBytes == null) {
      onLog?.call('数据连接: cookie 读取失败');
      _dataReader?.dispose();
      _dataReader = null;
      data.destroy();
      return;
    }

    int end = cookieBytes.indexOf(0);
    if (end < 0) end = cookieBytes.length;
    final receivedCookie = utf8.decode(cookieBytes.sublist(0, end));

    if (receivedCookie != _cookie) {
      onLog?.call('数据连接: cookie 不匹配');
      _dataReader?.dispose();
      _dataReader = null;
      data.destroy();
      return;
    }

    _dataReader!.switchToCountOnly();
    _dataSocket = data;
    onLog?.call('数据流已建立');
  }

  Future<int> _serverSendData(
    Socket data,
    int duration,
    int blkSize,
    _StreamReader ctrlReader,
    List<int> liveBytes,
  ) async {
    final buf = Uint8List(blkSize);
    int total = 0;
    bool testDone = false;

    unawaited(ctrlReader
        .readSignedByte(timeout: Duration(seconds: duration + 30))
        .then((_) => testDone = true));

    final deadline = Duration(seconds: duration + 2);
    final sw = Stopwatch()..start();
    while (!testDone && sw.elapsed < deadline) {
      try {
        data.add(buf);
        total += buf.length;
        liveBytes[0] = total;
        if (total % (blkSize * 4) == 0) {
          await data.flush();
          await Future.delayed(Duration.zero);
        }
      } catch (_) {
        break;
      }
    }
    try { await data.flush(); } catch (_) {}
    return total;
  }

  Future<void> _serverReceiveData(int duration, _StreamReader ctrlReader) async {
    bool testDone = false;
    unawaited(ctrlReader
        .readSignedByte(timeout: Duration(seconds: duration + 30))
        .then((_) => testDone = true));

    final deadline = Duration(seconds: duration + 5);
    final sw = Stopwatch()..start();
    while (!testDone && sw.elapsed < deadline) {
      await Future.delayed(const Duration(milliseconds: 200));
    }
  }

  Map<String, dynamic> _buildServerResults(int bytes, double elapsed) {
    return {
      'cpu_util_total': 0.0,
      'cpu_util_user': 0.0,
      'cpu_util_system': 0.0,
      'sender_has_retransmits': -1,
      'congestion_used': 'cubic',
      'streams': [
        {
          'id': 1,
          'bytes': bytes,
          'retransmits': -1,
          'jitter': 0,
          'errors': 0,
          'packets': 0,
          'start_time': 0,
          'end_time': elapsed,
        }
      ],
    };
  }
}

// ════════════════════════════════════════════
//  Iperf3Client – iperf3 v3.x 协议兼容客户端
// ════════════════════════════════════════════

class Iperf3Client {
  BwLogCallback? onLog;
  BwStatsCallback? onStats;
  bool _cancelled = false;

  void cancel() => _cancelled = true;

  Future<BandwidthResult?> runTest({
    required String host,
    required int port,
    required int duration,
    required bool upload,
  }) async {
    _cancelled = false;
    Socket? ctrl;
    Socket? data;
    _StreamReader? ctrlReader;
    _StreamReader? dataReader;

    try {
      onLog?.call('连接 $host:$port ...');
      ctrl = await Socket.connect(host, port,
          timeout: const Duration(seconds: 10));
      ctrlReader = _StreamReader(ctrl);

      final cookie = _Proto.makeCookie();
      final cookieSendBuf = Uint8List(_Proto.cookieSize);
      cookieSendBuf.setRange(0, cookie.length, utf8.encode(cookie));
      ctrl.add(cookieSendBuf);
      await ctrl.flush();
      onLog?.call('已连接，发送 cookie');

      var state = await ctrlReader.readSignedByte(
          timeout: const Duration(seconds: 10));
      if (state != _Proto.paramExchange) {
        onLog?.call('协议错误: 期望 PARAM_EXCHANGE(${_Proto.paramExchange}), 收到 $state');
        return null;
      }

      final blkSize = _Proto.defaultBlkSize;
      final params = <String, dynamic>{
        'tcp': true,
        'omit': 0,
        'time': duration,
        'num': 0,
        'blockcount': 0,
        'MSS': 0,
        'nodelay': false,
        'parallel': 1,
        'bidirectional': false,
        'window': 0,
        'len': blkSize,
        'bandwidth': 0,
        'fqrate': 0,
        'pacing_timer': 1000,
        'burst': 0,
        'TOS': 0,
        'flowlabel': 0,
        'title': '',
        'extra_data': '',
        'congestion': '',
        'congestion_used': '',
        'get_server_output': false,
        'udp_counters_64bit': true,
        'repeating_payload': false,
        'zerocopy': false,
        'dont_fragment': false,
      };
      if (!upload) params['reverse'] = true;
      await _sendJson(ctrl, params);

      state = await ctrlReader.readSignedByte(
          timeout: const Duration(seconds: 10));
      if (state != _Proto.createStreams) {
        onLog?.call('协议错误: 期望 CREATE_STREAMS, 收到 $state');
        return null;
      }

      data = await Socket.connect(host, port,
          timeout: const Duration(seconds: 10));
      final dataCookieBuf = Uint8List(_Proto.cookieSize);
      dataCookieBuf.setRange(0, cookie.length, utf8.encode(cookie));
      data.add(dataCookieBuf);
      await data.flush();
      dataReader = _StreamReader(data);
      onLog?.call('数据流已建立');

      state = await ctrlReader.readSignedByte(
          timeout: const Duration(seconds: 10));
      if (state != _Proto.testStart) {
        onLog?.call('协议错误: 期望 TEST_START, 收到 $state');
        return null;
      }

      state = await ctrlReader.readSignedByte(
          timeout: const Duration(seconds: 10));
      if (state != _Proto.testRunning) {
        onLog?.call('协议错误: 期望 TEST_RUNNING, 收到 $state');
        return null;
      }

      onLog?.call('开始${upload ? "上传" : "下载"}测试 (${duration}s)...');

      // 先 switchToCountOnly，再启动计时和统计
      dataReader.switchToCountOnly();

      final sw = Stopwatch()..start();
      int totalBytes = 0;
      int lastBytes = 0;
      int lastMs = 0;

      // 用实际时间间隔而非假设 500ms 来计算速率
      final _dr = dataReader; // 非空引用给定时器闭包
      final statsTimer =
          Timer.periodic(const Duration(milliseconds: 500), (_) {
        try {
          final nowMs = sw.elapsedMilliseconds;
          final elapsed = nowMs / 1000.0;
          final dtSec = (nowMs - lastMs) / 1000.0;
          int nowBytes = upload ? totalBytes : _dr.totalRead;
          final interval = nowBytes - lastBytes;
          final mbps = dtSec > 0 && interval > 0
              ? (interval * 8) / (dtSec * 1000000)
              : 0.0;
          lastBytes = nowBytes;
          lastMs = nowMs;
          onStats?.call(mbps, nowBytes, elapsed);
        } catch (_) {}
      });

      if (upload) {
        final buf = Uint8List(blkSize);
        final deadline = Duration(seconds: duration);
        while (sw.elapsed < deadline && !_cancelled) {
          try {
            data.add(buf);
            totalBytes += buf.length;
            if (totalBytes % (blkSize * 16) == 0) {
              await data.flush();
              await Future.delayed(Duration.zero);
            }
          } catch (_) {
            break;
          }
        }
        try { await data.flush(); } catch (_) {}
      } else {
        final deadline = Duration(seconds: duration);
        while (sw.elapsed < deadline && !_cancelled) {
          await Future.delayed(const Duration(milliseconds: 100));
        }
        totalBytes = _dr.totalRead;
      }

      sw.stop();
      statsTimer.cancel();

      final elapsed = sw.elapsedMilliseconds / 1000.0;
      if (!upload) totalBytes = _dr.totalRead;
      final avgMbps = elapsed > 0 ? (totalBytes * 8) / (elapsed * 1000000) : 0.0;

      // 发送最终统计
      onStats?.call(avgMbps, totalBytes, elapsed);

      await _sendState(ctrl, _Proto.testEnd);

      state = await ctrlReader.readSignedByte(
          timeout: const Duration(seconds: 10));
      if (state == _Proto.exchangeResults) {
        await _sendJson(ctrl, {
          'cpu_util_total': 0.0,
          'cpu_util_user': 0.0,
          'cpu_util_system': 0.0,
          'sender_has_retransmits': -1,
          'congestion_used': 'cubic',
          'streams': [
            {
              'id': 1,
              'bytes': totalBytes,
              'retransmits': -1,
              'jitter': 0,
              'errors': 0,
              'packets': 0,
              'start_time': 0,
              'end_time': elapsed,
            }
          ],
        });
        await ctrlReader.readJson(timeout: const Duration(seconds: 5));
      }

      state = await ctrlReader.readSignedByte(
          timeout: const Duration(seconds: 10));
      if (state == _Proto.displayResults) {
        await _sendJson(ctrl, {'server_output_text': ''});
        await ctrlReader.readJson(timeout: const Duration(seconds: 5));
      }

      await ctrlReader.readSignedByte(timeout: const Duration(seconds: 5));

      final result = BandwidthResult(
        mbps: avgMbps,
        totalBytes: totalBytes,
        duration: elapsed,
        isUpload: upload,
        host: host,
        port: port,
        timestamp: DateTime.now(),
      );

      onLog?.call('完成: ${result.formattedBytes}, ${result.formattedSpeed}');
      return result;
    } catch (e) {
      onLog?.call('错误: $e');
      return null;
    } finally {
      ctrlReader?.dispose();
      dataReader?.dispose();
      try { data?.destroy(); } catch (_) {}
      try { ctrl?.destroy(); } catch (_) {}
    }
  }
}
