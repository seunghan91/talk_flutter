import 'package:json_annotation/json_annotation.dart';
import 'package:talk_flutter/core/enums/app_enums.dart';
import 'package:talk_flutter/data/models/message_model.dart';
import 'package:talk_flutter/data/models/user_model.dart';
import 'package:talk_flutter/domain/entities/conversation.dart';

part 'conversation_model.g.dart';

/// Conversation DTO for API communication
@JsonSerializable()
class ConversationModel {
  final int id;
  @JsonKey(name: 'user_a')
  final UserModel? userA;
  @JsonKey(name: 'user_b')
  final UserModel? userB;
  @JsonKey(name: 'partner_user_id')
  final int? partnerUserId;
  @JsonKey(name: 'partner_nickname')
  final String? partnerNickname;
  @JsonKey(name: 'partner_gender')
  final String? partnerGender;
  @JsonKey(name: 'partner_profile_image_url')
  final String? partnerProfileImageUrl;
  @JsonKey(name: 'broadcast_id')
  final int? broadcastId;
  @JsonKey(name: 'is_favorite')
  final bool? isFavorite;
  @JsonKey(name: 'has_unread_messages')
  final bool? hasUnreadMessages;
  @JsonKey(name: 'unread_count')
  final int? unreadCount;
  @JsonKey(name: 'last_message')
  final MessageModel? lastMessage;
  @JsonKey(name: 'last_message_preview')
  final String? lastMessagePreview;
  @JsonKey(name: 'last_message_at')
  final String? lastMessageAt;
  @JsonKey(name: 'created_at')
  final String? createdAt;
  @JsonKey(name: 'updated_at')
  final String? updatedAt;

  const ConversationModel({
    required this.id,
    this.userA,
    this.userB,
    this.partnerUserId,
    this.partnerNickname,
    this.partnerGender,
    this.partnerProfileImageUrl,
    this.broadcastId,
    this.isFavorite,
    this.hasUnreadMessages,
    this.unreadCount,
    this.lastMessage,
    this.lastMessagePreview,
    this.lastMessageAt,
    this.createdAt,
    this.updatedAt,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) =>
      _$ConversationModelFromJson(json);

  Map<String, dynamic> toJson() => _$ConversationModelToJson(this);

  /// Convert to domain entity
  Conversation toEntity() {
    return Conversation(
      id: id,
      userA: userA?.toEntity(),
      userB: userB?.toEntity(),
      partnerUserId: partnerUserId,
      partnerNickname: partnerNickname,
      partnerGender: Gender.fromString(partnerGender),
      partnerProfileImageUrl: partnerProfileImageUrl,
      broadcastId: broadcastId,
      isFavorite: isFavorite ?? false,
      hasUnreadMessages: hasUnreadMessages ?? false,
      unreadCount: unreadCount ?? 0,
      lastMessage: lastMessage?.toEntity(),
      lastMessagePreview: lastMessagePreview,
      lastMessageAt: _parseDateTime(lastMessageAt),
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
