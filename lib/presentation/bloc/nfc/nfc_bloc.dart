import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/nfc_repository.dart';
import 'nfc_event.dart';
import 'nfc_state.dart';

/// NFC BLoC - Manages NFC operations and state
class NfcBloc extends Bloc<NfcEvent, NfcState> {
  final NfcRepository nfcRepository;
  StreamSubscription? _nfcEventSubscription;

  double _currentPaymentAmount = 0;

  NfcBloc({required this.nfcRepository}) : super(NfcInitial()) {
    on<CheckNfcAvailability>(_onCheckNfcAvailability);
    on<EnableHceMode>(_onEnableHceMode);
    on<DisableHceMode>(_onDisableHceMode);
    on<StartReaderMode>(_onStartReaderMode);
    on<StopReaderMode>(_onStopReaderMode);
    on<TokenReceived>(_onTokenReceived);
    on<NfcError>(_onNfcError);
    on<PaymentSent>(_onPaymentSent);
  }

  Future<void> _onCheckNfcAvailability(
    CheckNfcAvailability event,
    Emitter<NfcState> emit,
  ) async {
    emit(NfcChecking());

    final result = await nfcRepository.isNfcAvailable();

    result.fold(
      (failure) => emit(NfcUnavailable(failure.message)),
      (isAvailable) {
        if (isAvailable) {
          emit(NfcAvailable());
        } else {
          emit(const NfcUnavailable('NFC is not available on this device'));
        }
      },
    );
  }

  Future<void> _onEnableHceMode(
    EnableHceMode event,
    Emitter<NfcState> emit,
  ) async {
    emit(HceActivating());

    // Store the payment amount for later use
    _currentPaymentAmount = event.amount;

    // Generate token with amount
    final tokenResult = await nfcRepository.generateNfcToken(
      userId: event.userId,
      walletId: event.walletId,
      deviceId: event.deviceId,
      amount: event.amount,
    );

    await tokenResult.fold(
      (failure) async {
        emit(NfcFailureState(failure.message));
      },
      (token) async {
        // Enable HCE
        final hceResult = await nfcRepository.enableHce();

        await hceResult.fold(
          (failure) async => emit(NfcFailureState(failure.message)),
          (_) async {
            emit(HceActive(token));
            
            // Subscribe to NFC events to catch PAYMENT_SENT
            await _nfcEventSubscription?.cancel();
            print('👂 NfcBloc: Subscribing to NFC events for HCE payment confirmation...');
            _nfcEventSubscription = nfcRepository.nfcEventStream.listen(
              (result) {
                result.fold(
                  (failure) {
                    print('❌ NfcBloc HCE: Event failure: ${failure.message}');
                  },
                  (eventData) {
                    print('📨 NfcBloc HCE: Received event: $eventData');
                    if (eventData == 'PAYMENT_SENT') {
                      print('✅ NfcBloc: Payment sent! Triggering PaymentSent event...');
                      add(PaymentSent(_currentPaymentAmount));
                    }
                  },
                );
              },
              onError: (error) {
                print('❌ NfcBloc HCE: Stream error: $error');
              },
            );
          },
        );
      },
    );
  }

  Future<void> _onDisableHceMode(
    DisableHceMode event,
    Emitter<NfcState> emit,
  ) async {
    final result = await nfcRepository.disableHce();

    result.fold(
      (failure) => emit(NfcFailureState(failure.message)),
      (_) => emit(HceInactive()),
    );
  }

  Future<void> _onStartReaderMode(
    StartReaderMode event,
    Emitter<NfcState> emit,
  ) async {
    print('📡 NfcBloc: Starting reader mode...');
    emit(ReaderActivating());

    final result = await nfcRepository.startReaderMode();

    await result.fold(
      (failure) async {
        print('❌ NfcBloc: Failed to start reader mode: ${failure.message}');
        emit(NfcFailureState(failure.message));
      },
      (_) async {
        print('✅ NfcBloc: Reader mode started, waiting for tags...');
        emit(ReaderWaitingForTag());

        // Listen to NFC events
        await _nfcEventSubscription?.cancel();
        print('👂 NfcBloc: Subscribing to NFC event stream...');
        _nfcEventSubscription = nfcRepository.nfcEventStream.listen(
          (result) {
            print('📨 NfcBloc: Received event from stream!');
            result.fold(
              (failure) {
                print('❌ NfcBloc: Event is failure: ${failure.message}');
                add(NfcError(failure.message));
              },
              (token) {
                print('✅ NfcBloc: Event is token! Length: ${token.length}');
                add(TokenReceived(token));
              },
            );
          },
          onError: (error) {
            print('❌ NfcBloc: Stream error: $error');
          },
          onDone: () {
            print('🏁 NfcBloc: Stream completed');
          },
        );
        print('✅ NfcBloc: Subscription active');
      },
    );
  }

  Future<void> _onStopReaderMode(
    StopReaderMode event,
    Emitter<NfcState> emit,
  ) async {
    await _nfcEventSubscription?.cancel();
    _nfcEventSubscription = null;

    final result = await nfcRepository.stopReaderMode();

    result.fold(
      (failure) => emit(NfcFailureState(failure.message)),
      (_) => emit(ReaderInactive()),
    );
  }

  void _onTokenReceived(
    TokenReceived event,
    Emitter<NfcState> emit,
  ) {
    // Ignore special PAYMENT_SENT marker (handled by PaymentSent event)
    if (event.token == 'PAYMENT_SENT') {
      print('⏭️ NfcBloc: Skipping PAYMENT_SENT marker in TokenReceived');
      return;
    }
    
    print('🎫 NfcBloc: TokenReceived event! Token length: ${event.token.length}');
    print('🎫 NfcBloc: Emitting ReaderTagDetected state...');
    emit(ReaderTagDetected(event.token));
    print('✅ NfcBloc: ReaderTagDetected emitted!');
  }

  void _onNfcError(
    NfcError event,
    Emitter<NfcState> emit,
  ) {
    emit(NfcFailureState(event.message));
  }

  void _onPaymentSent(
    PaymentSent event,
    Emitter<NfcState> emit,
  ) {
    print('✅ NfcBloc: PaymentSent handler - amount: ${event.amount}');
    emit(HcePaymentSent(event.amount));
  }

  @override
  Future<void> close() {
    _nfcEventSubscription?.cancel();
    return super.close();
  }
}
