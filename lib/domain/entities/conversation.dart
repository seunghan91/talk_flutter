import 'package:equatable/equatable.dart';
import 'package:talk_flutter/core/enums/app_enums.dart';
import 'package:talk_flutter/domain/entities/message.dart';
import 'package:talk_flutter/domain/entities/user.dart';

/// Conversation entity - Domain layer
class Conversation extends Equatable {
  final int id;
  final User? userA;
  final User? userB;
  final int? partnerUserId;
  final String? partnerNickname;
  final Gender? partnerGender;
  final String? partnerProfileImageUrl;
  final int? broadcastId;
  final bool isFavorite;
  final bool hasUnreadMessages;
  final int unreadCount;
  final Message? lastMessage;
  final String? lastMessagePreview;
  final DateTime? lastMessageAt;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Conversation({
    required this.id,
    this.userA,
    this.userB,
    this.partnerUserId,
    this.partnerNickname,
    this.partnerGender,
    this.partnerProfileImageUrl,
    this.broadcastId,
    this.isFavorite = false,
    this.hasUnreadMessages = false,
    this.unreadCount = 0,
    this.lastMessage,
    this.lastMessagePreview,
    this.lastMessageAt,
    required this.createdAt,
    this.updatedAt,
  });

  /// Get the other user in the conversation (not the current user)
  User? getOtherUser(int currentUserId) {
    if (userA?.id == currentUserId) return userB;
    if (userB?.id == currentUserId) return userA;
    return null;
  }

  /// Check if this conversation is with a specific user
  bool isWithUser(int userId) {
    return userA?.id == userId || userB?.id == userId || partnerUserId == userId;
  }

  /// Get display name for the partner
  String get partnerDisplayName {
    return partnerNickname ?? userB?.nickname ?? userA?.nickname ?? 'Unknown';
  }

  /// Get last message preview text
  String get messagePreview {
    if (lastMessagePreview != null && lastMessagePreview!.isNotEmpty) {
      return lastMessagePreview!;
    }
    if (lastMessage?.content != null && lastMessage!.content!.isNotEmpty) {
      return lastMessage!.content!;
    }
    return '음성 메시지';
  }

  Conversation copyWith({
    int? id,
    User? userA,
    User? userB,
    int? partnerUserId,
    String? partnerNickname,
    Gender? partnerGender,
    String? partnerProfileImageUrl,
    int? broadcastId,
    bool? isFavorite,
    bool? hasUnreadMessages,
    int? unreadCount,
    Message? lastMessage,
    String? lastMessagePreview,
    DateTime? lastMessageAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Conversation(
      id: id ?? this.id,
      userA: userA ?? this.userA,
      userB: userB ?? this.userB,
      partnerUserId: partnerUserId ?? this.partnerUserId,
      partnerNickname: partnerNickname ?? this.partnerNickname,
      partnerGender: partnerGender ?? this.partnerGender,
      partnerProfileImageUrl: partnerProfileImageUrl ?? this.partnerProfileImageUrl,
      broadcastId: broadcastId ?? this.broadcastId,
      isFavorite: isFavorite ?? this.isFavorite,
      hasUnreadMessages: hasUnreadMessages ?? this.hasUnreadMessages,
      unreadCount: unreadCount ?? this.unreadCount,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessagePreview: lastMessagePreview ?? this.lastMessagePreview,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userA,
        userB,
        partnerUserId,
        partnerNickname,
        partnerGender,
        partnerProfileImageUrl,
        broadcastId,
        isFavorite,
        hasUnreadMessages,
        unreadCount,
        lastMessage,
        lastMessagePreview,
        lastMessageAt,
        createdAt,
        updatedAt,
      ];
}
