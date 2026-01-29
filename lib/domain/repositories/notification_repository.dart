import 'package:talk_flutter/domain/entities/notification.dart';

/// Notification repository interface - Domain layer
abstract class NotificationRepository {
  /// Get notifications with optional filtering
  Future<NotificationListResult> getNotifications({
    int page = 1,
    bool? readFilter,
    String? type,
  });

  /// Get single notification by ID
  Future<AppNotification> getNotificationById(int id);

  /// Mark notification as read
  Future<int> markAsRead(int notificationId);

  /// Mark all notifications as read
  Future<void> markAllAsRead();

  /// Get unread notification count
  Future<int> getUnreadCount();

  /// Update push token
  Future<void> updatePushToken(String token);

  /// Get notification settings
  Future<NotificationSettings> getSettings();

  /// Update notification settings
  Future<NotificationSettings> updateSettings({
    bool? pushEnabled,
    bool? broadcastPushEnabled,
    bool? messagePushEnabled,
  });
}

/// Notification list result with pagination info
class NotificationListResult {
  final List<AppNotification> notifications;
  final int unreadCount;
  final int currentPage;
  final int totalPages;
  final int totalCount;

  const NotificationListResult({
    required this.notifications,
    required this.unreadCount,
    required this.currentPage,
    required this.totalPages,
    required this.totalCount,
  });
}

/// Notification settings
class NotificationSettings {
  final bool pushEnabled;
  final bool broadcastPushEnabled;
  final bool messagePushEnabled;

  const NotificationSettings({
    required this.pushEnabled,
    required this.broadcastPushEnabled,
    required this.messagePushEnabled,
  });

  NotificationSettings copyWith({
    bool? pushEnabled,
    bool? broadcastPushEnabled,
    bool? messagePushEnabled,
  }) {
    return NotificationSettings(
      pushEnabled: pushEnabled ?? this.pushEnabled,
      broadcastPushEnabled: broadcastPushEnabled ?? this.broadcastPushEnabled,
      messagePushEnabled: messagePushEnabled ?? this.messagePushEnabled,
    );
  }
}
