import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/nfc_repository.dart';
import 'nfc_event.dart';
import 'nfc_state.dart';

/// NFC BLoC - Manages NFC operations and state
class NfcBloc extends Bloc<NfcEvent, NfcState> {
  final NfcRepository nfcRepository;
  StreamSubscription? _nfcEventSubscription;

  NfcBloc({required this.nfcRepository}) : super(NfcInitial()) {
    on<CheckNfcAvailability>(_onCheckNfcAvailability);
    on<EnableHceMode>(_onEnableHceMode);
    on<DisableHceMode>(_onDisableHceMode);
    on<StartReaderMode>(_onStartReaderMode);
    on<StopReaderMode>(_onStopReaderMode);
    on<TokenReceived>(_onTokenReceived);
    on<NfcError>(_onNfcError);
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

    // Generate token first
    final tokenResult = await nfcRepository.generateNfcToken(
      userId: event.userId,
      walletId: event.walletId,
      deviceId: event.deviceId,
      pin: '', // PIN validation will be added later
    );

    await tokenResult.fold(
      (failure) async {
        emit(NfcFailureState(failure.message));
      },
      (token) async {
        // Enable HCE
        final hceResult = await nfcRepository.enableHce();

        hceResult.fold(
          (failure) => emit(NfcFailureState(failure.message)),
          (_) => emit(HceActive(token)),
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
    emit(ReaderActivating());

    final result = await nfcRepository.startReaderMode();

    await result.fold(
      (failure) async {
        emit(NfcFailureState(failure.message));
      },
      (_) async {
        emit(ReaderWaitingForTag());

        // Listen to NFC events
        await _nfcEventSubscription?.cancel();
        _nfcEventSubscription = nfcRepository.nfcEventStream.listen(
          (result) {
            result.fold(
              (failure) => add(NfcError(failure.message)),
              (token) => add(TokenReceived(token)),
            );
          },
        );
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
    emit(ReaderTagDetected(event.token));
  }

  void _onNfcError(
    NfcError event,
    Emitter<NfcState> emit,
  ) {
    emit(NfcFailureState(event.message));
  }

  @override
  Future<void> close() {
    _nfcEventSubscription?.cancel();
    return super.close();
  }
}
