import 'package:equatable/equatable.dart';
import '../../../domain/entities/nfc_token.dart';

/// NFC States
abstract class NfcState extends Equatable {
  const NfcState();

  @override
  List<Object?> get props => [];
}

class NfcInitial extends NfcState {}

class NfcChecking extends NfcState {}

class NfcAvailable extends NfcState {}

class NfcUnavailable extends NfcState {
  final String reason;

  const NfcUnavailable(this.reason);

  @override
  List<Object?> get props => [reason];
}

// HCE States
class HceActivating extends NfcState {}

class HceActive extends NfcState {
  final NfcToken token;

  const HceActive(this.token);

  @override
  List<Object?> get props => [token];
}

class HceInactive extends NfcState {}

/// State when payment was successfully sent via HCE (payer side)
class HcePaymentSent extends NfcState {
  final double amount;

  const HcePaymentSent(this.amount);

  @override
  List<Object?> get props => [amount];
}

// Reader States
class ReaderActivating extends NfcState {}

class ReaderActive extends NfcState {}

class ReaderWaitingForTag extends NfcState {}

class ReaderTagDetected extends NfcState {
  final String token;

  const ReaderTagDetected(this.token);

  @override
  List<Object?> get props => [token];
}

class ReaderInactive extends NfcState {}

// Error State
class NfcFailureState extends NfcState {
  final String message;

  const NfcFailureState(this.message);

  @override
  List<Object?> get props => [message];
}
