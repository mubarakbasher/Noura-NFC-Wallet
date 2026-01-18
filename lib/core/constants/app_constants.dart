/// Application-wide constants
class AppConstants {
  // App Info
  static const String appName = 'NFC Wallet';
  static const String appVersion = '1.0.0';
  
  // Storage Keys
  static const String keyAccessToken = 'access_token';
  static const String keyRefreshToken = 'refresh_token';
  static const String keyUserId = 'user_id';
  static const String keyUserEmail = 'user_email';
  static const String keyDeviceId = 'device_id';
  static const String keyEncryptionKey = 'encryption_key';
  static const String keyPinHash = 'pin_hash';
  
  // Transaction Types
  static const String transactionTypeNfcPayment = 'nfc_payment';
  static const String transactionTypeTopUp = 'topup';
  static const String transactionTypeTransfer = 'transfer';
  
  // Transaction Status
  static const String statusPending = 'pending';
  static const String statusCompleted = 'completed';
  static const String statusFailed = 'failed';
  static const String statusCancelled = 'cancelled';
  
  // Currency
  static const String defaultCurrency = 'USD';
  static const String currencySymbol = '\$';
  
  // Validation
  static const int minPinLength = 4;
  static const int maxPinLength = 6;
  static const int minPasswordLength = 8;
  
  // Pagination
  static const int transactionPageSize = 20;
  
  // UI
  static const double cardBorderRadius = 16.0;
  static const double buttonBorderRadius = 12.0;
  static const double defaultPadding = 16.0;
}
