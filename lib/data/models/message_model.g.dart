// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MessageModel _$MessageModelFromJson(Map<String, dynamic> json) => MessageModel(
  id: (json['id'] as num).toInt(),
  conversationId: (json['conversation_id'] as num).toInt(),
  senderId: (json['sender_id'] as num).toInt(),
  sender: json['sender'] == null
      ? null
      : UserModel.fromJson(json['sender'] as Map<String, dynamic>),
  content: json['content'] as String?,
  voiceUrl: json['voice_url'] as String?,
  duration: (json['duration'] as num?)?.toInt(),
  messageType: json['message_type'] as String?,
  broadcastId: (json['broadcast_id'] as num?)?.toInt(),
  isRead: json['is_read'] as bool?,
  createdAt: json['created_at'] as String?,
  updatedAt: json['updated_at'] as String?,
);

Map<String, dynamic> _$MessageModelToJson(MessageModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'conversation_id': instance.conversationId,
      'sender_id': instance.senderId,
      'sender': instance.sender,
      'content': instance.content,
      'voice_url': instance.voiceUrl,
      'duration': instance.duration,
      'message_type': instance.messageType,
      'broadcast_id': instance.broadcastId,
      'is_read': instance.isRead,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };
