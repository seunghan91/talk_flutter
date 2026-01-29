import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';

import 'package:talk_flutter/core/constants/app_constants.dart';
import 'package:talk_flutter/data/datasources/local/secure_storage_datasource.dart';
import 'package:talk_flutter/data/datasources/remote/api_client.dart';
import 'package:talk_flutter/data/datasources/remote/dio_client.dart';
import 'package:talk_flutter/data/repositories/auth_repository_impl.dart';
import 'package:talk_flutter/data/repositories/broadcast_repository_impl.dart';
import 'package:talk_flutter/data/repositories/conversation_repository_impl.dart';
import 'package:talk_flutter/data/repositories/notification_repository_impl.dart';
import 'package:talk_flutter/data/repositories/user_repository_impl.dart';
import 'package:talk_flutter/data/repositories/wallet_repository_impl.dart';
import 'package:talk_flutter/domain/repositories/auth_repository.dart';
import 'package:talk_flutter/domain/repositories/broadcast_repository.dart';
import 'package:talk_flutter/domain/repositories/conversation_repository.dart';
import 'package:talk_flutter/domain/repositories/notification_repository.dart';
import 'package:talk_flutter/domain/repositories/user_repository.dart';
import 'package:talk_flutter/domain/repositories/wallet_repository.dart';
import 'package:talk_flutter/presentation/blocs/auth/auth_bloc.dart';
import 'package:talk_flutter/presentation/blocs/broadcast/broadcast_bloc.dart';
import 'package:talk_flutter/presentation/blocs/conversation/conversation_bloc.dart';
import 'package:talk_flutter/presentation/blocs/notification/notification_bloc.dart';
import 'package:talk_flutter/presentation/blocs/notification/notification_event.dart';
import 'package:talk_flutter/presentation/blocs/user/user_bloc.dart';
import 'package:talk_flutter/presentation/blocs/wallet/wallet_bloc.dart';
import 'package:talk_flutter/core/theme/app_theme.dart';
import 'package:talk_flutter/presentation/router/app_router.dart';

final logger = Logger(
  printer: PrettyPrinter(
    methodCount: 0,
    errorMethodCount: 5,
    lineLength: 50,
    colors: true,
    printEmojis: true,
  ),
);

/// Initialize Firebase services
Future<void> _initializeFirebase() async {
  try {
    await Firebase.initializeApp();
    logger.i('Firebase initialized successfully');

    // Initialize Crashlytics (only in release mode)
    if (!kDebugMode) {
      // Pass all uncaught errors to Crashlytics
      FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

      // Pass all uncaught asynchronous errors to Crashlytics
      PlatformDispatcher.instance.onError = (error, stack) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        return true;
      };

      logger.i('Crashlytics initialized');
    }
  } catch (e) {
    logger.e('Firebase initialization failed', error: e);
    // Continue without Firebase - app should still work
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await _initializeFirebase();

  // Initialize HydratedBloc storage
  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: HydratedStorageDirectory(
      (await getApplicationDocumentsDirectory()).path,
    ),
  );

  // Initialize BLoC observer for debugging
  Bloc.observer = AppBlocObserver();

  // Initialize dependencies
  final secureStorage = SecureStorageDatasource();

  // Create AuthBloc first to reference in DioClient callback
  late final AuthBloc authBloc;

  final dioClient = DioClient(
    secureStorage,
    baseUrl: AppConstants.apiBaseUrl,
    onAuthExpired: () async {
      // Trigger logout when token expires (401 response)
      logger.w('Auth expired - triggering logout');
      authBloc.add(const AuthLogoutRequested());
    },
  );
  final apiClient = ApiClient(dioClient.dio);

  // Initialize repositories
  final authRepository = AuthRepositoryImpl(
    apiClient: apiClient,
    secureStorage: secureStorage,
  );

  // Initialize AuthBloc
  authBloc = AuthBloc(authRepository: authRepository);

  final userRepository = UserRepositoryImpl(
    apiClient: apiClient,
  );

  final broadcastRepository = BroadcastRepositoryImpl(
    apiClient: apiClient,
    dio: dioClient.dio,
  );

  final conversationRepository = ConversationRepositoryImpl(
    apiClient: apiClient,
    dio: dioClient.dio,
  );

  final notificationRepository = NotificationRepositoryImpl(
    apiClient: apiClient,
  );

  final walletRepository = WalletRepositoryImpl(
    apiClient: apiClient,
  );

  runApp(
    TalkApp(
      authBloc: authBloc,
      authRepository: authRepository,
      userRepository: userRepository,
      broadcastRepository: broadcastRepository,
      conversationRepository: conversationRepository,
      notificationRepository: notificationRepository,
      walletRepository: walletRepository,
    ),
  );
}

/// Main app widget
class TalkApp extends StatelessWidget {
  final AuthBloc authBloc;
  final AuthRepository authRepository;
  final UserRepository userRepository;
  final BroadcastRepository broadcastRepository;
  final ConversationRepository conversationRepository;
  final NotificationRepository notificationRepository;
  final WalletRepository walletRepository;

  const TalkApp({
    super.key,
    required this.authBloc,
    required this.authRepository,
    required this.userRepository,
    required this.broadcastRepository,
    required this.conversationRepository,
    required this.notificationRepository,
    required this.walletRepository,
  });

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>.value(value: authRepository),
        RepositoryProvider<UserRepository>.value(value: userRepository),
        RepositoryProvider<BroadcastRepository>.value(value: broadcastRepository),
        RepositoryProvider<ConversationRepository>.value(value: conversationRepository),
        RepositoryProvider<NotificationRepository>.value(value: notificationRepository),
        RepositoryProvider<WalletRepository>.value(value: walletRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>.value(
            value: authBloc..add(const AuthAppStarted()),
          ),
          BlocProvider<UserBloc>(
            create: (context) => UserBloc(
              userRepository: userRepository,
            ),
          ),
          BlocProvider<BroadcastBloc>(
            create: (context) => BroadcastBloc(
              broadcastRepository: broadcastRepository,
            ),
          ),
          BlocProvider<ConversationBloc>(
            create: (context) => ConversationBloc(
              conversationRepository: conversationRepository,
            ),
          ),
          BlocProvider<NotificationBloc>(
            create: (context) => NotificationBloc(
              notificationRepository: notificationRepository,
            )..add(const NotificationUnreadCountRequested()),
          ),
          BlocProvider<WalletBloc>(
            create: (context) => WalletBloc(
              walletRepository: walletRepository,
            ),
          ),
        ],
        child: const _TalkAppView(),
      ),
    );
  }
}

/// App view with MaterialApp
class _TalkAppView extends StatelessWidget {
  const _TalkAppView();

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Talkk',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      routerConfig: appRouter,
    );
  }
}

/// BLoC observer for debugging
class AppBlocObserver extends BlocObserver {
  @override
  void onCreate(BlocBase bloc) {
    super.onCreate(bloc);
    logger.d('onCreate: ${bloc.runtimeType}');
  }

  @override
  void onEvent(Bloc bloc, Object? event) {
    super.onEvent(bloc, event);
    logger.d('onEvent: ${bloc.runtimeType}, $event');
  }

  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    logger.d('onChange: ${bloc.runtimeType}, $change');
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    super.onError(bloc, error, stackTrace);
    logger.e('onError: ${bloc.runtimeType}', error: error, stackTrace: stackTrace);
  }

  @override
  void onClose(BlocBase bloc) {
    super.onClose(bloc);
    logger.d('onClose: ${bloc.runtimeType}');
  }
}
