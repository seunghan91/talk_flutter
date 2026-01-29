// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AuthResponseModel _$AuthResponseModelFromJson(Map<String, dynamic> json) =>
    AuthResponseModel(
      token: json['token'] as String?,
      user: json['user'] == null
          ? null
          : UserModel.fromJson(json['user'] as Map<String, dynamic>),
      message: json['message'] as String?,
      verified: json['verified'] as bool?,
    );

Map<String, dynamic> _$AuthResponseModelToJson(AuthResponseModel instance) =>
    <String, dynamic>{
      'token': instance.token,
      'user': instance.user,
      'message': instance.message,
      'verified': instance.verified,
    };

VerificationResponseModel _$VerificationResponseModelFromJson(
  Map<String, dynamic> json,
) => VerificationResponseModel(
  verified: json['verified'] as bool?,
  message: json['message'] as String?,
);

Map<String, dynamic> _$VerificationResponseModelToJson(
  VerificationResponseModel instance,
) => <String, dynamic>{
  'verified': instance.verified,
  'message': instance.message,
};
