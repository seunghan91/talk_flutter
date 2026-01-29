import 'dart:io';

import 'package:dio/dio.dart';
import 'package:talk_flutter/core/enums/app_enums.dart';
import 'package:talk_flutter/data/datasources/remote/api_client.dart';
import 'package:talk_flutter/domain/entities/broadcast.dart';
import 'package:talk_flutter/domain/repositories/broadcast_repository.dart';

/// Broadcast repository implementation
class BroadcastRepositoryImpl implements BroadcastRepository {
  final ApiClient _apiClient;
  final Dio _dio;

  BroadcastRepositoryImpl({
    required ApiClient apiClient,
    required Dio dio,
  })  : _apiClient = apiClient,
        _dio = dio;

  @override
  Future<List<Broadcast>> getBroadcasts({int page = 1, int perPage = 20}) async {
    final response = await _apiClient.getBroadcasts();
    final data = response.data as Map<String, dynamic>? ?? {};
    final broadcasts = data['broadcasts'] as List<dynamic>? ?? [];
    return broadcasts.map((json) => _parseBroadcast(json as Map<String, dynamic>)).toList();
  }

  @override
  Future<Broadcast> getBroadcastById(int id) async {
    final response = await _apiClient.getBroadcastById(id);
    final data = response.data as Map<String, dynamic>? ?? {};
    return _parseBroadcast(data['broadcast'] as Map<String, dynamic>);
  }

  @override
  Future<Broadcast> createBroadcast({
    required String audioPath,
    required int duration,
    int recipientCount = 5,
    String? content,
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
    return _parseBroadcast(data['broadcast'] as Map<String, dynamic>);
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

  /// Parse broadcast data from API response
  Broadcast _parseBroadcast(Map<String, dynamic> data) {
    final userData = data['user'] as Map<String, dynamic>?;

    return Broadcast(
      id: data['id'] as int,
      userId: data['user_id'] as int,
      audioUrl: data['audio_url'] as String?,
      duration: data['duration'] as int? ?? 0,
      recipientCount: data['recipient_count'] as int? ?? 0,
      replyCount: data['reply_count'] as int? ?? 0,
      isExpired: data['is_expired'] as bool? ?? false,
      isFavorite: data['is_favorite'] as bool? ?? false,
      isRead: data['is_read'] as bool? ?? false,
      isListened: data['is_listened'] as bool? ?? false,
      senderNickname: userData?['nickname'] as String?,
      senderGender: Gender.fromString(userData?['gender'] as String?),
      expiredAt: data['expired_at'] != null
          ? DateTime.parse(data['expired_at'] as String)
          : null,
      createdAt: DateTime.parse(
        data['created_at'] as String? ?? DateTime.now().toIso8601String(),
      ),
    );
  }
}
