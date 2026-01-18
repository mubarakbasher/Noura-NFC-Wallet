import 'package:flutter_bloc/flutter_bloc.dart';
import 'wallet_event.dart';
import 'wallet_state.dart';
import '../../../domain/entities/transaction.dart';

/// Wallet BLoC
/// Manages wallet balance and transactions with NFC event handling
class WalletBloc extends Bloc<WalletEvent, WalletState> {
  WalletBloc() : super(WalletInitial()) {
    on<LoadWallet>(_onLoadWallet);
    on<NfcTransactionCompleted>(_onNfcTransactionCompleted);
    on<AddTransaction>(_onAddTransaction);
    on<UpdateBalance>(_onUpdateBalance);
  }

  Future<void> _onLoadWallet(
    LoadWallet event,
    Emitter<WalletState> emit,
  ) async {
    emit(WalletLoading());

    // Simulate loading - replace with actual repository call
    await Future.delayed(const Duration(milliseconds: 500));

    // Mock data - will be replaced with real data from repository
    emit(WalletLoaded(
      balance: 1250.50,
      walletId: 'wallet_123',
      transactions: _getMockTransactions(),
    ));
  }

  Future<void> _onNfcTransactionCompleted(
    NfcTransactionCompleted event,
    Emitter<WalletState> emit,
  ) async {
    if (state is! WalletLoaded) return;

    final currentState = state as WalletLoaded;

    // Calculate new balance
    final newBalance = event.isCredit
        ? currentState.balance + event.amount
        : currentState.balance - event.amount;

    // Create new transaction
    final newTransaction = Transaction(
      id: 'tx_${DateTime.now().millisecondsSinceEpoch}',
      payerWalletId: event.isCredit ? 'external' : currentState.walletId,
      merchantWalletId: event.isCredit ? currentState.walletId : 'external',
      amount: event.amount,
      currency: 'USD',
      status: 'completed',
      transactionType: 'nfc',
      metadata: {'merchantName': event.merchantName ?? 'NFC Payment'},
      createdAt: DateTime.now(),
    );

    // Update transactions list (add at beginning)
    final updatedTransactions = [newTransaction, ...currentState.transactions];

    // Create updated wallet state
    final updatedWallet = currentState.copyWith(
      balance: newBalance,
      transactions: updatedTransactions,
    );

    // Emit transaction success state (triggers animation)
    emit(WalletTransactionSuccess(
      amount: event.amount,
      isCredit: event.isCredit,
      wallet: updatedWallet,
    ));

    // After a brief delay, emit the updated wallet state
    await Future.delayed(const Duration(milliseconds: 100));
    emit(updatedWallet);
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
    emit(currentState.copyWith(balance: event.newBalance));
  }

  // Mock transactions for demo
  List<Transaction> _getMockTransactions() {
    final now = DateTime.now();
    return [
      Transaction(
        id: 'tx_001',
        payerWalletId: 'external',
        merchantWalletId: 'wallet_123',
        amount: 50.00,
        currency: 'USD',
        status: 'completed',
        transactionType: 'nfc',
        metadata: {'merchantName': 'Coffee Shop'},
        createdAt: now.subtract(const Duration(hours: 2)),
      ),
      Transaction(
        id: 'tx_002',
        payerWalletId: 'wallet_123',
        merchantWalletId: 'external',
        amount: 25.00,
        currency: 'USD',
        status: 'completed',
        transactionType: 'nfc',
        metadata: {'merchantName': 'Grocery Store'},
        createdAt: now.subtract(const Duration(days: 1)),
      ),
      Transaction(
        id: 'tx_003',
        payerWalletId: 'external',
        merchantWalletId: 'wallet_123',
        amount: 100.00,
        currency: 'USD',
        status: 'completed',
        transactionType: 'topup',
        metadata: {'merchantName': 'Bank Transfer'},
        createdAt: now.subtract(const Duration(days: 2)),
      ),
    ];
  }
}
