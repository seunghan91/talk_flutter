// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'broadcast_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BroadcastModel _$BroadcastModelFromJson(Map<String, dynamic> json) =>
    BroadcastModel(
      id: (json['id'] as num).toInt(),
      userId: (json['user_id'] as num).toInt(),
      sender: json['sender'] == null
          ? null
          : UserModel.fromJson(json['sender'] as Map<String, dynamic>),
      content: json['content'] as String?,
      audioUrl: json['audio_url'] as String?,
      duration: (json['duration'] as num?)?.toInt(),
      recipientCount: (json['recipient_count'] as num?)?.toInt(),
      replyCount: (json['reply_count'] as num?)?.toInt(),
      isExpired: json['is_expired'] as bool?,
      isFavorite: json['is_favorite'] as bool?,
      isRead: json['is_read'] as bool?,
      isListened: json['is_listened'] as bool?,
      senderGender: json['sender_gender'] as String?,
      senderNickname: json['sender_nickname'] as String?,
      createdAt: json['created_at'] as String?,
      expiredAt: json['expired_at'] as String?,
    );

Map<String, dynamic> _$BroadcastModelToJson(BroadcastModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'sender': instance.sender,
      'content': instance.content,
      'audio_url': instance.audioUrl,
      'duration': instance.duration,
      'recipient_count': instance.recipientCount,
      'reply_count': instance.replyCount,
      'is_expired': instance.isExpired,
      'is_favorite': instance.isFavorite,
      'is_read': instance.isRead,
      'is_listened': instance.isListened,
      'sender_gender': instance.senderGender,
      'sender_nickname': instance.senderNickname,
      'created_at': instance.createdAt,
      'expired_at': instance.expiredAt,
    };
