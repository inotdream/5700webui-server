import '../data/models/sms_model.dart';

/// 编码后的SMS-SUBMIT PDU
class SubmitPdu {
  /// 完整PDU十六进制串（含SMSC字段）
  final String pdu;

  /// TPDU字节数（`AT+CMGS=<length>` 使用，不含SMSC字段）
  final int tpduLength;

  const SubmitPdu(this.pdu, this.tpduLength);
}

/// SMS PDU 编解码（3GPP TS 23.040）
/// 支持 SMS-DELIVER 解码（收短信）与 SMS-SUBMIT 编码（发短信），
/// 字符集支持 GSM 7-bit 默认字母表与 UCS2。
class PduCodec {
  PduCodec._();

  // GSM 7-bit 默认字母表（0x00-0x7F），0x1B为扩展表转义符
  static const String _gsm7Table =
      '@£\$¥èéùìòÇ\nØø\rÅåΔ_ΦΓΛΩΠΨΣΘΞ\u001BÆæßÉ !"#¤%&\'()*+,-./'
      '0123456789:;<=>?¡ABCDEFGHIJKLMNOPQRSTUVWXYZÄÖÑÜ§¿abcdefghijklmnopqrstuvwxyzäöñüà';

  // 扩展表（0x1B转义后的字符）
  static const Map<int, String> _gsm7Extension = {
    0x14: '^',
    0x28: '{',
    0x29: '}',
    0x2F: '\\',
    0x3C: '[',
    0x3D: '~',
    0x3E: ']',
    0x40: '|',
    0x65: '€',
  };

  // ==================== 解码 ====================

  /// 解析 AT+CMGL（PDU模式）完整响应。
  /// 格式为 +CMGL: <index>,<stat>,[<alpha>],<length> 后跟一行PDU数据。
  static List<SmsModel> parseCmglResponse(String response) {
    final result = <SmsModel>[];
    final lines = response.split(RegExp(r'\r?\n'));

    for (var i = 0; i < lines.length; i++) {
      final match = RegExp(r'^\+CMGL:\s*(\d+)').firstMatch(lines[i].trim());
      if (match == null) continue;

      final index = int.parse(match.group(1)!);
      for (var j = i + 1; j < lines.length; j++) {
        final pduLine = lines[j].trim();
        if (pduLine.isEmpty) continue;
        final sms = decodeDeliver(pduLine, index: index);
        if (sms != null) result.add(sms);
        i = j;
        break;
      }
    }
    return result;
  }

  /// 解析 AT+CMGR（PDU模式）响应：+CMGR: <stat>,[<alpha>],<length> 后跟PDU数据行
  static SmsModel? parseCmgrResponse(String response, {int? index}) {
    final lines = response.split(RegExp(r'\r?\n'));
    for (var i = 0; i < lines.length; i++) {
      if (!lines[i].trim().startsWith('+CMGR:')) continue;
      for (var j = i + 1; j < lines.length; j++) {
        final pduLine = lines[j].trim();
        if (pduLine.isEmpty) continue;
        return decodeDeliver(pduLine, index: index);
      }
    }
    return null;
  }

  /// 解码 SMS-DELIVER PDU，失败返回 null
  static SmsModel? decodeDeliver(String pduHex, {int? index}) {
    try {
      final reader = _PduReader(pduHex);

      // SMSC信息：1字节长度 + 内容
      final smscLength = reader.octet();
      reader.skip(smscLength);

      final firstOctet = reader.octet();
      if ((firstOctet & 0x03) != 0x00) return null; // 仅处理SMS-DELIVER
      final hasUdh = (firstOctet & 0x40) != 0;

      // 发送方地址：长度为数字个数
      final addressDigits = reader.octet();
      final addressType = reader.octet();
      final addressOctets = (addressDigits + 1) ~/ 2;
      String sender;
      if ((addressType & 0x70) == 0x50) {
        // 字母数字地址，GSM 7-bit编码
        sender = _unpackGsm7(
            reader.bytes(addressOctets), addressDigits * 4 ~/ 7);
      } else {
        sender = _decodeSemiOctets(reader.bytes(addressOctets), addressDigits);
        if ((addressType & 0x70) == 0x10) sender = '+$sender';
      }

      reader.octet(); // TP-PID
      final dcs = reader.octet();
      final timestamp = _decodeTimestamp(reader.bytes(7));
      final udl = reader.octet();
      final udBytes = reader.remaining();

      // 数据编码方案：一般数据编码时 bit3-2 为字符集
      final isUcs2 = (dcs & 0x0C) == 0x08;
      final is8bit = (dcs & 0x0C) == 0x04;

      String content;
      if (isUcs2) {
        var offset = 0;
        if (hasUdh && udBytes.isNotEmpty) {
          offset = 1 + udBytes[0]; // 跳过UDH
        }
        final codeUnits = <int>[];
        for (var i = offset; i + 1 < udBytes.length; i += 2) {
          codeUnits.add((udBytes[i] << 8) | udBytes[i + 1]);
        }
        content = String.fromCharCodes(codeUnits);
      } else if (is8bit) {
        var offset = 0;
        if (hasUdh && udBytes.isNotEmpty) {
          offset = 1 + udBytes[0];
        }
        content = String.fromCharCodes(udBytes.sublist(offset));
      } else {
        // GSM 7-bit：UDL为septet数量；有UDH时需按septet边界对齐
        var septetCount = udl;
        var fillBits = 0;
        var data = udBytes;
        if (hasUdh && udBytes.isNotEmpty) {
          final udhOctets = 1 + udBytes[0];
          data = udBytes.sublist(udhOctets);
          fillBits = (7 - (udhOctets * 8) % 7) % 7;
          septetCount = udl - ((udhOctets * 8 + fillBits) ~/ 7);
        }
        content = _unpackGsm7(data, septetCount, fillBits: fillBits);
      }

      return SmsModel(
        sender: sender,
        content: content,
        time: timestamp,
        index: index,
        isComplete: !hasUdh,
      );
    } catch (_) {
      return null;
    }
  }

  // ==================== 编码 ====================

  /// 编码 SMS-SUBMIT PDU（SMSC使用SIM卡默认设置）。
  /// 纯GSM字符使用7-bit编码（最多160字符），否则使用UCS2（最多70字符）。
  static SubmitPdu encodeSubmit(String number, String text) {
    final sb = StringBuffer();
    sb.write('00'); // SMSC长度0：使用SIM默认短信中心
    sb.write('01'); // 首字节：SMS-SUBMIT，VPF=00（无有效期字段）
    sb.write('00'); // TP-MR：由模块分配

    // 目标地址
    var digits = number.trim();
    var addressType = '81'; // 未知类型
    if (digits.startsWith('+')) {
      digits = digits.substring(1);
      addressType = '91'; // 国际格式
    }
    if (digits.isEmpty || !RegExp(r'^\d+$').hasMatch(digits)) {
      throw ArgumentError('无效的手机号码');
    }
    sb.write(_toHex(digits.length));
    sb.write(addressType);
    sb.write(_encodeSemiOctets(digits));

    sb.write('00'); // TP-PID

    if (_isGsm7Compatible(text)) {
      final septets = _textToSeptets(text);
      if (septets.length > 160) {
        throw ArgumentError('短信内容过长（7-bit编码最多160字符）');
      }
      sb.write('00'); // DCS: GSM 7-bit
      sb.write(_toHex(septets.length));
      sb.write(_packGsm7(septets));
    } else {
      if (text.length > 70) {
        throw ArgumentError('短信内容过长（UCS2编码最多70字符）');
      }
      sb.write('08'); // DCS: UCS2
      final codeUnits = text.codeUnits;
      sb.write(_toHex(codeUnits.length * 2));
      for (final unit in codeUnits) {
        sb.write(_toHex((unit >> 8) & 0xFF));
        sb.write(_toHex(unit & 0xFF));
      }
    }

    final pdu = sb.toString().toUpperCase();
    // TPDU长度不含SMSC字段（此处SMSC字段固定1字节'00'）
    final tpduLength = pdu.length ~/ 2 - 1;
    return SubmitPdu(pdu, tpduLength);
  }

  // ==================== 内部工具 ====================

  static String _toHex(int value) =>
      value.toRadixString(16).padLeft(2, '0').toUpperCase();

  // 半字节交换解码（电话号码/时间戳）
  static String _decodeSemiOctets(List<int> bytes, int digitCount) {
    const digitChars = '0123456789*#abc';
    final sb = StringBuffer();
    for (final b in bytes) {
      final low = b & 0x0F;
      final high = (b >> 4) & 0x0F;
      if (low != 0x0F) sb.write(digitChars[low]);
      if (high != 0x0F) sb.write(digitChars[high]);
    }
    final s = sb.toString();
    return s.length > digitCount ? s.substring(0, digitCount) : s;
  }

  static String _encodeSemiOctets(String digits) {
    final sb = StringBuffer();
    for (var i = 0; i < digits.length; i += 2) {
      final low = digits[i];
      final high = i + 1 < digits.length ? digits[i + 1] : 'F';
      sb.write(high);
      sb.write(low);
    }
    return sb.toString();
  }

  // TP-SCTS：7字节半字节交换 yy MM dd hh mm ss tz
  static String _decodeTimestamp(List<int> bytes) {
    String swap(int b) {
      final low = b & 0x0F;
      final high = (b >> 4) & 0x0F;
      return '$low$high';
    }

    final yy = swap(bytes[0]);
    final mm = swap(bytes[1]);
    final dd = swap(bytes[2]);
    final hh = swap(bytes[3]);
    final mi = swap(bytes[4]);
    final ss = swap(bytes[5]);
    return '20$yy-$mm-$dd $hh:$mi:$ss';
  }

  // GSM 7-bit解包：字节流视为LSB-first比特流，每7比特一个septet
  static String _unpackGsm7(List<int> bytes, int septetCount,
      {int fillBits = 0}) {
    final septets = <int>[];
    var bits = 0;
    var bitCount = 0;
    var fillSkipped = fillBits == 0;

    for (final b in bytes) {
      bits |= b << bitCount;
      bitCount += 8;
      if (!fillSkipped) {
        bits >>= fillBits;
        bitCount -= fillBits;
        fillSkipped = true;
      }
      while (bitCount >= 7 && septets.length < septetCount) {
        septets.add(bits & 0x7F);
        bits >>= 7;
        bitCount -= 7;
      }
    }

    final sb = StringBuffer();
    var escaped = false;
    for (final septet in septets) {
      if (escaped) {
        sb.write(_gsm7Extension[septet] ?? ' ');
        escaped = false;
      } else if (septet == 0x1B) {
        escaped = true;
      } else {
        sb.write(_gsm7Table[septet]);
      }
    }
    return sb.toString();
  }

  static bool _isGsm7Compatible(String text) {
    for (final rune in text.runes) {
      final char = String.fromCharCode(rune);
      if (!_gsm7Table.contains(char) && !_gsm7Extension.containsValue(char)) {
        return false;
      }
      if (char == '\u001B') return false;
    }
    return true;
  }

  static List<int> _textToSeptets(String text) {
    final septets = <int>[];
    for (final rune in text.runes) {
      final char = String.fromCharCode(rune);
      final tableIndex = _gsm7Table.indexOf(char);
      if (tableIndex >= 0 && char != '\u001B') {
        septets.add(tableIndex);
      } else {
        final extEntry = _gsm7Extension.entries
            .firstWhere((e) => e.value == char, orElse: () => const MapEntry(-1, ''));
        if (extEntry.key < 0) throw ArgumentError('字符无法用GSM 7-bit编码: $char');
        septets.add(0x1B);
        septets.add(extEntry.key);
      }
    }
    return septets;
  }

  // GSM 7-bit打包：septet按LSB-first打包为字节流
  static String _packGsm7(List<int> septets) {
    final bytes = <int>[];
    var bits = 0;
    var bitCount = 0;
    for (final septet in septets) {
      bits |= (septet & 0x7F) << bitCount;
      bitCount += 7;
      while (bitCount >= 8) {
        bytes.add(bits & 0xFF);
        bits >>= 8;
        bitCount -= 8;
      }
    }
    if (bitCount > 0) bytes.add(bits & 0xFF);
    return bytes.map(_toHex).join();
  }
}

// PDU十六进制串读取器
class _PduReader {
  final String hex;
  int _pos = 0;

  _PduReader(this.hex);

  int octet() {
    final value = int.parse(hex.substring(_pos, _pos + 2), radix: 16);
    _pos += 2;
    return value;
  }

  List<int> bytes(int count) {
    final result = <int>[];
    for (var i = 0; i < count; i++) {
      result.add(octet());
    }
    return result;
  }

  void skip(int byteCount) {
    _pos += byteCount * 2;
  }

  List<int> remaining() {
    final result = <int>[];
    while (_pos + 2 <= hex.length) {
      result.add(octet());
    }
    return result;
  }
}
