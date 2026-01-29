import 'package:talk_flutter/domain/entities/broadcast.dart';

/// Broadcast repository interface - Domain layer
abstract class BroadcastRepository {
  /// Get broadcasts with pagination
  Future<List<Broadcast>> getBroadcasts({int page = 1, int perPage = 20});

  /// Get broadcast by ID
  Future<Broadcast> getBroadcastById(int id);

  /// Create new broadcast
  Future<Broadcast> createBroadcast({
    required String audioPath,
    required int duration,
    int recipientCount = 5,
    String? content,
  });

  /// Reply to a broadcast (creates conversation)
  Future<void> replyToBroadcast({
    required int broadcastId,
    required String audioPath,
    required int duration,
  });

  /// Mark broadcast as listened
  Future<void> markAsListened(int broadcastId);
}
