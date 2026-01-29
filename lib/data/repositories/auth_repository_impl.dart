import 'package:talk_flutter/data/datasources/local/secure_storage_datasource.dart';
import 'package:talk_flutter/data/datasources/remote/api_client.dart';
import 'package:talk_flutter/data/models/auth_response_model.dart';
import 'package:talk_flutter/data/models/user_model.dart';
import 'package:talk_flutter/domain/entities/user.dart';
import 'package:talk_flutter/domain/repositories/auth_repository.dart';

/// Auth repository implementation
class AuthRepositoryImpl implements AuthRepository {
  final ApiClient _apiClient;
  final SecureStorageDatasource _secureStorage;

  AuthRepositoryImpl({
    required ApiClient apiClient,
    required SecureStorageDatasource secureStorage,
  })  : _apiClient = apiClient,
        _secureStorage = secureStorage;

  @override
  Future<void> requestVerificationCode(String phoneNumber) async {
    await _apiClient.requestVerificationCode({
      'phone_number': phoneNumber,
    });
  }

  @override
  Future<bool> verifyCode(String phoneNumber, String code) async {
    final response = await _apiClient.verifyCode({
      'phone_number': phoneNumber,
      'code': code,
    });
    final data = response.data as Map<String, dynamic>? ?? {};
    final verificationResponse = VerificationResponseModel.fromJson(data);
    return verificationResponse.verified == true;
  }

  @override
  Future<User> register({
    required String phoneNumber,
    required String password,
    required String nickname,
    String? gender,
  }) async {
    final response = await _apiClient.register({
      'phone_number': phoneNumber,
      'password': password,
      'nickname': nickname,
      if (gender != null) 'gender': gender,
    });

    final data = response.data as Map<String, dynamic>? ?? {};
    final authResponse = AuthResponseModel.fromJson(data);

    // Save auth tokens
    if (authResponse.token != null) {
      await _secureStorage.saveAccessToken(authResponse.token!);
    }

    // Parse and save user
    if (authResponse.user == null) {
      throw Exception('User data is missing from response');
    }

    final userModel = authResponse.user!;
    await _secureStorage.saveUserData(userModel.toJson());
    await _secureStorage.saveUserId(userModel.id);

    return userModel.toEntity();
  }

  @override
  Future<User> login({
    required String phoneNumber,
    required String password,
  }) async {
    final response = await _apiClient.login({
      'phone_number': phoneNumber,
      'password': password,
    });

    final data = response.data as Map<String, dynamic>? ?? {};
    final authResponse = AuthResponseModel.fromJson(data);

    // Save auth tokens
    if (authResponse.token != null) {
      await _secureStorage.saveAccessToken(authResponse.token!);
    }

    // Parse and save user
    if (authResponse.user == null) {
      throw Exception('User data is missing from response');
    }

    final userModel = authResponse.user!;
    await _secureStorage.saveUserData(userModel.toJson());
    await _secureStorage.saveUserId(userModel.id);

    return userModel.toEntity();
  }

  @override
  Future<void> logout() async {
    try {
      await _apiClient.logout();
    } finally {
      await clearAuthData();
    }
  }

  @override
  Future<User?> getCurrentUser() async {
    // Try to get from local storage first
    final userData = await _secureStorage.getUserData();
    if (userData != null) {
      final userModel = UserModel.fromJson(userData);
      return userModel.toEntity();
    }

    // Fetch from API if not cached
    final hasToken = await _secureStorage.hasAccessToken();
    if (!hasToken) return null;

    try {
      final response = await _apiClient.getMe();
      final data = response.data as Map<String, dynamic>? ?? {};
      final userJson = data['user'] as Map<String, dynamic>?;
      if (userJson == null) return null;

      final userModel = UserModel.fromJson(userJson);
      await _secureStorage.saveUserData(userModel.toJson());
      return userModel.toEntity();
    } catch (_) {
      return null;
    }
  }

  @override
  Future<bool> isAuthenticated() async {
    return await _secureStorage.hasAccessToken();
  }

  @override
  Future<void> refreshToken() async {
    // API does not support token refresh
    // Clear auth data and require re-login
    await clearAuthData();
  }

  @override
  Future<void> updatePushToken(String token) async {
    await _apiClient.updatePushToken({'push_token': token});
  }

  @override
  Future<String?> getAccessToken() async {
    return await _secureStorage.getAccessToken();
  }

  @override
  Future<void> clearAuthData() async {
    await _secureStorage.clearAll();
  }
}
