package com.kemkes.satusehat_isdk

import android.os.Build
import androidx.biometric.BiometricPrompt
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.embedding.engine.plugins.activity.ActivityAware

import java.security.*
import android.security.keystore.*
import androidx.annotation.RequiresApi
import java.security.spec.*
import java.security.interfaces.ECPublicKey

/** SatusehatIsdkPlugin */
class SatusehatIsdkPlugin :
    FlutterPlugin,
    MethodCallHandler,
    ActivityAware {

    private lateinit var channel: MethodChannel

    private val CHANNEL = "satusehat_isdk_secure_key"

    private var activity: androidx.fragment.app.FragmentActivity? = null

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(binding.binaryMessenger, CHANNEL)
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(
        call: MethodCall,
        result: Result
    ) {
        try {
            when (call.method) {
                "generateKeyPair" -> {
                    val alias = call.argument<String>("alias")!!
                    result.success(generateKeyPair(alias))
                }
                "getPublicKey" -> {
                    val alias = call.argument<String>("alias")!!
                    result.success(getPublicKeyBytes(alias))
                }
                "sign" -> {
                    val alias = call.argument<String>("alias")!!
                    val data = call.argument<ByteArray>("data")!!
                    signData(alias, data, result)
                }
                else -> result.notImplemented()
            }
        } catch (e: Exception) {
            result.error("ERROR", e.message, null)
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onAttachedToActivity(binding: io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding) {
        activity = binding.activity as androidx.fragment.app.FragmentActivity
    }

    override fun onDetachedFromActivity() {
        activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding) {
        activity = binding.activity as androidx.fragment.app.FragmentActivity
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activity = null
    }

    @RequiresApi(Build.VERSION_CODES.P)
    private fun generateKeyPair(alias: String): Boolean {
        val ks = KeyStore.getInstance("AndroidKeyStore")
        ks.load(null)
        if (ks.containsAlias(alias)) return true

        val kpg = KeyPairGenerator.getInstance(KeyProperties.KEY_ALGORITHM_EC, "AndroidKeyStore")
        val builder = KeyGenParameterSpec.Builder(
            alias,
            KeyProperties.PURPOSE_SIGN or KeyProperties.PURPOSE_VERIFY
        )
        .setAlgorithmParameterSpec(ECGenParameterSpec("secp256r1"))
        .setDigests(KeyProperties.DIGEST_SHA256)
        .setUserAuthenticationRequired(true)
        .setUserAuthenticationParameters(
            0,
            KeyProperties.AUTH_BIOMETRIC_STRONG or
            KeyProperties.AUTH_DEVICE_CREDENTIAL
        )
        .setInvalidatedByBiometricEnrollment(false)
        .build()

        kpg.initialize(builder)
        kpg.generateKeyPair()
        return true
    }

    private fun getPublicKeyBytes(alias: String): ByteArray? {
        val ks = KeyStore.getInstance("AndroidKeyStore").apply { load(null) }
        val cert = ks.getCertificate(alias) ?: return null
        val pub = cert.publicKey
        if (pub is ECPublicKey) {
            val w = pub.w
            val x = w.affineX.toByteArray()
            val y = w.affineY.toByteArray()
            // Ensure 32 bytes big-endian
            val xb = trimOrPadTo32(x)
            val yb = trimOrPadTo32(y)
            val out = ByteArray(1 + 32 + 32)
            out[0] = 0x04
            System.arraycopy(xb, 0, out, 1, 32)
            System.arraycopy(yb, 0, out, 33, 32)
            return out
        }
        return null
    }

    private fun trimOrPadTo32(bytes: ByteArray): ByteArray {
        // bytes is big-endian, may have leading zero from BigInteger
        if (bytes.size == 32) return bytes
        if (bytes.size > 32) {
        // keep last 32 bytes
            return bytes.copyOfRange(bytes.size - 32, bytes.size)
        } else {
            val out = ByteArray(32)
            System.arraycopy(bytes, 0, out, 32 - bytes.size, bytes.size)
            return out
        }
    }

    private fun signData(
        alias: String,
        data: ByteArray,
        result: MethodChannel.Result
    ) {
        val act = activity ?: run {
            result.error("NO_ACTIVITY", "Activity not attached", null)
            return
        }
        val ks = KeyStore.getInstance("AndroidKeyStore").apply { load(null) }
        val entry = ks.getEntry(alias, null) as KeyStore.PrivateKeyEntry
        val privateKey = entry.privateKey

        // Use SHA256withECDSA
        val sig = Signature.getInstance("SHA256withECDSA")
        sig.initSign(privateKey)

        val executor = androidx.core.content.ContextCompat.getMainExecutor(act)

        val promptInfo = androidx.biometric.BiometricPrompt.PromptInfo.Builder()
            .setTitle("Authenticate to sign")
            .setSubtitle("Use biometric or device credential")
            .setAllowedAuthenticators(
                androidx.biometric.BiometricManager.Authenticators.BIOMETRIC_STRONG or
                androidx.biometric.BiometricManager.Authenticators.DEVICE_CREDENTIAL
            )
            .build()

        val biometricPrompt = androidx.biometric.BiometricPrompt(
            act,
            executor,
            object : BiometricPrompt.AuthenticationCallback() {

                override fun onAuthenticationSucceeded(
                    resultAuth: BiometricPrompt.AuthenticationResult
                ) {
                    try {
                        val crypto = resultAuth.cryptoObject!!
                        val sig = crypto.signature!!
                        sig.update(data)
                        val signed = sig.sign()
                        result.success(signed)
                    } catch (e: Exception) {
                        result.error("SIGN_ERROR", e.message, null)
                    }
                }

                override fun onAuthenticationError(code: Int, msg: CharSequence) {
                    when (code) {
                        BiometricPrompt.ERROR_USER_CANCELED,
                        BiometricPrompt.ERROR_NEGATIVE_BUTTON,
                        BiometricPrompt.ERROR_CANCELED -> {
                            result.error("CANCELED", "User canceled authentication", null)
                        }

                        BiometricPrompt.ERROR_LOCKOUT,
                        BiometricPrompt.ERROR_LOCKOUT_PERMANENT -> {
                            result.error("LOCKED", "Biometric locked, use device credential", null)
                        }

                        else -> {
                            result.error("AUTH_ERROR", msg.toString(), null)
                        }
                    }
                }
            }
        )

        biometricPrompt.authenticate(
            promptInfo,
            BiometricPrompt.CryptoObject(sig)
        )

        // sig.update(data)
        // val signatureDer = sig.sign() // DER encoded (r,s)
        // return signatureDer
    }
}
