import 'dart:async';

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

  /// The buffered content.
  StringBuffer get buffer => _buffer;

  /// Runs [callback] and buffers what it prints.
  Future<void> run(FutureOr<void> Function() callback) async {
    runZoned(
      callback,
      zoneSpecification: ZoneSpecification(
        print: (Zone self, ZoneDelegate parent, Zone zone, String line) {
          final transformed = isTransforming ? _transform(line) : line;

          if (isBuffering) {
            _buffer.writeln(transformed);
          } else {
            parent.print(zone, transformed);
          }
        },
      ),
    );
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
