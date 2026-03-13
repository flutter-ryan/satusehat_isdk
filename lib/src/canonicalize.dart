import 'dart:convert';

String canonicalize(String json) {
  final jsonObject = jsonDecode(json);
  final sb = StringBuffer();
  _serialize(jsonObject, sb);
  return sb.toString();
}

void _serialize(Object? value, StringBuffer sb) {
  if (value == null || value is bool) {
    sb.write(value);
  } else if (value is String) {
    sb.write(jsonEncode(value));
  } else if (value is num) {
    sb.write(_canonicalizeNumber(value));
  } else if (value is List) {
    sb.write('[');

    for (int i = 0; i < value.length; i++) {
      if (i > 0) sb.write(',');
      _serialize(value[i], sb);
    }

    sb.write(']');
  } else if (value is Map<String, dynamic>) {
    sb.write('{');

    final keys = value.keys.toList()..sort();

    for (int i = 0; i < keys.length; i++) {
      if (i > 0) sb.write(',');

      final key = keys[i];

      sb.write(jsonEncode(key));
      sb.write(':');

      _serialize(value[key], sb);
    }

    sb.write('}');
  } else {
    throw ArgumentError("Unsupported JSON type: ${value.runtimeType}");
  }
}

String _canonicalizeNumber(num n) {
  if (n is int) return n.toString();

  final d = n.toDouble();

  if (d.isNaN || d.isInfinite) {
    throw ArgumentError("Invalid JSON number");
  }

  return d.toString();
}
