package com.nfcwallet.nfc_wallet

import android.nfc.cardemulation.HostApduService
import android.os.Bundle
import android.util.Log

/**
 * NFC Host Card Emulation Service
 * Handles APDU commands when device acts as an NFC card
 */
class NfcHceService : HostApduService() {

    companion object {
        private const val TAG = "NfcHceService"
        
        // Custom AID
        private val CUSTOM_AID = byteArrayOf(
            0xF0.toByte(), 0x01, 0x02, 0x03, 0x04, 0x05, 0x06
        )
        
        // APDU Commands
        private const val SELECT_APDU_HEADER = "00A40400"
        private const val GET_TOKEN_COMMAND: Byte = 0xC0.toByte()
        
        // Response codes
        private val SUCCESS = byteArrayOf(0x90.toByte(), 0x00)
        private val ERROR = byteArrayOf(0x6F.toByte(), 0x00)
        private val AUTHENTICATION_REQUIRED = byteArrayOf(0x69.toByte(), 0x82.toByte())
        
        // Shared instance for communication with Flutter
        var currentToken: ByteArray? = null
        
        // Callback when token is successfully sent
        var onTokenSent: (() -> Unit)? = null
        
        // Track if token was successfully sent in this session
        var tokenWasSent: Boolean = false
    }

    override fun processCommandApdu(commandApdu: ByteArray?, extras: Bundle?): ByteArray {
        if (commandApdu == null) {
            Log.w(TAG, "Received null APDU")
            return ERROR
        }

        Log.d(TAG, "Received APDU: ${bytesToHex(commandApdu)}")

        return when {
            isSelectAidApdu(commandApdu) -> {
                Log.d(TAG, "SELECT AID command received")
                handleSelectAid(commandApdu)
            }
            isGetTokenApdu(commandApdu) -> {
                Log.d(TAG, "GET TOKEN command received")
                handleGetToken()
            }
            else -> {
                Log.w(TAG, "Unknown command received")
                ERROR
            }
        }
    }

    override fun onDeactivated(reason: Int) {
        Log.d(TAG, "Service deactivated. Reason: $reason, tokenWasSent: $tokenWasSent")
        
        // If token was successfully sent, notify Flutter
        if (tokenWasSent) {
            Log.d(TAG, "Payment was successful! Notifying Flutter...")
            onTokenSent?.invoke()
            tokenWasSent = false
        }
        
        // Clear token after transaction
        currentToken = null
    }

    /**
     * Check if APDU is SELECT AID command
     */
    private fun isSelectAidApdu(apdu: ByteArray): Boolean {
        if (apdu.size < 5) return false
        
        // Check if it's a SELECT command (CLA=00, INS=A4, P1=04, P2=00)
        return apdu[0] == 0x00.toByte() &&
               apdu[1] == 0xA4.toByte() &&
               apdu[2] == 0x04.toByte() &&
               apdu[3] == 0x00.toByte()
    }

    /**
     * Handle SELECT AID APDU
     */
    private fun handleSelectAid(apdu: ByteArray): ByteArray {
        // Extract AID from APDU
        if (apdu.size < 12) return ERROR
        
        val aidLength = apdu[4].toInt() and 0xFF
        if (apdu.size < 5 + aidLength) return ERROR
        
        val receivedAid = apdu.copyOfRange(5, 5 + aidLength)
        
        // Verify our custom AID
        if (receivedAid.contentEquals(CUSTOM_AID)) {
            Log.d(TAG, "Custom AID selected successfully")
            return SUCCESS
        }
        
        Log.w(TAG, "Unknown AID: ${bytesToHex(receivedAid)}")
        return ERROR
    }

    /**
     * Check if APDU is GET TOKEN command
     */
    private fun isGetTokenApdu(apdu: ByteArray): Boolean {
        if (apdu.size < 5) return false
        return apdu[1] == GET_TOKEN_COMMAND
    }

    /**
     * Handle GET TOKEN APDU
     */
    private fun handleGetToken(): ByteArray {
        val token = currentToken
        
        if (token == null) {
            Log.w(TAG, "No token available")
            return AUTHENTICATION_REQUIRED
        }
        
        // Mark that token was successfully sent
        tokenWasSent = true
        
        // Return token + success status
        Log.d(TAG, "Sending token (${token.size} bytes) - Payment successful!")
        return token + SUCCESS
    }

    /**
     * Convert byte array to hex string for logging
     */
    private fun bytesToHex(bytes: ByteArray): String {
        return bytes.joinToString("") { "%02X".format(it) }
    }
}
