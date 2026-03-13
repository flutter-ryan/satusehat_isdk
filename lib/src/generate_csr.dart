import 'dart:convert';
import 'dart:typed_data';
import 'package:pointycastle/pointycastle.dart';
import 'package:satusehat_isdk/src/secure_keystore.dart';
import 'package:uuid/uuid.dart';

class GenerateCsr {
  Future<String> generateCsr({
    required String cnId,
    bool isPractitioner = false,
  }) async {
    const alias = 'satusehat_isdk';

    // 1. generate key (only once)
    await SecureKeystore.generateKeyPair(alias);

    final Uint8List? pubPoint = await SecureKeystore.getPublicKey(alias);
    if (pubPoint == null) {
      throw Exception('Public key tidak tersedia dengan alias $alias');
    }

    // 2. Build DN
    final serialNumber = Uuid().v4();
    final dn = buildDN(
      cnId: cnId,
      serial: serialNumber,
      isPractitioner: isPractitioner,
    );

    // 3. Build SAN
    final san = buildSAN(isPractitioner: isPractitioner);

    // 4. Build EKU
    final eku = buildEKU();

    // 5. Build SubjectPublicKeyInfo
    // Ambil bytes public key
    final spki = buildEcdsaP256PublicKeyInfo(pubPoint);

    // 6. Build CSR Info
    final csrInfo = buildCSRInfo(dn: dn, spki: spki, san: san, eku: eku);

    // 7. Sign CSR
    // Ambil bytes private key
    final der = await signCSR(csrInfo, alias);

    // return 'String';
    // 8. Encode PEM
    final pem = toPem(der);

    return pem;
  }

  ASN1Sequence buildDN({
    required String cnId,
    required String serial,
    required bool isPractitioner,
  }) {
    final seq = ASN1Sequence();
    String ou = isPractitioner ? "Practioner" : "Patient";
    seq.add(_rdn("2.5.4.3", cnId)); // CN
    seq.add(_rdn("2.5.4.10", "SATUSEHAT")); // O
    seq.add(_rdn("2.5.4.11", ou)); // OU
    seq.add(_rdn("2.5.4.6", "ID")); // C
    seq.add(_rdn("2.5.4.5", serial)); // serialNumber
    return seq;
  }

  ASN1Set _rdn(String oid, String value) {
    final set = ASN1Set();
    final seq = ASN1Sequence();
    seq.add(ASN1ObjectIdentifier.fromIdentifierString(oid));
    seq.add(ASN1UTF8String(utf8StringValue: value));
    set.add(seq);
    return set;
  }

  ASN1Sequence buildSAN({required bool isPractitioner}) {
    // Build GeneralNames sequence with one GeneralName: otherName
    final generalNames = ASN1Sequence();

    final typeOid = isPractitioner
        ? "1.2.360.4.1.20011.1.2"
        : "1.2.360.4.1.20011.1.1";

    final stringOid = isPractitioner
        ? "SATUSEHAT-PRACTITIONER-ID"
        : "SATUSEHAT-ID";

    final otherName = ASN1Sequence();
    otherName.add(ASN1ObjectIdentifier.fromIdentifierString(typeOid));
    // value for OtherName must be [0] EXPLICIT, so we encode value as context-specific tag 0
    final utf8 = ASN1UTF8String(utf8StringValue: stringOid);
    final explicit = ASN1OctetString(octets: utf8.encode());

    explicit.tag = 0xA0;
    otherName.add(explicit);

    final gn = ASN1Sequence();
    gn.add(otherName);
    gn.tag = 0xA0;
    generalNames.add(gn);

    return generalNames;
  }

  ASN1Sequence buildEKU() {
    final ekuSeq = ASN1Sequence();
    ekuSeq.add(
      ASN1ObjectIdentifier.fromIdentifierString("1.3.6.1.5.5.7.3.2"),
    ); // ClientAuth
    ekuSeq.add(
      ASN1ObjectIdentifier.fromIdentifierString("1.3.6.1.5.5.7.3.36"),
    ); // DocumentSigning
    ekuSeq.add(
      ASN1ObjectIdentifier.fromIdentifierString("1.3.6.1.5.5.7.3.4"),
    ); // EmailProtection

    return ekuSeq;
  }

  ASN1Sequence buildEcdsaP256PublicKeyInfo(Uint8List ecdsaPoint) {
    // AlgorithmIdentifier
    final algId = ASN1Sequence();

    // id-ecPublicKey (1.2.840.10045.2.1)
    algId.add(ASN1ObjectIdentifier.fromIdentifierString("1.2.840.10045.2.1"));

    // prime256v1 (1.2.840.10045.3.1.7)
    algId.add(ASN1ObjectIdentifier.fromIdentifierString("1.2.840.10045.3.1.7"));

    final pubKeyBitString = ASN1BitString(stringValues: ecdsaPoint);
    final spki = ASN1Sequence();
    spki.add(algId);
    spki.add(pubKeyBitString);
    return spki;
  }

  ASN1Sequence buildCSRInfo({
    required ASN1Sequence dn,
    required ASN1Sequence spki,
    required ASN1Sequence san,
    required ASN1Sequence eku,
  }) {
    final info = ASN1Sequence();
    info.add(ASN1Integer(BigInt.zero));
    info.add(dn);
    info.add(spki);

    final attrs = ASN1Set(tag: 0xA0);

    // Build extensionRequest attribute (pkcs#9 extensionRequest OID = 1.2.840.113549.1.9.14)
    final extReq = ASN1Sequence();
    extReq.add(
      ASN1ObjectIdentifier.fromIdentifierString("1.2.840.113549.1.9.14"),
    );

    // The attribute value is a SET OF one element: a sequence of extensions
    final valueSet = ASN1Set();

    // extContainer is SEQUENCE of extension sequences
    final extContainer = ASN1Sequence();

    // SAN extension sequence: OID, critical BOOLEAN (false), extValue OCTET STRING (containing GeneralNames DER)
    final sanExt = ASN1Sequence();
    sanExt.add(ASN1ObjectIdentifier.fromIdentifierString("2.5.29.17"));
    sanExt.add(ASN1Boolean(false));
    sanExt.add(ASN1OctetString(octets: san.encode()));
    extContainer.add(sanExt);

    // EKU extension sequence
    final ekuExt = ASN1Sequence();
    ekuExt.add(ASN1ObjectIdentifier.fromIdentifierString("2.5.29.37"));
    ekuExt.add(ASN1Boolean(false));
    ekuExt.add(ASN1OctetString(octets: eku.encode()));
    extContainer.add(ekuExt);

    // add extContainer into the valueSet (value is SET OF extContainer)
    valueSet.add(extContainer);
    extReq.add(valueSet);

    // put the Attribute extReq into attrs (which is [0] IMPLICIT)
    attrs.add(extReq);

    info.add(attrs);

    return info;
  }

  Future<Uint8List> signCSR(ASN1Sequence info, String alias) async {
    final criDer = info.encode();
    final derSign = await SecureKeystore.sign(alias, criDer);
    if (derSign == null) throw Exception('Gagal sign DER');
    // OID: ecdsa-with-SHA256 -> 1.2.840.10045.4.3.2
    final algId = ASN1Sequence()
      ..add(ASN1ObjectIdentifier.fromIdentifierString("1.2.840.10045.4.3.2"))
      ..add(ASN1Null());

    // 6. Assemble final CSR
    final csr = ASN1Sequence()
      ..add(ASN1Sequence.fromBytes(criDer)) // CertificationRequestInfo
      ..add(algId)
      ..add(
        ASN1BitString(stringValues: derSign),
      ); // SignatureAlgorithm + SignatureValue

    // 7. DER output
    return csr.encode();
  }

  String toPem(Uint8List der) {
    final b64 = base64.encode(der);
    final chunks = RegExp(
      '.{1,64}',
    ).allMatches(b64).map((m) => m.group(0)).join('\n');
    return "-----BEGIN CERTIFICATE REQUEST-----\n$chunks\n-----END CERTIFICATE REQUEST-----";
  }
}
