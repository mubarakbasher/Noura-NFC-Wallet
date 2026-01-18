/// Custom exceptions for data layer
class ServerException implements Exception {
  final String message;
  final int? statusCode;

  ServerException(this.message, [this.statusCode]);

  @override
  String toString() => 'ServerException: $message (Code: $statusCode)';
}

class NetworkException implements Exception {
  final String message;

  NetworkException(this.message);

  @override
  String toString() => 'NetworkException: $message';
}

class CacheException implements Exception {
  final String message;

  CacheException(this.message);

  @override
  String toString() => 'CacheException: $message';
}

class AuthenticationException implements Exception {
  final String message;
  final int? statusCode;

  AuthenticationException(this.message, [this.statusCode]);

  @override
  String toString() => 'AuthenticationException: $message';
}

class NfcException implements Exception {
  final String message;
  final int? errorCode;

  NfcException(this.message, [this.errorCode]);

  @override
  String toString() => 'NfcException: $message (Code: $errorCode)';
}

class ValidationException implements Exception {
  final String message;

  ValidationException(this.message);

  @override
  String toString() => 'ValidationException: $message';
}
