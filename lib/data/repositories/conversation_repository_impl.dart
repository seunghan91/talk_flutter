import 'dart:io';

import 'package:dio/dio.dart';
import 'package:talk_flutter/core/enums/app_enums.dart';
import 'package:talk_flutter/data/datasources/remote/api_client.dart';
import 'package:talk_flutter/domain/entities/conversation.dart';
import 'package:talk_flutter/domain/entities/message.dart';
import 'package:talk_flutter/domain/repositories/conversation_repository.dart';

/// Conversation repository implementation
class ConversationRepositoryImpl implements ConversationRepository {
  final ApiClient _apiClient;
  final Dio _dio;

  ConversationRepositoryImpl({
    required ApiClient apiClient,
    required Dio dio,
  })  : _apiClient = apiClient,
        _dio = dio;

  @override
  Future<List<Conversation>> getConversations({int page = 1, int perPage = 20}) async {
    final response = await _apiClient.getConversations();
    final data = response.data as Map<String, dynamic>? ?? {};
    final conversations = data['conversations'] as List<dynamic>? ?? [];
    return conversations.map((json) => _parseConversation(json as Map<String, dynamic>)).toList();
  }

  @override
  Future<Conversation> getConversationById(int id) async {
    final response = await _apiClient.getConversationById(id);
    final data = response.data as Map<String, dynamic>? ?? {};
    return _parseConversation(data['conversation'] as Map<String, dynamic>);
  }

  @override
  Future<List<Message>> getMessages({
    required int conversationId,
    int page = 1,
    int perPage = 50,
  }) async {
    final response = await _apiClient.getConversationMessages(conversationId);
    final data = response.data as Map<String, dynamic>? ?? {};
    final messages = data['messages'] as List<dynamic>? ?? [];
    return messages.map((json) => _parseMessage(json as Map<String, dynamic>)).toList();
  }

  @override
  Future<Message> sendMessage({
    required int conversationId,
    required String audioPath,
    required int duration,
  }) async {
    final file = File(audioPath);
    final fileName = 'message_${DateTime.now().millisecondsSinceEpoch}.m4a';

    final formData = FormData.fromMap({
      'voice_file': await MultipartFile.fromFile(
        file.path,
        filename: fileName,
      ),
      'duration': duration.toString(),
    });

    final response = await _dio.post(
      '/conversations/$conversationId/send_message',
      data: formData,
      options: Options(
        contentType: 'multipart/form-data',
      ),
    );

    final data = response.data as Map<String, dynamic>? ?? {};
    return _parseMessage(data['message'] as Map<String, dynamic>);
  }

  @override
  Future<void> toggleFavorite(int conversationId) async {
    await _apiClient.toggleConversationFavorite(conversationId);
  }

  @override
  Future<void> deleteConversation(int conversationId) async {
    await _apiClient.deleteConversation(conversationId);
  }

  @override
  Future<void> markAsRead(int conversationId) async {
    await _apiClient.markConversationAsRead(conversationId);
  }

  /// Parse conversation data from API response
  Conversation _parseConversation(Map<String, dynamic> data) {
    final partnerData = data['partner'] as Map<String, dynamic>?;

    return Conversation(
      id: data['id'] as int,
      partnerUserId: partnerData?['id'] as int?,
      partnerNickname: partnerData?['nickname'] as String?,
      partnerGender: Gender.fromString(partnerData?['gender'] as String?),
      partnerProfileImageUrl: partnerData?['profile_image_url'] as String?,
      isFavorite: data['is_favorite'] as bool? ?? false,
      hasUnreadMessages: data['has_unread'] as bool? ?? false,
      unreadCount: data['unread_count'] as int? ?? 0,
      lastMessagePreview: data['last_message_preview'] as String?,
      lastMessageAt: data['last_message_at'] != null
          ? DateTime.parse(data['last_message_at'] as String)
          : null,
      createdAt: DateTime.parse(
        data['created_at'] as String? ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  /// Parse message data from API response
  Message _parseMessage(Map<String, dynamic> data) {
    return Message(
      id: data['id'] as int,
      conversationId: data['conversation_id'] as int,
      senderId: data['sender_id'] as int,
      content: data['content'] as String?,
      voiceUrl: data['audio_url'] as String?,
      duration: data['duration'] as int?,
      messageType: MessageType.fromString(data['message_type'] as String?),
      isRead: data['read'] as bool? ?? false,
      broadcastId: data['broadcast_id'] as int?,
      createdAt: DateTime.parse(
        data['created_at'] as String? ?? DateTime.now().toIso8601String(),
      ),
    );
  }
}
