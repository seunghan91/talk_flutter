import 'dart:io';
import 'package:talk_flutter/domain/entities/user.dart';

/// User repository interface - Domain layer
abstract class UserRepository {
  /// Get current user profile
  Future<User> getMe();

  /// Get user by ID
  Future<User> getUserById(int id);

  /// Update current user profile
  Future<User> updateProfile({
    String? nickname,
    String? gender,
    File? profileImage,
  });

  /// Change password
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  });

  /// Change nickname
  Future<User> changeNickname(String nickname);

  /// Get notification settings
  Future<Map<String, bool>> getNotificationSettings();

  /// Update notification settings
  Future<void> updateNotificationSettings({
    bool? pushEnabled,
    bool? broadcastPushEnabled,
    bool? messagePushEnabled,
  });

  /// Block a user
  Future<void> blockUser(int userId);

  /// Unblock a user
  Future<void> unblockUser(int userId);

  /// Get blocked users list
  Future<List<User>> getBlockedUsers();

  /// Report a user
  Future<void> reportUser(int userId, String reason);

  /// Disable push notifications
  Future<void> disablePush();
}
