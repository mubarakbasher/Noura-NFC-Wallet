import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../models/auth_response_model.dart';
import '../models/transaction_model.dart';

/// Remote data source for wallet operations
class WalletRemoteDataSource {
  final ApiClient _apiClient;

  WalletRemoteDataSource({required ApiClient apiClient}) : _apiClient = apiClient;

  /// Get wallet details
  Future<WalletResponseModel> getWallet() async {
    final response = await _apiClient.get(ApiConstants.getWallet);
    return WalletResponseModel.fromJson(response.data as Map<String, dynamic>);
  }

  /// Get wallet balance
  Future<BalanceResponse> getBalance() async {
    final response = await _apiClient.get(ApiConstants.getBalance);
    return BalanceResponse.fromJson(response.data as Map<String, dynamic>);
  }

  /// Top up wallet
  Future<WalletResponseModel> topUp({
    required double amount,
    String? reference,
  }) async {
    final response = await _apiClient.post(
      ApiConstants.topUp,
      data: {
        'amount': amount,
        if (reference != null) 'reference': reference,
      },
    );
    return WalletResponseModel.fromJson(response.data as Map<String, dynamic>);
  }

  /// Validate and process NFC transaction
  Future<TransactionModel> validateTransaction({
    required String encryptedToken,
    required double amount,
    String? merchantWalletId,
    Map<String, dynamic>? metadata,
  }) async {
    final response = await _apiClient.post(
      ApiConstants.validateTransaction,
      data: {
        'encryptedToken': encryptedToken,
        'amount': amount,
        if (merchantWalletId != null) 'merchantWalletId': merchantWalletId,
        if (metadata != null) 'metadata': metadata,
      },
    );
    return TransactionModel.fromJson(response.data as Map<String, dynamic>);
  }

  /// Get transaction history
  Future<TransactionHistoryResponse> getTransactionHistory({
    int page = 1,
    int pageSize = 20,
  }) async {
    final response = await _apiClient.get(
      ApiConstants.transactionHistory,
      queryParameters: {
        'page': page,
        'pageSize': pageSize,
      },
    );
    return TransactionHistoryResponse.fromJson(response.data as Map<String, dynamic>);
  }

  /// Get transaction by ID
  Future<TransactionModel> getTransaction(String id) async {
    final response = await _apiClient.get(ApiConstants.transactionDetail(id));
    return TransactionModel.fromJson(response.data as Map<String, dynamic>);
  }
}

/// Balance response from API
class BalanceResponse {
  final double balance;
  final String currency;
  final String status;

  BalanceResponse({
    required this.balance,
    required this.currency,
    required this.status,
  });

  factory BalanceResponse.fromJson(Map<String, dynamic> json) {
    return BalanceResponse(
      balance: (json['balance'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'SDG',
      status: json['status'] as String? ?? 'ACTIVE',
    );
  }
}
