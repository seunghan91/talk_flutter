import 'package:equatable/equatable.dart';
import 'package:talk_flutter/core/enums/app_enums.dart';
import 'package:talk_flutter/domain/entities/user.dart';

/// Message entity - Domain layer
class Message extends Equatable {
  final int id;
  final int conversationId;
  final int senderId;
  final User? sender;
  final String? content;
  final String? voiceUrl;
  final int? duration;
  final MessageType messageType;
  final int? broadcastId;
  final bool isRead;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Message({
    required this.id,
    required this.conversationId,
    required this.senderId,
    this.sender,
    this.content,
    this.voiceUrl,
    this.duration,
    this.messageType = MessageType.text,
    this.broadcastId,
    this.isRead = false,
    required this.createdAt,
    this.updatedAt,
  });

  /// Check if this is a voice message
  bool get isVoiceMessage =>
      messageType == MessageType.voice ||
      messageType == MessageType.broadcastReply;

  /// Check if this is a broadcast reply
  bool get isBroadcastReply => messageType == MessageType.broadcastReply;

  /// Format duration as MM:SS
  String get formattedDuration {
    if (duration == null) return '0:00';
    final minutes = duration! ~/ 60;
    final seconds = duration! % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  /// Get display text for the message
  String get displayText {
    if (content != null && content!.isNotEmpty) {
      return content!;
    }
    if (isVoiceMessage) {
      return '음성 메시지 $formattedDuration';
    }
    return '';
  }

  /// Check if this message is from the given user
  bool isFromUser(int userId) => senderId == userId;

  Message copyWith({
    int? id,
    int? conversationId,
    int? senderId,
    User? sender,
    String? content,
    String? voiceUrl,
    int? duration,
    MessageType? messageType,
    int? broadcastId,
    bool? isRead,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Message(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      senderId: senderId ?? this.senderId,
      sender: sender ?? this.sender,
      content: content ?? this.content,
      voiceUrl: voiceUrl ?? this.voiceUrl,
      duration: duration ?? this.duration,
      messageType: messageType ?? this.messageType,
      broadcastId: broadcastId ?? this.broadcastId,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        conversationId,
        senderId,
        sender,
        content,
        voiceUrl,
        duration,
        messageType,
        broadcastId,
        isRead,
        createdAt,
        updatedAt,
      ];
}
