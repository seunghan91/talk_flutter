import 'package:talk_flutter/data/services/audio_cache_service.dart';
import 'package:talk_flutter/domain/entities/conversation.dart';
import 'package:talk_flutter/domain/entities/message.dart';
import 'package:talk_flutter/domain/repositories/conversation_repository.dart';

/// Decorator that wraps a ConversationRepository and caches audio files.
class CachedConversationRepository implements ConversationRepository {
  final ConversationRepository _inner;
  final AudioCacheService _cacheService;

  CachedConversationRepository({
    required ConversationRepository inner,
    required AudioCacheService cacheService,
  })  : _inner = inner,
        _cacheService = cacheService;

  @override
  Future<List<Conversation>> getConversations({
    int page = 1,
    int perPage = 20,
  }) {
    return _inner.getConversations(page: page, perPage: perPage);
  }

  @override
  Future<Conversation> getConversationById(int id) {
    return _inner.getConversationById(id);
  }

  @override
  Future<List<Message>> getMessages({
    required int conversationId,
    int page = 1,
    int perPage = 50,
  }) async {
    final messages = await _inner.getMessages(
      conversationId: conversationId,
      page: page,
      perPage: perPage,
    );
    _backgroundCacheMessages(messages);
    return messages;
  }

  @override
  Future<Message> sendMessage({
    required int conversationId,
    required String audioPath,
    required int duration,
  }) {
    return _inner.sendMessage(
      conversationId: conversationId,
      audioPath: audioPath,
      duration: duration,
    );
  }

  @override
  Future<void> toggleFavorite(int conversationId) {
    return _inner.toggleFavorite(conversationId);
  }

  @override
  Future<void> deleteConversation(int conversationId) {
    return _inner.deleteConversation(conversationId);
  }

  @override
  Future<void> markAsRead(int conversationId) {
    return _inner.markAsRead(conversationId);
  }

  void _backgroundCacheMessages(List<Message> messages) {
    for (final message in messages) {
      if (message.voiceUrl != null) {
        _cacheService.cacheAudio(
          sourceType: 'message',
          sourceId: message.id,
          remoteUrl: message.voiceUrl!,
          durationSeconds: message.duration,
        );
      }
    }
  }
}
