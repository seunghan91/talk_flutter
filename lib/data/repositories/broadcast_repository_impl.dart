import 'dart:io';

import 'package:dio/dio.dart';
import 'package:talk_flutter/core/enums/app_enums.dart';
import 'package:talk_flutter/data/datasources/remote/api_client.dart';
import 'package:talk_flutter/domain/entities/broadcast.dart';
import 'package:talk_flutter/domain/entities/broadcast_limits.dart';
import 'package:talk_flutter/domain/repositories/broadcast_repository.dart';

/// Broadcast repository implementation
class BroadcastRepositoryImpl implements BroadcastRepository {
  final ApiClient _apiClient;
  final Dio _dio;
  static const int _fallbackDailyLimit = 20;

  BroadcastRepositoryImpl({
    required ApiClient apiClient,
    required Dio dio,
  })  : _apiClient = apiClient,
        _dio = dio;

  @override
  Future<List<Broadcast>> getBroadcasts({int page = 1, int perPage = 20}) async {
    final response = await _apiClient.getBroadcasts();
    final data = response.data as Map<String, dynamic>? ?? {};
    final broadcastsList = data['broadcasts'] as List<dynamic>? ?? [];
    final List<Broadcast> result = [];
    for (final json in broadcastsList) {
      if (json is Map<String, dynamic>) {
        try {
          result.add(_parseBroadcast(json));
        } catch (_) {
          // Skip malformed broadcast entries
        }
      }
    }
    return result;
  }

  @override
  Future<Broadcast> getBroadcastById(int id) async {
    final response = await _apiClient.getBroadcastById(id);
    final data = response.data as Map<String, dynamic>? ?? {};
    final broadcast = data['broadcast'] as Map<String, dynamic>? ?? data;
    return _parseBroadcast(broadcast);
  }

  @override
  Future<Broadcast> createBroadcast({
    required String audioPath,
    required int duration,
    int recipientCount = 5,
    String? content,
    String? targetGender,
  }) async {
    final file = File(audioPath);
    final fileName = 'broadcast_${DateTime.now().millisecondsSinceEpoch}.m4a';

    // Rails expects nested params under 'broadcast' key
    final formData = FormData.fromMap({
      'broadcast[voice_file]': await MultipartFile.fromFile(
        file.path,
        filename: fileName,
      ),
      'broadcast[recipient_count]': recipientCount.toString(),
      if (targetGender != null) 'broadcast[target_gender]': targetGender,
      if (content != null) 'broadcast[content]': content,
    });

    final response = await _dio.post(
      '/broadcasts',
      data: formData,
      options: Options(
        contentType: 'multipart/form-data',
      ),
    );

    final data = response.data as Map<String, dynamic>? ?? {};
    final broadcast = data['broadcast'] as Map<String, dynamic>? ?? data;
    return _parseBroadcast(broadcast);
  }

  @override
  Future<void> replyToBroadcast({
    required int broadcastId,
    required String audioPath,
    required int duration,
  }) async {
    final file = File(audioPath);
    final fileName = 'reply_${DateTime.now().millisecondsSinceEpoch}.m4a';

    final formData = FormData.fromMap({
      'voice_file': await MultipartFile.fromFile(
        file.path,
        filename: fileName,
      ),
      'duration': duration.toString(),
    });

    await _dio.post(
      '/broadcasts/$broadcastId/reply',
      data: formData,
      options: Options(
        contentType: 'multipart/form-data',
      ),
    );
  }

  @override
  Future<void> markAsListened(int broadcastId) async {
    await _apiClient.markBroadcastAsRead(broadcastId);
  }

  @override
  Future<BroadcastLimits> getBroadcastLimits() async {
    try {
      final response = await _apiClient.getBroadcastLimits();
      final data = response.data as Map<String, dynamic>? ?? {};
      final limitMap = data['limits'] as Map<String, dynamic>? ?? data;

      final dailyLimit = (limitMap['daily_limit'] as num?)?.toInt() ??
          (limitMap['dailyLimit'] as num?)?.toInt() ??
          _fallbackDailyLimit;
      final dailyUsed = (limitMap['daily_used'] as num?)?.toInt() ??
          (limitMap['dailyUsed'] as num?)?.toInt() ??
          0;
      final dailyRemaining = (limitMap['daily_remaining'] as num?)?.toInt() ??
          (limitMap['dailyRemaining'] as num?)?.toInt() ??
          (dailyLimit - dailyUsed).clamp(0, dailyLimit).toInt();

      return BroadcastLimits(
        dailyLimit: dailyLimit,
        dailyUsed: dailyUsed,
        dailyRemaining: dailyRemaining,
        hourlyLimit: (limitMap['hourly_limit'] as num?)?.toInt() ??
            (limitMap['hourlyLimit'] as num?)?.toInt(),
        hourlyUsed: (limitMap['hourly_used'] as num?)?.toInt() ??
            (limitMap['hourlyUsed'] as num?)?.toInt(),
        canBroadcast: limitMap['can_broadcast'] as bool? ??
            limitMap['canBroadcast'] as bool? ??
            dailyRemaining > 0,
        nextResetAt: _parseDateTime(
          limitMap['next_reset_at'] ?? limitMap['nextResetAt'],
        ),
        cooldownEndsAt: _parseDateTime(
          limitMap['cooldown_ends_at'] ?? limitMap['cooldownEndsAt'],
        ),
      );
    } catch (_) {
      return BroadcastLimits.fallback(dailyLimit: _fallbackDailyLimit);
    }
  }

  /// Parse broadcast data from API response
  Broadcast _parseBroadcast(Map<String, dynamic> data) {
    final userData = data['user'] as Map<String, dynamic>?;
    final senderData = data['sender'] as Map<String, dynamic>?;
    final effectiveUserData = userData ?? senderData;

    return Broadcast(
      id: (data['id'] as num?)?.toInt() ?? 0,
      userId: (data['user_id'] as num?)?.toInt() ?? 0,
      audioUrl: data['audio_url'] as String?,
      duration: (data['duration'] as num?)?.toInt() ?? 0,
      recipientCount: (data['recipient_count'] as num?)?.toInt() ?? 0,
      replyCount: (data['reply_count'] as num?)?.toInt() ?? 0,
      isExpired: data['is_expired'] as bool? ?? false,
      isFavorite: data['is_favorite'] as bool? ?? false,
      isRead: data['is_read'] as bool? ?? false,
      isListened: data['is_listened'] as bool? ?? false,
      senderNickname: data['sender_nickname'] as String? ??
          effectiveUserData?['nickname'] as String?,
      senderGender: Gender.fromString(
        data['sender_gender'] as String? ??
            effectiveUserData?['gender'] as String?,
      ),
      expiredAt: _parseDateTime(data['expired_at']),
      createdAt: _parseDateTime(data['created_at']) ?? DateTime.now(),
    );
  }

  /// Safely parse a datetime from various formats
  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is String && value.isNotEmpty) {
      try {
        return DateTime.parse(value);
      } catch (_) {
        return null;
      }
    }
    return null;
  }
}
