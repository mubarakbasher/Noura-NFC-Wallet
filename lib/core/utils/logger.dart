import 'dart:developer' as developer;

/// Application Logger
/// Provides consistent logging throughout the app using dart:developer
class AppLogger {
  static const String _defaultTag = 'NFC_Wallet';

  /// Log debug information
  static void debug(String message, {String? tag}) {
    developer.log(
      message,
      name: tag ?? _defaultTag,
      level: 500, // Fine level
    );
  }

  /// Log general information
  static void info(String message, {String? tag}) {
    developer.log(
      message,
      name: tag ?? _defaultTag,
      level: 800, // Info level
    );
  }

  /// Log warnings with optional error object
  static void warning(String message, {String? tag, Object? error}) {
    developer.log(
      message,
      name: tag ?? _defaultTag,
      level: 900, // Warning level
      error: error,
    );
  }

  /// Log errors with optional error object and stack trace
  static void error(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    developer.log(
      message,
      name: tag ?? _defaultTag,
      level: 1000, // Severe level
      error: error,
      stackTrace: stackTrace,
    );
  }
}
