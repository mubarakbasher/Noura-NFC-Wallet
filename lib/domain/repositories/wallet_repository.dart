import 'package:dartz/dartz.dart';
import '../entities/wallet.dart';
import '../../core/errors/failures.dart';

/// Wallet repository interface
abstract class WalletRepository {
  /// Get user's wallet
  Future<Either<Failure, Wallet>> getWallet();

  /// Get wallet balance
  Future<Either<Failure, double>> getBalance();

  /// Top up wallet (for testing purposes)
  Future<Either<Failure, Wallet>> topUp({
    required double amount,
  });

  /// Debit wallet
  Future<Either<Failure, void>> debit({
    required double amount,
  });

  /// Credit wallet
  Future<Either<Failure, void>> credit({
    required double amount,
  });
}
