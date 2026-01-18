import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_event.dart';
import 'auth_state.dart';

/// Authentication BLoC
/// Handles login, signup, and session management
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SharedPreferences sharedPreferences;

  AuthBloc({required this.sharedPreferences}) : super(AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<SignupRequested>(_onSignupRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<CheckAuthStatus>(_onCheckAuthStatus);
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // Mock authentication - accept any email/password for demo
    // In production, validate against backend
    if (event.email.isNotEmpty && event.password.isNotEmpty) {
      // Save session
      await sharedPreferences.setString('userId', 'user_123');
      await sharedPreferences.setString('userEmail', event.email);
      await sharedPreferences.setString('userFullName', 'Demo User');
      await sharedPreferences.setBool('isLoggedIn', true);

      emit(Authenticated(
        userId: 'user_123',
        email: event.email,
        fullName: 'Demo User',
      ));
    } else {
      emit(const AuthError('Invalid credentials'));
    }
  }

  Future<void> _onSignupRequested(
    SignupRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // Mock signup - accept any valid input for demo
    if (event.email.isNotEmpty &&
        event.password.length >= 6 &&
        event.fullName.isNotEmpty) {
      // Save session
      await sharedPreferences.setString('userId', 'user_123');
      await sharedPreferences.setString('userEmail', event.email);
      await sharedPreferences.setString('userFullName', event.fullName);
      await sharedPreferences.setBool('isLoggedIn', true);

      emit(Authenticated(
        userId: 'user_123',
        email: event.email,
        fullName: event.fullName,
      ));
    } else {
      emit(const AuthError('Please fill all fields correctly'));
    }
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    // Clear session
    await sharedPreferences.remove('userId');
    await sharedPreferences.remove('userEmail');
    await sharedPreferences.remove('userFullName');
    await sharedPreferences.setBool('isLoggedIn', false);

    emit(Unauthenticated());
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatus event,
    Emitter<AuthState> emit,
  ) async {
    final isLoggedIn = sharedPreferences.getBool('isLoggedIn') ?? false;

    if (isLoggedIn) {
      final userId = sharedPreferences.getString('userId') ?? '';
      final email = sharedPreferences.getString('userEmail') ?? '';
      final fullName = sharedPreferences.getString('userFullName') ?? '';

      emit(Authenticated(
        userId: userId,
        email: email,
        fullName: fullName,
      ));
    } else {
      emit(Unauthenticated());
    }
  }
}
