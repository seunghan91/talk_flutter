import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

/// Table for caching audio files locally
class AudioCacheEntries extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get sourceType => text()(); // 'broadcast' or 'message'
  IntColumn get sourceId => integer()();
  TextColumn get remoteUrl => text()();
  TextColumn get localPath => text()(); // relative path like audio_cache/broadcast_123.m4a
  IntColumn get fileSize => integer()();
  IntColumn get durationSeconds => integer().nullable()();
  DateTimeColumn get expiresAt => dateTime().nullable()();
  DateTimeColumn get cachedAt => dateTime()();
  DateTimeColumn get lastAccessedAt => dateTime().nullable()();

  @override
  List<Set<Column>> get uniqueKeys => [
        {sourceType, sourceId},
      ];
}

@DriftDatabase(tables: [AudioCacheEntries])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  /// Get cache entry by source type and ID
  Future<AudioCacheEntry?> getCacheEntry(
      String sourceType, int sourceId) async {
    return (select(audioCacheEntries)
          ..where(
              (t) => t.sourceType.equals(sourceType) & t.sourceId.equals(sourceId)))
        .getSingleOrNull();
  }

  /// Insert or update a cache entry (conflict on sourceType + sourceId unique key)
  Future<void> upsertCacheEntry(AudioCacheEntriesCompanion entry) async {
    await into(audioCacheEntries).insert(
      entry,
      onConflict: DoUpdate(
        (old) => entry,
        target: [audioCacheEntries.sourceType, audioCacheEntries.sourceId],
      ),
    );
  }

  /// Update lastAccessedAt timestamp
  Future<void> touchCacheEntry(String sourceType, int sourceId) async {
    (update(audioCacheEntries)
          ..where(
              (t) => t.sourceType.equals(sourceType) & t.sourceId.equals(sourceId)))
        .write(AudioCacheEntriesCompanion(
      lastAccessedAt: Value(DateTime.now()),
    ));
  }

  /// Delete entries that have expired before the given time
  Future<int> deleteExpiredEntries(DateTime before) async {
    return (delete(audioCacheEntries)
          ..where((t) =>
              t.expiresAt.isNotNull() & t.expiresAt.isSmallerThanValue(before)))
        .go();
  }

  /// Get oldest entries by lastAccessedAt (LRU), limited by count
  Future<List<AudioCacheEntry>> getOldestEntries(int limit) async {
    return (select(audioCacheEntries)
          ..orderBy([
            (t) => OrderingTerm(
                expression: coalesce([t.lastAccessedAt, t.cachedAt]),
                mode: OrderingMode.asc),
          ])
          ..limit(limit))
        .get();
  }

  /// Get total cache size in bytes
  Future<int> getTotalCacheSize() async {
    final result = await customSelect(
      'SELECT COALESCE(SUM(file_size), 0) AS total FROM audio_cache_entries',
    ).getSingle();
    return result.read<int>('total');
  }

  /// Batch delete cache entries by IDs
  Future<int> deleteEntriesByIds(List<int> ids) async {
    return (delete(audioCacheEntries)
          ..where((t) => t.id.isIn(ids)))
        .go();
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'talkk.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
