import 'package:equatable/equatable.dart';

/// Notification entity - Domain layer
class AppNotification extends Equatable {
  final int id;
  final String type;
  final String? title;
  final String? body;
  final bool isRead;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final String? formattedDate;

  const AppNotification({
    required this.id,
    required this.type,
    this.title,
    this.body,
    this.isRead = false,
    this.metadata,
    required this.createdAt,
    this.formattedDate,
  });

  /// Get notification icon based on type
  String get iconName {
    switch (type) {
      case 'broadcast':
        return 'campaign';
      case 'message':
        return 'message';
      case 'reply':
        return 'reply';
      case 'system':
        return 'notifications';
      default:
        return 'notifications';
    }
  }

  /// Get notification type display name
  String get typeDisplayName {
    switch (type) {
      case 'broadcast':
        return '브로드캐스트';
      case 'message':
        return '메시지';
      case 'reply':
        return '답장';
      case 'system':
        return '시스템';
      default:
        return '알림';
    }
  }

  AppNotification copyWith({
    int? id,
    String? type,
    String? title,
    String? body,
    bool? isRead,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    String? formattedDate,
  }) {
    return AppNotification(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      body: body ?? this.body,
      isRead: isRead ?? this.isRead,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      formattedDate: formattedDate ?? this.formattedDate,
    );
  }

  @override
  List<Object?> get props => [
        id,
        type,
        title,
        body,
        isRead,
        metadata,
        createdAt,
        formattedDate,
      ];
}
