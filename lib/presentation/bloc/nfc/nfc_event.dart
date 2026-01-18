import 'package:equatable/equatable.dart';
import '../../../domain/entities/nfc_token.dart';

/// NFC Events
abstract class NfcEvent extends Equatable {
  const NfcEvent();

  @override
  List<Object?> get props => [];
}

class CheckNfcAvailability extends NfcEvent {}

class EnableHceMode extends NfcEvent {
  final String userId;
  final String walletId;
  final String deviceId;

  const EnableHceMode({
    required this.userId,
    required this.walletId,
    required this.deviceId,
  });

  @override
  List<Object?> get props => [userId, walletId, deviceId];
}

class DisableHceMode extends NfcEvent {}

class StartReaderMode extends NfcEvent {}

class StopReaderMode extends NfcEvent {}

class TokenReceived extends NfcEvent {
  final String token;

  const TokenReceived(this.token);

  @override
  List<Object?> get props => [token];
}

class NfcError extends NfcEvent {
  final String message;

  const NfcError(this.message);

  @override
  List<Object?> get props => [message];
}
