import 'package:flutter_bloc/flutter_bloc.dart';
import 'wallet_event.dart';
import 'wallet_state.dart';
import '../../../domain/entities/transaction.dart';
import '../../../data/datasources/wallet_remote_datasource.dart';
import '../../../core/errors/exceptions.dart';
import '../../../core/utils/logger.dart';

/// Wallet BLoC
/// Manages wallet balance and transactions with real backend integration
class WalletBloc extends Bloc<WalletEvent, WalletState> {
  final WalletRemoteDataSource walletDataSource;

  WalletBloc({required this.walletDataSource}) : super(WalletInitial()) {
    on<LoadWallet>(_onLoadWallet);
    on<NfcTransactionCompleted>(_onNfcTransactionCompleted);
    on<AddTransaction>(_onAddTransaction);
    on<UpdateBalance>(_onUpdateBalance);
    on<RefreshWallet>(_onRefreshWallet);
    on<ResetWallet>(_onResetWallet);
  }

  Future<void> _onLoadWallet(
    LoadWallet event,
    Emitter<WalletState> emit,
  ) async {
    emit(WalletLoading());

    try {
      // Fetch wallet and transactions from backend
      final wallet = await walletDataSource.getWallet();
      final historyResponse = await walletDataSource.getTransactionHistory();
      
      final transactions = historyResponse.transactions
          .map((t) => t.toEntity())
          .toList();

      emit(WalletLoaded(
        wallet: wallet.toEntity(),
        transactions: transactions,
      ));
    } on UnauthorizedException catch (e) {
      emit(WalletError('Session expired. Please login again.'));
    } on NetworkException catch (e) {
      emit(WalletError('Network error: ${e.message}'));
    } on ServerException catch (e) {
      emit(WalletError(e.message));
    } catch (e) {
      emit(WalletError('Failed to load wallet: ${e.toString()}'));
    }
  }

  Future<void> _onRefreshWallet(
    RefreshWallet event,
    Emitter<WalletState> emit,
  ) async {
    // Keep current state while refreshing
    final currentState = state;
    
    try {
      final wallet = await walletDataSource.getWallet();
      final historyResponse = await walletDataSource.getTransactionHistory();
      
      final transactions = historyResponse.transactions
          .map((t) => t.toEntity())
          .toList();

      emit(WalletLoaded(
        wallet: wallet.toEntity(),
        transactions: transactions,
      ));
    } catch (e) {
      // If refresh fails, keep current state
      if (currentState is WalletLoaded) {
        emit(currentState);
      }
      AppLogger.warning('Wallet refresh error', tag: 'WalletBloc', error: e);
    }
  }

  void _onResetWallet(
      ResetWallet event,
      Emitter<WalletState> emit,
      ) {
    emit(WalletInitial());
  }

  Future<void> _onNfcTransactionCompleted(
    NfcTransactionCompleted event,
    Emitter<WalletState> emit,
  ) async {
    AppLogger.info('NFC Transaction Event Received: amount=${event.amount}, isCredit=${event.isCredit}, token=${event.token != null ? "provided" : "null"}', tag: 'WalletBloc');
    print('💰 WalletBloc: NfcTransactionCompleted received');
    print('   - amount: ${event.amount}');
    print('   - isCredit: ${event.isCredit}');
    print('   - token: ${event.token != null ? "provided" : "null"}');
    print('   - current state: ${state.runtimeType}');
    
    if (state is! WalletLoaded) {
      print('⚠️ WalletBloc: State is not WalletLoaded, ignoring event');
      return;
    }

    final currentState = state as WalletLoaded;
    print('   - current balance: ${currentState.balance}');

    // Calculate new balance locally for immediate UI update
    final newBalance = event.isCredit
        ? currentState.wallet.balance + event.amount
        : currentState.wallet.balance - event.amount;
    
    // Create new transaction for immediate display
    final newTransaction = Transaction(
      id: 'tx_${DateTime.now().millisecondsSinceEpoch}',
      payerWalletId: event.isCredit ? 'external' : currentState.wallet.id,
      merchantWalletId: event.isCredit ? currentState.wallet.id : 'external',
      amount: event.amount,
      currency: 'SDG',
      status: 'completed',
      transactionType: 'nfc',
      metadata: {'merchantName': event.merchantName ?? 'NFC Payment'},
      createdAt: DateTime.now(),
    );

    // Update transactions list (add at beginning)
    final updatedTransactions = [newTransaction, ...currentState.transactions];

    // Create updated wallet state
    final updatedWallet = currentState.copyWith(
      wallet: currentState.wallet.copyWith(balance: newBalance),
      transactions: updatedTransactions,
    );

    print('💰 WalletBloc: New balance will be: $newBalance');
    print('💰 WalletBloc: Emitting WalletTransactionSuccess');
    
    // Emit transaction success state (triggers animation)
    emit(WalletTransactionSuccess(
      amount: event.amount,
      isCredit: event.isCredit,
      wallet: updatedWallet,
    ));

    // After a brief delay, emit the updated wallet state to show UI changes
    await Future.delayed(const Duration(milliseconds: 100));
    print('💰 WalletBloc: Emitting updated WalletLoaded state');
    emit(updatedWallet);

    // Execute transaction on backend
    try {
      if (event.token != null) {
        // Real NFC Transaction
        await walletDataSource.validateTransaction(
          encryptedToken: event.token!,
          amount: event.amount,
        );
      } else if (event.isCredit) {
        // Test Simulation (Test Receiving Money)
        // Use topUp to simulate receiving money from an external source
        await walletDataSource.topUp(
          amount: event.amount,
          reference: 'Test NFC Payment',
        );
      }
      
      // Refresh consistent state from backend
      final wallet = await walletDataSource.getWallet();
      final historyResponse = await walletDataSource.getTransactionHistory();
      
      final transactions = historyResponse.transactions
          .map((t) => t.toEntity())
          .toList();

      emit(WalletLoaded(
        wallet: wallet.toEntity(),
        transactions: transactions,
      ));
    } catch (e) {
      AppLogger.error('Backend transaction execution failed', tag: 'WalletBloc', error: e);
      // If backend fails, we might want to revert local changes or show error
      // For now, we just refresh which will revert if backend didn't update
      try {
        final wallet = await walletDataSource.getWallet();
        final historyResponse = await walletDataSource.getTransactionHistory();
        
        // Don't revert immediately if it was just a network hiccup, but for consistency:
        final transactions = historyResponse.transactions
            .map((t) => t.toEntity())
            .toList();

        emit(WalletLoaded(
          wallet: wallet.toEntity(),
          transactions: transactions,
        ));
      } catch (_) {}
    }
  }

  Future<void> _onAddTransaction(
    AddTransaction event,
    Emitter<WalletState> emit,
  ) async {
    if (state is! WalletLoaded) return;

    final currentState = state as WalletLoaded;
    final updatedTransactions = [event.transaction, ...currentState.transactions];

    emit(currentState.copyWith(transactions: updatedTransactions));
  }

  Future<void> _onUpdateBalance(
    UpdateBalance event,
    Emitter<WalletState> emit,
  ) async {
    if (state is! WalletLoaded) return;

    final currentState = state as WalletLoaded;
    emit(currentState.copyWith(
        wallet: currentState.wallet.copyWith(balance: event.newBalance)));
  }
}
