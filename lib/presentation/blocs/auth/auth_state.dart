part of 'auth_bloc.dart';

/// Auth state
class AuthState extends Equatable {
  final AuthStatus status;
  final User? user;
  final String? phoneNumber;
  final bool isCodeSent;
  final bool isCodeVerified;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.phoneNumber,
    this.isCodeSent = false,
    this.isCodeVerified = false,
    this.errorMessage,
  });

  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isLoading => status == AuthStatus.loading;
  bool get hasError => status == AuthStatus.error;

  AuthState copyWith({
    AuthStatus? status,
    User? user,
    String? phoneNumber,
    bool? isCodeSent,
    bool? isCodeVerified,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      isCodeSent: isCodeSent ?? this.isCodeSent,
      isCodeVerified: isCodeVerified ?? this.isCodeVerified,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
        status,
        user,
        phoneNumber,
        isCodeSent,
        isCodeVerified,
        errorMessage,
      ];
}
