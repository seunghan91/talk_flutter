/// Gender enum matching API
enum Gender {
  unknown,
  male,
  female;

  String get displayName => switch (this) {
        Gender.unknown => '미지정',
        Gender.male => '남성',
        Gender.female => '여성',
      };

  String get apiValue => switch (this) {
        Gender.unknown => 'unknown',
        Gender.male => 'male',
        Gender.female => 'female',
      };

  static Gender fromString(String? value) => switch (value?.toLowerCase()) {
        'male' => Gender.male,
        'female' => Gender.female,
        _ => Gender.unknown,
      };
}

/// User status enum
enum UserStatus {
  active,
  suspended,
  banned;

  static UserStatus fromString(String? value) => switch (value?.toLowerCase()) {
        'suspended' => UserStatus.suspended,
        'banned' => UserStatus.banned,
        _ => UserStatus.active,
      };
}

/// Message type enum
enum MessageType {
  text,
  voice,
  broadcastReply;

  String get apiValue => switch (this) {
        MessageType.text => 'text',
        MessageType.voice => 'voice',
        MessageType.broadcastReply => 'broadcast_reply',
      };

  static MessageType fromString(String? value) => switch (value?.toLowerCase()) {
        'voice' => MessageType.voice,
        'broadcast_reply' => MessageType.broadcastReply,
        _ => MessageType.text,
      };
}

/// Notification type enum
enum NotificationType {
  broadcast,
  message,
  announcement,
  system;

  static NotificationType fromString(String? value) =>
      switch (value?.toLowerCase()) {
        'message' => NotificationType.message,
        'announcement' => NotificationType.announcement,
        'system' => NotificationType.system,
        _ => NotificationType.broadcast,
      };
}

/// Broadcast recipient status
enum BroadcastRecipientStatus {
  pending,
  delivered,
  read;

  static BroadcastRecipientStatus fromString(String? value) =>
      switch (value?.toLowerCase()) {
        'delivered' => BroadcastRecipientStatus.delivered,
        'read' => BroadcastRecipientStatus.read,
        _ => BroadcastRecipientStatus.pending,
      };
}

/// Auth status for BLoC
enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

/// Generic loading status
enum LoadingStatus {
  initial,
  loading,
  success,
  failure,
}
