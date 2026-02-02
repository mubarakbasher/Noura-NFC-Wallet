import 'package:equatable/equatable.dart';

/// Authentication States
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class Authenticated extends AuthState {
  final String userId;
  final String email;
  final String fullName;

  const Authenticated({
    required this.userId,
    required this.email,
    required this.fullName,
  });

  @override
  List<Object?> get props => [userId, email, fullName];
}

class Unauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}

/// State emitted after successful registration
/// Redirects to login with success message
class RegistrationSuccess extends AuthState {
  final String message;

  const RegistrationSuccess({this.message = 'Account created successfully! Please login.'});

  @override
  List<Object?> get props => [message];
}

