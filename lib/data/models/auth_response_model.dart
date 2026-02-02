import '../../domain/entities/user.dart';
import '../../domain/entities/wallet.dart';

/// Auth response from login/register API
class AuthResponse {
  final String accessToken;
  final String refreshToken;
  final String expiresIn;
  final UserModel user;
  final WalletResponseModel? wallet;

  AuthResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
    required this.user,
    this.wallet,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
      expiresIn: json['expiresIn'] as String? ?? '15m',
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
      wallet: json['wallet'] != null 
          ? WalletResponseModel.fromJson(json['wallet'] as Map<String, dynamic>)
          : null,
    );
  }
}

/// User model from API response
class UserModel {
  final String id;
  final String email;
  final String fullName;
  final String? phone;
  final String? deviceId;
  final String role;
  final String status;
  final String language;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    this.phone,
    this.deviceId,
    required this.role,
    required this.status,
    required this.language,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      fullName: json['fullName'] as String,
      phone: json['phone'] as String?,
      deviceId: json['deviceId'] as String?,
      role: json['role'] as String? ?? 'USER',
      status: json['status'] as String? ?? 'ACTIVE',
      language: json['language'] as String? ?? 'en',
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  /// Convert to domain entity
  User toEntity() {
    return User(
      id: id,
      email: email,
      fullName: fullName,
      phone: phone,
      deviceId: deviceId,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

/// Wallet response model from API
class WalletResponseModel {
  final String id;
  final String userId;
  final double balance;
  final String currency;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  WalletResponseModel({
    required this.id,
    required this.userId,
    required this.balance,
    required this.currency,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory WalletResponseModel.fromJson(Map<String, dynamic> json) {
    return WalletResponseModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      balance: (json['balance'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'SDG',
      status: json['status'] as String? ?? 'ACTIVE',
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  /// Convert to domain entity
  Wallet toEntity() {
    return Wallet(
      id: id,
      userId: userId,
      balance: balance,
      currency: currency,
      status: status,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
