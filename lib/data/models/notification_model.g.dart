// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NotificationModel _$NotificationModelFromJson(Map<String, dynamic> json) =>
    NotificationModel(
      id: (json['id'] as num).toInt(),
      type: json['type'] as String,
      title: json['title'] as String?,
      body: json['body'] as String?,
      isRead: json['is_read'] as bool?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: json['created_at'] as String?,
      formattedDate: json['formatted_date'] as String?,
    );

Map<String, dynamic> _$NotificationModelToJson(NotificationModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'title': instance.title,
      'body': instance.body,
      'is_read': instance.isRead,
      'metadata': instance.metadata,
      'created_at': instance.createdAt,
      'formatted_date': instance.formattedDate,
    };
