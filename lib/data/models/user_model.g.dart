// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
  id: (json['id'] as num).toInt(),
  phoneNumber: json['phone_number'] as String?,
  nickname: json['nickname'] as String?,
  gender: json['gender'] as String?,
  profileImageUrl: json['profile_image_url'] as String?,
  status: json['status'] as String?,
  verified: json['verified'] as bool?,
  pushEnabled: json['push_enabled'] as bool?,
  broadcastPushEnabled: json['broadcast_push_enabled'] as bool?,
  messagePushEnabled: json['message_push_enabled'] as bool?,
  walletBalance: (json['wallet_balance'] as num?)?.toInt(),
  createdAt: json['created_at'] as String?,
  updatedAt: json['updated_at'] as String?,
);

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
  'id': instance.id,
  'phone_number': instance.phoneNumber,
  'nickname': instance.nickname,
  'gender': instance.gender,
  'profile_image_url': instance.profileImageUrl,
  'status': instance.status,
  'verified': instance.verified,
  'push_enabled': instance.pushEnabled,
  'broadcast_push_enabled': instance.broadcastPushEnabled,
  'message_push_enabled': instance.messagePushEnabled,
  'wallet_balance': instance.walletBalance,
  'created_at': instance.createdAt,
  'updated_at': instance.updatedAt,
};
