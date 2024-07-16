import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:clock/clock.dart';

/// A buffer for printing.
class PrintBuffer {
  // ignore: public_member_api_docs
  PrintBuffer({
    List<StringTransformer> transformers = const [],
  }) : _transformers = transformers;

  /// Whether to intercept print and buffer it.
  bool isBuffering = true;

  /// Whether to apply transformations to both buffered and unbuffered text.
  bool isTransforming = true;

  final List<StringTransformer> _transformers;

  final _buffer = StringBuffer();
  Stdout? _originalStdout; // ignore: use_late_for_private_fields_and_variables

  /// The buffered content.
  StringBuffer get buffer => _buffer;

  /// Runs [callback] and buffers what it prints.
  @Deprecated('Use overridePrint')
  Future<R> run<R>(FutureOr<R> Function() callback) => overridePrint(callback);

  /// Runs [callback] and buffers what it prints.
  Future<R> overridePrint<R>(FutureOr<R> Function() callback) async {
    return await runZoned(
      callback,
      zoneSpecification: ZoneSpecification(
        print: (Zone self, ZoneDelegate parent, Zone zone, String line) {
          _print(parent, zone, line);
        },
      ),
    );
  }

  void _print(ZoneDelegate parent, Zone zone, String line) {
    final transformed = _transformIfNeed(line);

    if (isBuffering) {
      _buffer.writeln(transformed);
    } else {
      parent.print(zone, transformed);
    }
  }

  /// Runs [callback] and buffers what writes to stdout.
  Future<R> overrideStdout<R>(FutureOr<R> Function() callback) async {
    _originalStdout = stdout;

    // ignore: close_sinks
    final stdoutOverride = _StdoutOverride(_originalStdout!, _stdoutWrite);

    return await IOOverrides.runZoned(
      callback,
      stdout: () => stdoutOverride,
    );
  }

  void _stdoutWrite(Object? object) {
    final line = object.toString();
    final transformed = _transformIfNeed(line);

    if (isBuffering) {
      _buffer.write(transformed);
    } else {
      _originalStdout!.write(transformed);
    }
  }

  String _transformIfNeed(String line) {
    return isTransforming ? _transform(line) : line;
  }

  String _transform(String value) {
    for (final transformer in _transformers.reversed) {
      value = transformer(value); // ignore: parameter_assignments
    }
    return value;
  }
}

/// Transforms [value] to another String.
typedef StringTransformer = String Function(String value);

/// Prepends [value] with the current UTC date in the format of YYYY-MM-DD
/// and a space.
String utcDate(String value) {
  final dt = clock.now().toUtc();
  final formatted = dt.toIso8601String().substring(0, 'YYYY-MM-DD'.length);
  return '$formatted $value';
}

/// Prepends [value] with the current UTC time in the format of HH:mm:ss,
/// the letter 'Z' and a space.
String utcTimeSeconds(String value) {
  final dt = clock.now().toUtc();
  final formatted = dt.toIso8601String().substring(
        'YYYY-MM-DD '.length,
        'YYYY-MM-DD HH:mm:ss'.length,
      );
  return '${formatted}Z $value';
}

class _StdoutOverride implements Stdout {
  final IOSink _original;
  final void Function(Object? object) writeCallback;

  _StdoutOverride(this._original, this.writeCallback);

  @override
  Encoding get encoding => _original.encoding;

  @override
  set encoding(Encoding newValue) {
    _original.encoding = newValue;
  }

  @override
  String lineTerminator = '\n';

  @override
  void add(List<int> data) {
    _original.add(data);
  }

  @override
  void addError(Object error, [StackTrace? stackTrace]) {
    _original.addError(error, stackTrace);
  }

  @override
  Future addStream(Stream<List<int>> stream) => _original.addStream(stream);

  @override
  Future close() => _original.close();

  @override
  Future get done => _original.done;

  @override
  Future flush() => _original.flush();

  @override
  bool get hasTerminal => false;

  @override
  IOSink get nonBlocking => throw UnimplementedError();

  @override
  bool get supportsAnsiEscapes => false;

  @override
  int get terminalColumns => 80;

  @override
  int get terminalLines => 25;

  @override
  void write(Object? object) {
    writeCallback(object);
  }

  @override
  void writeAll(Iterable objects, [String sep = '']) {
    write(objects.join(sep));
  }

  @override
  void writeCharCode(int charCode) {
    write(String.fromCharCode(charCode));
  }

  @override
  void writeln([Object? object = '']) {
    write('$object$lineTerminator');
  }
}
