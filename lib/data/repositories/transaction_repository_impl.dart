import 'package:dartz/dartz.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../datasources/transaction_remote_datasource.dart';

/// Transaction Repository Implementation
class TransactionRepositoryImpl implements TransactionRepository {
  final TransactionRemoteDataSource remoteDataSource;

  TransactionRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, Transaction>> validateAndProcessTransaction({
    required String encryptedToken,
    required double amount,
  }) async {
    try {
      final result = await remoteDataSource.validateAndProcessTransaction(
        encryptedToken: encryptedToken,
        amount: amount,
      );
      return Right(result.toEntity());
    } on UnauthorizedException catch (e) {
      return Left(AuthenticationFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Transaction failed: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<Transaction>>> getTransactionHistory({
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await remoteDataSource.getTransactionHistory(
        page: page,
        pageSize: pageSize,
      );
      final transactions =
          response.transactions.map((t) => t.toEntity()).toList();
      return Right(transactions);
    } on UnauthorizedException catch (e) {
      return Left(AuthenticationFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to load history: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Transaction>> getTransactionById(String id) async {
    try {
      final result = await remoteDataSource.getTransactionById(id);
      return Right(result.toEntity());
    } on UnauthorizedException catch (e) {
      return Left(AuthenticationFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Transaction not found: ${e.toString()}'));
    }
  }
}
