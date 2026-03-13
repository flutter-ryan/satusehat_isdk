import Flutter
import UIKit

import Security
import LocalAuthentication
import CryptoKit

public class SatusehatIsdkPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "satusehat_isdk_secure_key", binaryMessenger: registrar.messenger())
    let instance = SatusehatIsdkPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    do {
      switch call.method {
      case "generateKeyPair":
        let args = call.arguments as! [String:Any]
        let alias = args["alias"] as! String
        let _ = try self.generateKeyPair(alias: alias)
        result(true)
      case "getPublicKey":
        let args = call.arguments as! [String:Any]
        let alias = args["alias"] as! String
        if let pub = try self.getPublicKey(alias: alias) {
          result(pub)
        } else { result(nil) }
      case "sign":
        let args = call.arguments as! [String:Any]
        let alias = args["alias"] as! String
        let data = args["data"] as! FlutterStandardTypedData
        if let sig = try self.sign(alias: alias, data: data.data) {
          result(sig)
        } else { result(nil) }
      default:
        result(FlutterMethodNotImplemented)
      }
    } catch {
      result(FlutterError(code: "ERROR", message: error.localizedDescription, details: nil))
    }
  }

  func generateKeyPair(alias: String) throws {
    if try getPrivateKey(alias: alias) != nil {
        return
    }
    // Attributes for Secure Enclave ECDSA P-256
    let access = SecAccessControlCreateWithFlags(
      kCFAllocatorDefault,
      kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
      .privateKeyUsage,
      nil
    )!

    let attributes: [String: Any] = [
      kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom,
      kSecAttrKeySizeInBits as String: 256,
      kSecAttrTokenID as String: kSecAttrTokenIDSecureEnclave,
      kSecPrivateKeyAttrs as String: [
        kSecAttrIsPermanent as String: true,
        kSecAttrApplicationTag as String: alias.data(using: .utf8)!,
        kSecAttrAccessControl as String: access
      ]
    ]

    var error: Unmanaged<CFError>?

    guard let privateKey = SecKeyCreateRandomKey(attributes as CFDictionary, &error) else {
      throw error!.takeRetainedValue() as Error
    }
    // private key stored in Secure Enclave; nothing to return
    (privateKey as Any)
  }

  func getPrivateKey(alias: String) throws -> SecKey? {

    let query: [String:Any] = [
        kSecClass as String: kSecClassKey,
        kSecAttrApplicationTag as String: alias.data(using: .utf8)!,
        kSecReturnRef as String: true,
        kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom
    ]

    var item: CFTypeRef?
    let status = SecItemCopyMatching(query as CFDictionary, &item)

    if status != errSecSuccess {
      return nil
    }

    return item as! SecKey
}

  func getPublicKey(alias: String) throws -> Data? {
    // Lookup by application tag
    let query: [String:Any] = [
      kSecClass as String: kSecClassKey,
      kSecAttrApplicationTag as String: alias.data(using: .utf8)!,
      kSecReturnRef as String: true,
      kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom
    ]

    var item: CFTypeRef?
    let status = SecItemCopyMatching(query as CFDictionary, &item)
    if status != errSecSuccess { return nil }
    guard let sk = item as! SecKey? else { return nil }
    guard let pubKey = SecKeyCopyPublicKey(sk) else { return nil }

    // External representation of public key (ANSI X9.62 uncompressed point)
    var error: Unmanaged<CFError>?
    guard let pubData = SecKeyCopyExternalRepresentation(pubKey, &error) as Data? else {
      throw error!.takeRetainedValue() as Error
    }
    // pubData is ANSI X9.62 (0x04||X||Y) 65 bytes
    return pubData
  }

  func sign(alias: String, data: Data) throws -> Data? {
    let query: [String:Any] = [
      kSecClass as String: kSecClassKey,
      kSecAttrApplicationTag as String: alias.data(using: .utf8)!,
      kSecReturnRef as String: true,
      kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom
    ]

    var item: CFTypeRef?
    let status = SecItemCopyMatching(query as CFDictionary, &item)
    if status != errSecSuccess { return nil }
    guard let sk = item as! SecKey? else { return nil }

     // Explicit SHA256 hashing
    let hash = SHA256.hash(data: data)
    let hashData = Data(hash)

    var error: Unmanaged<CFError>?
    // Use ECDSA with SHA256, get signature in DER (r,s)
    guard let sig = SecKeyCreateSignature(
      sk,
      .ecdsaSignatureDigestX962SHA256,
      hashData as CFData,
      &error
    ) as Data? else {
      throw error!.takeRetainedValue() as Error
    }
    return sig
  }
}
