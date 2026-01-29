import 'package:flutter/foundation.dart';

/// App-wide constants for Talk Flutter
class AppConstants {
  AppConstants._();

  // ============ API Configuration ============
  /// Development API URL (localhost for local development)
  static const String apiBaseUrlDev = 'http://localhost:3000/api/v1';

  /// Production API URL - Update this when production server is ready
  static const String apiBaseUrlProd = 'https://talkk-api-prod.onrender.com/api/v1';

  /// Get the appropriate API URL based on build mode
  static String get apiBaseUrl => kDebugMode ? apiBaseUrlDev : apiBaseUrlProd;
  static const Duration apiTimeout = Duration(seconds: 30);
  static const int maxRetries = 3;

  // ============ Database ============
  static const int databaseVersion = 1;
  static const String databaseName = 'talk_flutter.db';

  // ============ Audio ============
  static const int maxVoiceDurationSeconds = 60;
  static const int minVoiceDurationSeconds = 1;
  static const List<String> supportedAudioFormats = ['m4a', 'mp4', 'aac', 'wav'];

  // ============ Broadcast ============
  static const int defaultRecipientCount = 5;
  static const int maxRecipientCount = 20;
  static const int broadcastExpirationDays = 6;

  // ============ Pagination ============
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // ============ Storage Keys ============
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userIdKey = 'user_id';
  static const String userKey = 'user';

  // ============ Feature Flags ============
  static const bool enableOfflineMode = true;
  static const bool enablePushNotifications = true;
  static const bool enableAnalytics = true;

  // ============ Timeouts ============
  static const Duration authTimeout = Duration(seconds: 30);
  static const Duration syncTimeout = Duration(minutes: 5);
  static const Duration tokenRefreshThreshold = Duration(minutes: 5);

  // ============ Validation ============
  static const int minPasswordLength = 6;
  static const int maxNicknameLength = 20;
  static const int phoneNumberLength = 11;
  static const int verificationCodeLength = 6;
}
