part of 'auth_bloc.dart';

/// Auth state
class AuthState extends Equatable {
  final AuthStatus status;
  final User? user;
  final String? phoneNumber;
  final bool isCodeSent;
  final bool isCodeVerified;
  final String? errorMessage;
  final String? verificationId; // Firebase verificationId

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.phoneNumber,
    this.isCodeSent = false,
    this.isCodeVerified = false,
    this.errorMessage,
    this.verificationId,
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
    String? verificationId,
    bool clearError = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      isCodeSent: isCodeSent ?? this.isCodeSent,
      isCodeVerified: isCodeVerified ?? this.isCodeVerified,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      verificationId: verificationId ?? this.verificationId,
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
        verificationId,
      ];
}
