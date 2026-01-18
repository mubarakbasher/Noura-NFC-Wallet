import 'package:dartz/dartz.dart';
import '../entities/transaction.dart';
import '../../core/errors/failures.dart';

/// Transaction repository interface
abstract class TransactionRepository {
  /// Validate NFC token and process transaction
  Future<Either<Failure, Transaction>> validateAndProcessTransaction({
    required String encryptedToken,
    required double amount,
  });

  /// Get transaction history
  Future<Either<Failure, List<Transaction>>> getTransactionHistory({
    int page = 1,
    int pageSize = 20,
  });

  /// Get transaction by ID
  Future<Either<Failure, Transaction>> getTransactionById(String id);
}
