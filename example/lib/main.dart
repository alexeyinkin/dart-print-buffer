import 'dart:io';

import 'package:print_buffer/print_buffer.dart';

Future<void> main() async {
  await runPrint();
  print('--');
  await runPrintTransformed();
  print('--');
  await runReturns();
  print('--');
  await runStdoutTransformed();
}

Future<void> runPrint() async {
  print('Start buffering print');

  final buffer = PrintBuffer();
  await buffer.overridePrint(() {
    print('Buffered unchanged 1');
    buffer.isBuffering = false;
    print('Buffering paused');
    buffer.isBuffering = true;
    print('Buffered unchanged 2');
  });

  print('End buffering print');
  stdout.write(buffer.buffer);
}

Future<void> runPrintTransformed() async {
  print('Start buffering print with timestamp');

  final buffer = PrintBuffer(
    transformers: [utcDate, utcTimeSeconds],
  );

  await buffer.overridePrint(() {
    stdout.writeln('Not buffering or transforming stdout');
    print('Buffered with timestamp');
    buffer.isBuffering = false;
    print('Buffering paused');
    buffer.isTransforming = false;
    print('Buffering and transforming paused');
    buffer.isBuffering = true;
    print('Buffered without timestamp');
  });

  print('End buffering print with timestamp');
  stdout.write(buffer.buffer);
}

Future<void> runReturns() async {
  final buffer = PrintBuffer();

  print('Start buffering print sync');
  print(
    await buffer.overridePrint(() {
      print('Buffered sync');
      return 'Sync result';
    }),
  );
  print('End buffering print sync');

  print('Start buffering print async');
  print(
    await buffer.overridePrint(() async {
      await Future.delayed(Duration.zero);
      print('Buffered async');
      return 'Async result';
    }),
  );
  print('End buffering print async');

  stdout.write(buffer.buffer);
}

Future<void> runStdoutTransformed() async {
  stdout.writeln('Start buffering stdout with timestamp');

  final buffer = PrintBuffer(
    transformers: [utcDate, utcTimeSeconds],
  );

  await buffer.overrideStdout(() {
    print('Not buffering or transforming print');
    stdout.write('Buffered with timestamp\n');
    buffer.isBuffering = false;
    stdout.write('Buffering paused\n');
    buffer.isTransforming = false;
    stdout.writeln('Buffering and transforming paused');
    buffer.isBuffering = true;
    stdout.writeln('Buffered without timestamp');
  });

  stdout.writeln('End buffering stdout with timestamp');
  stdout.write(buffer.buffer);
}
