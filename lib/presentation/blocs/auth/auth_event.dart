part of 'auth_bloc.dart';

/// Auth events
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// App started - check initial auth state
class AuthAppStarted extends AuthEvent {
  const AuthAppStarted();
}

/// Request SMS verification code
class AuthRequestCodeRequested extends AuthEvent {
  final String phoneNumber;

  const AuthRequestCodeRequested({required this.phoneNumber});

  @override
  List<Object?> get props => [phoneNumber];
}

/// Verify SMS code
class AuthVerifyCodeRequested extends AuthEvent {
  final String phoneNumber;
  final String code;

  const AuthVerifyCodeRequested({
    required this.phoneNumber,
    required this.code,
  });

  @override
  List<Object?> get props => [phoneNumber, code];
}

/// Register new user
class AuthRegisterRequested extends AuthEvent {
  final String phoneNumber;
  final String password;
  final String nickname;
  final String? gender;

  const AuthRegisterRequested({
    required this.phoneNumber,
    required this.password,
    required this.nickname,
    this.gender,
  });

  @override
  List<Object?> get props => [phoneNumber, password, nickname, gender];
}

/// Login with credentials
class AuthLoginRequested extends AuthEvent {
  final String phoneNumber;
  final String password;

  const AuthLoginRequested({
    required this.phoneNumber,
    required this.password,
  });

  @override
  List<Object?> get props => [phoneNumber, password];
}

/// Logout
class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}

/// User data updated (from profile edit, etc.)
class AuthUserUpdated extends AuthEvent {
  final User user;

  const AuthUserUpdated({required this.user});

  @override
  List<Object?> get props => [user];
}
