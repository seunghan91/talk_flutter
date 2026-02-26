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
  TextColumn get localPath => text()();
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

/// Offline cache for broadcasts metadata
class CachedBroadcasts extends Table {
  IntColumn get id => integer()();
  IntColumn get userId => integer()();
  TextColumn get senderNickname => text().nullable()();
  TextColumn get senderGender => text().nullable()();
  TextColumn get content => text().nullable()();
  TextColumn get audioUrl => text().nullable()();
  IntColumn get duration => integer().nullable()();
  IntColumn get recipientCount => integer().withDefault(const Constant(0))();
  IntColumn get replyCount => integer().withDefault(const Constant(0))();
  BoolColumn get isExpired => boolean().withDefault(const Constant(false))();
  BoolColumn get isFavorite => boolean().withDefault(const Constant(false))();
  BoolColumn get isRead => boolean().withDefault(const Constant(false))();
  BoolColumn get isListened => boolean().withDefault(const Constant(false))();
  DateTimeColumn get expiredAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get cachedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Offline cache for conversations metadata
class CachedConversations extends Table {
  IntColumn get id => integer()();
  IntColumn get partnerUserId => integer().nullable()();
  TextColumn get partnerNickname => text().nullable()();
  TextColumn get partnerGender => text().nullable()();
  TextColumn get partnerProfileImageUrl => text().nullable()();
  IntColumn get broadcastId => integer().nullable()();
  BoolColumn get isFavorite => boolean().withDefault(const Constant(false))();
  BoolColumn get hasUnreadMessages => boolean().withDefault(const Constant(false))();
  IntColumn get unreadCount => integer().withDefault(const Constant(0))();
  TextColumn get lastMessagePreview => text().nullable()();
  DateTimeColumn get lastMessageAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  DateTimeColumn get cachedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Offline cache for messages
class CachedMessages extends Table {
  IntColumn get id => integer()();
  IntColumn get conversationId => integer()();
  IntColumn get senderId => integer()();
  TextColumn get content => text().nullable()();
  TextColumn get voiceUrl => text().nullable()();
  IntColumn get duration => integer().nullable()();
  TextColumn get messageType => text().withDefault(const Constant('text'))();
  IntColumn get broadcastId => integer().nullable()();
  BoolColumn get isRead => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  DateTimeColumn get cachedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [
  AudioCacheEntries,
  CachedBroadcasts,
  CachedConversations,
  CachedMessages,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          await m.createAll();
        },
        onUpgrade: (Migrator m, int from, int to) async {
          if (from < 2) {
            await m.createTable(cachedBroadcasts);
            await m.createTable(cachedConversations);
            await m.createTable(cachedMessages);
          }
        },
      );

  // ==================== Audio Cache ====================

  Future<AudioCacheEntry?> getCacheEntry(
      String sourceType, int sourceId) async {
    return (select(audioCacheEntries)
          ..where(
              (t) => t.sourceType.equals(sourceType) & t.sourceId.equals(sourceId)))
        .getSingleOrNull();
  }

  Future<void> upsertCacheEntry(AudioCacheEntriesCompanion entry) async {
    await into(audioCacheEntries).insert(
      entry,
      onConflict: DoUpdate(
        (old) => entry,
        target: [audioCacheEntries.sourceType, audioCacheEntries.sourceId],
      ),
    );
  }

  Future<void> touchCacheEntry(String sourceType, int sourceId) async {
    (update(audioCacheEntries)
          ..where(
              (t) => t.sourceType.equals(sourceType) & t.sourceId.equals(sourceId)))
        .write(AudioCacheEntriesCompanion(
      lastAccessedAt: Value(DateTime.now()),
    ));
  }

  Future<int> deleteExpiredEntries(DateTime before) async {
    return (delete(audioCacheEntries)
          ..where((t) =>
              t.expiresAt.isNotNull() & t.expiresAt.isSmallerThanValue(before)))
        .go();
  }

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

  Future<int> getTotalCacheSize() async {
    final result = await customSelect(
      'SELECT COALESCE(SUM(file_size), 0) AS total FROM audio_cache_entries',
    ).getSingle();
    return result.read<int>('total');
  }

  Future<int> deleteEntriesByIds(List<int> ids) async {
    return (delete(audioCacheEntries)..where((t) => t.id.isIn(ids))).go();
  }

  // ==================== Cached Broadcasts ====================

  Future<List<CachedBroadcast>> getAllCachedBroadcasts() async {
    return (select(cachedBroadcasts)
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .get();
  }

  Future<CachedBroadcast?> getCachedBroadcastById(int id) async {
    return (select(cachedBroadcasts)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  Future<void> upsertBroadcasts(List<CachedBroadcastsCompanion> entries) async {
    await batch((b) {
      for (final entry in entries) {
        b.insert(cachedBroadcasts, entry, mode: InsertMode.insertOrReplace);
      }
    });
  }

  Future<void> markBroadcastListened(int id) async {
    (update(cachedBroadcasts)..where((t) => t.id.equals(id)))
        .write(const CachedBroadcastsCompanion(isListened: Value(true)));
  }

  Future<int> deleteOldBroadcasts(DateTime olderThan) async {
    return (delete(cachedBroadcasts)
          ..where((t) => t.cachedAt.isSmallerThanValue(olderThan)))
        .go();
  }

  // ==================== Cached Conversations ====================

  Future<List<CachedConversation>> getAllCachedConversations() async {
    return (select(cachedConversations)
          ..orderBy([
            (t) => OrderingTerm.desc(
                coalesce([t.lastMessageAt, t.createdAt])),
          ]))
        .get();
  }

  Future<CachedConversation?> getCachedConversationById(int id) async {
    return (select(cachedConversations)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  Future<void> upsertConversations(
      List<CachedConversationsCompanion> entries) async {
    await batch((b) {
      for (final entry in entries) {
        b.insert(cachedConversations, entry, mode: InsertMode.insertOrReplace);
      }
    });
  }

  Future<void> deleteCachedConversation(int id) async {
    await (delete(cachedConversations)..where((t) => t.id.equals(id))).go();
    await (delete(cachedMessages)
          ..where((t) => t.conversationId.equals(id)))
        .go();
  }

  Future<void> updateConversationFavorite(int id, bool isFav) async {
    (update(cachedConversations)..where((t) => t.id.equals(id)))
        .write(CachedConversationsCompanion(isFavorite: Value(isFav)));
  }

  Future<void> markConversationRead(int id) async {
    (update(cachedConversations)..where((t) => t.id.equals(id))).write(
      const CachedConversationsCompanion(
        hasUnreadMessages: Value(false),
        unreadCount: Value(0),
      ),
    );
  }

  // ==================== Cached Messages ====================

  Future<List<CachedMessage>> getCachedMessages(int conversationId) async {
    return (select(cachedMessages)
          ..where((t) => t.conversationId.equals(conversationId))
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .get();
  }

  Future<void> upsertMessages(List<CachedMessagesCompanion> entries) async {
    await batch((b) {
      for (final entry in entries) {
        b.insert(cachedMessages, entry, mode: InsertMode.insertOrReplace);
      }
    });
  }

  Future<int> deleteOldMessages(DateTime olderThan) async {
    return (delete(cachedMessages)
          ..where((t) => t.cachedAt.isSmallerThanValue(olderThan)))
        .go();
  }

  // ==================== Cleanup ====================

  Future<void> clearAllCaches() async {
    await delete(cachedBroadcasts).go();
    await delete(cachedConversations).go();
    await delete(cachedMessages).go();
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'talkk.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
