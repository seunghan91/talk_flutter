import 'package:json_annotation/json_annotation.dart';
import 'package:talk_flutter/core/enums/app_enums.dart';
import 'package:talk_flutter/data/models/user_model.dart';
import 'package:talk_flutter/domain/entities/message.dart';

part 'message_model.g.dart';

/// Message DTO for API communication
@JsonSerializable()
class MessageModel {
  final int id;
  @JsonKey(name: 'conversation_id')
  final int conversationId;
  @JsonKey(name: 'sender_id')
  final int senderId;
  final UserModel? sender;
  final String? content;
  @JsonKey(name: 'voice_url')
  final String? voiceUrl;
  final int? duration;
  @JsonKey(name: 'message_type')
  final String? messageType;
  @JsonKey(name: 'broadcast_id')
  final int? broadcastId;
  @JsonKey(name: 'is_read')
  final bool? isRead;
  @JsonKey(name: 'created_at')
  final String? createdAt;
  @JsonKey(name: 'updated_at')
  final String? updatedAt;

  const MessageModel({
    required this.id,
    required this.conversationId,
    required this.senderId,
    this.sender,
    this.content,
    this.voiceUrl,
    this.duration,
    this.messageType,
    this.broadcastId,
    this.isRead,
    this.createdAt,
    this.updatedAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) =>
      _$MessageModelFromJson(json);

  Map<String, dynamic> toJson() => _$MessageModelToJson(this);

  /// Convert to domain entity
  Message toEntity() {
    return Message(
      id: id,
      conversationId: conversationId,
      senderId: senderId,
      sender: sender?.toEntity(),
      content: content,
      voiceUrl: voiceUrl,
      duration: duration,
      messageType: MessageType.fromString(messageType),
      broadcastId: broadcastId,
      isRead: isRead ?? false,
      createdAt: _parseDateTime(createdAt) ?? DateTime.now(),
      updatedAt: _parseDateTime(updatedAt),
    );
  }

  static DateTime? _parseDateTime(String? value) {
    if (value == null || value.isEmpty) return null;
    try {
      return DateTime.parse(value);
    } catch (_) {
      return null;
    }
  }
}
