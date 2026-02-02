package com.nfcwallet.nfc_wallet

import android.content.SharedPreferences
import android.os.Handler
import android.os.Looper
import android.util.Log
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

/**
 * NFC Method Channel
 * Bridge between Flutter and Android native NFC functionality
 */
class NfcMethodChannel(
    private val flutterEngine: FlutterEngine,
    private val nfcReaderManager: NfcReaderManager,
    private val securityManager: SecurityManager,
    private val sharedPreferences: SharedPreferences
) {

    companion object {
        private const val TAG = "NfcMethodChannel"
        private const val METHOD_CHANNEL_NAME = "com.graduation.nfc_wallet/nfc"
        private const val EVENT_CHANNEL_NAME = "com.graduation.nfc_wallet/nfc_events"
    }

    private var methodChannel: MethodChannel? = null
    private var eventChannel: EventChannel? = null
    private var eventSink: EventChannel.EventSink? = null
    
    // Main thread handler for posting events
    private val mainHandler = Handler(Looper.getMainLooper())

    /**
     * Initialize method channel
     */
    fun initialize() {
        methodChannel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            METHOD_CHANNEL_NAME
        )

        methodChannel?.setMethodCallHandler { call, result ->
            Log.d(TAG, "Method called: ${call.method}")
            
            when (call.method) {
                "checkNFCAvailability" -> {
                    handleCheckNfcAvailability(result)
                }
                "startReaderMode" -> {
                    handleStartReaderMode(result)
                }
                "stopReaderMode" -> {
                    handleStopReaderMode(result)
                }
                "enableHCE" -> {
                    handleEnableHce(result)
                }
                "disableHCE" -> {
                    handleDisableHce(result)
                }
                "generateNFCToken" -> {
                    val userId = call.argument<String>("userId")
                    val walletId = call.argument<String>("walletId")
                    val deviceId = call.argument<String>("deviceId")
                    val amount = call.argument<Double>("amount")
                    handleGenerateToken(userId, walletId, deviceId, amount, result)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }

        // Initialize event channel for NFC events
        eventChannel = EventChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            EVENT_CHANNEL_NAME
        )

        eventChannel?.setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                eventSink = events
                Log.d(TAG, "=== EVENT STREAM LISTENER ATTACHED ===")
                Log.d(TAG, "eventSink is now: ${if (eventSink != null) "SET" else "NULL"}")
            }

            override fun onCancel(arguments: Any?) {
                eventSink = null
                Log.d(TAG, "=== EVENT STREAM LISTENER CANCELLED ===")
            }
        })

        Log.d(TAG, "Method channel initialized")
    }

    /**
     * Check NFC availability
     */
    private fun handleCheckNfcAvailability(result: MethodChannel.Result) {
        try {
            val isAvailable = nfcReaderManager.isNfcAvailable()
            result.success(isAvailable)
        } catch (e: Exception) {
            Log.e(TAG, "Error checking NFC availability", e)
            result.error("NFC_ERROR", e.message, null)
        }
    }

    /**
     * Start NFC Reader Mode
     */
    private fun handleStartReaderMode(result: MethodChannel.Result) {
        try {
            Log.d(TAG, "=== STARTING READER MODE ===")
            Log.d(TAG, "Event sink available: ${eventSink != null}")
            
            nfcReaderManager.enableReaderMode(
                onTokenReceived = { token ->
                    Log.d(TAG, "=== TOKEN RECEIVED IN METHOD CHANNEL ===")
                    Log.d(TAG, "Token length: ${token.length}")
                    
                    // Post to main thread to avoid threading issues
                    mainHandler.post {
                        Log.d(TAG, "Sending event to Flutter on main thread")
                        Log.d(TAG, "Event sink available: ${eventSink != null}")
                        
                        val eventData = mapOf(
                            "event" to "onTokenReceived",
                            "token" to token
                        )
                        eventSink?.success(eventData)
                        Log.d(TAG, "Event sent to Flutter!")
                    }
                },
                onError = { error ->
                    Log.e(TAG, "=== READER ERROR ===")
                    Log.e(TAG, "Error: $error")
                    
                    // Post error to main thread
                    mainHandler.post {
                        eventSink?.error("READER_ERROR", error, null)
                    }
                }
            )
            Log.d(TAG, "Reader mode enabled successfully")
            result.success(true)
        } catch (e: Exception) {
            Log.e(TAG, "Error starting reader mode", e)
            result.error("READER_ERROR", e.message, null)
        }
    }

    /**
     * Stop NFC Reader Mode
     */
    private fun handleStopReaderMode(result: MethodChannel.Result) {
        try {
            nfcReaderManager.disableReaderMode()
            result.success(true)
        } catch (e: Exception) {
            Log.e(TAG, "Error stopping reader mode", e)
            result.error("READER_ERROR", e.message, null)
        }
    }

    /**
     * Enable HCE Mode
     */
    private fun handleEnableHce(result: MethodChannel.Result) {
        try {
            // Set up callback for when payment is completed
            NfcHceService.onTokenSent = {
                Log.d(TAG, "=== PAYMENT SENT CALLBACK TRIGGERED ===")
                Log.d(TAG, "eventSink status: ${if (eventSink != null) "AVAILABLE" else "NULL"}")
                // Notify Flutter that payment was sent successfully
                mainHandler.post {
                    Log.d(TAG, "Posting to main thread - eventSink: ${if (eventSink != null) "AVAILABLE" else "NULL"}")
                    if (eventSink != null) {
                        Log.d(TAG, "Sending payment_sent event to Flutter")
                        eventSink?.success(mapOf(
                            "event" to "onPaymentSent",
                            "success" to true
                        ))
                        Log.d(TAG, "Event sent successfully!")
                    } else {
                        Log.e(TAG, "ERROR: eventSink is null, cannot send event to Flutter!")
                    }
                }
            }
            
            // Reset the sent flag
            NfcHceService.tokenWasSent = false
            
            result.success(true)
            Log.d(TAG, "HCE mode enabled with callback")
        } catch (e: Exception) {
            Log.e(TAG, "Error enabling HCE", e)
            result.error("HCE_ERROR", e.message, null)
        }
    }

    /**
     * Disable HCE Mode
     */
    private fun handleDisableHce(result: MethodChannel.Result) {
        try {
            // Clear current token
            NfcHceService.currentToken = null
            result.success(true)
            Log.d(TAG, "HCE mode disabled")
        } catch (e: Exception) {
            Log.e(TAG, "Error disabling HCE", e)
            result.error("HCE_ERROR", e.message, null)
        }
    }

    /**
     * Generate NFC Token
     */
    private fun handleGenerateToken(
        userId: String?,
        walletId: String?,
        deviceId: String?,
        amount: Double?,
        result: MethodChannel.Result
    ) {
        if (userId == null || walletId == null || deviceId == null) {
            result.error("INVALID_ARGS", "Missing required arguments", null)
            return
        }

        try {
            val tokenAmount = amount ?: 0.0
            val token = securityManager.generateNfcToken(userId, walletId, deviceId, tokenAmount)
            val tokenBytes = securityManager.tokenToBytes(token)
            
            // Store token in HCE service for NFC transmission
            NfcHceService.currentToken = tokenBytes
            
            Log.d(TAG, "Token generated and stored for HCE with amount: $tokenAmount")
            Log.d(TAG, "Token bytes length: ${tokenBytes.size}")
            result.success(token)
        } catch (e: Exception) {
            Log.e(TAG, "Error generating token", e)
            result.error("TOKEN_ERROR", e.message, null)
        }
    }

    /**
     * Cleanup
     */
    fun dispose() {
        methodChannel?.setMethodCallHandler(null)
        eventChannel?.setStreamHandler(null)
        eventSink = null
        Log.d(TAG, "Method channel disposed")
    }
}
