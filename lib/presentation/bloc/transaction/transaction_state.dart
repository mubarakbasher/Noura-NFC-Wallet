import 'package:equatable/equatable.dart';
import '../../../domain/entities/transaction.dart';

/// Transaction BLoC States
abstract class TransactionState extends Equatable {
  const TransactionState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class TransactionInitial extends TransactionState {
  const TransactionInitial();
}

/// Loading transactions
class TransactionLoading extends TransactionState {
  const TransactionLoading();
}

/// Transactions loaded successfully
class TransactionLoaded extends TransactionState {
  final List<Transaction> transactions;
  final List<Transaction> filteredTransactions;
  final String currentFilter;
  final int currentPage;
  final bool hasMore;
  final bool isLoadingMore;

  const TransactionLoaded({
    required this.transactions,
    required this.filteredTransactions,
    this.currentFilter = 'all',
    this.currentPage = 1,
    this.hasMore = true,
    this.isLoadingMore = false,
  });

  TransactionLoaded copyWith({
    List<Transaction>? transactions,
    List<Transaction>? filteredTransactions,
    String? currentFilter,
    int? currentPage,
    bool? hasMore,
    bool? isLoadingMore,
  }) {
    return TransactionLoaded(
      transactions: transactions ?? this.transactions,
      filteredTransactions: filteredTransactions ?? this.filteredTransactions,
      currentFilter: currentFilter ?? this.currentFilter,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  List<Object?> get props => [
        transactions,
        filteredTransactions,
        currentFilter,
        currentPage,
        hasMore,
        isLoadingMore,
      ];
}

/// Transaction detail loaded
class TransactionDetailLoaded extends TransactionState {
  final Transaction transaction;

  const TransactionDetailLoaded(this.transaction);

  @override
  List<Object?> get props => [transaction];
}

/// Error state
class TransactionError extends TransactionState {
  final String message;

  const TransactionError(this.message);

  @override
  List<Object?> get props => [message];
}

/// LoadingMore state - used when loading more pages
class TransactionLoadingMore extends TransactionState {
  final TransactionLoaded previousState;

  const TransactionLoadingMore(this.previousState);

  @override
  List<Object?> get props => [previousState];
}

/// Validating a payment transaction
class TransactionValidating extends TransactionState {
  const TransactionValidating();
}

/// Payment transaction validated successfully
class TransactionValidated extends TransactionState {
  final Transaction transaction;

  const TransactionValidated(this.transaction);

  @override
  List<Object?> get props => [transaction];
}

/// Payment transaction validation failed
class TransactionFailure extends TransactionState {
  final String message;

  const TransactionFailure(this.message);

  @override
  List<Object?> get props => [message];
}

