import 'package:equatable/equatable.dart';

/// Wallet entity - Domain model
class Wallet extends Equatable {
  final String id;
  final String userId;
  final double balance;
  final String currency;
  final String status; // active, suspended, closed
  final DateTime createdAt;
  final DateTime updatedAt;

  const Wallet({
    required this.id,
    required this.userId,
    required this.balance,
    required this.currency,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isActive => status == 'active';
  bool get hasSufficientBalance => balance > 0;

  @override
  List<Object?> get props => [
        id,
        userId,
        balance,
        currency,
        status,
        createdAt,
        updatedAt,
      ];
}
