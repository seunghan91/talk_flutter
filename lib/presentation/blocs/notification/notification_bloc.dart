import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talk_flutter/domain/repositories/notification_repository.dart';
import 'package:talk_flutter/presentation/blocs/notification/notification_event.dart';
import 'package:talk_flutter/presentation/blocs/notification/notification_state.dart';

/// Notification BLoC
class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final NotificationRepository _notificationRepository;

  NotificationBloc({
    required NotificationRepository notificationRepository,
  })  : _notificationRepository = notificationRepository,
        super(const NotificationState()) {
    on<NotificationListRequested>(_onListRequested);
    on<NotificationMarkAsRead>(_onMarkAsRead);
    on<NotificationMarkAllAsRead>(_onMarkAllAsRead);
    on<NotificationUnreadCountRequested>(_onUnreadCountRequested);
    on<NotificationSettingsRequested>(_onSettingsRequested);
    on<NotificationSettingsUpdateRequested>(_onSettingsUpdateRequested);
    on<NotificationPushTokenUpdated>(_onPushTokenUpdated);
    on<NotificationCleared>(_onCleared);
  }

  Future<void> _onListRequested(
    NotificationListRequested event,
    Emitter<NotificationState> emit,
  ) async {
    if (state.hasReachedMax && !event.refresh) return;

    try {
      final page = event.refresh ? 1 : state.currentPage;
      emit(state.copyWith(status: NotificationStatus.loading));

      final result = await _notificationRepository.getNotifications(page: page);

      emit(state.copyWith(
        status: NotificationStatus.loaded,
        notifications: event.refresh
            ? result.notifications
            : [...state.notifications, ...result.notifications],
        unreadCount: result.unreadCount,
        currentPage: result.currentPage + 1,
        totalPages: result.totalPages,
        hasReachedMax: result.currentPage >= result.totalPages,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: NotificationStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onMarkAsRead(
    NotificationMarkAsRead event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      // Optimistic update
      final updatedNotifications = state.notifications.map((n) {
        if (n.id == event.notificationId) {
          return n.copyWith(isRead: true);
        }
        return n;
      }).toList();

      emit(state.copyWith(
        notifications: updatedNotifications,
        unreadCount: state.unreadCount > 0 ? state.unreadCount - 1 : 0,
      ));

      // Sync with server
      final newUnreadCount =
          await _notificationRepository.markAsRead(event.notificationId);

      emit(state.copyWith(unreadCount: newUnreadCount));
    } catch (e) {
      // Revert on error
      add(const NotificationListRequested(refresh: true));
    }
  }

  Future<void> _onMarkAllAsRead(
    NotificationMarkAllAsRead event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      // Optimistic update
      final updatedNotifications = state.notifications.map((n) {
        return n.copyWith(isRead: true);
      }).toList();

      emit(state.copyWith(
        notifications: updatedNotifications,
        unreadCount: 0,
        successMessage: '모든 알림을 읽음 처리했습니다.',
      ));

      // Sync with server
      await _notificationRepository.markAllAsRead();
    } catch (e) {
      emit(state.copyWith(
        errorMessage: '알림 읽음 처리에 실패했습니다.',
      ));
      // Revert on error
      add(const NotificationListRequested(refresh: true));
    }
  }

  Future<void> _onUnreadCountRequested(
    NotificationUnreadCountRequested event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      final count = await _notificationRepository.getUnreadCount();
      emit(state.copyWith(unreadCount: count));
    } catch (e) {
      // Silent failure for unread count
    }
  }

  Future<void> _onSettingsRequested(
    NotificationSettingsRequested event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      emit(state.copyWith(status: NotificationStatus.loading));
      final settings = await _notificationRepository.getSettings();
      emit(state.copyWith(
        status: NotificationStatus.loaded,
        settings: settings,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: NotificationStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onSettingsUpdateRequested(
    NotificationSettingsUpdateRequested event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      emit(state.copyWith(status: NotificationStatus.loading));

      final settings = await _notificationRepository.updateSettings(
        pushEnabled: event.pushEnabled,
        broadcastPushEnabled: event.broadcastPushEnabled,
        messagePushEnabled: event.messagePushEnabled,
      );

      emit(state.copyWith(
        status: NotificationStatus.loaded,
        settings: settings,
        successMessage: '알림 설정이 업데이트되었습니다.',
      ));
    } catch (e) {
      emit(state.copyWith(
        status: NotificationStatus.error,
        errorMessage: '알림 설정 업데이트에 실패했습니다.',
      ));
    }
  }

  Future<void> _onPushTokenUpdated(
    NotificationPushTokenUpdated event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      await _notificationRepository.updatePushToken(event.token);
    } catch (e) {
      // Silent failure for push token update
    }
  }

  void _onCleared(
    NotificationCleared event,
    Emitter<NotificationState> emit,
  ) {
    emit(const NotificationState());
  }
}
