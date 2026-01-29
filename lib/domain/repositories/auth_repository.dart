import 'package:talk_flutter/domain/entities/user.dart';

/// Auth repository interface - Domain layer
abstract class AuthRepository {
  /// Request SMS verification code
  Future<void> requestVerificationCode(String phoneNumber);

  /// Verify SMS code
  Future<bool> verifyCode(String phoneNumber, String code);

  /// Register new user
  Future<User> register({
    required String phoneNumber,
    required String password,
    required String nickname,
    String? gender,
  });

  /// Login with phone number and password
  Future<User> login({
    required String phoneNumber,
    required String password,
  });

  /// Logout current user
  Future<void> logout();

  /// Get current authenticated user
  Future<User?> getCurrentUser();

  /// Check if user is authenticated
  Future<bool> isAuthenticated();

  /// Refresh authentication token
  Future<void> refreshToken();

  /// Update push notification token
  Future<void> updatePushToken(String token);

  /// Get stored access token
  Future<String?> getAccessToken();

  /// Clear all auth data
  Future<void> clearAuthData();
}
