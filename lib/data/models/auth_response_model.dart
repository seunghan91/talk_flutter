import 'package:json_annotation/json_annotation.dart';
import 'package:talk_flutter/data/models/user_model.dart';

part 'auth_response_model.g.dart';

/// Auth response DTO for login/register API
@JsonSerializable()
class AuthResponseModel {
  final String? token;
  final UserModel? user;
  final String? message;
  final bool? verified;

  const AuthResponseModel({
    this.token,
    this.user,
    this.message,
    this.verified,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$AuthResponseModelToJson(this);
}

/// Verification code response DTO
@JsonSerializable()
class VerificationResponseModel {
  final bool? verified;
  final String? message;

  const VerificationResponseModel({
    this.verified,
    this.message,
  });

  factory VerificationResponseModel.fromJson(Map<String, dynamic> json) =>
      _$VerificationResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$VerificationResponseModelToJson(this);
}
