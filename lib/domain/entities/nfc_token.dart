import 'package:equatable/equatable.dart';

/// NFC Token entity - Domain model for secure payment tokens
class NfcToken extends Equatable {
  final String userId;
  final String walletId;
  final double amount;
  final int timestamp;
  final String nonce;
  final String deviceId;
  final String signature;
  final String encryptedData;

  const NfcToken({
    required this.userId,
    required this.walletId,
    required this.amount,
    required this.timestamp,
    required this.nonce,
    required this.deviceId,
    required this.signature,
    required this.encryptedData,
  });

  /// Check if token is still valid (within 2 minutes)
  bool get isValid {
    final now = DateTime.now().millisecondsSinceEpoch;
    final tokenTime = timestamp;
    final difference = now - tokenTime;
    // Valid for 2 minutes = 120,000 milliseconds
    return difference <= 120000 && difference >= 0;
  }

  /// Check if token is expired
  bool get isExpired => !isValid;

  @override
  List<Object?> get props => [
        userId,
        walletId,
        amount,
        timestamp,
        nonce,
        deviceId,
        signature,
        encryptedData,
      ];
}
