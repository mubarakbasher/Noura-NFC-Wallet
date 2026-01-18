import 'package:equatable/equatable.dart';

/// User entity - Domain model
class User extends Equatable {
  final String id;
  final String email;
  final String fullName;
  final String? phone;
  final String? deviceId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const User({
    required this.id,
    required this.email,
    required this.fullName,
    this.phone,
    this.deviceId,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        email,
        fullName,
        phone,
        deviceId,
        createdAt,
        updatedAt,
      ];
}
