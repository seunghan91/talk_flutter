import 'package:json_annotation/json_annotation.dart';
import 'package:talk_flutter/core/enums/app_enums.dart';
import 'package:talk_flutter/domain/entities/user.dart';

part 'user_model.g.dart';

/// User DTO for API communication
@JsonSerializable()
class UserModel {
  final int id;
  @JsonKey(name: 'phone_number')
  final String? phoneNumber;
  final String? nickname;
  final String? gender;
  @JsonKey(name: 'profile_image_url')
  final String? profileImageUrl;
  final String? status;
  final bool? verified;
  @JsonKey(name: 'push_enabled')
  final bool? pushEnabled;
  @JsonKey(name: 'broadcast_push_enabled')
  final bool? broadcastPushEnabled;
  @JsonKey(name: 'message_push_enabled')
  final bool? messagePushEnabled;
  @JsonKey(name: 'wallet_balance')
  final int? walletBalance;
  @JsonKey(name: 'created_at')
  final String? createdAt;
  @JsonKey(name: 'updated_at')
  final String? updatedAt;

  const UserModel({
    required this.id,
    this.phoneNumber,
    this.nickname,
    this.gender,
    this.profileImageUrl,
    this.status,
    this.verified,
    this.pushEnabled,
    this.broadcastPushEnabled,
    this.messagePushEnabled,
    this.walletBalance,
    this.createdAt,
    this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  /// Convert to domain entity
  User toEntity() {
    return User(
      id: id,
      phoneNumber: phoneNumber,
      nickname: nickname ?? 'User',
      gender: Gender.fromString(gender),
      profileImageUrl: profileImageUrl,
      status: UserStatus.fromString(status),
      verified: verified ?? false,
      pushEnabled: pushEnabled ?? true,
      broadcastPushEnabled: broadcastPushEnabled ?? true,
      messagePushEnabled: messagePushEnabled ?? true,
      walletBalance: walletBalance,
      createdAt: _parseDateTime(createdAt) ?? DateTime.now(),
      updatedAt: _parseDateTime(updatedAt),
    );
  }

  /// Create from domain entity
  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      phoneNumber: user.phoneNumber,
      nickname: user.nickname,
      gender: user.gender.apiValue,
      profileImageUrl: user.profileImageUrl,
      status: user.status.name,
      verified: user.verified,
      pushEnabled: user.pushEnabled,
      broadcastPushEnabled: user.broadcastPushEnabled,
      messagePushEnabled: user.messagePushEnabled,
      walletBalance: user.walletBalance,
      createdAt: user.createdAt.toIso8601String(),
      updatedAt: user.updatedAt?.toIso8601String(),
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
