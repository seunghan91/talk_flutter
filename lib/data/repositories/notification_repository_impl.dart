import 'package:talk_flutter/data/datasources/remote/api_client.dart';
import 'package:talk_flutter/domain/entities/notification.dart';
import 'package:talk_flutter/domain/repositories/notification_repository.dart';

/// Notification repository implementation
class NotificationRepositoryImpl implements NotificationRepository {
  final ApiClient _apiClient;

  NotificationRepositoryImpl({
    required ApiClient apiClient,
  }) : _apiClient = apiClient;

  @override
  Future<NotificationListResult> getNotifications({
    int page = 1,
    bool? readFilter,
    String? type,
  }) async {
    final response = await _apiClient.getNotifications();
    final data = response.data as Map<String, dynamic>? ?? {};
    final notifications = data['notifications'] as List<dynamic>? ?? [];
    final pagination = data['pagination'] as Map<String, dynamic>? ?? {};

    return NotificationListResult(
      notifications: notifications
          .map((json) => _parseNotification(json as Map<String, dynamic>))
          .toList(),
      unreadCount: data['unread_count'] as int? ?? 0,
      currentPage: pagination['current_page'] as int? ?? 1,
      totalPages: pagination['total_pages'] as int? ?? 1,
      totalCount: pagination['total_count'] as int? ?? 0,
    );
  }

  @override
  Future<AppNotification> getNotificationById(int id) async {
    final response = await _apiClient.getNotifications();
    final data = response.data as Map<String, dynamic>? ?? {};
    final notifications = data['notifications'] as List<dynamic>? ?? [];

    final notification = notifications.firstWhere(
      (n) => (n as Map<String, dynamic>)['id'] == id,
      orElse: () => throw Exception('Notification not found'),
    );

    return _parseNotification(notification as Map<String, dynamic>);
  }

  @override
  Future<int> markAsRead(int notificationId) async {
    final response = await _apiClient.markNotificationAsRead(notificationId);
    final data = response.data as Map<String, dynamic>? ?? {};
    return data['unread_count'] as int? ?? 0;
  }

  @override
  Future<void> markAllAsRead() async {
    await _apiClient.markAllNotificationsAsRead();
  }

  @override
  Future<int> getUnreadCount() async {
    final response = await _apiClient.getUnreadNotificationCount();
    final data = response.data as Map<String, dynamic>? ?? {};
    return data['unread_count'] as int? ?? 0;
  }

  @override
  Future<void> updatePushToken(String token) async {
    await _apiClient.updatePushToken({'push_token': token});
  }

  @override
  Future<NotificationSettings> getSettings() async {
    final response = await _apiClient.getNotificationSettings();
    final data = response.data as Map<String, dynamic>? ?? {};

    return NotificationSettings(
      pushEnabled: data['push_enabled'] as bool? ?? true,
      broadcastPushEnabled: data['broadcast_push_enabled'] as bool? ?? true,
      messagePushEnabled: data['message_push_enabled'] as bool? ?? true,
    );
  }

  @override
  Future<NotificationSettings> updateSettings({
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

    final response = await _apiClient.updateNotificationSettings(body);
    final data = response.data as Map<String, dynamic>? ?? {};
    final settings = data['settings'] as Map<String, dynamic>? ?? {};

    return NotificationSettings(
      pushEnabled: settings['push_enabled'] as bool? ?? true,
      broadcastPushEnabled: settings['broadcast_push_enabled'] as bool? ?? true,
      messagePushEnabled: settings['message_push_enabled'] as bool? ?? true,
    );
  }

  /// Parse notification data from API response
  AppNotification _parseNotification(Map<String, dynamic> data) {
    return AppNotification(
      id: data['id'] as int,
      type: data['type'] as String? ?? 'system',
      title: data['title'] as String?,
      body: data['body'] as String?,
      isRead: data['read'] as bool? ?? false,
      metadata: data['metadata'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(
        data['created_at'] as String? ?? DateTime.now().toIso8601String(),
      ),
      formattedDate: data['formatted_date'] as String?,
    );
  }
}
