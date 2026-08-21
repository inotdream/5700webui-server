import 'package:flutter_test/flutter_test.dart';
import 'package:webui_5700/app/utils/at_protocol.dart';

void main() {
  group('AtLineAssembler', () {
    test('assembles CRLF lines across TCP fragments', () {
      final assembler = AtLineAssembler();
      expect(assembler.add('AT+CSQ\r'), isEmpty);
      expect(assembler.add('\n+CSQ: 25,99\r\nOK\r\n'), ['AT+CSQ', '+CSQ: 25,99', 'OK']);
      expect(assembler.leftover, isEmpty);
    });

    test('normalizes bare CR as line ending', () {
      final assembler = AtLineAssembler();
      expect(assembler.add('+CMTI: "ME",5\r'), ['+CMTI: "ME",5']);
    });

    test('detects SMS prompt without trailing newline', () {
      final assembler = AtLineAssembler();
      expect(assembler.add('\r\n>'), ['']);
      expect(assembler.hasSmsPrompt, isTrue);
    });

    test('keeps incomplete line in leftover', () {
      final assembler = AtLineAssembler();
      expect(assembler.add('+CSQ: 1'), isEmpty);
      expect(assembler.leftover, '+CSQ: 1');
      expect(assembler.add('7,99\n'), ['+CSQ: 17,99']);
    });
  });

  group('AtFrameParser', () {
    test('only treats standalone OK/ERROR as final result', () {
      expect(AtFrameParser.isFinalResultLine('OK'), isTrue);
      expect(AtFrameParser.isFinalResultLine('  ERROR  '), isTrue);
      expect(AtFrameParser.isFinalResultLine('+CME ERROR: 3'), isTrue);
      expect(AtFrameParser.isFinalResultLine('+CMS ERROR: 500'), isTrue);
      expect(AtFrameParser.isFinalResultLine('>'), isTrue);

      expect(AtFrameParser.isFinalResultLine('BOOK'), isFalse);
      expect(AtFrameParser.isFinalResultLine('+CSQ: 25,99'), isFalse);
      expect(AtFrameParser.isFinalResultLine('TOKEN=OK'), isFalse);
    });

    test('recognizes interleaved URCs', () {
      expect(AtFrameParser.isInterleavedUrc('+CMTI: "ME",5'), isTrue);
      expect(AtFrameParser.isInterleavedUrc('RING'), isTrue);
      expect(AtFrameParser.isInterleavedUrc('+CLIP: "13800138000",128'), isTrue);
      expect(AtFrameParser.isInterleavedUrc('^HCSQ: "LTE",50,20,120,255'), isTrue);
      expect(AtFrameParser.isInterleavedUrc('NO CARRIER'), isTrue);
      expect(AtFrameParser.isInterleavedUrc('+CSQ: 25,99'), isFalse);
    });
  });
}
