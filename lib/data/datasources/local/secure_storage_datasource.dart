import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:talk_flutter/core/constants/app_constants.dart';

/// Secure storage datasource for sensitive data
class SecureStorageDatasource {
  final FlutterSecureStorage _storage;

  SecureStorageDatasource({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(
                encryptedSharedPreferences: true,
              ),
              iOptions: IOSOptions(
                accessibility: KeychainAccessibility.first_unlock,
              ),
            );

  // ============ Access Token ============

  Future<String?> getAccessToken() async {
    return await _storage.read(key: AppConstants.accessTokenKey);
  }

  Future<void> saveAccessToken(String token) async {
    await _storage.write(key: AppConstants.accessTokenKey, value: token);
  }

  Future<void> deleteAccessToken() async {
    await _storage.delete(key: AppConstants.accessTokenKey);
  }

  // ============ Refresh Token ============

  Future<String?> getRefreshToken() async {
    return await _storage.read(key: AppConstants.refreshTokenKey);
  }

  Future<void> saveRefreshToken(String token) async {
    await _storage.write(key: AppConstants.refreshTokenKey, value: token);
  }

  Future<void> deleteRefreshToken() async {
    await _storage.delete(key: AppConstants.refreshTokenKey);
  }

  // ============ User ID ============

  Future<int?> getUserId() async {
    final value = await _storage.read(key: AppConstants.userIdKey);
    return value != null ? int.tryParse(value) : null;
  }

  Future<void> saveUserId(int userId) async {
    await _storage.write(key: AppConstants.userIdKey, value: userId.toString());
  }

  Future<void> deleteUserId() async {
    await _storage.delete(key: AppConstants.userIdKey);
  }

  // ============ User Data ============

  Future<Map<String, dynamic>?> getUserData() async {
    final value = await _storage.read(key: AppConstants.userKey);
    if (value == null) return null;
    try {
      return jsonDecode(value) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  Future<void> saveUserData(Map<String, dynamic> userData) async {
    await _storage.write(key: AppConstants.userKey, value: jsonEncode(userData));
  }

  Future<void> deleteUserData() async {
    await _storage.delete(key: AppConstants.userKey);
  }

  // ============ Clear All ============

  Future<void> clearAll() async {
    await _storage.deleteAll();
  }

  // ============ Check Auth State ============

  Future<bool> hasAccessToken() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }
}
