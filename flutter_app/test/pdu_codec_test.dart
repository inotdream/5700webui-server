import 'package:flutter_test/flutter_test.dart';
import 'package:webui_5700/app/utils/pdu_codec.dart';

void main() {
  group('PduCodec.decodeDeliver', () {
    test('解码经典GSM 7-bit SMS-DELIVER', () {
      // 经典示例PDU（dreamfabric.com），正文为 hellohello
      final sms = PduCodec.decodeDeliver(
        '07917283010010F5040BC87238880900F10000993092516195800AE8329BFD4697D9EC37',
        index: 3,
      );
      expect(sms, isNotNull);
      expect(sms!.content, 'hellohello');
      expect(sms.index, 3);
    });

    test('解码UCS2中文SMS-DELIVER', () {
      // 发送方 +13800138000，正文 你好，时间 2025-10-23 12:34:00
      final sms = PduCodec.decodeDeliver(
        '00040B913108108300F0000852013221430008044F60597D',
      );
      expect(sms, isNotNull);
      expect(sms!.sender, '+13800138000');
      expect(sms.content, '你好');
      expect(sms.time, '2025-10-23 12:34:00');
    });

    test('非DELIVER类型返回null', () {
      expect(PduCodec.decodeDeliver('0001000581'), isNull);
    });
  });

  group('PduCodec.encodeSubmit', () {
    test('ASCII内容使用GSM 7-bit编码', () {
      final result = PduCodec.encodeSubmit('+8613800138000', 'hello');
      expect(result.pdu, '0001000D91683108108300F0000005E8329BFD06');
      expect(result.tpduLength, 19);
    });

    test('中文内容使用UCS2编码', () {
      final result = PduCodec.encodeSubmit('10086', '你好');
      expect(result.pdu, '00010005810180F60008044F60597D');
      expect(result.tpduLength, 14);
    });

    test('超长内容抛出异常', () {
      expect(
        () => PduCodec.encodeSubmit('10086', '你' * 71),
        throwsArgumentError,
      );
      expect(
        () => PduCodec.encodeSubmit('10086', 'a' * 161),
        throwsArgumentError,
      );
    });

    test('无效号码抛出异常', () {
      expect(() => PduCodec.encodeSubmit('abc', 'hi'), throwsArgumentError);
    });
  });

  group('PduCodec.parseCmglResponse', () {
    test('解析AT+CMGL完整响应', () {
      const response = 'AT+CMGL=4\r\n'
          '+CMGL: 5,1,,24\r\n'
          '00040B913108108300F0000852013221430008044F60597D\r\n'
          '+CMGL: 7,1,,30\r\n'
          '07917283010010F5040BC87238880900F10000993092516195800AE8329BFD4697D9EC37\r\n'
          'OK';
      final list = PduCodec.parseCmglResponse(response);
      expect(list.length, 2);
      expect(list[0].index, 5);
      expect(list[0].content, '你好');
      expect(list[1].index, 7);
      expect(list[1].content, 'hellohello');
    });

    test('空列表响应', () {
      expect(PduCodec.parseCmglResponse('OK'), isEmpty);
    });
  });

  group('PduCodec.parseCmgrResponse', () {
    test('解析AT+CMGR响应', () {
      const response = '+CMGR: 0,,24\r\n'
          '00040B913108108300F0000852013221430008044F60597D\r\n'
          'OK';
      final sms = PduCodec.parseCmgrResponse(response, index: 9);
      expect(sms, isNotNull);
      expect(sms!.sender, '+13800138000');
      expect(sms.content, '你好');
      expect(sms.index, 9);
    });
  });
}
