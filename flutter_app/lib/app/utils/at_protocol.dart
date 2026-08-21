/// AT 行组装与终态/URC 判定，独立于 Socket，便于单测。
class AtLineAssembler {
  final StringBuffer _pending = StringBuffer();

  /// 喂入原始文本，返回已凑齐的行（不含行尾）。
  List<String> add(String chunk) {
    if (chunk.isEmpty) return const [];
    _pending.write(chunk);
    final text = _pending.toString().replaceAll('\r\n', '\n').replaceAll('\r', '\n');
    final lines = <String>[];
    var start = 0;
    for (var i = 0; i < text.length; i++) {
      if (text.codeUnitAt(i) == 0x0A) {
        lines.add(text.substring(start, i));
        start = i + 1;
      }
    }
    _pending
      ..clear()
      ..write(start < text.length ? text.substring(start) : '');
    return lines;
  }

  String get leftover => _pending.toString();

  bool get hasSmsPrompt {
    final t = leftover.trim();
    return t == '>';
  }

  void clear() => _pending.clear();

  /// 防止畸形数据撑爆内存。
  bool get isOverflowed => _pending.length > 8192;
}

class AtFrameParser {
  AtFrameParser._();

  static bool isFinalResultLine(String line) {
    final t = line.trim();
    if (t == 'OK' || t == 'ERROR' || t == '>') return true;
    return t.startsWith('+CME ERROR') || t.startsWith('+CMS ERROR');
  }

  /// 可与命令响应交错、需要立刻上抛的主动上报。
  static bool isInterleavedUrc(String line) {
    final t = line.trim();
    if (t == 'RING' || t == 'NO CARRIER') return true;
    return t.startsWith('+CMTI:') ||
        t.startsWith('+CLIP:') ||
        t.startsWith('^CEND:') ||
        t.startsWith('^HCSQ:') ||
        t.startsWith('^CERSSI:');
  }
}
