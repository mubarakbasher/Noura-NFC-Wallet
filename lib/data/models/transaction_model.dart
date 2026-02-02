import '../../domain/entities/transaction.dart';

/// Transaction model from API response
class TransactionModel {
  final String id;
  final String payerWalletId;
  final String merchantWalletId;
  final double amount;
  final String currency;
  final String status;
  final String type;
  final String? nonce;
  final String? idempotencyKey;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime? completedAt;
  final String? direction;
  final PayerMerchantInfo? payerWallet;
  final PayerMerchantInfo? merchantWallet;

  TransactionModel({
    required this.id,
    required this.payerWalletId,
    required this.merchantWalletId,
    required this.amount,
    required this.currency,
    required this.status,
    required this.type,
    this.nonce,
    this.idempotencyKey,
    this.metadata,
    required this.createdAt,
    this.completedAt,
    this.direction,
    this.payerWallet,
    this.merchantWallet,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as String,
      payerWalletId: json['payerWalletId'] as String,
      merchantWalletId: json['merchantWalletId'] as String,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'SDG',
      status: json['status'] as String,
      type: json['type'] as String,
      nonce: json['nonce'] as String?,
      idempotencyKey: json['idempotencyKey'] as String?,
      metadata: json['metadata'] != null
          ? (json['metadata'] is String
              ? _parseMetadata(json['metadata'] as String)
              : json['metadata'] as Map<String, dynamic>)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      direction: json['direction'] as String?,
      payerWallet: json['payerWallet'] != null
          ? PayerMerchantInfo.fromJson(json['payerWallet'] as Map<String, dynamic>)
          : null,
      merchantWallet: json['merchantWallet'] != null
          ? PayerMerchantInfo.fromJson(json['merchantWallet'] as Map<String, dynamic>)
          : null,
    );
  }

  static Map<String, dynamic>? _parseMetadata(String metadata) {
    try {
      // Handle JSON string metadata from SQLite
      return Map<String, dynamic>.from(
        (metadata.isNotEmpty) ? {} : {},
      );
    } catch (_) {
      return null;
    }
  }

  /// Convert to domain entity
  Transaction toEntity() {
    String merchantName = 'Unknown';
    if (metadata != null && metadata!.containsKey('merchantName')) {
      merchantName = metadata!['merchantName'] as String;
    } else if (merchantWallet?.user != null) {
      merchantName = merchantWallet!.user!.fullName;
    }

    return Transaction(
      id: id,
      payerWalletId: payerWalletId,
      merchantWalletId: merchantWalletId,
      amount: amount,
      currency: currency,
      status: status,
      transactionType: type.toLowerCase(),
      metadata: {'merchantName': merchantName, ...?metadata},
      createdAt: createdAt,
    );
  }
}

/// Payer/Merchant wallet info from API
class PayerMerchantInfo {
  final String id;
  final UserBasicInfo? user;

  PayerMerchantInfo({required this.id, this.user});

  factory PayerMerchantInfo.fromJson(Map<String, dynamic> json) {
    return PayerMerchantInfo(
      id: json['id'] as String,
      user: json['user'] != null
          ? UserBasicInfo.fromJson(json['user'] as Map<String, dynamic>)
          : null,
    );
  }
}

/// Basic user info for transaction display
class UserBasicInfo {
  final String fullName;
  final String email;

  UserBasicInfo({required this.fullName, required this.email});

  factory UserBasicInfo.fromJson(Map<String, dynamic> json) {
    return UserBasicInfo(
      fullName: json['fullName'] as String,
      email: json['email'] as String,
    );
  }
}

/// Transaction history response from API
class TransactionHistoryResponse {
  final List<TransactionModel> transactions;
  final PaginationInfo pagination;

  TransactionHistoryResponse({
    required this.transactions,
    required this.pagination,
  });

  factory TransactionHistoryResponse.fromJson(Map<String, dynamic> json) {
    return TransactionHistoryResponse(
      transactions: (json['transactions'] as List<dynamic>)
          .map((e) => TransactionModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      pagination: PaginationInfo.fromJson(json['pagination'] as Map<String, dynamic>),
    );
  }
}

/// Pagination info from API
class PaginationInfo {
  final int page;
  final int pageSize;
  final int total;
  final int totalPages;
  final bool hasMore;

  PaginationInfo({
    required this.page,
    required this.pageSize,
    required this.total,
    required this.totalPages,
    required this.hasMore,
  });

  factory PaginationInfo.fromJson(Map<String, dynamic> json) {
    return PaginationInfo(
      page: json['page'] as int,
      pageSize: json['pageSize'] as int,
      total: json['total'] as int,
      totalPages: json['totalPages'] as int,
      hasMore: json['hasMore'] as bool,
    );
  }
}
