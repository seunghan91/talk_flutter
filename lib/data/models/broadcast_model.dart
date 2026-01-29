import 'package:json_annotation/json_annotation.dart';
import 'package:talk_flutter/core/enums/app_enums.dart';
import 'package:talk_flutter/data/models/user_model.dart';
import 'package:talk_flutter/domain/entities/broadcast.dart';

part 'broadcast_model.g.dart';

/// Broadcast DTO for API communication
@JsonSerializable()
class BroadcastModel {
  final int id;
  @JsonKey(name: 'user_id')
  final int userId;
  final UserModel? sender;
  final String? content;
  @JsonKey(name: 'audio_url')
  final String? audioUrl;
  final int? duration;
  @JsonKey(name: 'recipient_count')
  final int? recipientCount;
  @JsonKey(name: 'reply_count')
  final int? replyCount;
  @JsonKey(name: 'is_expired')
  final bool? isExpired;
  @JsonKey(name: 'is_favorite')
  final bool? isFavorite;
  @JsonKey(name: 'is_read')
  final bool? isRead;
  @JsonKey(name: 'is_listened')
  final bool? isListened;
  @JsonKey(name: 'sender_gender')
  final String? senderGender;
  @JsonKey(name: 'sender_nickname')
  final String? senderNickname;
  @JsonKey(name: 'created_at')
  final String? createdAt;
  @JsonKey(name: 'expired_at')
  final String? expiredAt;

  const BroadcastModel({
    required this.id,
    required this.userId,
    this.sender,
    this.content,
    this.audioUrl,
    this.duration,
    this.recipientCount,
    this.replyCount,
    this.isExpired,
    this.isFavorite,
    this.isRead,
    this.isListened,
    this.senderGender,
    this.senderNickname,
    this.createdAt,
    this.expiredAt,
  });

  factory BroadcastModel.fromJson(Map<String, dynamic> json) =>
      _$BroadcastModelFromJson(json);

  Map<String, dynamic> toJson() => _$BroadcastModelToJson(this);

  /// Convert to domain entity
  Broadcast toEntity() {
    return Broadcast(
      id: id,
      userId: userId,
      sender: sender?.toEntity(),
      content: content,
      audioUrl: audioUrl,
      duration: duration,
      recipientCount: recipientCount ?? 0,
      replyCount: replyCount ?? 0,
      isExpired: isExpired ?? false,
      isFavorite: isFavorite ?? false,
      isRead: isRead ?? false,
      isListened: isListened ?? false,
      senderGender: Gender.fromString(senderGender),
      senderNickname: senderNickname,
      createdAt: _parseDateTime(createdAt) ?? DateTime.now(),
      expiredAt: _parseDateTime(expiredAt),
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
