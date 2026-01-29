import 'package:equatable/equatable.dart';

/// Base failure class for domain errors
abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object?> get props => [message];

  /// Get user-friendly error message
  String toUserMessage();

  /// Check if operation can be retried
  bool get isRetryable;
}

/// Network connection failure
class NetworkFailure extends Failure {
  const NetworkFailure([super.message = '네트워크 오류']);

  @override
  String toUserMessage() => '네트워크 연결을 확인해주세요';

  @override
  bool get isRetryable => true;
}

/// Authentication failure (401)
class AuthenticationFailure extends Failure {
  const AuthenticationFailure([super.message = '인증 오류']);

  @override
  String toUserMessage() => '로그인이 만료되었습니다. 다시 로그인해주세요';

  @override
  bool get isRetryable => false;
}

/// Authorization failure (403)
class AuthorizationFailure extends Failure {
  const AuthorizationFailure([super.message = '권한 오류']);

  @override
  String toUserMessage() => '권한이 없습니다';

  @override
  bool get isRetryable => false;
}

/// Not found failure (404)
class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = '찾을 수 없음']);

  @override
  String toUserMessage() => '요청한 정보를 찾을 수 없습니다';

  @override
  bool get isRetryable => false;
}

/// Validation failure (422)
class ValidationFailure extends Failure {
  const ValidationFailure([super.message = '유효성 검사 오류']);

  @override
  String toUserMessage() => message;

  @override
  bool get isRetryable => false;
}

/// Server failure (500+)
class ServerFailure extends Failure {
  const ServerFailure([super.message = '서버 오류']);

  @override
  String toUserMessage() => '서버 오류가 발생했습니다. 잠시 후 다시 시도해주세요';

  @override
  bool get isRetryable => true;
}

/// Cache/local storage failure
class CacheFailure extends Failure {
  const CacheFailure([super.message = '캐시 오류']);

  @override
  String toUserMessage() => '로컬 데이터 오류가 발생했습니다';

  @override
  bool get isRetryable => true;
}

/// Unknown failure
class UnknownFailure extends Failure {
  const UnknownFailure([super.message = '알 수 없는 오류']);

  @override
  String toUserMessage() => '예상하지 못한 오류가 발생했습니다';

  @override
  bool get isRetryable => true;
}

/// Exception for API errors
class ApiException implements Exception {
  final int? statusCode;
  final String message;
  final dynamic data;

  const ApiException({
    this.statusCode,
    required this.message,
    this.data,
  });

  @override
  String toString() => 'ApiException(statusCode: $statusCode, message: $message)';

  Failure toFailure() {
    if (statusCode == null) {
      return NetworkFailure(message);
    }

    return switch (statusCode!) {
      401 => AuthenticationFailure(message),
      403 => AuthorizationFailure(message),
      404 => NotFoundFailure(message),
      422 => ValidationFailure(message),
      >= 500 => ServerFailure(message),
      _ => UnknownFailure(message),
    };
  }
}
