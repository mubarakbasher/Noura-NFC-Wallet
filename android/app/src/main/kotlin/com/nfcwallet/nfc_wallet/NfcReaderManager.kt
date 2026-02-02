package com.nfcwallet.nfc_wallet

import android.app.Activity
import android.nfc.NfcAdapter
import android.nfc.Tag
import android.nfc.tech.IsoDep
import android.util.Base64
import android.util.Log
import java.io.IOException

/**
 * NFC Reader Mode Manager
 * Handles NFC reader functionality for POS mode
 */
class NfcReaderManager(private val activity: Activity) {

    companion object {
        private const val TAG = "NfcReaderManager"
        
        // Custom AID
        private val CUSTOM_AID = byteArrayOf(
            0xF0.toByte(), 0x01, 0x02, 0x03, 0x04, 0x05, 0x06
        )
        
        // APDU Commands
        private val SELECT_APDU = byteArrayOf(
            0x00, // CLA
            0xA4.toByte(), // INS (SELECT)
            0x04, // P1
            0x00, // P2
            0x07, // Lc (length of AID)
            0xF0.toByte(), 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, // AID
            0x00  // Le
        )
        
        private val GET_TOKEN_APDU = byteArrayOf(
            0x00, // CLA
            0xC0.toByte(), // INS (GET DATA)
            0x00, // P1
            0x00, // P2
            0x00  // Le (max expected length)
        )
    }

    private var nfcAdapter: NfcAdapter? = null
    private var isReading = false
    private var onTokenReceived: ((String) -> Unit)? = null
    private var onError: ((String) -> Unit)? = null

    init {
        nfcAdapter = NfcAdapter.getDefaultAdapter(activity)
    }

    /**
     * Check if NFC is available and enabled
     */
    fun isNfcAvailable(): Boolean {
        val adapter = nfcAdapter
        if (adapter == null) {
            Log.w(TAG, "NFC not available on this device")
            return false
        }
        
        if (!adapter.isEnabled) {
            Log.w(TAG, "NFC is disabled")
            return false
        }
        
        return true
    }

    /**
     * Enable NFC Reader Mode
     */
    fun enableReaderMode(
        onTokenReceived: (String) -> Unit,
        onError: (String) -> Unit
    ) {
        if (!isNfcAvailable()) {
            onError("NFC is not available or enabled")
            return
        }

        this.onTokenReceived = onTokenReceived
        this.onError = onError
        isReading = true

        val flags = NfcAdapter.FLAG_READER_NFC_A or
                    NfcAdapter.FLAG_READER_SKIP_NDEF_CHECK

        nfcAdapter?.enableReaderMode(
            activity,
            { tag -> handleTag(tag) },
            flags,
            null
        )

        Log.d(TAG, "Reader mode enabled")
    }

    /**
     * Disable NFC Reader Mode
     */
    fun disableReaderMode() {
        nfcAdapter?.disableReaderMode(activity)
        isReading = false
        onTokenReceived = null
        onError = null
        Log.d(TAG, "Reader mode disabled")
    }

    /**
     * Handle discovered NFC tag
     */
    private fun handleTag(tag: Tag) {
        Log.d(TAG, "=== NFC TAG DISCOVERED ===")
        Log.d(TAG, "Tag ID: ${tag.id.joinToString("") { "%02X".format(it) }}")
        Log.d(TAG, "Tag tech list: ${tag.techList.joinToString()}")

        val isoDep = IsoDep.get(tag)
        if (isoDep == null) {
            Log.w(TAG, "Tag does not support IsoDep - available: ${tag.techList.joinToString()}")
            onError?.invoke("Incompatible NFC tag (no IsoDep)")
            return
        }

        try {
            isoDep.timeout = 5000 // 5 second timeout
            isoDep.connect()
            Log.d(TAG, "Connected to tag, max transceive: ${isoDep.maxTransceiveLength}")

            // Step 1: Select AID
            Log.d(TAG, "Sending SELECT AID command...")
            val selectResponse = isoDep.transceive(SELECT_APDU)
            Log.d(TAG, "SELECT response (${selectResponse.size} bytes): ${bytesToHex(selectResponse)}")

            if (!isSuccess(selectResponse)) {
                Log.w(TAG, "SELECT AID failed with response: ${bytesToHex(selectResponse)}")
                onError?.invoke("Failed to select payment app")
                isoDep.close()
                return
            }
            Log.d(TAG, "SELECT AID successful!")

            // Step 2: Get payment token
            Log.d(TAG, "Sending GET TOKEN command...")
            val tokenResponse = isoDep.transceive(GET_TOKEN_APDU)
            Log.d(TAG, "GET TOKEN response (${tokenResponse.size} bytes)")
            
            // Debug: Show last 4 bytes
            if (tokenResponse.size >= 4) {
                val lastBytes = tokenResponse.takeLast(4).toByteArray()
                Log.d(TAG, "Last 4 bytes: ${bytesToHex(lastBytes)}")
            }

            // Check for common error codes first
            if (tokenResponse.size == 2) {
                val sw = bytesToHex(tokenResponse)
                Log.w(TAG, "Received status word only: $sw")
                when (sw) {
                    "6982" -> onError?.invoke("Payment not ready - payer must enable payment mode first")
                    "6A82" -> onError?.invoke("Payment app not found")
                    "6F00" -> onError?.invoke("Unknown error on payment device")
                    else -> onError?.invoke("Payment error: $sw")
                }
                isoDep.close()
                return
            }

            if (!isSuccess(tokenResponse)) {
                Log.w(TAG, "GET TOKEN response doesn't end with 9000")
                Log.w(TAG, "Response size: ${tokenResponse.size}")
                if (tokenResponse.size > 10) {
                    Log.w(TAG, "First 10 bytes: ${bytesToHex(tokenResponse.take(10).toByteArray())}")
                    Log.w(TAG, "Last 10 bytes: ${bytesToHex(tokenResponse.takeLast(10).toByteArray())}")
                }
                onError?.invoke("Invalid payment response")
                isoDep.close()
                return
            }

            // Extract token (remove status bytes 9000)
            val token = tokenResponse.copyOfRange(0, tokenResponse.size - 2)
            Log.d(TAG, "Token extracted: ${token.size} bytes")
            
            // Convert to Base64 for Flutter
            val tokenBase64 = Base64.encodeToString(token, Base64.NO_WRAP)
            
            Log.d(TAG, "=== TOKEN RECEIVED SUCCESSFULLY ===")
            Log.d(TAG, "Token size: ${token.size} bytes")
            
            // Send to Flutter via callback
            onTokenReceived?.invoke(tokenBase64)
            Log.d(TAG, "Token sent to Flutter callback")

            isoDep.close()
            Log.d(TAG, "Connection closed")
        } catch (e: IOException) {
            Log.e(TAG, "=== NFC ERROR ===")
            Log.e(TAG, "Error communicating with tag: ${e.message}", e)
            onError?.invoke("NFC error: ${e.message}")
            try {
                isoDep.close()
            } catch (closeError: IOException) {
                Log.e(TAG, "Error closing connection", closeError)
            }
        } catch (e: Exception) {
            Log.e(TAG, "=== UNEXPECTED ERROR ===")
            Log.e(TAG, "Unexpected error: ${e.message}", e)
            onError?.invoke("Unexpected error: ${e.message}")
        }
    }

    /**
     * Check if APDU response indicates success (9000)
     */
    private fun isSuccess(response: ByteArray): Boolean {
        if (response.size < 2) return false
        return response[response.size - 2] == 0x90.toByte() &&
               response[response.size - 1] == 0x00.toByte()
    }

    /**
     * Convert byte array to hex string
     */
    private fun bytesToHex(bytes: ByteArray): String {
        return bytes.joinToString("") { "%02X".format(it) }
    }
}
