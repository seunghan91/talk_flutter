import 'package:equatable/equatable.dart';
import 'package:talk_flutter/core/enums/app_enums.dart';
import 'package:talk_flutter/domain/entities/user.dart';

/// Broadcast entity - Domain layer
class Broadcast extends Equatable {
  final int id;
  final int userId;
  final User? sender;
  final String? content;
  final String? audioUrl;
  final int? duration;
  final int recipientCount;
  final int replyCount;
  final bool isExpired;
  final bool isFavorite;
  final bool isRead;
  final bool isListened;
  final Gender? senderGender;
  final String? senderNickname;
  final DateTime createdAt;
  final DateTime? expiredAt;

  const Broadcast({
    required this.id,
    required this.userId,
    this.sender,
    this.content,
    this.audioUrl,
    this.duration,
    this.recipientCount = 0,
    this.replyCount = 0,
    this.isExpired = false,
    this.isFavorite = false,
    this.isRead = false,
    this.isListened = false,
    this.senderGender,
    this.senderNickname,
    required this.createdAt,
    this.expiredAt,
  });

  /// Check if broadcast is active (not expired)
  bool get isActive => !isExpired && (expiredAt == null || expiredAt!.isAfter(DateTime.now()));

  /// Check if expiring soon (within 24 hours)
  bool get isExpiringSoon {
    if (expiredAt == null) return false;
    final hoursUntilExpiry = expiredAt!.difference(DateTime.now()).inHours;
    return hoursUntilExpiry > 0 && hoursUntilExpiry <= 24;
  }

  /// Format duration as MM:SS
  String get formattedDuration {
    if (duration == null) return '0:00';
    final minutes = duration! ~/ 60;
    final seconds = duration! % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  Broadcast copyWith({
    int? id,
    int? userId,
    User? sender,
    String? content,
    String? audioUrl,
    int? duration,
    int? recipientCount,
    int? replyCount,
    bool? isExpired,
    bool? isFavorite,
    bool? isRead,
    bool? isListened,
    Gender? senderGender,
    String? senderNickname,
    DateTime? createdAt,
    DateTime? expiredAt,
  }) {
    return Broadcast(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      sender: sender ?? this.sender,
      content: content ?? this.content,
      audioUrl: audioUrl ?? this.audioUrl,
      duration: duration ?? this.duration,
      recipientCount: recipientCount ?? this.recipientCount,
      replyCount: replyCount ?? this.replyCount,
      isExpired: isExpired ?? this.isExpired,
      isFavorite: isFavorite ?? this.isFavorite,
      isRead: isRead ?? this.isRead,
      isListened: isListened ?? this.isListened,
      senderGender: senderGender ?? this.senderGender,
      senderNickname: senderNickname ?? this.senderNickname,
      createdAt: createdAt ?? this.createdAt,
      expiredAt: expiredAt ?? this.expiredAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        sender,
        content,
        audioUrl,
        duration,
        recipientCount,
        replyCount,
        isExpired,
        isFavorite,
        isRead,
        isListened,
        senderGender,
        senderNickname,
        createdAt,
        expiredAt,
      ];
}
