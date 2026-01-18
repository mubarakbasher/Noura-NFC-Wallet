/// API configuration constants
class ApiConstants {
  // Base URL - Update this with your actual backend URL
  static const String baseUrl = 'http://localhost:3000/api';
  
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
  
  // Timeout
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
