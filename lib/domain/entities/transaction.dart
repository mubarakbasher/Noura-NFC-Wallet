import 'package:equatable/equatable.dart';

/// Transaction entity - Domain model
class Transaction extends Equatable {
  final String id;
  final String payerWalletId;
  final String merchantWalletId;
  final double amount;
  final String currency;
  final String status; // pending, completed, failed, cancelled
  final String transactionType; // nfc_payment, topup, transfer
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime? completedAt;

  const Transaction({
    required this.id,
    required this.payerWalletId,
    required this.merchantWalletId,
    required this.amount,
    required this.currency,
    required this.status,
    required this.transactionType,
    this.metadata,
    required this.createdAt,
    this.completedAt,
  });

  bool get isPending => status == 'pending';
  bool get isCompleted => status == 'completed';
  bool get isFailed => status == 'failed';
  bool get isNfcPayment => transactionType == 'nfc_payment';

  @override
  List<Object?> get props => [
        id,
        payerWalletId,
        merchantWalletId,
        amount,
        currency,
        status,
        transactionType,
        metadata,
        createdAt,
        completedAt,
      ];
}
