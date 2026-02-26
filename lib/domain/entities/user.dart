import 'package:equatable/equatable.dart';
import 'package:talk_flutter/core/enums/app_enums.dart';

/// User entity - Domain layer
class User extends Equatable {
  final int id;
  final String? phoneNumber;
  final String nickname;
  final Gender gender;
  final String? profileImageUrl;
  final UserStatus status;
  final bool verified;
  final bool pushEnabled;
  final bool broadcastPushEnabled;
  final bool messagePushEnabled;
  final int? walletBalance;
  final DateTime? nicknameChangedAt;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const User({
    required this.id,
    this.phoneNumber,
    required this.nickname,
    this.gender = Gender.unknown,
    this.profileImageUrl,
    this.status = UserStatus.active,
    this.verified = false,
    this.pushEnabled = true,
    this.broadcastPushEnabled = true,
    this.messagePushEnabled = true,
    this.walletBalance,
    this.nicknameChangedAt,
    required this.createdAt,
    this.updatedAt,
  });

  /// 닉네임 변경 가능 여부 (한 달에 한 번 제한)
  bool get canChangeNickname {
    if (nicknameChangedAt == null) return true;
    return DateTime.now().difference(nicknameChangedAt!).inDays >= 30;
  }

  /// 닉네임 변경까지 남은 일수
  int get daysUntilNicknameChange {
    if (canChangeNickname) return 0;
    return 30 - DateTime.now().difference(nicknameChangedAt!).inDays;
  }

  bool get isActive => status == UserStatus.active;
  bool get isSuspended => status == UserStatus.suspended;
  bool get isBanned => status == UserStatus.banned;

  User copyWith({
    int? id,
    String? phoneNumber,
    String? nickname,
    Gender? gender,
    String? profileImageUrl,
    UserStatus? status,
    bool? verified,
    bool? pushEnabled,
    bool? broadcastPushEnabled,
    bool? messagePushEnabled,
    int? walletBalance,
    DateTime? nicknameChangedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      nickname: nickname ?? this.nickname,
      gender: gender ?? this.gender,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      status: status ?? this.status,
      verified: verified ?? this.verified,
      pushEnabled: pushEnabled ?? this.pushEnabled,
      broadcastPushEnabled: broadcastPushEnabled ?? this.broadcastPushEnabled,
      messagePushEnabled: messagePushEnabled ?? this.messagePushEnabled,
      walletBalance: walletBalance ?? this.walletBalance,
      nicknameChangedAt: nicknameChangedAt ?? this.nicknameChangedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        phoneNumber,
        nickname,
        gender,
        profileImageUrl,
        status,
        verified,
        pushEnabled,
        broadcastPushEnabled,
        messagePushEnabled,
        walletBalance,
        nicknameChangedAt,
        createdAt,
        updatedAt,
      ];
}
