/// Environment configuration for the app
/// Allows switching between development, staging, and production environments
enum Environment {
  development,
  staging,
  production,
}

/// Environment configuration class
/// Configure the app for different deployment environments
class EnvironmentConfig {
  static Environment _environment = Environment.development;
  
  /// Initialize environment (call in main.dart before runApp)
  static void init(Environment env) {
    _environment = env;
  }
  
  /// Current environment
  static Environment get environment => _environment;
  
  /// Check if running in development mode
  static bool get isDevelopment => _environment == Environment.development;
  
  /// Check if running in staging mode
  static bool get isStaging => _environment == Environment.staging;
  
  /// Check if running in production mode
  static bool get isProduction => _environment == Environment.production;
  
  /// API Base URL based on environment
  static String get apiBaseUrl {
    switch (_environment) {
      case Environment.development:
        // For development - use local IP or emulator address
        // Android Emulator: 10.0.2.2:3000
        // iOS Simulator: localhost:3000
        // Physical device: Use your computer's local IP (run 'ipconfig' to find it)
        return const String.fromEnvironment(
          'API_URL',
          defaultValue: 'http://192.168.1.227:3000/api',
        );
      case Environment.staging:
        return const String.fromEnvironment(
          'API_URL',
          defaultValue: 'https://staging-api.nfcwallet.com/api',
        );
      case Environment.production:
        return const String.fromEnvironment(
          'API_URL',
          defaultValue: 'https://api.nfcwallet.com/api',
        );
    }
  }
  
  /// Connection timeout duration
  static Duration get connectionTimeout {
    switch (_environment) {
      case Environment.development:
        return const Duration(seconds: 60);
      case Environment.staging:
      case Environment.production:
        return const Duration(seconds: 30);
    }
  }
  
  /// Receive timeout duration
  static Duration get receiveTimeout {
    switch (_environment) {
      case Environment.development:
        return const Duration(seconds: 60);
      case Environment.staging:
      case Environment.production:
        return const Duration(seconds: 30);
    }
  }
  
  /// Enable debug logging
  static bool get enableLogging {
    switch (_environment) {
      case Environment.development:
      case Environment.staging:
        return true;
      case Environment.production:
        return false;
    }
  }
}
