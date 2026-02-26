import 'package:flutter_test/flutter_test.dart';
import 'package:talk_flutter/core/enums/app_enums.dart';
import 'package:talk_flutter/domain/entities/conversation.dart';
import 'package:talk_flutter/domain/entities/message.dart';
import 'package:talk_flutter/domain/entities/user.dart';

void main() {
  group('Conversation', () {
    final now = DateTime(2024, 1, 1);
    final userA = User(id: 1, nickname: 'Alice', createdAt: now);
    final userB = User(id: 2, nickname: 'Bob', createdAt: now);

    test('getOtherUser returns correct user', () {
      final conv = Conversation(
        id: 1,
        userA: userA,
        userB: userB,
        createdAt: now,
      );
      expect(conv.getOtherUser(1), userB);
      expect(conv.getOtherUser(2), userA);
      expect(conv.getOtherUser(99), isNull);
    });

    test('isWithUser checks correctly', () {
      final conv = Conversation(
        id: 1,
        userA: userA,
        userB: userB,
        partnerUserId: 3,
        createdAt: now,
      );
      expect(conv.isWithUser(1), isTrue);
      expect(conv.isWithUser(2), isTrue);
      expect(conv.isWithUser(3), isTrue);
      expect(conv.isWithUser(99), isFalse);
    });

    test('partnerDisplayName returns nickname', () {
      final conv = Conversation(
        id: 1,
        partnerNickname: 'Partner',
        createdAt: now,
      );
      expect(conv.partnerDisplayName, 'Partner');
    });

    test('partnerDisplayName returns Unknown as fallback', () {
      final conv = Conversation(id: 1, createdAt: now);
      expect(conv.partnerDisplayName, 'Unknown');
    });

    test('messagePreview returns lastMessagePreview', () {
      final conv = Conversation(
        id: 1,
        lastMessagePreview: '안녕하세요',
        createdAt: now,
      );
      expect(conv.messagePreview, '안녕하세요');
    });

    test('messagePreview fallback to voice message', () {
      final conv = Conversation(id: 1, createdAt: now);
      expect(conv.messagePreview, '음성 메시지');
    });

    test('copyWith preserves original values', () {
      final original = Conversation(
        id: 1,
        isFavorite: false,
        unreadCount: 5,
        createdAt: now,
      );
      final updated = original.copyWith(isFavorite: true);

      expect(updated.isFavorite, isTrue);
      expect(updated.unreadCount, 5);
      expect(original.isFavorite, isFalse);
    });
  });

  group('Message', () {
    test('isVoiceMessage returns true for voice type', () {
      final msg = Message(
        id: 1,
        conversationId: 1,
        senderId: 1,
        messageType: MessageType.voice,
        createdAt: DateTime.now(),
      );
      expect(msg.isVoiceMessage, isTrue);
    });

    test('isVoiceMessage returns true for broadcastReply type', () {
      final msg = Message(
        id: 1,
        conversationId: 1,
        senderId: 1,
        messageType: MessageType.broadcastReply,
        createdAt: DateTime.now(),
      );
      expect(msg.isVoiceMessage, isTrue);
      expect(msg.isBroadcastReply, isTrue);
    });

    test('displayText returns content when available', () {
      final msg = Message(
        id: 1,
        conversationId: 1,
        senderId: 1,
        content: 'Hello!',
        createdAt: DateTime.now(),
      );
      expect(msg.displayText, 'Hello!');
    });

    test('displayText shows formatted duration for voice messages', () {
      final msg = Message(
        id: 1,
        conversationId: 1,
        senderId: 1,
        messageType: MessageType.voice,
        duration: 65,
        createdAt: DateTime.now(),
      );
      expect(msg.displayText, '음성 메시지 1:05');
    });

    test('isFromUser checks correctly', () {
      final msg = Message(
        id: 1,
        conversationId: 1,
        senderId: 42,
        createdAt: DateTime.now(),
      );
      expect(msg.isFromUser(42), isTrue);
      expect(msg.isFromUser(99), isFalse);
    });
  });
}
