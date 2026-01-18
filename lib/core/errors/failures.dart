import 'package:equatable/equatable.dart';

/// Base class for all failures in the application
abstract class Failure extends Equatable {
  final String message;
  final int? code;

  const Failure(this.message, [this.code]);

  @override
  List<Object?> get props => [message, code];
}

/// Server-related failures
class ServerFailure extends Failure {
  const ServerFailure(String message, [int? code]) : super(message, code);
}

/// Network/Connection failures
class NetworkFailure extends Failure {
  const NetworkFailure(String message) : super(message);
}

/// Cache/Local storage failures
class CacheFailure extends Failure {
  const CacheFailure(String message) : super(message);
}

/// Authentication failures
class AuthenticationFailure extends Failure {
  const AuthenticationFailure(String message, [int? code]) : super(message, code);
}

/// NFC-specific failures
class NfcFailure extends Failure {
  const NfcFailure(String message, [int? code]) : super(message, code);
}

/// Validation failures
class ValidationFailure extends Failure {
  const ValidationFailure(String message) : super(message);
}

/// General/Unknown failures
class UnknownFailure extends Failure {
  const UnknownFailure(String message) : super(message);
}
