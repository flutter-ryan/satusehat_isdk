import 'dart:convert';
import 'dart:typed_data';

import 'package:asn1lib/asn1lib.dart';
import 'package:flutter/material.dart';
import 'package:pointycastle/export.dart' as exportpoint;
import 'package:satusehat_isdk/satusehat_isdk.dart';
import 'package:satusehat_isdk_example/models/consent_model.dart';

class SignatureValidator extends StatefulWidget {
  const SignatureValidator({super.key, this.consent, this.signature});

  final Consent? consent;
  final String? signature;

  @override
  State<SignatureValidator> createState() => _SignatureValidatorState();
}

class _SignatureValidatorState extends State<SignatureValidator> {
  bool _isValid = false;

  @override
  void initState() {
    super.initState();
    _verifyingSignature();
  }

  Future<void> _verifyingSignature() async {
    const alias = 'satusehat_isdk';
    final pubkey = await SecureKeystore.getPublicKey(alias);

    String jsonCanonical = canonicalize(consentModelToJson(widget.consent!));

    /// tidak perlu dihash lagi karena sudah dihash oleh keystore
    final bytes = utf8.encode(jsonCanonical);

    final valid = verifyEcdsaP256(
      publicKey: pubkey!,
      signatureDer: base64Decode(widget.signature!),
      canonicalBytes: bytes,
    );

    setState(() {
      _isValid = valid;
    });
  }

  bool verifyEcdsaP256({
    required Uint8List publicKey,
    required Uint8List signatureDer,
    required Uint8List canonicalBytes,
  }) {
    if (publicKey.length != 65 || publicKey[0] != 0x04) {
      throw ArgumentError('Public key harus 65 byte (0x04||X||Y)');
    }

    final xBytes = publicKey.sublist(1, 33);
    final yBytes = publicKey.sublist(33, 65);

    final ecDomain = exportpoint.ECDomainParameters('prime256v1');

    final q = ecDomain.curve.createPoint(
      _bytesToBigInt(xBytes),
      _bytesToBigInt(yBytes),
    );

    final pubKeyParams = exportpoint.ECPublicKey(q, ecDomain);

    final signer = exportpoint.Signer('SHA-256/DET-ECDSA');

    signer.init(
      false,
      exportpoint.PublicKeyParameter<exportpoint.ECPublicKey>(pubKeyParams),
    );

    try {
      return signer.verifySignature(
        canonicalBytes,
        _decodeDerSignature(signatureDer),
      );
    } catch (_) {
      return false;
    }
  }

  // Decode DER signature
  exportpoint.ECSignature _decodeDerSignature(Uint8List derBytes) {
    final asn1 = ASN1Parser(derBytes);
    final sequence = asn1.nextObject() as ASN1Sequence;
    final r = (sequence.elements[0] as ASN1Integer).valueAsBigInteger;
    final s = (sequence.elements[1] as ASN1Integer).valueAsBigInteger;
    return exportpoint.ECSignature(r, s);
  }

  // Convert bytes → BigInt
  BigInt _bytesToBigInt(Uint8List bytes) => BigInt.parse(
    bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join(),
    radix: 16,
  );

  // Convert hex string → Uint8List
  Uint8List hexToBytes(String hex) {
    final result = Uint8List(hex.length ~/ 2);
    for (int i = 0; i < hex.length; i += 2) {
      result[i ~/ 2] = int.parse(hex.substring(i, i + 2), radix: 16);
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Validate Signature')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _isValid
                  ? Icons.check_circle_outline_rounded
                  : Icons.cancel_outlined,
              size: 82,
              color: _isValid ? Colors.green : Colors.red,
            ),
            SizedBox(height: 18),
            Text(
              'Signature valid? $_isValid',
              style: TextStyle(
                fontSize: 22,
                color: _isValid ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
