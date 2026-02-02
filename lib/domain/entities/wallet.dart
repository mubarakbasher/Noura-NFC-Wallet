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

  Wallet copyWith({
    String? id,
    String? userId,
    double? balance,
    String? currency,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Wallet(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      balance: balance ?? this.balance,
      currency: currency ?? this.currency,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

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
