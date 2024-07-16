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
Start buffering print
Buffering paused
End buffering print
Buffered unchanged 1
Buffered unchanged 2
--
Start buffering print with timestamp
Not buffering or transforming stdout
XXXX-XX-XX XX:XX:XXZ Buffering paused
Buffering and transforming paused
End buffering print with timestamp
XXXX-XX-XX XX:XX:XXZ Buffered with timestamp
Buffered without timestamp
--
Start buffering print sync
Sync result
End buffering print sync
Start buffering print async
Async result
End buffering print async
Buffered sync
Buffered async
--
Start buffering stdout with timestamp
Not buffering or transforming print
XXXX-XX-XX XX:XX:XXZ Buffering paused
Buffering and transforming paused
End buffering stdout with timestamp
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
