package com.kemkes.satusehat_isdk

import android.os.Build
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

import java.security.*
import android.security.keystore.*
import androidx.annotation.RequiresApi
import java.security.spec.*
import java.security.interfaces.ECPublicKey

/** SatusehatIsdkPlugin */
class SatusehatIsdkPlugin :
    FlutterPlugin,
    MethodCallHandler {

    private lateinit var channel: MethodChannel

    private val CHANNEL = "satusehat_isdk_secure_key"

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, CHANNEL)
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
                    result.success(signData(alias, data))
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
        .setUserAuthenticationRequired(false)
        .setIsStrongBoxBacked(false)
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

    private fun signData(alias: String, data: ByteArray): ByteArray? {
        val ks = KeyStore.getInstance("AndroidKeyStore").apply { load(null) }
        val entry = ks.getEntry(alias, null) ?: return null
        val privateKey = (entry as KeyStore.PrivateKeyEntry).privateKey

        // Use SHA256withECDSA
        val sig = Signature.getInstance("SHA256withECDSA")
        sig.initSign(privateKey)
        sig.update(data)
        val signatureDer = sig.sign() // DER encoded (r,s)
        return signatureDer
    }
}
