import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

import '../config/api_config.dart';
import 'auth_service.dart';
import 'connectivity_service.dart';

// ═══════════════════════════════════════════════════════════════════════════
// API CLIENT PROVIDER
// ═══════════════════════════════════════════════════════════════════════════

final apiClientProvider = Provider<ApiClient>((ref) {
  final authService = ref.watch(authServiceProvider);
  final isOnline = ref.watch(isOnlineProvider);
  return ApiClient(authService: authService, isOnline: isOnline);
});

// ═══════════════════════════════════════════════════════════════════════════
// API CLIENT
// ═══════════════════════════════════════════════════════════════════════════

class ApiClient {
  final AuthService authService;
  final bool isOnline;
  final Dio _dio;
  final Logger _logger = Logger();

  ApiClient({
    required this.authService,
    required this.isOnline,
  }) : _dio = Dio(
          BaseOptions(
            baseUrl: ApiConfig.baseUrl,
            connectTimeout: ApiConfig.connectTimeout,
            receiveTimeout: ApiConfig.receiveTimeout,
            sendTimeout: ApiConfig.sendTimeout,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          ),
        ) {
    _setupInterceptors();
  }

  // ═════════════════════════════════════════════════════════════════════════
  // INTERCEPTOR SETUP
  // ═════════════════════════════════════════════════════════════════════════

  void _setupInterceptors() {
    // Request interceptor - add auth token
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Add Firebase ID token as bearer token
          final user = authService.currentUser;
          if (user != null) {
            try {
              final idToken = await user.getIdToken();
              if (idToken != null) {
                options.headers['Authorization'] = 'Bearer $idToken';
              }
            } catch (e) {
              _logger.w('Failed to get ID token: $e');
            }
          }

          _logger.d('Request: ${options.method} ${options.uri}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          _logger.d('Response: ${response.statusCode} ${response.requestOptions.uri}');
          return handler.next(response);
        },
        onError: (error, handler) async {
          _logger.e('API Error: ${error.response?.statusCode} ${error.requestOptions.uri}');
          _logger.e('Error message: ${error.message}');
          
          // Handle 401 Unauthorized - token expired
          if (error.response?.statusCode == 401) {
            try {
              // Attempt token refresh
              final user = authService.currentUser;
              if (user != null) {
                await user.getIdToken(true); // Force refresh
                
                // Retry original request
                final options = error.requestOptions;
                final idToken = await user.getIdToken();
                options.headers['Authorization'] = 'Bearer $idToken';
                
                final response = await _dio.fetch(options);
                return handler.resolve(response);
              }
            } catch (e) {
              _logger.e('Token refresh failed: $e');
            }
          }
          
          return handler.next(error);
        },
      ),
    );

    // Logging interceptor (development only)
    if (ApiConfig.isDevelopment) {
      _dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        error: true,
      ));
    }
  }

  // ═════════════════════════════════════════════════════════════════════════
  // HTTP METHODS
  // ═════════════════════════════════════════════════════════════════════════

  /// GET request
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    _checkOnlineStatus();
    
    try {
      return await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// POST request
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    _checkOnlineStatus();
    
    try {
      return await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// PUT request
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    _checkOnlineStatus();
    
    try {
      return await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// PATCH request
  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    _checkOnlineStatus();
    
    try {
      return await _dio.patch<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// DELETE request
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    _checkOnlineStatus();
    
    try {
      return await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ═════════════════════════════════════════════════════════════════════════
  // ERROR HANDLING
  // ═════════════════════════════════════════════════════════════════════════

  void _checkOnlineStatus() {
    if (!isOnline) {
      throw ApiException(
        message: 'No internet connection',
        statusCode: 0,
        type: ApiErrorType.network,
      );
    }
  }

  ApiException _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiException(
          message: 'Request timeout. Please check your connection and try again.',
          statusCode: 0,
          type: ApiErrorType.timeout,
          originalError: error,
        );

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode ?? 0;
        final data = error.response?.data;
        
        String message = 'An error occurred';
        if (data is Map<String, dynamic>) {
          message = data['message'] ?? data['error'] ?? message;
        }

        ApiErrorType type;
        if (statusCode == 401) {
          type = ApiErrorType.unauthorized;
          message = 'Session expired. Please login again.';
        } else if (statusCode == 403) {
          type = ApiErrorType.forbidden;
          message = 'You do not have permission to perform this action.';
        } else if (statusCode == 404) {
          type = ApiErrorType.notFound;
          message = 'Resource not found.';
        } else if (statusCode >= 500) {
          type = ApiErrorType.server;
          message = 'Server error. Please try again later.';
        } else {
          type = ApiErrorType.unknown;
        }

        return ApiException(
          message: message,
          statusCode: statusCode,
          type: type,
          originalError: error,
        );

      case DioExceptionType.cancel:
        return ApiException(
          message: 'Request cancelled',
          statusCode: 0,
          type: ApiErrorType.cancel,
          originalError: error,
        );

      case DioExceptionType.connectionError:
        return ApiException(
          message: 'Connection failed. Please check your internet connection.',
          statusCode: 0,
          type: ApiErrorType.network,
          originalError: error,
        );

      default:
        return ApiException(
          message: error.message ?? 'An unexpected error occurred',
          statusCode: 0,
          type: ApiErrorType.unknown,
          originalError: error,
        );
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// API EXCEPTION
// ═══════════════════════════════════════════════════════════════════════════

enum ApiErrorType {
  network,
  timeout,
  unauthorized,
  forbidden,
  notFound,
  server,
  cancel,
  unknown,
}

class ApiException implements Exception {
  final String message;
  final int statusCode;
  final ApiErrorType type;
  final dynamic originalError;

  ApiException({
    required this.message,
    required this.statusCode,
    required this.type,
    this.originalError,
  });

  @override
  String toString() => message;

  /// Check if error is recoverable (e.g., network, timeout)
  bool get isRecoverable {
    return type == ApiErrorType.network || 
           type == ApiErrorType.timeout ||
           type == ApiErrorType.server;
  }

  /// Check if user should be logged out
  bool get shouldLogout {
    return type == ApiErrorType.unauthorized;
  }
}
