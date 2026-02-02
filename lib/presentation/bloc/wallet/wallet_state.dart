import 'package:equatable/equatable.dart';
import '../../../domain/entities/transaction.dart';
import '../../../domain/entities/wallet.dart';

/// Wallet States
abstract class WalletState extends Equatable {
  const WalletState();

  @override
  List<Object?> get props => [];
}

class WalletInitial extends WalletState {}

class WalletLoading extends WalletState {}

class WalletLoaded extends WalletState {
  final Wallet wallet;
  final List<Transaction> transactions;

  const WalletLoaded({
    required this.wallet,
    required this.transactions,
  });

  @override
  List<Object?> get props => [wallet, transactions];

  WalletLoaded copyWith({
    Wallet? wallet,
    List<Transaction>? transactions,
  }) {
    return WalletLoaded(
      wallet: wallet ?? this.wallet,
      transactions: transactions ?? this.transactions,
    );
  }

  // Convenience getters
  String get id => wallet.id;
  double get balance => wallet.balance;
  String get currency => wallet.currency;
  String get userId => wallet.userId;
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

  // Convenience getters (delegate to the internal WalletLoaded state)
  String get id => wallet.id;
  double get balance => wallet.balance;
  String get currency => wallet.currency;
  String get userId => wallet.userId;
  List<Transaction> get transactions => wallet.transactions;
}

class WalletError extends WalletState {
  final String message;

  const WalletError(this.message);

  @override
  List<Object?> get props => [message];
}
