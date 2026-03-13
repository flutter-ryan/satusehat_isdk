import 'package:flutter/services.dart';

class SecureKeystore {
  static const MethodChannel _ch = MethodChannel('satusehat_isdk_secure_key');

  /// Generate keypair dengan menggunakan hardware secure keystore
  static Future<bool> generateKeyPair(String alias) async {
    final res = await _ch.invokeMethod<bool>('generateKeyPair', {
      'alias': alias,
    });
    return res ?? false;
  }

  /// Memngambil public key from keystore
  static Future<Uint8List?> getPublicKey(String alias) async {
    final res = await _ch.invokeMethod<Uint8List?>('getPublicKey', {
      'alias': alias,
    });
    return res;
  }

  /// Sign data menggunakan hardware private key
  static Future<Uint8List?> sign(String alias, Uint8List data) async {
    final res = await _ch.invokeMethod<Uint8List?>('sign', {
      'alias': alias,
      'data': data,
    });
    return res;
  }

  /// Menghapus keypair
  static Future<bool> delete(String alias) async {
    final res = await _ch.invokeMethod<bool>('deleteKey', {'alias': alias});
    return res ?? false;
  }
}
