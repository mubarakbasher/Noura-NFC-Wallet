import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/transaction.dart';
import '../../../domain/repositories/transaction_repository.dart';
import 'transaction_event.dart';
import 'transaction_state.dart';

/// Transaction BLoC - Manages transaction history and details
class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final TransactionRepository transactionRepository;

  TransactionBloc({required this.transactionRepository})
      : super(const TransactionInitial()) {
    on<LoadTransactions>(_onLoadTransactions);
    on<RefreshTransactions>(_onRefreshTransactions);
    on<LoadMoreTransactions>(_onLoadMoreTransactions);
    on<FilterTransactions>(_onFilterTransactions);
    on<GetTransactionDetail>(_onGetTransactionDetail);
    on<ValidateTransaction>(_onValidateTransaction);
  }

  Future<void> _onLoadTransactions(
    LoadTransactions event,
    Emitter<TransactionState> emit,
  ) async {
    emit(const TransactionLoading());

    final result = await transactionRepository.getTransactionHistory(
      page: event.page,
      pageSize: event.pageSize,
    );

    result.fold(
      (failure) => emit(TransactionError(failure.message)),
      (transactions) {
        final filtered = _applyFilter(transactions, event.filter ?? 'all');
        emit(TransactionLoaded(
          transactions: transactions,
          filteredTransactions: filtered,
          currentFilter: event.filter ?? 'all',
          currentPage: event.page,
          hasMore: transactions.length >= event.pageSize,
        ));
      },
    );
  }

  Future<void> _onRefreshTransactions(
    RefreshTransactions event,
    Emitter<TransactionState> emit,
  ) async {
    final currentState = state;
    String currentFilter = 'all';
    
    if (currentState is TransactionLoaded) {
      currentFilter = currentState.currentFilter;
    }

    final result = await transactionRepository.getTransactionHistory(
      page: 1,
      pageSize: 20,
    );

    result.fold(
      (failure) {
        // If refresh fails, keep current state if available
        if (currentState is TransactionLoaded) {
          emit(currentState);
        } else {
          emit(TransactionError(failure.message));
        }
      },
      (transactions) {
        final filtered = _applyFilter(transactions, currentFilter);
        emit(TransactionLoaded(
          transactions: transactions,
          filteredTransactions: filtered,
          currentFilter: currentFilter,
          currentPage: 1,
          hasMore: transactions.length >= 20,
        ));
      },
    );
  }

  Future<void> _onLoadMoreTransactions(
    LoadMoreTransactions event,
    Emitter<TransactionState> emit,
  ) async {
    if (state is! TransactionLoaded) return;

    final currentState = state as TransactionLoaded;
    if (!currentState.hasMore || currentState.isLoadingMore) return;

    emit(currentState.copyWith(isLoadingMore: true));

    final nextPage = currentState.currentPage + 1;
    final result = await transactionRepository.getTransactionHistory(
      page: nextPage,
      pageSize: 20,
    );

    result.fold(
      (failure) => emit(currentState.copyWith(isLoadingMore: false)),
      (newTransactions) {
        final allTransactions = [...currentState.transactions, ...newTransactions];
        final filtered = _applyFilter(allTransactions, currentState.currentFilter);
        emit(TransactionLoaded(
          transactions: allTransactions,
          filteredTransactions: filtered,
          currentFilter: currentState.currentFilter,
          currentPage: nextPage,
          hasMore: newTransactions.length >= 20,
          isLoadingMore: false,
        ));
      },
    );
  }

  Future<void> _onFilterTransactions(
    FilterTransactions event,
    Emitter<TransactionState> emit,
  ) async {
    if (state is! TransactionLoaded) return;

    final currentState = state as TransactionLoaded;
    final filtered = _applyFilter(currentState.transactions, event.filter);
    
    emit(currentState.copyWith(
      filteredTransactions: filtered,
      currentFilter: event.filter,
    ));
  }

  Future<void> _onGetTransactionDetail(
    GetTransactionDetail event,
    Emitter<TransactionState> emit,
  ) async {
    emit(const TransactionLoading());

    final result = await transactionRepository.getTransactionById(
      event.transactionId,
    );

    result.fold(
      (failure) => emit(TransactionError(failure.message)),
      (transaction) => emit(TransactionDetailLoaded(transaction)),
    );
  }

  /// Apply filter to transactions
  List<Transaction> _applyFilter(
    List<Transaction> transactions,
    String filter,
  ) {
    switch (filter.toLowerCase()) {
      case 'incoming':
      case 'received':
        // Transactions where user is the merchant (receiving money)
        return transactions
            .where((t) => t.metadata?['direction'] == 'incoming' ||
                         t.transactionType.toLowerCase() == 'topup')
            .toList();
      case 'outgoing':
      case 'sent':
        // Transactions where user is the payer (sending money)
        return transactions
            .where((t) => t.metadata?['direction'] == 'outgoing')
            .toList();
      case 'topup':
        return transactions
            .where((t) => t.transactionType.toLowerCase() == 'topup')
            .toList();
      case 'all':
      default:
        return transactions;
    }
  }

  /// Handle ValidateTransaction event - Process NFC payment
  Future<void> _onValidateTransaction(
    ValidateTransaction event,
    Emitter<TransactionState> emit,
  ) async {
    emit(const TransactionValidating());

    final result = await transactionRepository.validateAndProcessTransaction(
      encryptedToken: event.encryptedToken,
      amount: event.amount,
    );

    result.fold(
      (failure) => emit(TransactionFailure(failure.message)),
      (transaction) => emit(TransactionValidated(transaction)),
    );
  }
}
