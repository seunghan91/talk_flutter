import 'package:talk_flutter/core/services/firebase_phone_auth_service.dart';
import 'package:talk_flutter/data/datasources/local/secure_storage_datasource.dart';
import 'package:talk_flutter/data/datasources/remote/api_client.dart';
import 'package:talk_flutter/data/models/auth_response_model.dart';
import 'package:talk_flutter/data/models/user_model.dart';
import 'package:talk_flutter/domain/entities/user.dart';
import 'package:talk_flutter/domain/repositories/auth_repository.dart';

/// Auth repository implementation using Firebase Phone Auth
class AuthRepositoryImpl implements AuthRepository {
  final ApiClient _apiClient;
  final SecureStorageDatasource _secureStorage;
  final FirebasePhoneAuthService _firebasePhoneAuth;

  AuthRepositoryImpl({
    required ApiClient apiClient,
    required SecureStorageDatasource secureStorage,
    FirebasePhoneAuthService? firebasePhoneAuth,
  })  : _apiClient = apiClient,
        _secureStorage = secureStorage,
        _firebasePhoneAuth = firebasePhoneAuth ?? FirebasePhoneAuthService();

  @override
  Future<String> requestVerificationCode(String phoneNumber) async {
    return await _firebasePhoneAuth.sendVerificationCode(phoneNumber);
  }

  @override
  Future<bool> verifyCode(
      String phoneNumber, String code, String verificationId) async {
    // Dev bypass: verificationId가 비어있으면 서버 직접 호출 (Firebase 스킵)
    if (verificationId.isEmpty) {
      await _apiClient.verifyCode({'phone_number': phoneNumber, 'code': code});
      return true;
    }

    // 1. Verify with Firebase → get ID token
    final firebaseToken =
        await _firebasePhoneAuth.verifyCodeAndGetToken(verificationId, code);

    // 2. Send Firebase token to Rails → marks phone as verified
    await _apiClient.firebaseVerifyPhone({'firebase_token': firebaseToken});

    // 3. Sign out from Firebase (Rails manages session from here)
    await _firebasePhoneAuth.signOut();

    return true;
  }

  @override
  Future<User> register({
    required String phoneNumber,
    required String password,
    required String nickname,
    String? gender,
  }) async {
    final body = {
      'user': {
        'phone_number': phoneNumber,
        'password': password,
        'password_confirmation': password,
        'nickname': nickname,
        if (gender != null) 'gender': gender,
      },
    };

    final response = await _apiClient.register(body);

    final data = response.data as Map<String, dynamic>? ?? {};
    final authResponse = AuthResponseModel.fromJson(data);

    if (authResponse.token != null) {
      await _secureStorage.saveAccessToken(authResponse.token!);
    }

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

    if (authResponse.token != null) {
      await _secureStorage.saveAccessToken(authResponse.token!);
    }

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
    final userData = await _secureStorage.getUserData();
    if (userData != null) {
      final userModel = UserModel.fromJson(userData);
      return userModel.toEntity();
    }

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
