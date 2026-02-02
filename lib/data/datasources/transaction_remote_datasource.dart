import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../models/transaction_model.dart';

/// Remote data source for transaction operations
class TransactionRemoteDataSource {
  final ApiClient _apiClient;

  TransactionRemoteDataSource({required ApiClient apiClient})
      : _apiClient = apiClient;

  /// Validate and process NFC transaction
  Future<TransactionModel> validateAndProcessTransaction({
    required String encryptedToken,
    required double amount,
    String? merchantWalletId,
    String? idempotencyKey,
    Map<String, dynamic>? metadata,
  }) async {
    final response = await _apiClient.post(
      ApiConstants.validateTransaction,
      data: {
        'encryptedToken': encryptedToken,
        'amount': amount,
        if (merchantWalletId != null) 'merchantWalletId': merchantWalletId,
        if (idempotencyKey != null) 'idempotencyKey': idempotencyKey,
        if (metadata != null) 'metadata': metadata,
      },
    );
    return TransactionModel.fromJson(response.data as Map<String, dynamic>);
  }

  /// Get transaction history with pagination
  Future<TransactionHistoryResponse> getTransactionHistory({
    int page = 1,
    int pageSize = 20,
    String? filter, // 'all', 'incoming', 'outgoing'
  }) async {
    final response = await _apiClient.get(
      ApiConstants.transactionHistory,
      queryParameters: {
        'page': page,
        'pageSize': pageSize,
      },
    );
    return TransactionHistoryResponse.fromJson(
        response.data as Map<String, dynamic>);
  }

  /// Get transaction by ID
  Future<TransactionModel> getTransactionById(String id) async {
    final response = await _apiClient.get(ApiConstants.transactionDetail(id));
    return TransactionModel.fromJson(response.data as Map<String, dynamic>);
  }
}
