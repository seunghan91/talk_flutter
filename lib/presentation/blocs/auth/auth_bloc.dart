import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:talk_flutter/core/enums/app_enums.dart';
import 'package:talk_flutter/core/errors/failures.dart';
import 'package:talk_flutter/domain/entities/user.dart';
import 'package:talk_flutter/domain/repositories/auth_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

/// Auth BLoC - manages authentication state
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  AuthBloc({
    required AuthRepository authRepository,
  })  : _authRepository = authRepository,
        super(const AuthState()) {
    on<AuthAppStarted>(_onAppStarted);
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthRegisterRequested>(_onRegisterRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthRequestCodeRequested>(_onRequestCodeRequested);
    on<AuthVerifyCodeRequested>(_onVerifyCodeRequested);
    on<AuthUserUpdated>(_onUserUpdated);
  }

  /// Check initial auth state on app start
  Future<void> _onAppStarted(
    AuthAppStarted event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));

    try {
      final isAuthenticated = await _authRepository.isAuthenticated();

      if (isAuthenticated) {
        final user = await _authRepository.getCurrentUser();
        emit(state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
        ));
      } else {
        emit(state.copyWith(status: AuthStatus.unauthenticated));
      }
    } catch (e) {
      emit(state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: _getErrorMessage(e),
      ));
    }
  }

  /// Request SMS verification code
  Future<void> _onRequestCodeRequested(
    AuthRequestCodeRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading, clearError: true));

    try {
      await _authRepository.requestVerificationCode(event.phoneNumber);
      emit(state.copyWith(
        status: AuthStatus.unauthenticated,
        phoneNumber: event.phoneNumber,
        isCodeSent: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: _getErrorMessage(e),
      ));
    }
  }

  /// Verify SMS code
  Future<void> _onVerifyCodeRequested(
    AuthVerifyCodeRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading, clearError: true));

    try {
      final verified = await _authRepository.verifyCode(
        event.phoneNumber,
        event.code,
      );

      emit(state.copyWith(
        status: AuthStatus.unauthenticated,
        isCodeVerified: verified,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: _getErrorMessage(e),
      ));
    }
  }

  /// Register new user
  Future<void> _onRegisterRequested(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading, clearError: true));

    try {
      final user = await _authRepository.register(
        phoneNumber: event.phoneNumber,
        password: event.password,
        nickname: event.nickname,
        gender: event.gender,
      );

      emit(state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: _getErrorMessage(e),
      ));
    }
  }

  /// Login with phone and password
  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading, clearError: true));

    try {
      final user = await _authRepository.login(
        phoneNumber: event.phoneNumber,
        password: event.password,
      );

      emit(state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: _getErrorMessage(e),
      ));
    }
  }

  /// Logout
  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      await _authRepository.logout();
    } catch (_) {
      // Ignore errors - always clear local state on logout
    }
    emit(const AuthState(status: AuthStatus.unauthenticated));
  }

  /// Update user data
  void _onUserUpdated(
    AuthUserUpdated event,
    Emitter<AuthState> emit,
  ) {
    emit(state.copyWith(user: event.user));
  }

  /// Convert exception to user-friendly error message
  String _getErrorMessage(dynamic error) {
    // Handle DioException with ApiException
    if (error is DioException && error.error is ApiException) {
      final apiException = error.error as ApiException;
      return apiException.toFailure().toUserMessage();
    }

    // Handle ApiException directly
    if (error is ApiException) {
      return error.toFailure().toUserMessage();
    }

    // Handle Failure directly
    if (error is Failure) {
      return error.toUserMessage();
    }

    // Fallback for unknown errors
    return const UnknownFailure().toUserMessage();
  }
}
