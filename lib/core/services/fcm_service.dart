import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';

/// Top-level background message handler (MUST be top-level function)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // No need to show notification here - FCM auto-displays when app is in background
  debugPrint('[FCM] Background message: ${message.messageId}');
}

class FcmService {
  static final FcmService _instance = FcmService._internal();
  factory FcmService() => _instance;
  FcmService._internal();

  final _logger = Logger(printer: PrettyPrinter(methodCount: 0));
  final _messaging = FirebaseMessaging.instance;
  final _localNotifications = FlutterLocalNotificationsPlugin();

  GoRouter? _router;
  void Function(String token)? _onTokenRefresh;

  /// Android notification channel
  static const _androidChannel = AndroidNotificationChannel(
    'talkk_messages',
    'Messages',
    description: 'Talkk message and broadcast notifications',
    importance: Importance.high,
    playSound: true,
    enableVibration: true,
  );

  /// Initialize FCM service
  Future<void> initialize({
    required GoRouter router,
    required void Function(String token) onTokenRefresh,
  }) async {
    _router = router;
    _onTokenRefresh = onTokenRefresh;

    // 1. Set up background handler
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // 2. Create Android notification channel
    await _createNotificationChannel();

    // 3. Initialize local notifications (for foreground display)
    await _initializeLocalNotifications();

    // 4. Request permissions
    await _requestPermissions();

    // 5. Get initial token
    await _getToken();

    // 6. Listen for token refresh
    _messaging.onTokenRefresh.listen((token) {
      _logger.i('[FCM] Token refreshed');
      _onTokenRefresh?.call(token);
    });

    // 7. Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // 8. Handle notification tap (from background)
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

    // 9. Handle notification tap (from terminated state)
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationTap(initialMessage);
    }

    _logger.i('[FCM] Service initialized');
  }

  Future<void> _createNotificationChannel() async {
    if (Platform.isAndroid) {
      await _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(_androidChannel);
    }
  }

  Future<void> _initializeLocalNotifications() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _localNotifications.initialize(
      const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
      onDidReceiveNotificationResponse: (response) {
        // Handle notification tap from local notification
        if (response.payload != null) {
          _navigateFromPayload(response.payload!);
        }
      },
    );
  }

  Future<void> _requestPermissions() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
      announcement: false,
      carPlay: false,
      criticalAlert: false,
    );

    _logger.i('[FCM] Permission status: ${settings.authorizationStatus}');

    // iOS foreground presentation options
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: false, // We handle foreground display ourselves
      badge: true,
      sound: false,
    );
  }

  Future<void> _getToken() async {
    try {
      final token = await _messaging.getToken();
      if (token != null) {
        _logger.i('[FCM] Token obtained: ${token.substring(0, 20)}...');
        _onTokenRefresh?.call(token);
      }
    } catch (e) {
      _logger.e('[FCM] Failed to get token', error: e);
    }
  }

  /// Show notification in foreground using flutter_local_notifications
  void _handleForegroundMessage(RemoteMessage message) {
    _logger.i('[FCM] Foreground message: ${message.notification?.title}');

    final notification = message.notification;
    if (notification == null) return;

    _localNotifications.show(
      message.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _androidChannel.id,
          _androidChannel.name,
          channelDescription: _androidChannel.description,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: jsonEncode(message.data),
    );
  }

  /// Handle notification tap and navigate to appropriate screen
  void _handleNotificationTap(RemoteMessage message) {
    _logger.i('[FCM] Notification tapped: ${message.data}');
    _navigateFromPayload(jsonEncode(message.data));
  }

  void _navigateFromPayload(String payload) {
    try {
      final data = jsonDecode(payload) as Map<String, dynamic>;
      final type = data['type'] as String?;

      switch (type) {
        case 'new_message':
        case 'broadcast_reply':
          final conversationId = data['conversation_id']?.toString();
          if (conversationId != null) {
            _router?.go('/chats/$conversationId');
          }
          break;
        case 'new_broadcast':
          final broadcastId = data['broadcast_id']?.toString();
          if (broadcastId != null) {
            _router?.go('/broadcast/$broadcastId');
          }
          break;
        default:
          _router?.go('/notifications');
      }
    } catch (e) {
      _logger.e('[FCM] Navigation error', error: e);
    }
  }

  /// Get current FCM token and register it via callback
  /// Call this after login to ensure token is registered with server
  Future<void> registerToken() async {
    await _getToken();
  }

  /// Delete FCM token (on logout)
  Future<void> deleteToken() async {
    try {
      await _messaging.deleteToken();
      _logger.i('[FCM] Token deleted');
    } catch (e) {
      _logger.e('[FCM] Failed to delete token', error: e);
    }
  }
}
