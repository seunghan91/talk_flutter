import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:talk_flutter/domain/entities/user.dart';
import 'package:talk_flutter/domain/repositories/user_repository.dart';

part 'user_event.dart';
part 'user_state.dart';

/// User BLoC - manages user profile state
class UserBloc extends Bloc<UserEvent, UserState> {
  final UserRepository _userRepository;

  UserBloc({
    required UserRepository userRepository,
  })  : _userRepository = userRepository,
        super(const UserState()) {
    on<UserProfileRequested>(_onProfileRequested);
    on<UserByIdRequested>(_onByIdRequested);
    on<UserProfileUpdateRequested>(_onProfileUpdateRequested);
    on<UserNicknameChangeRequested>(_onNicknameChangeRequested);
    on<UserPasswordChangeRequested>(_onPasswordChangeRequested);
    on<UserNotificationSettingsUpdateRequested>(_onNotificationSettingsUpdateRequested);
    on<UserBlockRequested>(_onBlockRequested);
    on<UserUnblockRequested>(_onUnblockRequested);
    on<UserBlockedListRequested>(_onBlockedListRequested);
    on<UserReportRequested>(_onReportRequested);
    on<UserCleared>(_onCleared);
  }

  /// Load current user profile
  Future<void> _onProfileRequested(
    UserProfileRequested event,
    Emitter<UserState> emit,
  ) async {
    emit(state.copyWith(status: UserBlocStatus.loading, clearError: true));

    try {
      final user = await _userRepository.getMe();
      final settings = await _userRepository.getNotificationSettings();

      emit(state.copyWith(
        status: UserBlocStatus.success,
        currentUser: user,
        notificationSettings: settings,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: UserBlocStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  /// Load user by ID
  Future<void> _onByIdRequested(
    UserByIdRequested event,
    Emitter<UserState> emit,
  ) async {
    emit(state.copyWith(status: UserBlocStatus.loading, clearError: true));

    try {
      final user = await _userRepository.getUserById(event.userId);
      emit(state.copyWith(
        status: UserBlocStatus.success,
        viewedUser: user,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: UserBlocStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  /// Update user profile
  Future<void> _onProfileUpdateRequested(
    UserProfileUpdateRequested event,
    Emitter<UserState> emit,
  ) async {
    emit(state.copyWith(status: UserBlocStatus.loading, clearError: true));

    try {
      final user = await _userRepository.updateProfile(
        nickname: event.nickname,
        gender: event.gender,
      );
      emit(state.copyWith(
        status: UserBlocStatus.success,
        currentUser: user,
        successMessage: '프로필이 수정되었습니다.',
      ));
    } catch (e) {
      emit(state.copyWith(
        status: UserBlocStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  /// Change nickname
  Future<void> _onNicknameChangeRequested(
    UserNicknameChangeRequested event,
    Emitter<UserState> emit,
  ) async {
    emit(state.copyWith(status: UserBlocStatus.loading, clearError: true));

    try {
      final user = await _userRepository.changeNickname(event.nickname);
      emit(state.copyWith(
        status: UserBlocStatus.success,
        currentUser: user,
        successMessage: '닉네임이 변경되었습니다.',
      ));
    } catch (e) {
      emit(state.copyWith(
        status: UserBlocStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  /// Change password
  Future<void> _onPasswordChangeRequested(
    UserPasswordChangeRequested event,
    Emitter<UserState> emit,
  ) async {
    emit(state.copyWith(status: UserBlocStatus.loading, clearError: true));

    try {
      await _userRepository.changePassword(
        currentPassword: event.currentPassword,
        newPassword: event.newPassword,
      );
      emit(state.copyWith(
        status: UserBlocStatus.success,
        successMessage: '비밀번호가 변경되었습니다.',
      ));
    } catch (e) {
      emit(state.copyWith(
        status: UserBlocStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  /// Update notification settings
  Future<void> _onNotificationSettingsUpdateRequested(
    UserNotificationSettingsUpdateRequested event,
    Emitter<UserState> emit,
  ) async {
    emit(state.copyWith(status: UserBlocStatus.loading, clearError: true));

    try {
      await _userRepository.updateNotificationSettings(
        pushEnabled: event.pushEnabled,
        broadcastPushEnabled: event.broadcastPushEnabled,
        messagePushEnabled: event.messagePushEnabled,
      );

      // Update local state
      final updatedSettings = Map<String, bool>.from(state.notificationSettings);
      if (event.pushEnabled != null) {
        updatedSettings['push_enabled'] = event.pushEnabled!;
      }
      if (event.broadcastPushEnabled != null) {
        updatedSettings['broadcast_push_enabled'] = event.broadcastPushEnabled!;
      }
      if (event.messagePushEnabled != null) {
        updatedSettings['message_push_enabled'] = event.messagePushEnabled!;
      }

      emit(state.copyWith(
        status: UserBlocStatus.success,
        notificationSettings: updatedSettings,
        successMessage: '알림 설정이 저장되었습니다.',
      ));
    } catch (e) {
      emit(state.copyWith(
        status: UserBlocStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  /// Block user
  Future<void> _onBlockRequested(
    UserBlockRequested event,
    Emitter<UserState> emit,
  ) async {
    emit(state.copyWith(status: UserBlocStatus.loading, clearError: true));

    try {
      await _userRepository.blockUser(event.userId);
      emit(state.copyWith(
        status: UserBlocStatus.success,
        successMessage: '사용자를 차단했습니다.',
      ));
    } catch (e) {
      emit(state.copyWith(
        status: UserBlocStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  /// Unblock user
  Future<void> _onUnblockRequested(
    UserUnblockRequested event,
    Emitter<UserState> emit,
  ) async {
    emit(state.copyWith(status: UserBlocStatus.loading, clearError: true));

    try {
      await _userRepository.unblockUser(event.userId);

      // Remove from blocked list
      final updatedList = state.blockedUsers
          .where((u) => u.id != event.userId)
          .toList();

      emit(state.copyWith(
        status: UserBlocStatus.success,
        blockedUsers: updatedList,
        successMessage: '차단이 해제되었습니다.',
      ));
    } catch (e) {
      emit(state.copyWith(
        status: UserBlocStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  /// Load blocked users list
  Future<void> _onBlockedListRequested(
    UserBlockedListRequested event,
    Emitter<UserState> emit,
  ) async {
    emit(state.copyWith(status: UserBlocStatus.loading, clearError: true));

    try {
      final users = await _userRepository.getBlockedUsers();
      emit(state.copyWith(
        status: UserBlocStatus.success,
        blockedUsers: users,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: UserBlocStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  /// Report user
  Future<void> _onReportRequested(
    UserReportRequested event,
    Emitter<UserState> emit,
  ) async {
    emit(state.copyWith(status: UserBlocStatus.loading, clearError: true));

    try {
      await _userRepository.reportUser(event.userId, event.reason);
      emit(state.copyWith(
        status: UserBlocStatus.success,
        successMessage: '신고가 접수되었습니다.',
      ));
    } catch (e) {
      emit(state.copyWith(
        status: UserBlocStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  /// Clear user state (on logout)
  void _onCleared(
    UserCleared event,
    Emitter<UserState> emit,
  ) {
    emit(const UserState());
  }
}
