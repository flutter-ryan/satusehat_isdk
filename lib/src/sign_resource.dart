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

  String canonicalize(String json) {
    var jsonObject = jsonDecode(json);
    var sb = StringBuffer();
    serialize(jsonObject, sb);
    return sb.toString();
  }

  void serialize(Object? o, StringBuffer sb) {
    if (o == null || o is num || o is bool || o is String) {
      // Primitive type
      sb.write(json.encode(o));
    } else if (o is List) {
      // Array - Maintain element order
      sb.write('[');

      var next = false;
      for (var element in o) {
        if (next) {
          sb.write(',');
        }
        next = true;
        // Array element - Recursive expansion
        serialize(element, sb);
      }
      sb.write(']');
    } else if (o is Map) {
      // Object - Sort properties before serializing
      sb.write('{');
      var next = false;

      var keys = List<String>.from(o.keys);
      keys.sort();

      for (var element in keys) {
        if (next) {
          sb.write(',');
        }
        next = true;
        // Property names are strings - Use ES6/JSON
        sb.write(json.encode(element));
        sb.write(':');
        // Property value - Recursive expansion
        serialize(o[element], sb);
      }

      sb.write('}');
    }
  }
}
