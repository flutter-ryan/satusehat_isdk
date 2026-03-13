import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart' as crypto;

import 'package:satusehat_isdk/src/secure_keystore.dart';

class SignResource {
  Future<String?> signApproval(String data) async {
    const alias = 'satusehat_isdk';

    /// RFC 8785
    String jsonCanonical = canonicalize(data);
    final bytes = utf8.encode(jsonCanonical);

    /// Hasing before signing
    final hashing = crypto.sha256.convert(bytes);
    Uint8List signingData = Uint8List.fromList(hashing.bytes);

    /// Signing hashing json/document
    final signatureDer = await SecureKeystore.sign(alias, signingData);
    if (signatureDer == null) {
      return null;
    }

    /// ECDSA, CURVE P256, FORMAT DER : signature sudah menggunakan format DER jadi lagsung diencoding ke base64
    return base64Encode(signatureDer);
  }

  /// RFC8785  JSON Canonicalization
  String canonicalize(dynamic json) {
    var jsonObject = json is String ? jsonDecode(json) : json;
    var sb = StringBuffer();
    serialize(jsonObject, sb);
    return sb.toString();
  }

  void serialize(Object? o, StringBuffer sb) {
    if (o == null || o is bool || o is String) {
      // Primitive type
      sb.write(json.encode(o));
    } else if (o is num) {
      // Primitive type
      sb.write(o.toString());
    } else if (o is List) {
      // Array - Maintain element order
      sb.write('[');

      for (var i = 0; i < o.length; i++) {
        if (i > 0) sb.write(',');
        serialize(o[i], sb);
      }

      sb.write(']');
    } else if (o is Map) {
      // Object - Sort properties before serializing
      sb.write('{');

      final keys = o.keys.map((e) => e.toString()).toList()..sort();

      for (var i = 0; i < keys.length; i++) {
        if (i > 0) sb.write(',');

        final key = keys[i];
        sb.write(json.encode(key));
        sb.write(':');

        serialize(o[key], sb);
      }

      sb.write('}');
    } else {
      throw ArgumentError("Unsupported JSON type: ${o.runtimeType}");
    }
  }
}
