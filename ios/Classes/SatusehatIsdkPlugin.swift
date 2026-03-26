import Flutter
import UIKit

import Security
import LocalAuthentication

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
        sign(alias: alias, data: data.data) { signature, error in
            if let error = error {
                result(FlutterError(
                    code: "SIGN_ERROR",
                    message: error.localizedDescription,
                    details: nil
                ))
                return
            }

            if let signature = signature {
                result(signature)
            } else {
                result(nil)
            }
        }
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
      [.privateKeyUsage, .userPresence],
      nil
    )!

    let attributes: [String: Any] = [
      kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom,
      kSecAttrKeySizeInBits as String: 256,
      kSecAttrTokenID as String: kSecAttrTokenIDSecureEnclave,
      kSecPrivateKeyAttrs as String: [
        kSecAttrIsPermanent as String: true,
        kSecAttrApplicationTag as String: alias.data(using: .utf8)!,
        kSecAttrAccessControl as String: access,
        kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
      ]
    ]

    var error: Unmanaged<CFError>?

    guard SecKeyCreateRandomKey(attributes as CFDictionary, &error) != nil else {
        if let err = error?.takeRetainedValue() {
            throw err
        } else {
            throw NSError(domain: "KEYGEN", code: -1, userInfo: [
                NSLocalizedDescriptionKey: "Unknown error generating key"
            ])
        }
    }
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

  func sign(alias: String, data: Data, completion: @escaping (Data?, Error?) -> Void) {
    let context = LAContext()
    context.localizedReason = "Authenticate to sign consent"
    context.interactionNotAllowed = false

    var authError: NSError?

    guard context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &authError) else {
        completion(nil, authError ?? NSError(
            domain: "AUTH",
            code: -1,
            userInfo: [NSLocalizedDescriptionKey: "Authentication not available"]
        ))
        return
    }

    context.evaluatePolicy(
        .deviceOwnerAuthentication,
        localizedReason: "Authenticate to sign consent"
    ) { success, error in

        DispatchQueue.main.async {

            if !success {
                completion(nil, error)
                return
            }

            do {
                let query: [String:Any] = [
                    kSecClass as String: kSecClassKey,
                    kSecAttrApplicationTag as String: alias.data(using: .utf8)!,
                    kSecReturnRef as String: true,
                    kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom,
                    kSecUseAuthenticationContext as String: context
                ]

                var item: CFTypeRef?
                let status = SecItemCopyMatching(query as CFDictionary, &item)

                if status != errSecSuccess {
                    throw NSError(
                        domain: NSOSStatusErrorDomain,
                        code: Int(status),
                        userInfo: nil
                    )
                }

                guard let privateKey = item else {
                    throw NSError(domain: "KEY", code: -1, userInfo: [
                        NSLocalizedDescriptionKey: "Private key not found"
                    ])
                }

                var error: Unmanaged<CFError>?

                guard let signature = SecKeyCreateSignature(
                    privateKey as! SecKey,
                    .ecdsaSignatureMessageX962SHA256,
                    data as CFData,
                    &error
                ) as Data? else {
                    throw error!.takeRetainedValue()
                }

                completion(signature, nil)

            } catch {
                completion(nil, error)
            }
        }
    }
  }
}
