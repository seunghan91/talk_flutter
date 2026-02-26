import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:talk_flutter/core/enums/app_enums.dart';
import 'package:talk_flutter/domain/entities/broadcast.dart';
import 'package:talk_flutter/domain/entities/broadcast_limits.dart';
import 'package:talk_flutter/domain/entities/user.dart';
import 'package:talk_flutter/domain/entities/wallet.dart';
import 'package:talk_flutter/domain/repositories/auth_repository.dart';
import 'package:talk_flutter/domain/repositories/broadcast_repository.dart';
import 'package:talk_flutter/domain/repositories/notification_repository.dart';
import 'package:talk_flutter/domain/repositories/wallet_repository.dart';
import 'package:talk_flutter/presentation/blocs/auth/auth_bloc.dart';
import 'package:talk_flutter/presentation/blocs/broadcast/broadcast_bloc.dart';
import 'package:talk_flutter/presentation/blocs/notification/notification_bloc.dart';
import 'package:talk_flutter/presentation/blocs/wallet/wallet_bloc.dart';
import 'package:talk_flutter/presentation/screens/home/home_screen.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockBroadcastRepository extends Mock implements BroadcastRepository {}

class MockNotificationRepository extends Mock
    implements NotificationRepository {}

class MockWalletRepository extends Mock implements WalletRepository {}

void main() {
  late AuthBloc authBloc;
  late BroadcastBloc broadcastBloc;
  late NotificationBloc notificationBloc;
  late WalletBloc walletBloc;

  late MockAuthRepository mockAuthRepo;
  late MockBroadcastRepository mockBroadcastRepo;
  late MockNotificationRepository mockNotificationRepo;
  late MockWalletRepository mockWalletRepo;

  final testUser = User(
    id: 1,
    nickname: 'TestUser',
    gender: Gender.male,
    createdAt: DateTime.now(),
  );

  setUp(() {
    mockAuthRepo = MockAuthRepository();
    mockBroadcastRepo = MockBroadcastRepository();
    mockNotificationRepo = MockNotificationRepository();
    mockWalletRepo = MockWalletRepository();

    when(() => mockBroadcastRepo.getBroadcasts(page: any(named: 'page')))
        .thenAnswer((_) async => <Broadcast>[]);
    when(() => mockBroadcastRepo.getBroadcastLimits())
        .thenAnswer((_) async => BroadcastLimits.fallback());
    when(() => mockNotificationRepo.getUnreadCount())
        .thenAnswer((_) async => 0);
    when(() => mockWalletRepo.getWallet()).thenAnswer(
        (_) async => const Wallet(balance: 100, formattedBalance: '₩100'));

    authBloc = AuthBloc(authRepository: mockAuthRepo);
    broadcastBloc = BroadcastBloc(broadcastRepository: mockBroadcastRepo);
    notificationBloc =
        NotificationBloc(notificationRepository: mockNotificationRepo);
    walletBloc = WalletBloc(walletRepository: mockWalletRepo);
  });

  tearDown(() {
    authBloc.close();
    broadcastBloc.close();
    notificationBloc.close();
    walletBloc.close();
  });

  Widget buildSubject() {
    return MaterialApp(
      home: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>.value(value: authBloc),
          BlocProvider<BroadcastBloc>.value(value: broadcastBloc),
          BlocProvider<NotificationBloc>.value(value: notificationBloc),
          BlocProvider<WalletBloc>.value(value: walletBloc),
        ],
        child: const HomeScreen(),
      ),
    );
  }

  group('HomeScreen', () {
    testWidgets('renders app title', (tester) async {
      authBloc.emit(AuthState(
        status: AuthStatus.authenticated,
        user: testUser,
      ));

      await tester.pumpWidget(buildSubject());
      await tester.pump();

      expect(find.text('보이스팅'), findsOneWidget);
    });

    testWidgets('shows welcome card with nickname', (tester) async {
      authBloc.emit(AuthState(
        status: AuthStatus.authenticated,
        user: testUser,
      ));

      await tester.pumpWidget(buildSubject());
      await tester.pump();

      expect(find.textContaining('TestUser'), findsOneWidget);
    });

    testWidgets('shows action cards for send and receive', (tester) async {
      authBloc.emit(AuthState(
        status: AuthStatus.authenticated,
        user: testUser,
      ));

      await tester.pumpWidget(buildSubject());
      await tester.pump();

      expect(find.text('새로운 보이스 받기'), findsWidgets);
      expect(find.text('내 보이스 보내기'), findsOneWidget);
    });

    testWidgets('shows daily limit info', (tester) async {
      authBloc.emit(AuthState(
        status: AuthStatus.authenticated,
        user: testUser,
      ));

      await tester.pumpWidget(buildSubject());
      await tester.pump();

      expect(find.textContaining('20개'), findsWidgets);
    });

    testWidgets('shows gender selection buttons', (tester) async {
      authBloc.emit(AuthState(
        status: AuthStatus.authenticated,
        user: testUser,
      ));

      await tester.pumpWidget(buildSubject());
      await tester.pump();

      expect(find.text('여성'), findsWidgets);
      expect(find.text('남성'), findsWidgets);
    });
  });
}
