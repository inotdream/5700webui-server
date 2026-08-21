import 'package:flutter_test/flutter_test.dart';
import 'package:webui_5700/app/utils/at_protocol.dart';

void main() {
  test('AT 行解析可独立运行', () {
    final assembler = AtLineAssembler();
    expect(assembler.add('OK\r\n'), ['OK']);
    expect(AtFrameParser.isFinalResultLine('OK'), isTrue);
  });
}
