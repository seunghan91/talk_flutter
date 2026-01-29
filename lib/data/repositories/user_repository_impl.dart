import 'dart:io';

import 'package:talk_flutter/core/enums/app_enums.dart';
import 'package:talk_flutter/data/datasources/remote/api_client.dart';
import 'package:talk_flutter/domain/entities/user.dart';
import 'package:talk_flutter/domain/repositories/user_repository.dart';

/// User repository implementation
class UserRepositoryImpl implements UserRepository {
  final ApiClient _apiClient;

  UserRepositoryImpl({
    required ApiClient apiClient,
  }) : _apiClient = apiClient;

  @override
  Future<User> getMe() async {
    final response = await _apiClient.getMe();
    final data = response.data as Map<String, dynamic>? ?? {};
    final userData = data['user'] as Map<String, dynamic>? ?? data;
    return _parseUser(userData);
  }

  @override
  Future<User> getUserById(int id) async {
    final response = await _apiClient.getUserById(id);
    final data = response.data as Map<String, dynamic>? ?? {};
    final userData = data['user'] as Map<String, dynamic>? ?? data;
    return _parseUser(userData);
  }

  @override
  Future<User> updateProfile({
    String? nickname,
    String? gender,
    File? profileImage,
  }) async {
    final body = <String, dynamic>{};
    if (nickname != null) body['nickname'] = nickname;
    if (gender != null) body['gender'] = gender;

    // TODO: Handle profile image upload with multipart
    if (profileImage != null) {
      // For now, just update text fields
      // Image upload requires separate handling
    }

    final response = await _apiClient.updateMe(body);
    final data = response.data as Map<String, dynamic>? ?? {};
    final userData = data['user'] as Map<String, dynamic>? ?? data;
    return _parseUser(userData);
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await _apiClient.changePassword({
      'current_password': currentPassword,
      'new_password': newPassword,
    });
  }

  @override
  Future<User> changeNickname(String nickname) async {
    final response = await _apiClient.changeNickname({
      'nickname': nickname,
    });
    final data = response.data as Map<String, dynamic>? ?? {};
    final userData = data['user'] as Map<String, dynamic>? ?? data;
    return _parseUser(userData);
  }

  @override
  Future<Map<String, bool>> getNotificationSettings() async {
    final response = await _apiClient.getNotificationSettings();
    final data = response.data as Map<String, dynamic>? ?? {};
    return {
      'push_enabled': data['push_enabled'] as bool? ?? true,
      'broadcast_push_enabled': data['broadcast_push_enabled'] as bool? ?? true,
      'message_push_enabled': data['message_push_enabled'] as bool? ?? true,
    };
  }

  @override
  Future<void> updateNotificationSettings({
    bool? pushEnabled,
    bool? broadcastPushEnabled,
    bool? messagePushEnabled,
  }) async {
    final body = <String, dynamic>{};
    if (pushEnabled != null) body['push_enabled'] = pushEnabled;
    if (broadcastPushEnabled != null) {
      body['broadcast_push_enabled'] = broadcastPushEnabled;
    }
    if (messagePushEnabled != null) {
      body['message_push_enabled'] = messagePushEnabled;
    }

    await _apiClient.updateNotificationSettings(body);
  }

  @override
  Future<void> blockUser(int userId) async {
    await _apiClient.blockUser(userId);
  }

  @override
  Future<void> unblockUser(int userId) async {
    await _apiClient.unblockUser(userId);
  }

  @override
  Future<List<User>> getBlockedUsers() async {
    final response = await _apiClient.getBlockedUsers();
    final data = response.data as Map<String, dynamic>? ?? {};
    final usersData = data['users'] as List<dynamic>? ?? [];
    return usersData
        .map((u) => _parseUser(u as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> reportUser(int userId, String reason) async {
    await _apiClient.createReport({
      'reported_id': userId,
      'reason': reason,
      'report_type': 'user',
    });
  }

  @override
  Future<void> disablePush() async {
    await _apiClient.disablePush();
  }

  /// Parse user data from API response
  User _parseUser(Map<String, dynamic> data) {
    return User(
      id: data['id'] as int,
      phoneNumber: data['phone_number'] as String?,
      nickname: data['nickname'] as String? ?? 'User',
      gender: Gender.fromString(data['gender'] as String?),
      profileImageUrl: data['profile_image_url'] as String?,
      status: UserStatus.fromString(data['status'] as String?),
      verified: data['verified'] as bool? ?? false,
      pushEnabled: data['push_enabled'] as bool? ?? true,
      broadcastPushEnabled: data['broadcast_push_enabled'] as bool? ?? true,
      messagePushEnabled: data['message_push_enabled'] as bool? ?? true,
      walletBalance: data['wallet_balance'] as int?,
      createdAt: DateTime.parse(
        data['created_at'] as String? ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: data['updated_at'] != null
          ? DateTime.parse(data['updated_at'] as String)
          : null,
    );
  }
}
