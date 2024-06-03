import 'dart:io';

import 'package:test/test.dart';

void main() {
  test('Example runs as expected', () async {
    final pubGet = await Process.start(
      'dart',
      ['pub', 'get'],
      workingDirectory: 'example',
    );
    await pubGet.exitCode;

    final process = await Process.start(
      'dart',
      [
        'run',
        'lib/main.dart',
      ],
      workingDirectory: 'example',
    );

    final exitCode = await process.exitCode;
    final output = await process.stdout.toJointString();
    final stderr = await process.stderr.toJointString();

    expect(exitCode, 0, reason: stderr);
    expect(stderr, '');
    expect(output.replaceAll(RegExp(r'\d{2}'), 'XX'), '''
Start buffering unchanged
Buffering paused
End buffering unchanged
Buffered unchanged 1
Buffered unchanged 2
--
Start buffering with timestamp
XXXX-XX-XX XX:XX:XXZ Buffering paused
Buffering and transforming paused
End buffering with timestamp
XXXX-XX-XX XX:XX:XXZ Buffered with timestamp
Buffered without timestamp
''');
  });
}

extension on Stream<List<int>> {
  Future<String> toJointString() async {
    final list = await toList();
    final charCodes = list.expand((l) => l);
    return String.fromCharCodes(charCodes);
  }
}
