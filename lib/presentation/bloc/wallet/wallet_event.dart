import 'package:equatable/equatable.dart';
import '../../../domain/entities/transaction.dart';

/// Wallet Events
abstract class WalletEvent extends Equatable {
  const WalletEvent();

  @override
  List<Object?> get props => [];
}

class LoadWallet extends WalletEvent {}

class RefreshWallet extends WalletEvent {}

/// Event to reset wallet state on logout
class ResetWallet extends WalletEvent {}

class NfcTransactionCompleted extends WalletEvent {
  final double amount;
  final bool isCredit; // true for receiving, false for sending
  final String? merchantName;
  final String? token; // Encrypted token from NFC tag

  const NfcTransactionCompleted({
    required this.amount,
    required this.isCredit,
    this.merchantName,
    this.token,
  });

  @override
  List<Object?> get props => [amount, isCredit, merchantName, token];
}

class AddTransaction extends WalletEvent {
  final Transaction transaction;

  const AddTransaction(this.transaction);

  @override
  List<Object?> get props => [transaction];
}

class UpdateBalance extends WalletEvent {
  final double newBalance;

  const UpdateBalance(this.newBalance);

  @override
  List<Object?> get props => [newBalance];
}

