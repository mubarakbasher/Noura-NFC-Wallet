import 'package:equatable/equatable.dart';
import '../../../domain/entities/transaction.dart';

/// Wallet Events
abstract class WalletEvent extends Equatable {
  const WalletEvent();

  @override
  List<Object?> get props => [];
}

class LoadWallet extends WalletEvent {}

class NfcTransactionCompleted extends WalletEvent {
  final double amount;
  final bool isCredit; // true for receiving, false for sending
  final String? merchantName;

  const NfcTransactionCompleted({
    required this.amount,
    required this.isCredit,
    this.merchantName,
  });

  @override
  List<Object?> get props => [amount, isCredit, merchantName];
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
