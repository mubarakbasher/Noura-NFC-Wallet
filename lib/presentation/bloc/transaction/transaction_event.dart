import 'package:equatable/equatable.dart';

/// Transaction BLoC Events
abstract class TransactionEvent extends Equatable {
  const TransactionEvent();

  @override
  List<Object?> get props => [];
}

/// Load transaction history
class LoadTransactions extends TransactionEvent {
  final int page;
  final int pageSize;
  final String? filter; // 'all', 'incoming', 'outgoing', 'topup'

  const LoadTransactions({
    this.page = 1,
    this.pageSize = 20,
    this.filter,
  });

  @override
  List<Object?> get props => [page, pageSize, filter];
}

/// Refresh transactions (pull-to-refresh)
class RefreshTransactions extends TransactionEvent {
  const RefreshTransactions();
}

/// Load more transactions (pagination)
class LoadMoreTransactions extends TransactionEvent {
  const LoadMoreTransactions();
}

/// Filter transactions by type
class FilterTransactions extends TransactionEvent {
  final String filter; // 'all', 'incoming', 'outgoing', 'topup'

  const FilterTransactions(this.filter);

  @override
  List<Object?> get props => [filter];
}

/// Get single transaction details
class GetTransactionDetail extends TransactionEvent {
  final String transactionId;

  const GetTransactionDetail(this.transactionId);

  @override
  List<Object?> get props => [transactionId];
}

/// Validate and process NFC payment transaction
class ValidateTransaction extends TransactionEvent {
  final String encryptedToken;
  final double amount;
  final String? idempotencyKey;

  const ValidateTransaction({
    required this.encryptedToken,
    required this.amount,
    this.idempotencyKey,
  });

  @override
  List<Object?> get props => [encryptedToken, amount, idempotencyKey];
}

