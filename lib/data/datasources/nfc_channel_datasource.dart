import 'package:flutter/services.dart';
import '../../core/constants/nfc_constants.dart';
import '../../core/errors/exceptions.dart';
import 'dart:async';

/// NFC Channel Data Source
/// Communicates with Android native layer via MethodChannel
class NfcChannelDatasource {
  static const MethodChannel _methodChannel =
      MethodChannel(NfcConstants.methodChannelName);
  
  static const EventChannel _eventChannel =
      EventChannel(NfcConstants.eventChannelName);

  Stream<Map<String, dynamic>>? _nfcEventStream;

  /// Check if NFC is available on device
  Future<bool> checkNfcAvailability() async {
    try {
      final result = await _methodChannel.invokeMethod<bool>('checkNFCAvailability');
      return result ?? false;
    } on PlatformException catch (e) {
      throw NfcException('Failed to check NFC availability: ${e.message}', e.code.hashCode);
    } catch (e) {
      throw NfcException('Unexpected error checking NFC: $e');
    }
  }

  /// Enable HCE mode
  Future<void> enableHce() async {
    try {
      await _methodChannel.invokeMethod('enableHCE');
    } on PlatformException catch (e) {
      throw NfcException('Failed to enable HCE: ${e.message}', e.code.hashCode);
    } catch (e) {
      throw NfcException('Unexpected error enabling HCE: $e');
    }
  }

  /// Disable HCE mode
  Future<void> disableHce() async {
    try {
      await _methodChannel.invokeMethod('disableHCE');
    } on PlatformException catch (e) {
      throw NfcException('Failed to disable HCE: ${e.message}', e.code.hashCode);
    } catch (e) {
      throw NfcException('Unexpected error disabling HCE: $e');
    }
  }

  /// Start NFC reader mode
  Future<void> startReaderMode() async {
    try {
      await _methodChannel.invokeMethod('startReaderMode');
    } on PlatformException catch (e) {
      throw NfcException('Failed to start reader mode: ${e.message}', e.code.hashCode);
    } catch (e) {
      throw NfcException('Unexpected error starting reader mode: $e');
    }
  }

  /// Stop NFC reader mode
  Future<void> stopReaderMode() async {
    try {
      await _methodChannel.invokeMethod('stopReaderMode');
    } on PlatformException catch (e) {
      throw NfcException('Failed to stop reader mode: ${e.message}', e.code.hashCode);
    } catch (e) {
      throw NfcException('Unexpected error stopping reader mode: $e');
    }
  }

  /// Generate NFC token with payment amount
  Future<String> generateNfcToken({
    required String userId,
    required String walletId,
    required String deviceId,
    required double amount,
  }) async {
    try {
      final token = await _methodChannel.invokeMethod<String>(
        'generateNFCToken',
        {
          'userId': userId,
          'walletId': walletId,
          'deviceId': deviceId,
          'amount': amount,
        },
      );
      
      if (token == null) {
        throw NfcException('Token generation returned null');
      }
      
      return token;
    } on PlatformException catch (e) {
      throw NfcException('Failed to generate token: ${e.message}', e.code.hashCode);
    } catch (e) {
      throw NfcException('Unexpected error generating token: $e');
    }
  }

  /// Get stream of NFC events
  Stream<Map<String, dynamic>> get nfcEventStream {
    _nfcEventStream ??= _eventChannel
        .receiveBroadcastStream()
        .map((event) => Map<String, dynamic>.from(event as Map));
    return _nfcEventStream!;
  }
}
