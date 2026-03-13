# Satusehat ISDK

Flutter plugin untuk integrasi **Secure Key + Digital Signature** dengan standar **SATUSEHAT ISDK**.
Plugin ini menyediakan mekanisme untuk:

- Membuat **key pair** di secure hardware
- Mengambil **public key**
- Melakukan **digital signing**
- Digunakan untuk kebutuhan **FHIR Provenance Signature**

Plugin ini menggunakan:

- **Android Keystore**
- **iOS Secure Enclave**
- **ECDSA P-256**
- **SHA256**

# Documentation

Dokumentasi lengkap dapat dilihat pada link berikut:

🔗 https://docs.google.com/document/d/1gyN-qL7eD_Hj-QHHRwGcgALRGNoxqUWhsOpDonxRn1I/edit?tab=t.0


---

# Features

- Generate **Secure KeyPair**
- Get **Public Key (ANSI X9.62 format)**
- Sign data menggunakan **ECDSA SHA256**
- JSON Canonicalization menggunakan **RFC 8785**
- Private key **tidak pernah keluar dari device**
- Signature output dalam **DER format**

---

# Platform Support

| Platform | Status |
|--------|--------|
| Android | ✅ Android Keystore |
| iOS | ✅ Secure Enclave |
| Web | ❌ Not Supported |
| Desktop | ❌ Not Supported |

---

# Installation

Tambahkan dependency pada `pubspec.yaml`.

```yaml
dependencies:
  satusehat_isdk:
    git:
      url: https://github.com/flutter-ryan/satusehat_isdk.git
      ref: master
