import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:satusehat_isdk/src/canonicalize.dart';
import 'package:satusehat_isdk/src/secure_keystore.dart';

class SignResource {
  Future<String?> signApproval(String data) async {
    const alias = 'satusehat_isdk';

    try {
      /// RFC 8785
      String jsonCanonical = canonicalize(data);
      final bytes = utf8.encode(jsonCanonical);

      /// Signing bytes json/document
      Uint8List signingData = Uint8List.fromList(bytes);
      final signatureDer = await SecureKeystore.sign(alias, signingData);
      if (signatureDer == null) return null;

      /// ECDSA, CURVE P256, FORMAT DER : signature sudah menggunakan format DER jadi lagsung diencoding ke base64
      return base64Encode(signatureDer);
    } on PlatformException catch (e) {
      switch (e.code) {
        case "CANCELED":
          throw Exception(e.message);

        case "LOCKED":
          throw Exception('Invalid credential: ${e.message}');

        case "NO_ACTIVITY":
          throw Exception('UI belum siap. Coba lagi.');

        case "AUTH_ERROR":
          throw Exception('Authentication failed: ${e.message}');

        default:
          throw Exception('Unknown error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Sign failed: $e');
    }
  }
}
