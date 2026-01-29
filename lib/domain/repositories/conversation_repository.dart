import 'package:talk_flutter/domain/entities/conversation.dart';
import 'package:talk_flutter/domain/entities/message.dart';

/// Conversation repository interface - Domain layer
abstract class ConversationRepository {
  /// Get conversations with pagination
  Future<List<Conversation>> getConversations({int page = 1, int perPage = 20});

  /// Get conversation by ID
  Future<Conversation> getConversationById(int id);

  /// Get messages for a conversation with pagination
  Future<List<Message>> getMessages({
    required int conversationId,
    int page = 1,
    int perPage = 50,
  });

  /// Send voice message
  Future<Message> sendMessage({
    required int conversationId,
    required String audioPath,
    required int duration,
  });

  /// Toggle favorite status
  Future<void> toggleFavorite(int conversationId);

  /// Delete conversation (soft delete)
  Future<void> deleteConversation(int conversationId);

  /// Mark all messages as read
  Future<void> markAsRead(int conversationId);
}
