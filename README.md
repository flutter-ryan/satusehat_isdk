# satusehat_isdk

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

---

# Features

- Generate **Secure KeyPair**
- Get **Public Key (ANSI X9.62 format)**
- Sign data menggunakan **ECDSA SHA256**
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
      url: git@github.com:your-org/satusehat_isdk.git
      ref: master
