import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/api_constants.dart';
import '../errors/exceptions.dart';

/// HTTP Client wrapper using Dio for API calls
class ApiClient {
  late final Dio _dio;
  final FlutterSecureStorage _secureStorage;
  
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';

  ApiClient(this._secureStorage) {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: ApiConstants.connectionTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
        headers: {
          'Content-Type': ApiConstants.contentType,
        },
      ),
    );

    // Add interceptors
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: _onRequest,
        onResponse: _onResponse,
        onError: _onError,
      ),
    );
  }

  // ============== Token Management ==============
  
  /// Get stored access token
  Future<String?> get accessToken => _secureStorage.read(key: _accessTokenKey);
  
  /// Get stored refresh token
  Future<String?> get refreshToken => _secureStorage.read(key: _refreshTokenKey);

  /// Store tokens after login/register
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _secureStorage.write(key: _accessTokenKey, value: accessToken);
    await _secureStorage.write(key: _refreshTokenKey, value: refreshToken);
  }

  /// Clear tokens on logout
  Future<void> clearTokens() async {
    await _secureStorage.delete(key: _accessTokenKey);
    await _secureStorage.delete(key: _refreshTokenKey);
  }

  /// Check if user has valid tokens
  Future<bool> get hasTokens async {
    final token = await accessToken;
    return token != null && token.isNotEmpty;
  }

  // ============== Interceptors ==============

  /// Add authorization token to requests
  Future<void> _onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Get access token from secure storage
    final token = await _secureStorage.read(key: _accessTokenKey);
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  /// Handle responses
  void _onResponse(
    Response response,
    ResponseInterceptorHandler handler,
  ) {
    handler.next(response);
  }

  /// Handle errors
  Future<void> _onError(
    DioException error,
    ErrorInterceptorHandler handler,
  ) async {
    // Handle 401 Unauthorized - try to refresh token
    if (error.response?.statusCode == 401) {
      final refresh = await _secureStorage.read(key: _refreshTokenKey);
      
      if (refresh != null) {
        try {
          // Try to refresh the token
          final refreshResponse = await _dio.post(
            ApiConstants.refresh,
            data: {'refreshToken': refresh},
            options: Options(
              headers: {'Authorization': 'Bearer $refresh'},
            ),
          );
          
          if (refreshResponse.statusCode == 200 || refreshResponse.statusCode == 201) {
            final newAccessToken = refreshResponse.data['accessToken'];
            final newRefreshToken = refreshResponse.data['refreshToken'] ?? refresh;
            
            // Save new tokens
            await saveTokens(
              accessToken: newAccessToken,
              refreshToken: newRefreshToken,
            );
            
            // Retry the original request with new token
            final opts = error.requestOptions;
            opts.headers['Authorization'] = 'Bearer $newAccessToken';
            
            final retryResponse = await _dio.fetch(opts);
            return handler.resolve(retryResponse);
          }
        } catch (refreshError) {
          // Token refresh failed, clear tokens and let error propagate
          await clearTokens();
        }
      }
    }
    handler.next(error);
  }

  // ============== HTTP Methods ==============

  /// GET request
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// POST request
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// PUT request
  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// DELETE request
  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Handle and transform Dio errors
  Exception _handleError(DioException error) {
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return NetworkException('Connection timeout. Please check your internet connection.');
    }

    if (error.type == DioExceptionType.connectionError) {
      return NetworkException('No internet connection. Please try again.');
    }

    if (error.response != null) {
      final statusCode = error.response!.statusCode;
      final message = error.response!.data is Map 
          ? error.response!.data['message'] ?? 'An error occurred'
          : 'An error occurred';

      switch (statusCode) {
        case 400:
          return BadRequestException(message);
        case 401:
          return UnauthorizedException(message);
        case 403:
          return ForbiddenException(message);
        case 404:
          return NotFoundException(message);
        case 409:
          return ConflictException(message);
        default:
          return ServerException(message, statusCode);
      }
    }

    return ServerException('An unexpected error occurred');
  }
}

