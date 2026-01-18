package com.nfcwallet.nfc_wallet

import android.content.Context
import android.security.keystore.KeyGenParameterSpec
import android.security.keystore.KeyProperties
import android.util.Base64
import android.util.Log
import java.security.KeyStore
import java.security.SecureRandom
import javax.crypto.Cipher
import javax.crypto.KeyGenerator
import javax.crypto.SecretKey
import javax.crypto.spec.GCMParameterSpec
import org.json.JSONObject

/**
 * Security Manager
 * Handles encryption, token generation, and secure key storage
 */
class SecurityManager(private val context: Context) {

    companion object {
        private const val TAG = "SecurityManager"
        private const val KEYSTORE_PROVIDER = "AndroidKeyStore"
        private const val KEY_ALIAS = "nfc_wallet_key"
        private const val TRANSFORMATION = "AES/GCM/NoPadding"
        private const val GCM_TAG_LENGTH = 128
        private const val NONCE_LENGTH = 32
    }

    private val keyStore: KeyStore = KeyStore.getInstance(KEYSTORE_PROVIDER).apply {
        load(null)
    }

    init {
        // Generate key if it doesn't exist
        if (!keyStore.containsAlias(KEY_ALIAS)) {
            generateKey()
        }
    }

    /**
     * Generate encryption key in Android Keystore
     */
    private fun generateKey() {
        val keyGenerator = KeyGenerator.getInstance(
            KeyProperties.KEY_ALGORITHM_AES,
            KEYSTORE_PROVIDER
        )

        val keyGenParameterSpec = KeyGenParameterSpec.Builder(
            KEY_ALIAS,
            KeyProperties.PURPOSE_ENCRYPT or KeyProperties.PURPOSE_DECRYPT
        )
            .setBlockModes(KeyProperties.BLOCK_MODE_GCM)
            .setEncryptionPaddings(KeyProperties.ENCRYPTION_PADDING_NONE)
            .setUserAuthenticationRequired(false)
            .build()

        keyGenerator.init(keyGenParameterSpec)
        keyGenerator.generateKey()
        
        Log.d(TAG, "Encryption key generated")
    }

    /**
     * Get encryption key from Keystore
     */
    private fun getKey(): SecretKey {
        return keyStore.getKey(KEY_ALIAS, null) as SecretKey
    }

    /**
     * Generate NFC payment token
     */
    fun generateNfcToken(
        userId: String,
        walletId: String,
        deviceId: String
    ): String {
        // Generate nonce
        val nonce = generateNonce()
        val timestamp = System.currentTimeMillis()

        // Create token payload
        val payload = JSONObject().apply {
            put("userId", userId)
            put("walletId", walletId)
            put("amount", 0) // Amount determined by merchant
            put("timestamp", timestamp)
            put("nonce", Base64.encodeToString(nonce, Base64.NO_WRAP))
            put("deviceId", deviceId)
        }

        // Encrypt payload
        val encryptedData = encrypt(payload.toString())
        
        Log.d(TAG, "NFC token generated")
        return encryptedData
    }

    /**
     * Encrypt data using AES-GCM
     */
    private fun encrypt(plaintext: String): String {
        val cipher = Cipher.getInstance(TRANSFORMATION)
        cipher.init(Cipher.ENCRYPT_MODE, getKey())

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
        cipher.init(Cipher.DECRYPT_MODE, getKey(), spec)

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
