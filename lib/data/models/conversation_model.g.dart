// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'conversation_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ConversationModel _$ConversationModelFromJson(Map<String, dynamic> json) =>
    ConversationModel(
      id: (json['id'] as num).toInt(),
      userA: json['user_a'] == null
          ? null
          : UserModel.fromJson(json['user_a'] as Map<String, dynamic>),
      userB: json['user_b'] == null
          ? null
          : UserModel.fromJson(json['user_b'] as Map<String, dynamic>),
      partnerUserId: (json['partner_user_id'] as num?)?.toInt(),
      partnerNickname: json['partner_nickname'] as String?,
      partnerGender: json['partner_gender'] as String?,
      partnerProfileImageUrl: json['partner_profile_image_url'] as String?,
      broadcastId: (json['broadcast_id'] as num?)?.toInt(),
      isFavorite: json['is_favorite'] as bool?,
      hasUnreadMessages: json['has_unread_messages'] as bool?,
      unreadCount: (json['unread_count'] as num?)?.toInt(),
      lastMessage: json['last_message'] == null
          ? null
          : MessageModel.fromJson(json['last_message'] as Map<String, dynamic>),
      lastMessagePreview: json['last_message_preview'] as String?,
      lastMessageAt: json['last_message_at'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );

Map<String, dynamic> _$ConversationModelToJson(ConversationModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_a': instance.userA,
      'user_b': instance.userB,
      'partner_user_id': instance.partnerUserId,
      'partner_nickname': instance.partnerNickname,
      'partner_gender': instance.partnerGender,
      'partner_profile_image_url': instance.partnerProfileImageUrl,
      'broadcast_id': instance.broadcastId,
      'is_favorite': instance.isFavorite,
      'has_unread_messages': instance.hasUnreadMessages,
      'unread_count': instance.unreadCount,
      'last_message': instance.lastMessage,
      'last_message_preview': instance.lastMessagePreview,
      'last_message_at': instance.lastMessageAt,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };
