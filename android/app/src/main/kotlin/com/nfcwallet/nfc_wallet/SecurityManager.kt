package com.nfcwallet.nfc_wallet

import android.content.Context
import android.os.Build
import android.security.keystore.KeyGenParameterSpec
import android.security.keystore.KeyProperties
import android.util.Base64
import android.util.Log
import java.security.KeyStore
import java.security.MessageDigest
import java.security.SecureRandom
import javax.crypto.Cipher
import javax.crypto.KeyGenerator
import javax.crypto.Mac
import javax.crypto.SecretKey
import javax.crypto.spec.GCMParameterSpec
import javax.crypto.spec.SecretKeySpec
import org.json.JSONObject

/**
 * Security Manager
 * Handles encryption, token generation, and secure key storage
 * Uses Android Keystore for secure key management
 */
class SecurityManager(private val context: Context) {

    companion object {
        private const val TAG = "SecurityManager"
        private const val KEYSTORE_PROVIDER = "AndroidKeyStore"
        private const val ENCRYPTION_KEY_ALIAS = "nfc_wallet_encryption_key"
        private const val SIGNING_KEY_ALIAS = "nfc_wallet_signing_key"
        private const val TRANSFORMATION = "AES/GCM/NoPadding"
        private const val GCM_TAG_LENGTH = 128
        private const val NONCE_LENGTH = 32
        private const val HMAC_ALGORITHM = "HmacSHA256"
    }

    private val keyStore: KeyStore = KeyStore.getInstance(KEYSTORE_PROVIDER).apply {
        load(null)
    }

    init {
        // Generate encryption key if it doesn't exist
        if (!keyStore.containsAlias(ENCRYPTION_KEY_ALIAS)) {
            generateEncryptionKey()
        }
        // Generate signing key if it doesn't exist
        if (!keyStore.containsAlias(SIGNING_KEY_ALIAS)) {
            generateSigningKey()
        }
    }

    /**
     * Generate AES encryption key in Android Keystore
     */
    private fun generateEncryptionKey() {
        val keyGenerator = KeyGenerator.getInstance(
            KeyProperties.KEY_ALGORITHM_AES,
            KEYSTORE_PROVIDER
        )

        val keyGenParameterSpec = KeyGenParameterSpec.Builder(
            ENCRYPTION_KEY_ALIAS,
            KeyProperties.PURPOSE_ENCRYPT or KeyProperties.PURPOSE_DECRYPT
        )
            .setBlockModes(KeyProperties.BLOCK_MODE_GCM)
            .setEncryptionPaddings(KeyProperties.ENCRYPTION_PADDING_NONE)
            .setUserAuthenticationRequired(false)
            .setRandomizedEncryptionRequired(true)
            .build()

        keyGenerator.init(keyGenParameterSpec)
        keyGenerator.generateKey()
        
        Log.d(TAG, "Encryption key generated in Keystore")
    }

    /**
     * Generate HMAC signing key in Android Keystore
     */
    private fun generateSigningKey() {
        val keyGenerator = KeyGenerator.getInstance(
            KeyProperties.KEY_ALGORITHM_HMAC_SHA256,
            KEYSTORE_PROVIDER
        )

        val keyGenParameterSpec = KeyGenParameterSpec.Builder(
            SIGNING_KEY_ALIAS,
            KeyProperties.PURPOSE_SIGN or KeyProperties.PURPOSE_VERIFY
        )
            .setUserAuthenticationRequired(false)
            .build()

        keyGenerator.init(keyGenParameterSpec)
        keyGenerator.generateKey()
        
        Log.d(TAG, "Signing key generated in Keystore")
    }

    /**
     * Get encryption key from Keystore
     */
    private fun getEncryptionKey(): SecretKey {
        return keyStore.getKey(ENCRYPTION_KEY_ALIAS, null) as SecretKey
    }

    /**
     * Get signing key from Keystore
     */
    private fun getSigningKey(): SecretKey {
        return keyStore.getKey(SIGNING_KEY_ALIAS, null) as SecretKey
    }

    /**
     * Generate NFC payment token with amount
     * For development: Token is base64-encoded JSON (not encrypted)
     * For production: Should use server-side key exchange for encryption
     */
    fun generateNfcToken(
        userId: String,
        walletId: String,
        deviceId: String,
        amount: Double = 0.0
    ): String {
        // Generate nonce
        val nonce = generateNonce()
        val timestamp = System.currentTimeMillis()

        // Create token payload
        val payload = JSONObject().apply {
            put("userId", userId)
            put("walletId", walletId)
            put("amount", amount)
            put("timestamp", timestamp)
            put("nonce", Base64.encodeToString(nonce, Base64.NO_WRAP))
            put("deviceId", deviceId)
            // Add signature for token integrity
            put("signature", generateSignature(userId, walletId, amount, timestamp))
        }

        // For development/testing: Send as base64-encoded JSON (not encrypted)
        // The backend can verify the signature for integrity
        // TODO: For production, implement server-side key exchange for proper encryption
        val tokenJson = payload.toString()
        val tokenBase64 = Base64.encodeToString(tokenJson.toByteArray(Charsets.UTF_8), Base64.NO_WRAP)
        
        Log.d(TAG, "NFC token generated with amount: $amount")
        Log.d(TAG, "Token JSON: $tokenJson")
        return tokenBase64
    }
    
    /**
     * Generate HMAC signature for token integrity
     * Uses shared secret to allow backend verification
     * TODO: For production, implement secure key exchange or certificate pinning
     */
    private fun generateSignature(userId: String, walletId: String, amount: Double, timestamp: Long): String {
        // Shared secret - must match backend NFC_SIGNING_SECRET env variable
        // TODO: Load this from secure config in production
        val sharedSecret = "nfc-development-signing-secret-key"
        
        val data = "$userId|$walletId|$amount|$timestamp"
        
        val mac = Mac.getInstance(HMAC_ALGORITHM)
        val secretKey = SecretKeySpec(sharedSecret.toByteArray(Charsets.UTF_8), HMAC_ALGORITHM)
        mac.init(secretKey)
        val signatureBytes = mac.doFinal(data.toByteArray(Charsets.UTF_8))
        
        return Base64.encodeToString(signatureBytes, Base64.NO_WRAP)
    }
    
    /**
     * Verify HMAC signature (for local verification)
     */
    fun verifySignature(userId: String, walletId: String, amount: Double, timestamp: Long, signature: String): Boolean {
        return try {
            val expectedSignature = generateSignature(userId, walletId, amount, timestamp)
            // Use constant-time comparison
            MessageDigest.isEqual(expectedSignature.toByteArray(), signature.toByteArray())
        } catch (e: Exception) {
            Log.e(TAG, "Signature verification failed", e)
            false
        }
    }

    /**
     * Encrypt data using AES-GCM
     */
    private fun encrypt(plaintext: String): String {
        val cipher = Cipher.getInstance(TRANSFORMATION)
        cipher.init(Cipher.ENCRYPT_MODE, getEncryptionKey())

        val iv = cipher.iv
        val encryptedBytes = cipher.doFinal(plaintext.toByteArray(Charsets.UTF_8))

        // Combine IV + encrypted data
        val combined = iv + encryptedBytes
        
        return Base64.encodeToString(combined, Base64.NO_WRAP)
    }

    /**
     * Decrypt data using AES-GCM
     */
    fun decrypt(ciphertext: String): String {
        val combined = Base64.decode(ciphertext, Base64.NO_WRAP)
        
        // Extract IV (first 12 bytes for GCM)
        val iv = combined.copyOfRange(0, 12)
        val encryptedBytes = combined.copyOfRange(12, combined.size)

        val cipher = Cipher.getInstance(TRANSFORMATION)
        val spec = GCMParameterSpec(GCM_TAG_LENGTH, iv)
        cipher.init(Cipher.DECRYPT_MODE, getEncryptionKey(), spec)

        val decryptedBytes = cipher.doFinal(encryptedBytes)
        return String(decryptedBytes, Charsets.UTF_8)
    }

    /**
     * Generate random nonce
     */
    private fun generateNonce(): ByteArray {
        val nonce = ByteArray(NONCE_LENGTH)
        SecureRandom().nextBytes(nonce)
        return nonce
    }

    /**
     * Convert encrypted token to byte array for NFC transmission
     */
    fun tokenToBytes(token: String): ByteArray {
        return Base64.decode(token, Base64.NO_WRAP)
    }

    /**
     * Convert byte array to token string
     */
    fun bytesToToken(bytes: ByteArray): String {
        return Base64.encodeToString(bytes, Base64.NO_WRAP)
    }
}
