import '../config/environment.dart';

/// API configuration constants
class ApiConstants {
  // Base URL - Retrieved from environment configuration
  // Can be overridden via --dart-define=API_URL=https://your-api.com/api
  static String get baseUrl => EnvironmentConfig.apiBaseUrl;
  
  // API Endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String refresh = '/auth/refresh';
  static const String logout = '/auth/logout';
  
  static const String getWallet = '/wallet';
  static const String getBalance = '/wallet/balance';
  static const String topUp = '/wallet/topup';
  
  static const String validateTransaction = '/transaction/validate';
  static const String transactionHistory = '/transaction/history';
  static String transactionDetail(String id) => '/transaction/$id';
  
  static const String getUserProfile = '/user/profile';
  static const String updateProfile = '/user/profile';
  static const String updatePin = '/user/pin';
  
  // Headers
  static const String contentType = 'application/json';
  static const String authorization = 'Authorization';
  
  // Timeout - Retrieved from environment configuration
  static Duration get connectionTimeout => EnvironmentConfig.connectionTimeout;
  static Duration get receiveTimeout => EnvironmentConfig.receiveTimeout;
}
