import 'package:equatable/equatable.dart';

/// Notification events
abstract class NotificationEvent extends Equatable {
  const NotificationEvent();

  @override
  List<Object?> get props => [];
}

/// Request notification list
class NotificationListRequested extends NotificationEvent {
  final bool refresh;

  const NotificationListRequested({this.refresh = false});

  @override
  List<Object?> get props => [refresh];
}

/// Mark notification as read
class NotificationMarkAsRead extends NotificationEvent {
  final int notificationId;

  const NotificationMarkAsRead(this.notificationId);

  @override
  List<Object?> get props => [notificationId];
}

/// Mark all notifications as read
class NotificationMarkAllAsRead extends NotificationEvent {
  const NotificationMarkAllAsRead();
}

/// Request unread count
class NotificationUnreadCountRequested extends NotificationEvent {
  const NotificationUnreadCountRequested();
}

/// Request notification settings
class NotificationSettingsRequested extends NotificationEvent {
  const NotificationSettingsRequested();
}

/// Update notification settings
class NotificationSettingsUpdateRequested extends NotificationEvent {
  final bool? pushEnabled;
  final bool? broadcastPushEnabled;
  final bool? messagePushEnabled;

  const NotificationSettingsUpdateRequested({
    this.pushEnabled,
    this.broadcastPushEnabled,
    this.messagePushEnabled,
  });

  @override
  List<Object?> get props => [pushEnabled, broadcastPushEnabled, messagePushEnabled];
}

/// Update push token
class NotificationPushTokenUpdated extends NotificationEvent {
  final String token;

  const NotificationPushTokenUpdated(this.token);

  @override
  List<Object?> get props => [token];
}

/// Clear notification state
class NotificationCleared extends NotificationEvent {
  const NotificationCleared();
}
