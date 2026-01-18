import 'package:equatable/equatable.dart';
import '../../../domain/entities/transaction.dart';

/// Wallet States
abstract class WalletState extends Equatable {
  const WalletState();

  @override
  List<Object?> get props => [];
}

class WalletInitial extends WalletState {}

class WalletLoading extends WalletState {}

class WalletLoaded extends WalletState {
  final double balance;
  final List<Transaction> transactions;
  final String walletId;

  const WalletLoaded({
    required this.balance,
    required this.transactions,
    required this.walletId,
  });

  @override
  List<Object?> get props => [balance, transactions, walletId];

  WalletLoaded copyWith({
    double? balance,
    List<Transaction>? transactions,
    String? walletId,
  }) {
    return WalletLoaded(
      balance: balance ?? this.balance,
      transactions: transactions ?? this.transactions,
      walletId: walletId ?? this.walletId,
    );
  }
}

class WalletTransactionSuccess extends WalletState {
  final double amount;
  final bool isCredit;
  final WalletLoaded wallet;

  const WalletTransactionSuccess({
    required this.amount,
    required this.isCredit,
    required this.wallet,
  });

  @override
  List<Object?> get props => [amount, isCredit, wallet];
}

class WalletError extends WalletState {
  final String message;

  const WalletError(this.message);

  @override
  List<Object?> get props => [message];
}
