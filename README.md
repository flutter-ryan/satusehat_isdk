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
- Biometric & Passcode Authentication **Signing**

---

# Platform Support

| Platform | Status |
|--------|--------|
| Android | ✅ Android Keystore |
| iOS | ✅ Secure Enclave |
| Web | ❌ Not Supported |
| Desktop | ❌ Not Supported |

---

# Biometric & Passcode Authentication

Plugin ini mendukung autentikasi menggunakan **Biometric (Face ID / Touch ID / Fingerprint)** dengan fallback ke **device passcode / credential**.  

---

## iOS

### Info.plist

Tambahkan key berikut:

```xml
<key>NSFaceIDUsageDescription</key>
<string>Aplikasi membutuhkan Face ID / Touch ID untuk menandatangani dokumen secara aman</string>
```

## Android 

### AndroidManifest.xml (Opsional)

Tambahkan key berikut:

```xml
<uses-permission android:name="android.permission.USE_BIOMETRIC"/>
<uses-permission android:name="android.permission.USE_FINGERPRINT"/>
```

### MainActivity.kt

Gunakan flutter embedding v2

```kotlin

import io.flutter.embedding.android.FlutterFragmentActivity

class MainActivity : FlutterFragmentActivity()

```

---
### Flow

1. User klik **Sign**
2. Muncul prompt **Face ID / Touch ID**
3. Jika autentikasi berhasil → tanda tangan data berhasil
4. Jika gagal atau tidak tersedia → fallback ke **device passcode**
5. Setelah passcode valid → tanda tangan data berhasil

**Catatan:**

- Testing harus dilakukan di **real device**
- Pastikan **Face ID / Touch ID aktif** di device
- Pastikan **passcode/PIN** aktif untuk fallback

# Installation

Tambahkan dependency pada `pubspec.yaml`.

```yaml
dependencies:
  satusehat_isdk:
    git:
      url: https://github.com/flutter-ryan/satusehat_isdk.git
      ref: master
