import 'dart:io';

import 'package:dio/dio.dart';
import 'package:drift/drift.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:talk_flutter/data/database/app_database.dart';

/// Service for caching audio files locally with LRU eviction.
class AudioCacheService {
  final AppDatabase _db;
  final Dio _dio;
  final String _docsPath; // absolute path to app documents directory

  static const int maxCacheSizeBytes = 500 * 1024 * 1024; // 500MB
  final Set<String> _activeDownloads = {};

  AudioCacheService._(this._db, this._dio, this._docsPath);

  /// Factory constructor that initializes the cache directory.
  static Future<AudioCacheService> create(AppDatabase db, Dio dio) async {
    final docsDir = await getApplicationDocumentsDirectory();
    final cacheDir = Directory(p.join(docsDir.path, 'audio_cache'));
    await cacheDir.create(recursive: true);
    return AudioCacheService._(db, dio, docsDir.path);
  }

  /// Resolve audio path: returns local file path if cached, otherwise remote URL.
  Future<String> resolveAudioPath({
    required String sourceType,
    required int sourceId,
    required String remoteUrl,
  }) async {
    final entry = await _db.getCacheEntry(sourceType, sourceId);
    if (entry != null) {
      final localFile = File(p.join(_docsPath, entry.localPath));
      if (localFile.existsSync()) {
        // Touch for LRU tracking (fire-and-forget)
        _db.touchCacheEntry(sourceType, sourceId);
        return localFile.path;
      }
    }
    return remoteUrl;
  }

  /// Download and cache audio file. Safe for fire-and-forget usage.
  Future<void> cacheAudio({
    required String sourceType,
    required int sourceId,
    required String remoteUrl,
    DateTime? expiresAt,
    int? durationSeconds,
  }) async {
    final key = '$sourceType:$sourceId';

    // Skip if already downloading or already cached
    if (_activeDownloads.contains(key)) return;

    final existing = await _db.getCacheEntry(sourceType, sourceId);
    if (existing != null) {
      final localFile = File(p.join(_docsPath, existing.localPath));
      if (localFile.existsSync()) return;
    }

    _activeDownloads.add(key);

    final ext = _extractExtension(remoteUrl);
    final relativePath = 'audio_cache/${sourceType}_$sourceId$ext';
    final localFile = File(p.join(_docsPath, relativePath));

    try {
      await _dio.download(remoteUrl, localFile.path);

      final fileSize = await localFile.length();

      await _db.upsertCacheEntry(AudioCacheEntriesCompanion(
        sourceType: Value(sourceType),
        sourceId: Value(sourceId),
        remoteUrl: Value(remoteUrl),
        localPath: Value(relativePath),
        fileSize: Value(fileSize),
        durationSeconds: Value(durationSeconds),
        expiresAt: Value(expiresAt),
        cachedAt: Value(DateTime.now()),
        lastAccessedAt: Value(DateTime.now()),
      ));

      await _enforceStorageLimit();
    } catch (_) {
      // Clean up partial file on failure
      if (localFile.existsSync()) {
        try {
          await localFile.delete();
        } catch (_) {}
      }
    } finally {
      _activeDownloads.remove(key);
    }
  }

  /// Delete entries that have expired.
  Future<int> cleanupExpired() async {
    final expiredEntries = await _db.deleteExpiredEntries(DateTime.now());
    return expiredEntries;
  }

  /// LRU eviction when total cache exceeds maxCacheSizeBytes.
  Future<void> _enforceStorageLimit() async {
    var totalSize = await _db.getTotalCacheSize();
    if (totalSize <= maxCacheSizeBytes) return;

    // Target 80% of max to avoid frequent evictions
    final targetSize = (maxCacheSizeBytes * 0.8).toInt();
    final bytesToFree = totalSize - targetSize;

    // Get enough old entries in one query
    final oldEntries = await _db.getOldestEntries(50);
    if (oldEntries.isEmpty) return;

    int freedBytes = 0;
    final idsToDelete = <int>[];

    for (final entry in oldEntries) {
      if (freedBytes >= bytesToFree) break;

      final file = File(p.join(_docsPath, entry.localPath));
      if (file.existsSync()) {
        try {
          await file.delete();
        } catch (_) {}
      }
      idsToDelete.add(entry.id);
      freedBytes += entry.fileSize;
    }

    if (idsToDelete.isNotEmpty) {
      await _db.deleteEntriesByIds(idsToDelete);
    }
  }

  String _extractExtension(String url) {
    try {
      final uri = Uri.parse(url);
      final path = uri.path;
      final ext = p.extension(path);
      if (ext.isNotEmpty && ext.length <= 5) return ext;
    } catch (_) {}
    return '.m4a';
  }
}
