import 'package:equatable/equatable.dart';
import 'package:talk_flutter/domain/entities/notification.dart';
import 'package:talk_flutter/domain/repositories/notification_repository.dart';

/// Notification state status
enum NotificationStatus { initial, loading, loaded, error }

/// Notification state
class NotificationState extends Equatable {
  final NotificationStatus status;
  final List<AppNotification> notifications;
  final int unreadCount;
  final NotificationSettings? settings;
  final int currentPage;
  final int totalPages;
  final bool hasReachedMax;
  final String? errorMessage;
  final String? successMessage;

  const NotificationState({
    this.status = NotificationStatus.initial,
    this.notifications = const [],
    this.unreadCount = 0,
    this.settings,
    this.currentPage = 1,
    this.totalPages = 1,
    this.hasReachedMax = false,
    this.errorMessage,
    this.successMessage,
  });

  bool get isLoading => status == NotificationStatus.loading;
  bool get hasError => errorMessage != null;
  bool get hasNotifications => notifications.isNotEmpty;

  NotificationState copyWith({
    NotificationStatus? status,
    List<AppNotification>? notifications,
    int? unreadCount,
    NotificationSettings? settings,
    int? currentPage,
    int? totalPages,
    bool? hasReachedMax,
    String? errorMessage,
    String? successMessage,
  }) {
    return NotificationState(
      status: status ?? this.status,
      notifications: notifications ?? this.notifications,
      unreadCount: unreadCount ?? this.unreadCount,
      settings: settings ?? this.settings,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        notifications,
        unreadCount,
        settings,
        currentPage,
        totalPages,
        hasReachedMax,
        errorMessage,
        successMessage,
      ];
}
