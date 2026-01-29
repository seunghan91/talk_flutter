import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:talk_flutter/core/enums/app_enums.dart';
import 'package:talk_flutter/presentation/blocs/auth/auth_bloc.dart';
import 'package:talk_flutter/presentation/screens/auth/login_screen.dart';
import 'package:talk_flutter/presentation/screens/auth/register_screen.dart';
import 'package:talk_flutter/presentation/screens/broadcast/broadcast_detail_screen.dart';
import 'package:talk_flutter/presentation/screens/broadcast/broadcast_list_screen.dart';
import 'package:talk_flutter/presentation/screens/broadcast/broadcast_reply_screen.dart';
import 'package:talk_flutter/presentation/screens/broadcast/record_screen.dart';
import 'package:talk_flutter/presentation/screens/conversation/conversation_screen.dart';
import 'package:talk_flutter/presentation/screens/feedback/feedback_screen.dart';
import 'package:talk_flutter/presentation/screens/home/home_screen.dart';
import 'package:talk_flutter/presentation/screens/home/main_scaffold.dart';
import 'package:talk_flutter/presentation/screens/messages/messages_screen.dart';
import 'package:talk_flutter/presentation/screens/notifications/notification_screen.dart';
import 'package:talk_flutter/presentation/screens/profile/profile_screen.dart';
import 'package:talk_flutter/presentation/screens/profile/profile_edit_screen.dart';
import 'package:talk_flutter/presentation/screens/report/report_user_screen.dart';
import 'package:talk_flutter/presentation/screens/settings/settings_screen.dart';
import 'package:talk_flutter/presentation/screens/wallet/wallet_screen.dart';

/// App router configuration using GoRouter
final appRouter = GoRouter(
  initialLocation: '/',
  debugLogDiagnostics: true,
  redirect: (context, state) {
    final authState = context.read<AuthBloc>().state;
    final isAuthenticated = authState.status == AuthStatus.authenticated;
    final isAuthRoute = state.uri.path.startsWith('/auth');
    final isInitializing = authState.status == AuthStatus.initial ||
        authState.status == AuthStatus.loading;

    // Wait for auth to initialize
    if (isInitializing) {
      return null;
    }

    // Redirect to login if not authenticated
    if (!isAuthenticated && !isAuthRoute) {
      return '/auth/login';
    }

    // Redirect to home if already authenticated
    if (isAuthenticated && isAuthRoute) {
      return '/';
    }

    return null;
  },
  routes: [
    // ============ Main App Routes (with bottom navigation) ============
    ShellRoute(
      builder: (context, state, child) => MainScaffold(child: child),
      routes: [
        GoRoute(
          path: '/',
          name: 'home',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: HomeScreen(),
          ),
        ),
        GoRoute(
          path: '/messages',
          name: 'messages',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: MessagesScreen(),
          ),
        ),
        GoRoute(
          path: '/feedback',
          name: 'feedback',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: FeedbackScreen(),
          ),
        ),
        GoRoute(
          path: '/settings',
          name: 'settings',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: SettingsScreen(),
          ),
        ),
      ],
    ),

    // ============ Conversation Detail (without bottom navigation) ============
    GoRoute(
      path: '/messages/:id',
      name: 'conversation',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return ConversationScreen(conversationId: id);
      },
    ),

    // ============ Profile Edit (without bottom navigation) ============
    GoRoute(
      path: '/settings/profile',
      name: 'profile-edit',
      builder: (context, state) => const ProfileEditScreen(),
    ),

    // ============ Broadcast Routes ============
    GoRoute(
      path: '/broadcast',
      name: 'broadcast-list',
      builder: (context, state) => const BroadcastListScreen(),
      routes: [
        GoRoute(
          path: 'record',
          name: 'broadcast-record',
          builder: (context, state) => const RecordScreen(),
        ),
        GoRoute(
          path: 'reply/:id',
          name: 'broadcast-reply',
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            return BroadcastReplyScreen(broadcastId: id);
          },
        ),
        GoRoute(
          path: ':id',
          name: 'broadcast-detail',
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            return BroadcastDetailScreen(broadcastId: id);
          },
        ),
      ],
    ),

    // ============ Profile Routes ============
    GoRoute(
      path: '/profile',
      name: 'profile',
      builder: (context, state) => const ProfileScreen(),
    ),

    // ============ Notification Routes ============
    GoRoute(
      path: '/notifications',
      name: 'notifications',
      builder: (context, state) => const NotificationScreen(),
    ),

    // ============ Wallet Routes ============
    GoRoute(
      path: '/wallet',
      name: 'wallet',
      builder: (context, state) => const WalletScreen(),
    ),

    // ============ Report Routes ============
    GoRoute(
      path: '/report/user/:id',
      name: 'report-user',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return ReportUserScreen(userId: id);
      },
    ),

    // ============ Auth Routes ============
    GoRoute(
      path: '/auth/login',
      name: 'login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/auth/register',
      name: 'register',
      builder: (context, state) => const RegisterScreen(),
    ),
  ],
);
