part of 'user_bloc.dart';

/// User events
abstract class UserEvent extends Equatable {
  const UserEvent();

  @override
  List<Object?> get props => [];
}

/// Load current user profile
class UserProfileRequested extends UserEvent {
  const UserProfileRequested();
}

/// Load user by ID
class UserByIdRequested extends UserEvent {
  final int userId;

  const UserByIdRequested({required this.userId});

  @override
  List<Object?> get props => [userId];
}

/// Update user profile
class UserProfileUpdateRequested extends UserEvent {
  final String? nickname;
  final String? gender;

  const UserProfileUpdateRequested({
    this.nickname,
    this.gender,
  });

  @override
  List<Object?> get props => [nickname, gender];
}

/// Change nickname
class UserNicknameChangeRequested extends UserEvent {
  final String nickname;

  const UserNicknameChangeRequested({required this.nickname});

  @override
  List<Object?> get props => [nickname];
}

/// Change password
class UserPasswordChangeRequested extends UserEvent {
  final String currentPassword;
  final String newPassword;

  const UserPasswordChangeRequested({
    required this.currentPassword,
    required this.newPassword,
  });

  @override
  List<Object?> get props => [currentPassword, newPassword];
}

/// Update notification settings
class UserNotificationSettingsUpdateRequested extends UserEvent {
  final bool? pushEnabled;
  final bool? broadcastPushEnabled;
  final bool? messagePushEnabled;

  const UserNotificationSettingsUpdateRequested({
    this.pushEnabled,
    this.broadcastPushEnabled,
    this.messagePushEnabled,
  });

  @override
  List<Object?> get props => [pushEnabled, broadcastPushEnabled, messagePushEnabled];
}

/// Block user
class UserBlockRequested extends UserEvent {
  final int userId;

  const UserBlockRequested({required this.userId});

  @override
  List<Object?> get props => [userId];
}

/// Unblock user
class UserUnblockRequested extends UserEvent {
  final int userId;

  const UserUnblockRequested({required this.userId});

  @override
  List<Object?> get props => [userId];
}

/// Load blocked users list
class UserBlockedListRequested extends UserEvent {
  const UserBlockedListRequested();
}

/// Report user
class UserReportRequested extends UserEvent {
  final int userId;
  final String reason;

  const UserReportRequested({
    required this.userId,
    required this.reason,
  });

  @override
  List<Object?> get props => [userId, reason];
}

/// Clear user state (on logout)
class UserCleared extends UserEvent {
  const UserCleared();
}
