import 'package:dio/dio.dart';
import 'package:talk_flutter/core/errors/failures.dart';

/// Extract a user-friendly error message from any exception.
/// Hides technical details (DioException, ApiException, etc.) from end users.
String getUserFriendlyErrorMessage(dynamic error) {
  if (error is DioException && error.error is ApiException) {
    return (error.error as ApiException).toFailure().toUserMessage();
  }
  if (error is ApiException) {
    return error.toFailure().toUserMessage();
  }
  return '잠시 후 다시 시도해주세요';
}
