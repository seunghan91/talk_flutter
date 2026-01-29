part of 'user_bloc.dart';

/// User status enum
enum UserBlocStatus {
  initial,
  loading,
  success,
  error,
}

/// User state
class UserState extends Equatable {
  final UserBlocStatus status;
  final User? currentUser;
  final User? viewedUser;
  final List<User> blockedUsers;
  final Map<String, bool> notificationSettings;
  final String? errorMessage;
  final String? successMessage;

  const UserState({
    this.status = UserBlocStatus.initial,
    this.currentUser,
    this.viewedUser,
    this.blockedUsers = const [],
    this.notificationSettings = const {},
    this.errorMessage,
    this.successMessage,
  });

  bool get isLoading => status == UserBlocStatus.loading;
  bool get hasError => status == UserBlocStatus.error;
  bool get isSuccess => status == UserBlocStatus.success;

  UserState copyWith({
    UserBlocStatus? status,
    User? currentUser,
    User? viewedUser,
    List<User>? blockedUsers,
    Map<String, bool>? notificationSettings,
    String? errorMessage,
    String? successMessage,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return UserState(
      status: status ?? this.status,
      currentUser: currentUser ?? this.currentUser,
      viewedUser: viewedUser ?? this.viewedUser,
      blockedUsers: blockedUsers ?? this.blockedUsers,
      notificationSettings: notificationSettings ?? this.notificationSettings,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearSuccess ? null : (successMessage ?? this.successMessage),
    );
  }

  @override
  List<Object?> get props => [
        status,
        currentUser,
        viewedUser,
        blockedUsers,
        notificationSettings,
        errorMessage,
        successMessage,
      ];
}
