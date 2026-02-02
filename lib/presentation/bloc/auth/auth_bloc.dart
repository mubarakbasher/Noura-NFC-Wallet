import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/network/api_client.dart';
import '../../../core/utils/logger.dart';
import '../../../data/datasources/auth_remote_datasource.dart';
import '../../../core/errors/exceptions.dart';
import 'auth_event.dart';
import 'auth_state.dart';

/// Authentication BLoC
/// Handles login, signup, and session management with real backend
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SharedPreferences sharedPreferences;
  final AuthRemoteDataSource authDataSource;
  final ApiClient apiClient;

  AuthBloc({
    required this.sharedPreferences,
    required this.authDataSource,
    required this.apiClient,
  }) : super(AuthInitial()) {
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

    try {
      final response = await authDataSource.login(
        email: event.email,
        password: event.password,
      );

      // Save user info to shared preferences
      await sharedPreferences.setString('userId', response.user.id);
      await sharedPreferences.setString('userEmail', response.user.email);
      await sharedPreferences.setString('userFullName', response.user.fullName);
      await sharedPreferences.setBool('isLoggedIn', true);

      // Save wallet info if available
      if (response.wallet != null) {
        await sharedPreferences.setString('walletId', response.wallet!.id);
        await sharedPreferences.setDouble('walletBalance', response.wallet!.balance);
      }

      emit(Authenticated(
        userId: response.user.id,
        email: response.user.email,
        fullName: response.user.fullName,
      ));
    } on UnauthorizedException catch (e) {
      emit(AuthError(e.message));
    } on NetworkException catch (e) {
      emit(AuthError('Network error: ${e.message}'));
    } on ServerException catch (e) {
      emit(AuthError(e.message));
    } catch (e) {
      emit(AuthError('Login failed: ${e.toString()}'));
    }
  }

  Future<void> _onSignupRequested(
    SignupRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      // Register user
      await authDataSource.register(
        fullName: event.fullName,
        email: event.email,
        password: event.password,
        phone: event.phone,
      );

      // Clear tokens - user needs to login after registration
      await apiClient.clearTokens();
      await sharedPreferences.setBool('isLoggedIn', false);

      // Emit success state - will redirect to login
      emit(const RegistrationSuccess());
    } on ConflictException catch (e) {
      emit(AuthError(e.message));
    } on BadRequestException catch (e) {
      emit(AuthError(e.message));
    } on NetworkException catch (e) {
      emit(AuthError('Network error: ${e.message}'));
    } on ServerException catch (e) {
      emit(AuthError(e.message));
    } catch (e) {
      emit(AuthError('Registration failed: ${e.toString()}'));
    }
  }


  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      await authDataSource.logout();
    } catch (e) {
      // Continue with logout even if API call fails
      AppLogger.warning('Logout API error', tag: 'AuthBloc', error: e);
    }

    // Clear local session
    await sharedPreferences.remove('userId');
    await sharedPreferences.remove('userEmail');
    await sharedPreferences.remove('userFullName');
    await sharedPreferences.remove('walletId');
    await sharedPreferences.remove('walletBalance');
    await sharedPreferences.setBool('isLoggedIn', false);

    emit(Unauthenticated());
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatus event,
    Emitter<AuthState> emit,
  ) async {
    final isLoggedIn = sharedPreferences.getBool('isLoggedIn') ?? false;
    final hasTokens = await apiClient.hasTokens;

    if (isLoggedIn && hasTokens) {
      final userId = sharedPreferences.getString('userId') ?? '';
      final email = sharedPreferences.getString('userEmail') ?? '';
      final fullName = sharedPreferences.getString('userFullName') ?? '';

      emit(Authenticated(
        userId: userId,
        email: email,
        fullName: fullName,
      ));
    } else {
      // Clear any stale session data
      await sharedPreferences.setBool('isLoggedIn', false);
      emit(Unauthenticated());
    }
  }
}
