import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:satusehat_isdk/src/canonicalize.dart';
import 'package:satusehat_isdk/src/secure_keystore.dart';

class SignResource {
  Future<String?> signApproval(String data) async {
    const alias = 'satusehat_isdk';

    /// RFC 8785
    String jsonCanonical = canonicalize(data);
    final bytes = utf8.encode(jsonCanonical);

    /// Explicit SHA256 hashing
    // final digest = sha256.convert(bytes);

    /// Signing hashing json/document
    Uint8List signingData = Uint8List.fromList(bytes);
    final signatureDer = await SecureKeystore.sign(alias, signingData);
    if (signatureDer == null) return null;

    /// ECDSA, CURVE P256, FORMAT DER : signature sudah menggunakan format DER jadi lagsung diencoding ke base64
    return base64Encode(signatureDer);
  }
}
