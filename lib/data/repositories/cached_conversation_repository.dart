import 'package:drift/drift.dart';
import 'package:talk_flutter/core/enums/app_enums.dart';
import 'package:talk_flutter/core/services/connectivity_service.dart';
import 'package:talk_flutter/data/database/app_database.dart';
import 'package:talk_flutter/data/services/audio_cache_service.dart';
import 'package:talk_flutter/domain/entities/conversation.dart';
import 'package:talk_flutter/domain/entities/message.dart';
import 'package:talk_flutter/domain/repositories/conversation_repository.dart';

/// Cache-first decorator: tries network, falls back to local DB when offline.
class CachedConversationRepository implements ConversationRepository {
  final ConversationRepository _inner;
  final AudioCacheService _cacheService;
  final AppDatabase _db;
  final ConnectivityService _connectivity;

  CachedConversationRepository({
    required ConversationRepository inner,
    required AudioCacheService cacheService,
    required AppDatabase db,
    required ConnectivityService connectivity,
  })  : _inner = inner,
        _cacheService = cacheService,
        _db = db,
        _connectivity = connectivity;

  @override
  Future<List<Conversation>> getConversations({
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final conversations =
          await _inner.getConversations(page: page, perPage: perPage);
      _persistConversationsToDb(conversations);
      return conversations;
    } catch (e) {
      if (!_connectivity.isOnline) {
        return _loadConversationsFromDb();
      }
      rethrow;
    }
  }

  @override
  Future<Conversation> getConversationById(int id) async {
    try {
      final conversation = await _inner.getConversationById(id);
      _persistConversationsToDb([conversation]);
      return conversation;
    } catch (e) {
      if (!_connectivity.isOnline) {
        final cached = await _db.getCachedConversationById(id);
        if (cached != null) return _toConversationEntity(cached);
      }
      rethrow;
    }
  }

  @override
  Future<List<Message>> getMessages({
    required int conversationId,
    int page = 1,
    int perPage = 50,
  }) async {
    try {
      final messages = await _inner.getMessages(
        conversationId: conversationId,
        page: page,
        perPage: perPage,
      );
      _backgroundCacheMessages(messages);
      _persistMessagesToDb(messages);
      return messages;
    } catch (e) {
      if (!_connectivity.isOnline) {
        return _loadMessagesFromDb(conversationId);
      }
      rethrow;
    }
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
  Future<void> toggleFavorite(int conversationId) async {
    final cached = await _db.getCachedConversationById(conversationId);
    if (cached != null) {
      _db.updateConversationFavorite(conversationId, !cached.isFavorite);
    }
    return _inner.toggleFavorite(conversationId);
  }

  @override
  Future<void> deleteConversation(int conversationId) async {
    _db.deleteCachedConversation(conversationId);
    return _inner.deleteConversation(conversationId);
  }

  @override
  Future<void> markAsRead(int conversationId) async {
    _db.markConversationRead(conversationId);
    return _inner.markAsRead(conversationId);
  }

  // ==================== Private helpers ====================

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

  void _persistConversationsToDb(List<Conversation> conversations) {
    final now = DateTime.now();
    final entries = conversations.map((c) => CachedConversationsCompanion(
          id: Value(c.id),
          partnerUserId: Value(c.partnerUserId),
          partnerNickname: Value(c.partnerNickname),
          partnerGender: Value(c.partnerGender?.apiValue),
          partnerProfileImageUrl: Value(c.partnerProfileImageUrl),
          broadcastId: Value(c.broadcastId),
          isFavorite: Value(c.isFavorite),
          hasUnreadMessages: Value(c.hasUnreadMessages),
          unreadCount: Value(c.unreadCount),
          lastMessagePreview: Value(c.lastMessagePreview),
          lastMessageAt: Value(c.lastMessageAt),
          createdAt: Value(c.createdAt),
          updatedAt: Value(c.updatedAt),
          cachedAt: Value(now),
        )).toList();
    _db.upsertConversations(entries);
  }

  void _persistMessagesToDb(List<Message> messages) {
    final now = DateTime.now();
    final entries = messages.map((m) => CachedMessagesCompanion(
          id: Value(m.id),
          conversationId: Value(m.conversationId),
          senderId: Value(m.senderId),
          content: Value(m.content),
          voiceUrl: Value(m.voiceUrl),
          duration: Value(m.duration),
          messageType: Value(m.messageType.apiValue),
          broadcastId: Value(m.broadcastId),
          isRead: Value(m.isRead),
          createdAt: Value(m.createdAt),
          updatedAt: Value(m.updatedAt),
          cachedAt: Value(now),
        )).toList();
    _db.upsertMessages(entries);
  }

  Future<List<Conversation>> _loadConversationsFromDb() async {
    final cached = await _db.getAllCachedConversations();
    return cached.map(_toConversationEntity).toList();
  }

  Future<List<Message>> _loadMessagesFromDb(int conversationId) async {
    final cached = await _db.getCachedMessages(conversationId);
    return cached.map(_toMessageEntity).toList();
  }

  Conversation _toConversationEntity(CachedConversation c) {
    return Conversation(
      id: c.id,
      partnerUserId: c.partnerUserId,
      partnerNickname: c.partnerNickname,
      partnerGender: Gender.fromString(c.partnerGender),
      partnerProfileImageUrl: c.partnerProfileImageUrl,
      broadcastId: c.broadcastId,
      isFavorite: c.isFavorite,
      hasUnreadMessages: c.hasUnreadMessages,
      unreadCount: c.unreadCount,
      lastMessagePreview: c.lastMessagePreview,
      lastMessageAt: c.lastMessageAt,
      createdAt: c.createdAt,
      updatedAt: c.updatedAt,
    );
  }

  Message _toMessageEntity(CachedMessage m) {
    return Message(
      id: m.id,
      conversationId: m.conversationId,
      senderId: m.senderId,
      content: m.content,
      voiceUrl: m.voiceUrl,
      duration: m.duration,
      messageType: MessageType.fromString(m.messageType),
      broadcastId: m.broadcastId,
      isRead: m.isRead,
      createdAt: m.createdAt,
      updatedAt: m.updatedAt,
    );
  }
}
