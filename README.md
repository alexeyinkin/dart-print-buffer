Buffers the output of 'print' function.

# Usage

## Simple buffering of `print`

```dart
print('Start buffering');

final buffer = PrintBuffer();
await buffer.overridePrint(() {
  print('Buffered');
});

print('End buffering');
stdout.write(buffer.buffer);
```

Output:

```
Start buffering
End buffering
Buffered
```

## Simple buffering of `stdout`

```dart
stdout.writeln('Start buffering');

final buffer = PrintBuffer();
await buffer.overrideStdout(() {
  stdout.writeln('Buffered');
});

stdout.writeln('End buffering');
stdout.write(buffer.buffer);
```

Output:

```
Start buffering
End buffering
Buffered
```

## Pausing

```dart
print('Start buffering');

final buffer = PrintBuffer();
await buffer.overridePrint(() {
  print('Buffered 1');
  buffer.isBuffering = false;
  print('Buffering paused');
  buffer.isBuffering = true;
  print('Buffered 2');
});

print('End buffering');
stdout.write(buffer.buffer);
```

Output:

```
Start buffering
Buffering paused
End buffering
Buffered 1
Buffered 2
```

## Adding Timestamp

Use transformer functions.
Each one takes a string and returns a string:

```dart
print('Start buffering');

final buffer = PrintBuffer(
  transformers: [utcDate, utcTimeSeconds],
);

await buffer.overridePrint(() {
  print('Buffered with timestamp');
  buffer.isBuffering = false;
  print('Buffering paused');
  buffer.isTransforming = false;
  print('Buffering and transforming paused');
  buffer.isBuffering = true;
  print('Buffered without timestamp');
});

print('End buffering');
stdout.write(buffer.buffer);  
```

Output:

```
Start buffering
2024-06-03 05:04:02Z Buffering paused
Buffering and transforming paused
End buffering
2024-06-03 05:04:02Z Buffered with timestamp
Buffered without timestamp
```
