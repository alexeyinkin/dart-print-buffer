import 'dart:io';

import 'package:print_buffer/print_buffer.dart';

Future<void> main() async {
  await runUnchangedBuffer();
  print('--');
  await runBufferedWithTimestamp();
}

Future<void> runUnchangedBuffer() async {
  print('Start buffering unchanged');

  final buffer = PrintBuffer();
  await buffer.run(() {
    print('Buffered unchanged 1');
    buffer.isBuffering = false;
    print('Buffering paused');
    buffer.isBuffering = true;
    print('Buffered unchanged 2');
  });

  print('End buffering unchanged');
  stdout.write(buffer.buffer);
}

Future<void> runBufferedWithTimestamp() async {
  print('Start buffering with timestamp');

  final buffer = PrintBuffer(
    transformers: [utcDate, utcTimeSeconds],
  );

  await buffer.run(() {
    print('Buffered with timestamp');
    buffer.isBuffering = false;
    print('Buffering paused');
    buffer.isTransforming = false;
    print('Buffering and transforming paused');
    buffer.isBuffering = true;
    print('Buffered without timestamp');
  });

  print('End buffering with timestamp');
  stdout.write(buffer.buffer);
}
