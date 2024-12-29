import 'dart:convert';

/// Useful string methods.
extension StringX on String {
  /// Convert `this` string into a dart doc comment.
  String get dartComment {
    final buffer = StringBuffer();
    for (final line in split('\n')) {
      if (line.trim().isEmpty) {
        buffer.writeln('///');
      } else {
        buffer.writeln('/// $line');
      }
    }
    return buffer.toString();
  }

  /// Quote `this` string according to Dart conventions.
  String get dartString {
    if (contains("'")) {
      return json.encode(this);
    }
    return this;
  }
}
