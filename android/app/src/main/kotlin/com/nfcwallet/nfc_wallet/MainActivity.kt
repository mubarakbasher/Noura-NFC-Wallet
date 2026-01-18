package com.nfcwallet.nfc_wallet

import android.content.Context
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity: FlutterActivity() {

    private lateinit var nfcReaderManager: NfcReaderManager
    private lateinit var securityManager: SecurityManager
    private lateinit var nfcMethodChannel: NfcMethodChannel

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Initialize components
        nfcReaderManager = NfcReaderManager(this)
        securityManager = SecurityManager(this)

        val sharedPreferences = getSharedPreferences("nfc_wallet_prefs", Context.MODE_PRIVATE)
        
        nfcMethodChannel = NfcMethodChannel(
            flutterEngine,
            nfcReaderManager,
            securityManager,
            sharedPreferences
        )

        nfcMethodChannel.initialize()
    }

    override fun onResume() {
        super.onResume()
        // NFC reader mode will be enabled from Flutter when needed
    }

    override fun onPause() {
        super.onPause()
        // Disable reader mode when app is paused
        nfcReaderManager.disableReaderMode()
    }

    override fun onDestroy() {
        super.onDestroy()
        nfcMethodChannel.dispose()
    }
}
