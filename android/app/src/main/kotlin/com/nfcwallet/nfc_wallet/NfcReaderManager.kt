package com.nfcwallet.nfc_wallet

import android.app.Activity
import android.nfc.NfcAdapter
import android.nfc.Tag
import android.nfc.tech.IsoDep
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
        Log.d(TAG, "Tag discovered: ${tag.id.joinToString("") { "%02X".format(it) }}")

        val isoDep = IsoDep.get(tag)
        if (isoDep == null) {
            Log.w(TAG, "Tag does not support IsoDep")
            onError?.invoke("Incompatible NFC tag")
            return
        }

        try {
            isoDep.connect()
            Log.d(TAG, "Connected to  tag")

            // Step 1: Select AID
            val selectResponse = isoDep.transceive(SELECT_APDU)
            Log.d(TAG, "SELECT response: ${bytesToHex(selectResponse)}")

            if (!isSuccess(selectResponse)) {
                Log.w(TAG, "SELECT AID failed")
                onError?.invoke("Failed to select payment application")
                isoDep.close()
                return
            }

            // Step 2: Get payment token
            val tokenResponse = isoDep.transceive(GET_TOKEN_APDU)
            Log.d(TAG, "GET TOKEN response: ${bytesToHex(tokenResponse)}")

            if (!isSuccess(tokenResponse)) {
                Log.w(TAG, "GET TOKEN failed")
                onError?.invoke("Failed to retrieve payment token")
                isoDep.close()
                return
            }

            // Extract token (remove status bytes 9000)
            val token = tokenResponse.copyOfRange(0, tokenResponse.size - 2)
            val tokenHex = bytesToHex(token)
            
            Log.d(TAG, "Token received successfully (${token.size} bytes)")
            onTokenReceived?.invoke(tokenHex)

            isoDep.close()
        } catch (e: IOException) {
            Log.e(TAG, "Error communicating with tag", e)
            onError?.invoke("Communication error: ${e.message}")
            try {
                isoDep.close()
            } catch (closeError: IOException) {
                Log.e(TAG, "Error closing connection", closeError)
            }
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
