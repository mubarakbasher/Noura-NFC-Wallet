import 'package:dartz/dartz.dart';
import '../entities/user.dart';
import '../../core/errors/failures.dart';

/// Authentication repository interface
abstract class AuthRepository {
  /// Login user with email and password
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
  });

  /// Register new user
  Future<Either<Failure, User>> register({
    required String email,
    required String password,
    required String fullName,
    String? phone,
  });

  /// Logout current user
  Future<Either<Failure, void>> logout();

  /// Get current user
  Future<Either<Failure, User>> getCurrentUser();

  /// Check if user is logged in
  Future<bool> isLoggedIn();

  /// Refresh access token
  Future<Either<Failure, void>> refreshToken();
}
