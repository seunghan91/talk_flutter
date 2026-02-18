import 'package:talk_flutter/data/services/audio_cache_service.dart';
import 'package:talk_flutter/domain/entities/broadcast.dart';
import 'package:talk_flutter/domain/entities/broadcast_limits.dart';
import 'package:talk_flutter/domain/repositories/broadcast_repository.dart';

/// Decorator that wraps a BroadcastRepository and caches audio files.
class CachedBroadcastRepository implements BroadcastRepository {
  final BroadcastRepository _inner;
  final AudioCacheService _cacheService;

  CachedBroadcastRepository({
    required BroadcastRepository inner,
    required AudioCacheService cacheService,
  })  : _inner = inner,
        _cacheService = cacheService;

  @override
  Future<List<Broadcast>> getBroadcasts({
    int page = 1,
    int perPage = 20,
  }) async {
    final broadcasts = await _inner.getBroadcasts(page: page, perPage: perPage);
    _backgroundCacheBroadcasts(broadcasts);
    return broadcasts;
  }

  @override
  Future<Broadcast> getBroadcastById(int id) async {
    final broadcast = await _inner.getBroadcastById(id);
    _backgroundCacheBroadcast(broadcast);
    return broadcast;
  }

  @override
  Future<Broadcast> createBroadcast({
    required String audioPath,
    required int duration,
    int recipientCount = 5,
    String? content,
    String? targetGender,
  }) {
    return _inner.createBroadcast(
      audioPath: audioPath,
      duration: duration,
      recipientCount: recipientCount,
      content: content,
      targetGender: targetGender,
    );
  }

  @override
  Future<void> replyToBroadcast({
    required int broadcastId,
    required String audioPath,
    required int duration,
  }) {
    return _inner.replyToBroadcast(
      broadcastId: broadcastId,
      audioPath: audioPath,
      duration: duration,
    );
  }

  @override
  Future<void> markAsListened(int broadcastId) {
    return _inner.markAsListened(broadcastId);
  }

  @override
  Future<BroadcastLimits> getBroadcastLimits() {
    return _inner.getBroadcastLimits();
  }

  void _backgroundCacheBroadcasts(List<Broadcast> broadcasts) {
    for (final broadcast in broadcasts) {
      _backgroundCacheBroadcast(broadcast);
    }
  }

  void _backgroundCacheBroadcast(Broadcast broadcast) {
    if (broadcast.audioUrl != null) {
      // Fire and forget - no await
      _cacheService.cacheAudio(
        sourceType: 'broadcast',
        sourceId: broadcast.id,
        remoteUrl: broadcast.audioUrl!,
        expiresAt: broadcast.expiredAt,
        durationSeconds: broadcast.duration,
      );
    }
  }
}
