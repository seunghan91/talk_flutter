import 'package:json_annotation/json_annotation.dart';
import 'package:talk_flutter/domain/entities/notification.dart';

part 'notification_model.g.dart';

/// Notification DTO for API communication
@JsonSerializable()
class NotificationModel {
  final int id;
  final String type;
  final String? title;
  final String? body;
  @JsonKey(name: 'is_read')
  final bool? isRead;
  final Map<String, dynamic>? metadata;
  @JsonKey(name: 'created_at')
  final String? createdAt;
  @JsonKey(name: 'formatted_date')
  final String? formattedDate;

  const NotificationModel({
    required this.id,
    required this.type,
    this.title,
    this.body,
    this.isRead,
    this.metadata,
    this.createdAt,
    this.formattedDate,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      _$NotificationModelFromJson(json);

  Map<String, dynamic> toJson() => _$NotificationModelToJson(this);

  /// Convert to domain entity
  AppNotification toEntity() {
    return AppNotification(
      id: id,
      type: type,
      title: title,
      body: body,
      isRead: isRead ?? false,
      metadata: metadata,
      createdAt: _parseDateTime(createdAt) ?? DateTime.now(),
      formattedDate: formattedDate,
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
