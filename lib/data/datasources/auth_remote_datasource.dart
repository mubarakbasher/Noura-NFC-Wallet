import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../models/auth_response_model.dart';

/// Remote data source for authentication operations
class AuthRemoteDataSource {
  final ApiClient _apiClient;

  AuthRemoteDataSource({required ApiClient apiClient}) : _apiClient = apiClient;

  /// Login with email and password
  Future<AuthResponse> login({
    required String email,
    required String password,
    String? deviceId,
  }) async {
    final response = await _apiClient.post(
      ApiConstants.login,
      data: {
        'email': email,
        'password': password,
        if (deviceId != null) 'deviceId': deviceId,
      },
    );

    final authResponse = AuthResponse.fromJson(response.data as Map<String, dynamic>);
    
    // Save tokens
    await _apiClient.saveTokens(
      accessToken: authResponse.accessToken,
      refreshToken: authResponse.refreshToken,
    );

    return authResponse;
  }

  /// Register new user
  Future<AuthResponse> register({
    required String fullName,
    required String email,
    required String password,
    String? phone,
    String? deviceId,
  }) async {
    final response = await _apiClient.post(
      ApiConstants.register,
      data: {
        'fullName': fullName,
        'email': email,
        'password': password,
        if (phone != null) 'phone': phone,
        if (deviceId != null) 'deviceId': deviceId,
      },
    );

    final authResponse = AuthResponse.fromJson(response.data as Map<String, dynamic>);
    
    // Save tokens
    await _apiClient.saveTokens(
      accessToken: authResponse.accessToken,
      refreshToken: authResponse.refreshToken,
    );

    return authResponse;
  }

  /// Refresh access token
  Future<AuthResponse> refreshToken() async {
    final currentRefreshToken = await _apiClient.refreshToken;
    
    if (currentRefreshToken == null) {
      throw Exception('No refresh token available');
    }

    final response = await _apiClient.post(
      ApiConstants.refresh,
      data: {'refreshToken': currentRefreshToken},
    );

    final authResponse = AuthResponse.fromJson(response.data as Map<String, dynamic>);
    
    // Save new tokens
    await _apiClient.saveTokens(
      accessToken: authResponse.accessToken,
      refreshToken: authResponse.refreshToken,
    );

    return authResponse;
  }

  /// Logout user
  Future<void> logout() async {
    try {
      await _apiClient.post(ApiConstants.logout);
    } finally {
      // Always clear tokens, even if API call fails
      await _apiClient.clearTokens();
    }
  }

  /// Check if user is authenticated
  Future<bool> isAuthenticated() async {
    return await _apiClient.hasTokens;
  }
}
