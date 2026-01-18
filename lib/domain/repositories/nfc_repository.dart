import 'package:dartz/dartz.dart';
import '../entities/nfc_token.dart';
import '../../core/errors/failures.dart';

/// NFC repository interface
abstract class NfcRepository {
  /// Check if NFC is available on device
  Future<Either<Failure, bool>> isNfcAvailable();

  /// Enable HCE mode (card emulation for payment)
  Future<Either<Failure, void>> enableHce();

  /// Disable HCE mode
  Future<Either<Failure, void>> disableHce();

  /// Start NFC reader mode (POS functionality)
  Future<Either<Failure, void>> startReaderMode();

  /// Stop NFC reader mode
  Future<Either<Failure, void>> stopReaderMode();

  /// Generate NFC payment token
  Future<Either<Failure, NfcToken>> generateNfcToken({
    required String userId,
    required String walletId,
    required String deviceId,
    required String pin,
  });

  /// Read NFC tag and extract token
  Future<Either<Failure, String>> readNfcTag();

  /// Stream of NFC events (for reader mode)
  Stream<Either<Failure, String>> get nfcEventStream;
}
