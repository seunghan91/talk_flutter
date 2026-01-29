import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:talk_flutter/core/constants/app_constants.dart';
import 'package:talk_flutter/core/errors/failures.dart';
import 'package:talk_flutter/data/datasources/local/secure_storage_datasource.dart';

/// Callback for handling authentication expiration
typedef OnAuthExpired = Future<void> Function();

/// Dio HTTP client configuration
class DioClient {
  final SecureStorageDatasource _secureStorage;
  final String baseUrl;
  final OnAuthExpired? onAuthExpired;
  late final Dio dio;

  DioClient(
    this._secureStorage, {
    String? baseUrl,
    this.onAuthExpired,
  }) : baseUrl = baseUrl ?? AppConstants.apiBaseUrl {
    dio = _createDio();
  }

  Dio _createDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: AppConstants.apiTimeout,
        receiveTimeout: AppConstants.apiTimeout,
        sendTimeout: AppConstants.apiTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add interceptors
    dio.interceptors.addAll([
      _AuthInterceptor(_secureStorage, onAuthExpired: onAuthExpired),
      _ErrorInterceptor(),
      if (kDebugMode)
        PrettyDioLogger(
          requestHeader: true,
          requestBody: true,
          responseBody: true,
          responseHeader: false,
          error: true,
          compact: true,
        ),
    ]);

    return dio;
  }
}

/// Auth interceptor - adds JWT token to requests
class _AuthInterceptor extends Interceptor {
  final SecureStorageDatasource _secureStorage;
  final OnAuthExpired? onAuthExpired;
  bool _isHandlingExpiry = false;

  _AuthInterceptor(this._secureStorage, {this.onAuthExpired});

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Skip auth for certain endpoints
    final noAuthPaths = [
      '/auth/phone_verifications',
      '/auth/sessions',
      '/auth/registrations',
      '/auth/request_code',
      '/auth/verify_code',
      '/auth/register',
      '/auth/login',
      '/health',
    ];

    final needsAuth = !noAuthPaths.any((path) => options.path.contains(path));

    if (needsAuth) {
      final token = await _secureStorage.getAccessToken();
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }

    handler.next(options);
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    // Handle 401 - token expired (only if we had a token)
    if (err.response?.statusCode == 401) {
      // Only trigger logout if user was authenticated (had a token)
      final token = await _secureStorage.getAccessToken();
      if (token != null && !_isHandlingExpiry && onAuthExpired != null) {
        _isHandlingExpiry = true;
        try {
          // Clear stored tokens
          await _secureStorage.clearAll();
          // Notify app of auth expiration (triggers logout)
          await onAuthExpired!();
        } finally {
          _isHandlingExpiry = false;
        }
      }
    }
    handler.next(err);
  }
}

/// Error interceptor - transforms Dio errors to ApiException
class _ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final statusCode = err.response?.statusCode;
    String message = '네트워크 오류가 발생했습니다';

    if (err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.receiveTimeout) {
      message = '연결 시간이 초과되었습니다';
    } else if (err.type == DioExceptionType.connectionError) {
      message = '인터넷 연결을 확인해주세요';
    } else if (err.response != null) {
      final data = err.response?.data;
      if (data is Map<String, dynamic>) {
        message = data['error'] ?? data['message'] ?? message;
      }
    }

    final apiException = ApiException(
      statusCode: statusCode,
      message: message,
      data: err.response?.data,
    );

    handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        response: err.response,
        type: err.type,
        error: apiException,
      ),
    );
  }
}
