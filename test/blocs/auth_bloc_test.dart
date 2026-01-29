import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:talk_flutter/core/enums/app_enums.dart';
import 'package:talk_flutter/core/errors/failures.dart';
import 'package:talk_flutter/domain/entities/user.dart';
import 'package:talk_flutter/domain/repositories/auth_repository.dart';
import 'package:talk_flutter/presentation/blocs/auth/auth_bloc.dart';

// Mock classes
class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late AuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
  });

  group('AuthBloc', () {
    final testUser = User(
      id: 1,
      nickname: 'TestUser',
      phoneNumber: '01012345678',
      gender: Gender.male,
      verified: true,
      createdAt: DateTime.now(),
    );

    group('AuthAppStarted', () {
      blocTest<AuthBloc, AuthState>(
        'emits [loading, authenticated] when user is authenticated',
        setUp: () {
          when(() => mockAuthRepository.isAuthenticated())
              .thenAnswer((_) async => true);
          when(() => mockAuthRepository.getCurrentUser())
              .thenAnswer((_) async => testUser);
        },
        build: () => AuthBloc(authRepository: mockAuthRepository),
        act: (bloc) => bloc.add(const AuthAppStarted()),
        expect: () => [
          const AuthState(status: AuthStatus.loading),
          AuthState(status: AuthStatus.authenticated, user: testUser),
        ],
        verify: (_) {
          verify(() => mockAuthRepository.isAuthenticated()).called(1);
          verify(() => mockAuthRepository.getCurrentUser()).called(1);
        },
      );

      blocTest<AuthBloc, AuthState>(
        'emits [loading, unauthenticated] when user is not authenticated',
        setUp: () {
          when(() => mockAuthRepository.isAuthenticated())
              .thenAnswer((_) async => false);
        },
        build: () => AuthBloc(authRepository: mockAuthRepository),
        act: (bloc) => bloc.add(const AuthAppStarted()),
        expect: () => [
          const AuthState(status: AuthStatus.loading),
          const AuthState(status: AuthStatus.unauthenticated),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [loading, unauthenticated] with error message on failure',
        setUp: () {
          when(() => mockAuthRepository.isAuthenticated())
              .thenThrow(const NetworkFailure('Network error'));
        },
        build: () => AuthBloc(authRepository: mockAuthRepository),
        act: (bloc) => bloc.add(const AuthAppStarted()),
        expect: () => [
          const AuthState(status: AuthStatus.loading),
          isA<AuthState>()
              .having((s) => s.status, 'status', AuthStatus.unauthenticated)
              .having((s) => s.errorMessage, 'errorMessage', isNotNull),
        ],
      );
    });

    group('AuthLoginRequested', () {
      blocTest<AuthBloc, AuthState>(
        'emits [loading, authenticated] when login succeeds',
        setUp: () {
          when(() => mockAuthRepository.login(
                phoneNumber: any(named: 'phoneNumber'),
                password: any(named: 'password'),
              )).thenAnswer((_) async => testUser);
        },
        build: () => AuthBloc(authRepository: mockAuthRepository),
        act: (bloc) => bloc.add(const AuthLoginRequested(
          phoneNumber: '01012345678',
          password: 'password123',
        )),
        expect: () => [
          const AuthState(status: AuthStatus.loading),
          AuthState(status: AuthStatus.authenticated, user: testUser),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [loading, error] when login fails',
        setUp: () {
          when(() => mockAuthRepository.login(
                phoneNumber: any(named: 'phoneNumber'),
                password: any(named: 'password'),
              )).thenThrow(
            const ApiException(statusCode: 401, message: 'Invalid credentials'),
          );
        },
        build: () => AuthBloc(authRepository: mockAuthRepository),
        act: (bloc) => bloc.add(const AuthLoginRequested(
          phoneNumber: '01012345678',
          password: 'wrongpassword',
        )),
        expect: () => [
          const AuthState(status: AuthStatus.loading),
          isA<AuthState>()
              .having((s) => s.status, 'status', AuthStatus.error)
              .having((s) => s.errorMessage, 'errorMessage', isNotNull),
        ],
      );
    });

    group('AuthRegisterRequested', () {
      blocTest<AuthBloc, AuthState>(
        'emits [loading, authenticated] when registration succeeds',
        setUp: () {
          when(() => mockAuthRepository.register(
                phoneNumber: any(named: 'phoneNumber'),
                password: any(named: 'password'),
                nickname: any(named: 'nickname'),
                gender: any(named: 'gender'),
              )).thenAnswer((_) async => testUser);
        },
        build: () => AuthBloc(authRepository: mockAuthRepository),
        act: (bloc) => bloc.add(const AuthRegisterRequested(
          phoneNumber: '01012345678',
          password: 'password123',
          nickname: 'NewUser',
          gender: 'male',
        )),
        expect: () => [
          const AuthState(status: AuthStatus.loading),
          AuthState(status: AuthStatus.authenticated, user: testUser),
        ],
      );
    });

    group('AuthLogoutRequested', () {
      blocTest<AuthBloc, AuthState>(
        'emits [unauthenticated] when logout succeeds',
        setUp: () {
          when(() => mockAuthRepository.logout()).thenAnswer((_) async {});
        },
        build: () => AuthBloc(authRepository: mockAuthRepository),
        act: (bloc) => bloc.add(const AuthLogoutRequested()),
        expect: () => [
          const AuthState(status: AuthStatus.unauthenticated),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [unauthenticated] even when logout fails',
        setUp: () {
          when(() => mockAuthRepository.logout())
              .thenThrow(const NetworkFailure('Network error'));
        },
        build: () => AuthBloc(authRepository: mockAuthRepository),
        act: (bloc) => bloc.add(const AuthLogoutRequested()),
        expect: () => [
          const AuthState(status: AuthStatus.unauthenticated),
        ],
      );
    });

    group('AuthRequestCodeRequested', () {
      blocTest<AuthBloc, AuthState>(
        'emits [loading, unauthenticated with isCodeSent=true] on success',
        setUp: () {
          when(() => mockAuthRepository.requestVerificationCode(any()))
              .thenAnswer((_) async {});
        },
        build: () => AuthBloc(authRepository: mockAuthRepository),
        act: (bloc) => bloc.add(
          const AuthRequestCodeRequested(phoneNumber: '01012345678'),
        ),
        expect: () => [
          const AuthState(status: AuthStatus.loading),
          isA<AuthState>()
              .having((s) => s.status, 'status', AuthStatus.unauthenticated)
              .having((s) => s.isCodeSent, 'isCodeSent', true)
              .having((s) => s.phoneNumber, 'phoneNumber', '01012345678'),
        ],
      );
    });

    group('AuthVerifyCodeRequested', () {
      blocTest<AuthBloc, AuthState>(
        'emits [loading, unauthenticated with isCodeVerified=true] on success',
        setUp: () {
          when(() => mockAuthRepository.verifyCode(any(), any()))
              .thenAnswer((_) async => true);
        },
        build: () => AuthBloc(authRepository: mockAuthRepository),
        act: (bloc) => bloc.add(const AuthVerifyCodeRequested(
          phoneNumber: '01012345678',
          code: '123456',
        )),
        expect: () => [
          const AuthState(status: AuthStatus.loading),
          isA<AuthState>()
              .having((s) => s.status, 'status', AuthStatus.unauthenticated)
              .having((s) => s.isCodeVerified, 'isCodeVerified', true),
        ],
      );
    });
  });
}
