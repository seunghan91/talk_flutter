import 'package:drift/drift.dart';
import 'package:talk_flutter/core/enums/app_enums.dart';
import 'package:talk_flutter/core/services/connectivity_service.dart';
import 'package:talk_flutter/data/database/app_database.dart';
import 'package:talk_flutter/data/services/audio_cache_service.dart';
import 'package:talk_flutter/domain/entities/broadcast.dart';
import 'package:talk_flutter/domain/entities/broadcast_limits.dart';
import 'package:talk_flutter/domain/repositories/broadcast_repository.dart';

/// Cache-first decorator: tries network, falls back to local DB when offline.
class CachedBroadcastRepository implements BroadcastRepository {
  final BroadcastRepository _inner;
  final AudioCacheService _cacheService;
  final AppDatabase _db;
  final ConnectivityService _connectivity;

  CachedBroadcastRepository({
    required BroadcastRepository inner,
    required AudioCacheService cacheService,
    required AppDatabase db,
    required ConnectivityService connectivity,
  })  : _inner = inner,
        _cacheService = cacheService,
        _db = db,
        _connectivity = connectivity;

  @override
  Future<List<Broadcast>> getBroadcasts({
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final broadcasts = await _inner.getBroadcasts(page: page, perPage: perPage);
      _backgroundCacheBroadcasts(broadcasts);
      _persistBroadcastsToDb(broadcasts);
      return broadcasts;
    } catch (e) {
      if (!_connectivity.isOnline) {
        return _loadBroadcastsFromDb();
      }
      rethrow;
    }
  }

  @override
  Future<Broadcast> getBroadcastById(int id) async {
    try {
      final broadcast = await _inner.getBroadcastById(id);
      _backgroundCacheBroadcast(broadcast);
      _persistBroadcastsToDb([broadcast]);
      return broadcast;
    } catch (e) {
      if (!_connectivity.isOnline) {
        final cached = await _db.getCachedBroadcastById(id);
        if (cached != null) return _toBroadcastEntity(cached);
      }
      rethrow;
    }
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
  Future<void> markAsListened(int broadcastId) async {
    _db.markBroadcastListened(broadcastId);
    return _inner.markAsListened(broadcastId);
  }

  @override
  Future<BroadcastLimits> getBroadcastLimits() {
    return _inner.getBroadcastLimits();
  }

  // ==================== Private helpers ====================

  void _backgroundCacheBroadcasts(List<Broadcast> broadcasts) {
    for (final broadcast in broadcasts) {
      _backgroundCacheBroadcast(broadcast);
    }
  }

  void _backgroundCacheBroadcast(Broadcast broadcast) {
    if (broadcast.audioUrl != null) {
      _cacheService.cacheAudio(
        sourceType: 'broadcast',
        sourceId: broadcast.id,
        remoteUrl: broadcast.audioUrl!,
        expiresAt: broadcast.expiredAt,
        durationSeconds: broadcast.duration,
      );
    }
  }

  void _persistBroadcastsToDb(List<Broadcast> broadcasts) {
    final now = DateTime.now();
    final entries = broadcasts.map((b) => CachedBroadcastsCompanion(
          id: Value(b.id),
          userId: Value(b.userId),
          senderNickname: Value(b.senderNickname),
          senderGender: Value(b.senderGender?.apiValue),
          content: Value(b.content),
          audioUrl: Value(b.audioUrl),
          duration: Value(b.duration),
          recipientCount: Value(b.recipientCount),
          replyCount: Value(b.replyCount),
          isExpired: Value(b.isExpired),
          isFavorite: Value(b.isFavorite),
          isRead: Value(b.isRead),
          isListened: Value(b.isListened),
          expiredAt: Value(b.expiredAt),
          createdAt: Value(b.createdAt),
          cachedAt: Value(now),
        )).toList();
    _db.upsertBroadcasts(entries);
  }

  Future<List<Broadcast>> _loadBroadcastsFromDb() async {
    final cached = await _db.getAllCachedBroadcasts();
    return cached.map(_toBroadcastEntity).toList();
  }

  Broadcast _toBroadcastEntity(CachedBroadcast c) {
    return Broadcast(
      id: c.id,
      userId: c.userId,
      senderNickname: c.senderNickname,
      senderGender: Gender.fromString(c.senderGender),
      content: c.content,
      audioUrl: c.audioUrl,
      duration: c.duration,
      recipientCount: c.recipientCount,
      replyCount: c.replyCount,
      isExpired: c.isExpired,
      isFavorite: c.isFavorite,
      isRead: c.isRead,
      isListened: c.isListened,
      expiredAt: c.expiredAt,
      createdAt: c.createdAt,
    );
  }
}
