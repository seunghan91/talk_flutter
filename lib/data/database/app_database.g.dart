// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $AudioCacheEntriesTable extends AudioCacheEntries
    with TableInfo<$AudioCacheEntriesTable, AudioCacheEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AudioCacheEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _sourceTypeMeta = const VerificationMeta(
    'sourceType',
  );
  @override
  late final GeneratedColumn<String> sourceType = GeneratedColumn<String>(
    'source_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceIdMeta = const VerificationMeta(
    'sourceId',
  );
  @override
  late final GeneratedColumn<int> sourceId = GeneratedColumn<int>(
    'source_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _remoteUrlMeta = const VerificationMeta(
    'remoteUrl',
  );
  @override
  late final GeneratedColumn<String> remoteUrl = GeneratedColumn<String>(
    'remote_url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _localPathMeta = const VerificationMeta(
    'localPath',
  );
  @override
  late final GeneratedColumn<String> localPath = GeneratedColumn<String>(
    'local_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fileSizeMeta = const VerificationMeta(
    'fileSize',
  );
  @override
  late final GeneratedColumn<int> fileSize = GeneratedColumn<int>(
    'file_size',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _durationSecondsMeta = const VerificationMeta(
    'durationSeconds',
  );
  @override
  late final GeneratedColumn<int> durationSeconds = GeneratedColumn<int>(
    'duration_seconds',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _expiresAtMeta = const VerificationMeta(
    'expiresAt',
  );
  @override
  late final GeneratedColumn<DateTime> expiresAt = GeneratedColumn<DateTime>(
    'expires_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cachedAtMeta = const VerificationMeta(
    'cachedAt',
  );
  @override
  late final GeneratedColumn<DateTime> cachedAt = GeneratedColumn<DateTime>(
    'cached_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastAccessedAtMeta = const VerificationMeta(
    'lastAccessedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastAccessedAt =
      GeneratedColumn<DateTime>(
        'last_accessed_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sourceType,
    sourceId,
    remoteUrl,
    localPath,
    fileSize,
    durationSeconds,
    expiresAt,
    cachedAt,
    lastAccessedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'audio_cache_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<AudioCacheEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('source_type')) {
      context.handle(
        _sourceTypeMeta,
        sourceType.isAcceptableOrUnknown(data['source_type']!, _sourceTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceTypeMeta);
    }
    if (data.containsKey('source_id')) {
      context.handle(
        _sourceIdMeta,
        sourceId.isAcceptableOrUnknown(data['source_id']!, _sourceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceIdMeta);
    }
    if (data.containsKey('remote_url')) {
      context.handle(
        _remoteUrlMeta,
        remoteUrl.isAcceptableOrUnknown(data['remote_url']!, _remoteUrlMeta),
      );
    } else if (isInserting) {
      context.missing(_remoteUrlMeta);
    }
    if (data.containsKey('local_path')) {
      context.handle(
        _localPathMeta,
        localPath.isAcceptableOrUnknown(data['local_path']!, _localPathMeta),
      );
    } else if (isInserting) {
      context.missing(_localPathMeta);
    }
    if (data.containsKey('file_size')) {
      context.handle(
        _fileSizeMeta,
        fileSize.isAcceptableOrUnknown(data['file_size']!, _fileSizeMeta),
      );
    } else if (isInserting) {
      context.missing(_fileSizeMeta);
    }
    if (data.containsKey('duration_seconds')) {
      context.handle(
        _durationSecondsMeta,
        durationSeconds.isAcceptableOrUnknown(
          data['duration_seconds']!,
          _durationSecondsMeta,
        ),
      );
    }
    if (data.containsKey('expires_at')) {
      context.handle(
        _expiresAtMeta,
        expiresAt.isAcceptableOrUnknown(data['expires_at']!, _expiresAtMeta),
      );
    }
    if (data.containsKey('cached_at')) {
      context.handle(
        _cachedAtMeta,
        cachedAt.isAcceptableOrUnknown(data['cached_at']!, _cachedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_cachedAtMeta);
    }
    if (data.containsKey('last_accessed_at')) {
      context.handle(
        _lastAccessedAtMeta,
        lastAccessedAt.isAcceptableOrUnknown(
          data['last_accessed_at']!,
          _lastAccessedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {sourceType, sourceId},
  ];
  @override
  AudioCacheEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AudioCacheEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      sourceType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_type'],
      )!,
      sourceId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}source_id'],
      )!,
      remoteUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}remote_url'],
      )!,
      localPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_path'],
      )!,
      fileSize: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}file_size'],
      )!,
      durationSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_seconds'],
      ),
      expiresAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}expires_at'],
      ),
      cachedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}cached_at'],
      )!,
      lastAccessedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_accessed_at'],
      ),
    );
  }

  @override
  $AudioCacheEntriesTable createAlias(String alias) {
    return $AudioCacheEntriesTable(attachedDatabase, alias);
  }
}

class AudioCacheEntry extends DataClass implements Insertable<AudioCacheEntry> {
  final int id;
  final String sourceType;
  final int sourceId;
  final String remoteUrl;
  final String localPath;
  final int fileSize;
  final int? durationSeconds;
  final DateTime? expiresAt;
  final DateTime cachedAt;
  final DateTime? lastAccessedAt;
  const AudioCacheEntry({
    required this.id,
    required this.sourceType,
    required this.sourceId,
    required this.remoteUrl,
    required this.localPath,
    required this.fileSize,
    this.durationSeconds,
    this.expiresAt,
    required this.cachedAt,
    this.lastAccessedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['source_type'] = Variable<String>(sourceType);
    map['source_id'] = Variable<int>(sourceId);
    map['remote_url'] = Variable<String>(remoteUrl);
    map['local_path'] = Variable<String>(localPath);
    map['file_size'] = Variable<int>(fileSize);
    if (!nullToAbsent || durationSeconds != null) {
      map['duration_seconds'] = Variable<int>(durationSeconds);
    }
    if (!nullToAbsent || expiresAt != null) {
      map['expires_at'] = Variable<DateTime>(expiresAt);
    }
    map['cached_at'] = Variable<DateTime>(cachedAt);
    if (!nullToAbsent || lastAccessedAt != null) {
      map['last_accessed_at'] = Variable<DateTime>(lastAccessedAt);
    }
    return map;
  }

  AudioCacheEntriesCompanion toCompanion(bool nullToAbsent) {
    return AudioCacheEntriesCompanion(
      id: Value(id),
      sourceType: Value(sourceType),
      sourceId: Value(sourceId),
      remoteUrl: Value(remoteUrl),
      localPath: Value(localPath),
      fileSize: Value(fileSize),
      durationSeconds: durationSeconds == null && nullToAbsent
          ? const Value.absent()
          : Value(durationSeconds),
      expiresAt: expiresAt == null && nullToAbsent
          ? const Value.absent()
          : Value(expiresAt),
      cachedAt: Value(cachedAt),
      lastAccessedAt: lastAccessedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastAccessedAt),
    );
  }

  factory AudioCacheEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AudioCacheEntry(
      id: serializer.fromJson<int>(json['id']),
      sourceType: serializer.fromJson<String>(json['sourceType']),
      sourceId: serializer.fromJson<int>(json['sourceId']),
      remoteUrl: serializer.fromJson<String>(json['remoteUrl']),
      localPath: serializer.fromJson<String>(json['localPath']),
      fileSize: serializer.fromJson<int>(json['fileSize']),
      durationSeconds: serializer.fromJson<int?>(json['durationSeconds']),
      expiresAt: serializer.fromJson<DateTime?>(json['expiresAt']),
      cachedAt: serializer.fromJson<DateTime>(json['cachedAt']),
      lastAccessedAt: serializer.fromJson<DateTime?>(json['lastAccessedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'sourceType': serializer.toJson<String>(sourceType),
      'sourceId': serializer.toJson<int>(sourceId),
      'remoteUrl': serializer.toJson<String>(remoteUrl),
      'localPath': serializer.toJson<String>(localPath),
      'fileSize': serializer.toJson<int>(fileSize),
      'durationSeconds': serializer.toJson<int?>(durationSeconds),
      'expiresAt': serializer.toJson<DateTime?>(expiresAt),
      'cachedAt': serializer.toJson<DateTime>(cachedAt),
      'lastAccessedAt': serializer.toJson<DateTime?>(lastAccessedAt),
    };
  }

  AudioCacheEntry copyWith({
    int? id,
    String? sourceType,
    int? sourceId,
    String? remoteUrl,
    String? localPath,
    int? fileSize,
    Value<int?> durationSeconds = const Value.absent(),
    Value<DateTime?> expiresAt = const Value.absent(),
    DateTime? cachedAt,
    Value<DateTime?> lastAccessedAt = const Value.absent(),
  }) => AudioCacheEntry(
    id: id ?? this.id,
    sourceType: sourceType ?? this.sourceType,
    sourceId: sourceId ?? this.sourceId,
    remoteUrl: remoteUrl ?? this.remoteUrl,
    localPath: localPath ?? this.localPath,
    fileSize: fileSize ?? this.fileSize,
    durationSeconds: durationSeconds.present
        ? durationSeconds.value
        : this.durationSeconds,
    expiresAt: expiresAt.present ? expiresAt.value : this.expiresAt,
    cachedAt: cachedAt ?? this.cachedAt,
    lastAccessedAt: lastAccessedAt.present
        ? lastAccessedAt.value
        : this.lastAccessedAt,
  );
  AudioCacheEntry copyWithCompanion(AudioCacheEntriesCompanion data) {
    return AudioCacheEntry(
      id: data.id.present ? data.id.value : this.id,
      sourceType: data.sourceType.present
          ? data.sourceType.value
          : this.sourceType,
      sourceId: data.sourceId.present ? data.sourceId.value : this.sourceId,
      remoteUrl: data.remoteUrl.present ? data.remoteUrl.value : this.remoteUrl,
      localPath: data.localPath.present ? data.localPath.value : this.localPath,
      fileSize: data.fileSize.present ? data.fileSize.value : this.fileSize,
      durationSeconds: data.durationSeconds.present
          ? data.durationSeconds.value
          : this.durationSeconds,
      expiresAt: data.expiresAt.present ? data.expiresAt.value : this.expiresAt,
      cachedAt: data.cachedAt.present ? data.cachedAt.value : this.cachedAt,
      lastAccessedAt: data.lastAccessedAt.present
          ? data.lastAccessedAt.value
          : this.lastAccessedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AudioCacheEntry(')
          ..write('id: $id, ')
          ..write('sourceType: $sourceType, ')
          ..write('sourceId: $sourceId, ')
          ..write('remoteUrl: $remoteUrl, ')
          ..write('localPath: $localPath, ')
          ..write('fileSize: $fileSize, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('expiresAt: $expiresAt, ')
          ..write('cachedAt: $cachedAt, ')
          ..write('lastAccessedAt: $lastAccessedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    sourceType,
    sourceId,
    remoteUrl,
    localPath,
    fileSize,
    durationSeconds,
    expiresAt,
    cachedAt,
    lastAccessedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AudioCacheEntry &&
          other.id == this.id &&
          other.sourceType == this.sourceType &&
          other.sourceId == this.sourceId &&
          other.remoteUrl == this.remoteUrl &&
          other.localPath == this.localPath &&
          other.fileSize == this.fileSize &&
          other.durationSeconds == this.durationSeconds &&
          other.expiresAt == this.expiresAt &&
          other.cachedAt == this.cachedAt &&
          other.lastAccessedAt == this.lastAccessedAt);
}

class AudioCacheEntriesCompanion extends UpdateCompanion<AudioCacheEntry> {
  final Value<int> id;
  final Value<String> sourceType;
  final Value<int> sourceId;
  final Value<String> remoteUrl;
  final Value<String> localPath;
  final Value<int> fileSize;
  final Value<int?> durationSeconds;
  final Value<DateTime?> expiresAt;
  final Value<DateTime> cachedAt;
  final Value<DateTime?> lastAccessedAt;
  const AudioCacheEntriesCompanion({
    this.id = const Value.absent(),
    this.sourceType = const Value.absent(),
    this.sourceId = const Value.absent(),
    this.remoteUrl = const Value.absent(),
    this.localPath = const Value.absent(),
    this.fileSize = const Value.absent(),
    this.durationSeconds = const Value.absent(),
    this.expiresAt = const Value.absent(),
    this.cachedAt = const Value.absent(),
    this.lastAccessedAt = const Value.absent(),
  });
  AudioCacheEntriesCompanion.insert({
    this.id = const Value.absent(),
    required String sourceType,
    required int sourceId,
    required String remoteUrl,
    required String localPath,
    required int fileSize,
    this.durationSeconds = const Value.absent(),
    this.expiresAt = const Value.absent(),
    required DateTime cachedAt,
    this.lastAccessedAt = const Value.absent(),
  }) : sourceType = Value(sourceType),
       sourceId = Value(sourceId),
       remoteUrl = Value(remoteUrl),
       localPath = Value(localPath),
       fileSize = Value(fileSize),
       cachedAt = Value(cachedAt);
  static Insertable<AudioCacheEntry> custom({
    Expression<int>? id,
    Expression<String>? sourceType,
    Expression<int>? sourceId,
    Expression<String>? remoteUrl,
    Expression<String>? localPath,
    Expression<int>? fileSize,
    Expression<int>? durationSeconds,
    Expression<DateTime>? expiresAt,
    Expression<DateTime>? cachedAt,
    Expression<DateTime>? lastAccessedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sourceType != null) 'source_type': sourceType,
      if (sourceId != null) 'source_id': sourceId,
      if (remoteUrl != null) 'remote_url': remoteUrl,
      if (localPath != null) 'local_path': localPath,
      if (fileSize != null) 'file_size': fileSize,
      if (durationSeconds != null) 'duration_seconds': durationSeconds,
      if (expiresAt != null) 'expires_at': expiresAt,
      if (cachedAt != null) 'cached_at': cachedAt,
      if (lastAccessedAt != null) 'last_accessed_at': lastAccessedAt,
    });
  }

  AudioCacheEntriesCompanion copyWith({
    Value<int>? id,
    Value<String>? sourceType,
    Value<int>? sourceId,
    Value<String>? remoteUrl,
    Value<String>? localPath,
    Value<int>? fileSize,
    Value<int?>? durationSeconds,
    Value<DateTime?>? expiresAt,
    Value<DateTime>? cachedAt,
    Value<DateTime?>? lastAccessedAt,
  }) {
    return AudioCacheEntriesCompanion(
      id: id ?? this.id,
      sourceType: sourceType ?? this.sourceType,
      sourceId: sourceId ?? this.sourceId,
      remoteUrl: remoteUrl ?? this.remoteUrl,
      localPath: localPath ?? this.localPath,
      fileSize: fileSize ?? this.fileSize,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      expiresAt: expiresAt ?? this.expiresAt,
      cachedAt: cachedAt ?? this.cachedAt,
      lastAccessedAt: lastAccessedAt ?? this.lastAccessedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (sourceType.present) {
      map['source_type'] = Variable<String>(sourceType.value);
    }
    if (sourceId.present) {
      map['source_id'] = Variable<int>(sourceId.value);
    }
    if (remoteUrl.present) {
      map['remote_url'] = Variable<String>(remoteUrl.value);
    }
    if (localPath.present) {
      map['local_path'] = Variable<String>(localPath.value);
    }
    if (fileSize.present) {
      map['file_size'] = Variable<int>(fileSize.value);
    }
    if (durationSeconds.present) {
      map['duration_seconds'] = Variable<int>(durationSeconds.value);
    }
    if (expiresAt.present) {
      map['expires_at'] = Variable<DateTime>(expiresAt.value);
    }
    if (cachedAt.present) {
      map['cached_at'] = Variable<DateTime>(cachedAt.value);
    }
    if (lastAccessedAt.present) {
      map['last_accessed_at'] = Variable<DateTime>(lastAccessedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AudioCacheEntriesCompanion(')
          ..write('id: $id, ')
          ..write('sourceType: $sourceType, ')
          ..write('sourceId: $sourceId, ')
          ..write('remoteUrl: $remoteUrl, ')
          ..write('localPath: $localPath, ')
          ..write('fileSize: $fileSize, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('expiresAt: $expiresAt, ')
          ..write('cachedAt: $cachedAt, ')
          ..write('lastAccessedAt: $lastAccessedAt')
          ..write(')'))
        .toString();
  }
}

class $CachedBroadcastsTable extends CachedBroadcasts
    with TableInfo<$CachedBroadcastsTable, CachedBroadcast> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedBroadcastsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<int> userId = GeneratedColumn<int>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _senderNicknameMeta = const VerificationMeta(
    'senderNickname',
  );
  @override
  late final GeneratedColumn<String> senderNickname = GeneratedColumn<String>(
    'sender_nickname',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _senderGenderMeta = const VerificationMeta(
    'senderGender',
  );
  @override
  late final GeneratedColumn<String> senderGender = GeneratedColumn<String>(
    'sender_gender',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _audioUrlMeta = const VerificationMeta(
    'audioUrl',
  );
  @override
  late final GeneratedColumn<String> audioUrl = GeneratedColumn<String>(
    'audio_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _durationMeta = const VerificationMeta(
    'duration',
  );
  @override
  late final GeneratedColumn<int> duration = GeneratedColumn<int>(
    'duration',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _recipientCountMeta = const VerificationMeta(
    'recipientCount',
  );
  @override
  late final GeneratedColumn<int> recipientCount = GeneratedColumn<int>(
    'recipient_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _replyCountMeta = const VerificationMeta(
    'replyCount',
  );
  @override
  late final GeneratedColumn<int> replyCount = GeneratedColumn<int>(
    'reply_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _isExpiredMeta = const VerificationMeta(
    'isExpired',
  );
  @override
  late final GeneratedColumn<bool> isExpired = GeneratedColumn<bool>(
    'is_expired',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_expired" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isFavoriteMeta = const VerificationMeta(
    'isFavorite',
  );
  @override
  late final GeneratedColumn<bool> isFavorite = GeneratedColumn<bool>(
    'is_favorite',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_favorite" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isReadMeta = const VerificationMeta('isRead');
  @override
  late final GeneratedColumn<bool> isRead = GeneratedColumn<bool>(
    'is_read',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_read" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isListenedMeta = const VerificationMeta(
    'isListened',
  );
  @override
  late final GeneratedColumn<bool> isListened = GeneratedColumn<bool>(
    'is_listened',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_listened" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _expiredAtMeta = const VerificationMeta(
    'expiredAt',
  );
  @override
  late final GeneratedColumn<DateTime> expiredAt = GeneratedColumn<DateTime>(
    'expired_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cachedAtMeta = const VerificationMeta(
    'cachedAt',
  );
  @override
  late final GeneratedColumn<DateTime> cachedAt = GeneratedColumn<DateTime>(
    'cached_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    senderNickname,
    senderGender,
    content,
    audioUrl,
    duration,
    recipientCount,
    replyCount,
    isExpired,
    isFavorite,
    isRead,
    isListened,
    expiredAt,
    createdAt,
    cachedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_broadcasts';
  @override
  VerificationContext validateIntegrity(
    Insertable<CachedBroadcast> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('sender_nickname')) {
      context.handle(
        _senderNicknameMeta,
        senderNickname.isAcceptableOrUnknown(
          data['sender_nickname']!,
          _senderNicknameMeta,
        ),
      );
    }
    if (data.containsKey('sender_gender')) {
      context.handle(
        _senderGenderMeta,
        senderGender.isAcceptableOrUnknown(
          data['sender_gender']!,
          _senderGenderMeta,
        ),
      );
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    }
    if (data.containsKey('audio_url')) {
      context.handle(
        _audioUrlMeta,
        audioUrl.isAcceptableOrUnknown(data['audio_url']!, _audioUrlMeta),
      );
    }
    if (data.containsKey('duration')) {
      context.handle(
        _durationMeta,
        duration.isAcceptableOrUnknown(data['duration']!, _durationMeta),
      );
    }
    if (data.containsKey('recipient_count')) {
      context.handle(
        _recipientCountMeta,
        recipientCount.isAcceptableOrUnknown(
          data['recipient_count']!,
          _recipientCountMeta,
        ),
      );
    }
    if (data.containsKey('reply_count')) {
      context.handle(
        _replyCountMeta,
        replyCount.isAcceptableOrUnknown(data['reply_count']!, _replyCountMeta),
      );
    }
    if (data.containsKey('is_expired')) {
      context.handle(
        _isExpiredMeta,
        isExpired.isAcceptableOrUnknown(data['is_expired']!, _isExpiredMeta),
      );
    }
    if (data.containsKey('is_favorite')) {
      context.handle(
        _isFavoriteMeta,
        isFavorite.isAcceptableOrUnknown(data['is_favorite']!, _isFavoriteMeta),
      );
    }
    if (data.containsKey('is_read')) {
      context.handle(
        _isReadMeta,
        isRead.isAcceptableOrUnknown(data['is_read']!, _isReadMeta),
      );
    }
    if (data.containsKey('is_listened')) {
      context.handle(
        _isListenedMeta,
        isListened.isAcceptableOrUnknown(data['is_listened']!, _isListenedMeta),
      );
    }
    if (data.containsKey('expired_at')) {
      context.handle(
        _expiredAtMeta,
        expiredAt.isAcceptableOrUnknown(data['expired_at']!, _expiredAtMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('cached_at')) {
      context.handle(
        _cachedAtMeta,
        cachedAt.isAcceptableOrUnknown(data['cached_at']!, _cachedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_cachedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CachedBroadcast map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedBroadcast(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}user_id'],
      )!,
      senderNickname: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sender_nickname'],
      ),
      senderGender: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sender_gender'],
      ),
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content'],
      ),
      audioUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}audio_url'],
      ),
      duration: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration'],
      ),
      recipientCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}recipient_count'],
      )!,
      replyCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reply_count'],
      )!,
      isExpired: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_expired'],
      )!,
      isFavorite: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_favorite'],
      )!,
      isRead: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_read'],
      )!,
      isListened: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_listened'],
      )!,
      expiredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}expired_at'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      cachedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}cached_at'],
      )!,
    );
  }

  @override
  $CachedBroadcastsTable createAlias(String alias) {
    return $CachedBroadcastsTable(attachedDatabase, alias);
  }
}

class CachedBroadcast extends DataClass implements Insertable<CachedBroadcast> {
  final int id;
  final int userId;
  final String? senderNickname;
  final String? senderGender;
  final String? content;
  final String? audioUrl;
  final int? duration;
  final int recipientCount;
  final int replyCount;
  final bool isExpired;
  final bool isFavorite;
  final bool isRead;
  final bool isListened;
  final DateTime? expiredAt;
  final DateTime createdAt;
  final DateTime cachedAt;
  const CachedBroadcast({
    required this.id,
    required this.userId,
    this.senderNickname,
    this.senderGender,
    this.content,
    this.audioUrl,
    this.duration,
    required this.recipientCount,
    required this.replyCount,
    required this.isExpired,
    required this.isFavorite,
    required this.isRead,
    required this.isListened,
    this.expiredAt,
    required this.createdAt,
    required this.cachedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['user_id'] = Variable<int>(userId);
    if (!nullToAbsent || senderNickname != null) {
      map['sender_nickname'] = Variable<String>(senderNickname);
    }
    if (!nullToAbsent || senderGender != null) {
      map['sender_gender'] = Variable<String>(senderGender);
    }
    if (!nullToAbsent || content != null) {
      map['content'] = Variable<String>(content);
    }
    if (!nullToAbsent || audioUrl != null) {
      map['audio_url'] = Variable<String>(audioUrl);
    }
    if (!nullToAbsent || duration != null) {
      map['duration'] = Variable<int>(duration);
    }
    map['recipient_count'] = Variable<int>(recipientCount);
    map['reply_count'] = Variable<int>(replyCount);
    map['is_expired'] = Variable<bool>(isExpired);
    map['is_favorite'] = Variable<bool>(isFavorite);
    map['is_read'] = Variable<bool>(isRead);
    map['is_listened'] = Variable<bool>(isListened);
    if (!nullToAbsent || expiredAt != null) {
      map['expired_at'] = Variable<DateTime>(expiredAt);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['cached_at'] = Variable<DateTime>(cachedAt);
    return map;
  }

  CachedBroadcastsCompanion toCompanion(bool nullToAbsent) {
    return CachedBroadcastsCompanion(
      id: Value(id),
      userId: Value(userId),
      senderNickname: senderNickname == null && nullToAbsent
          ? const Value.absent()
          : Value(senderNickname),
      senderGender: senderGender == null && nullToAbsent
          ? const Value.absent()
          : Value(senderGender),
      content: content == null && nullToAbsent
          ? const Value.absent()
          : Value(content),
      audioUrl: audioUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(audioUrl),
      duration: duration == null && nullToAbsent
          ? const Value.absent()
          : Value(duration),
      recipientCount: Value(recipientCount),
      replyCount: Value(replyCount),
      isExpired: Value(isExpired),
      isFavorite: Value(isFavorite),
      isRead: Value(isRead),
      isListened: Value(isListened),
      expiredAt: expiredAt == null && nullToAbsent
          ? const Value.absent()
          : Value(expiredAt),
      createdAt: Value(createdAt),
      cachedAt: Value(cachedAt),
    );
  }

  factory CachedBroadcast.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedBroadcast(
      id: serializer.fromJson<int>(json['id']),
      userId: serializer.fromJson<int>(json['userId']),
      senderNickname: serializer.fromJson<String?>(json['senderNickname']),
      senderGender: serializer.fromJson<String?>(json['senderGender']),
      content: serializer.fromJson<String?>(json['content']),
      audioUrl: serializer.fromJson<String?>(json['audioUrl']),
      duration: serializer.fromJson<int?>(json['duration']),
      recipientCount: serializer.fromJson<int>(json['recipientCount']),
      replyCount: serializer.fromJson<int>(json['replyCount']),
      isExpired: serializer.fromJson<bool>(json['isExpired']),
      isFavorite: serializer.fromJson<bool>(json['isFavorite']),
      isRead: serializer.fromJson<bool>(json['isRead']),
      isListened: serializer.fromJson<bool>(json['isListened']),
      expiredAt: serializer.fromJson<DateTime?>(json['expiredAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      cachedAt: serializer.fromJson<DateTime>(json['cachedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'userId': serializer.toJson<int>(userId),
      'senderNickname': serializer.toJson<String?>(senderNickname),
      'senderGender': serializer.toJson<String?>(senderGender),
      'content': serializer.toJson<String?>(content),
      'audioUrl': serializer.toJson<String?>(audioUrl),
      'duration': serializer.toJson<int?>(duration),
      'recipientCount': serializer.toJson<int>(recipientCount),
      'replyCount': serializer.toJson<int>(replyCount),
      'isExpired': serializer.toJson<bool>(isExpired),
      'isFavorite': serializer.toJson<bool>(isFavorite),
      'isRead': serializer.toJson<bool>(isRead),
      'isListened': serializer.toJson<bool>(isListened),
      'expiredAt': serializer.toJson<DateTime?>(expiredAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'cachedAt': serializer.toJson<DateTime>(cachedAt),
    };
  }

  CachedBroadcast copyWith({
    int? id,
    int? userId,
    Value<String?> senderNickname = const Value.absent(),
    Value<String?> senderGender = const Value.absent(),
    Value<String?> content = const Value.absent(),
    Value<String?> audioUrl = const Value.absent(),
    Value<int?> duration = const Value.absent(),
    int? recipientCount,
    int? replyCount,
    bool? isExpired,
    bool? isFavorite,
    bool? isRead,
    bool? isListened,
    Value<DateTime?> expiredAt = const Value.absent(),
    DateTime? createdAt,
    DateTime? cachedAt,
  }) => CachedBroadcast(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    senderNickname: senderNickname.present
        ? senderNickname.value
        : this.senderNickname,
    senderGender: senderGender.present ? senderGender.value : this.senderGender,
    content: content.present ? content.value : this.content,
    audioUrl: audioUrl.present ? audioUrl.value : this.audioUrl,
    duration: duration.present ? duration.value : this.duration,
    recipientCount: recipientCount ?? this.recipientCount,
    replyCount: replyCount ?? this.replyCount,
    isExpired: isExpired ?? this.isExpired,
    isFavorite: isFavorite ?? this.isFavorite,
    isRead: isRead ?? this.isRead,
    isListened: isListened ?? this.isListened,
    expiredAt: expiredAt.present ? expiredAt.value : this.expiredAt,
    createdAt: createdAt ?? this.createdAt,
    cachedAt: cachedAt ?? this.cachedAt,
  );
  CachedBroadcast copyWithCompanion(CachedBroadcastsCompanion data) {
    return CachedBroadcast(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      senderNickname: data.senderNickname.present
          ? data.senderNickname.value
          : this.senderNickname,
      senderGender: data.senderGender.present
          ? data.senderGender.value
          : this.senderGender,
      content: data.content.present ? data.content.value : this.content,
      audioUrl: data.audioUrl.present ? data.audioUrl.value : this.audioUrl,
      duration: data.duration.present ? data.duration.value : this.duration,
      recipientCount: data.recipientCount.present
          ? data.recipientCount.value
          : this.recipientCount,
      replyCount: data.replyCount.present
          ? data.replyCount.value
          : this.replyCount,
      isExpired: data.isExpired.present ? data.isExpired.value : this.isExpired,
      isFavorite: data.isFavorite.present
          ? data.isFavorite.value
          : this.isFavorite,
      isRead: data.isRead.present ? data.isRead.value : this.isRead,
      isListened: data.isListened.present
          ? data.isListened.value
          : this.isListened,
      expiredAt: data.expiredAt.present ? data.expiredAt.value : this.expiredAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      cachedAt: data.cachedAt.present ? data.cachedAt.value : this.cachedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedBroadcast(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('senderNickname: $senderNickname, ')
          ..write('senderGender: $senderGender, ')
          ..write('content: $content, ')
          ..write('audioUrl: $audioUrl, ')
          ..write('duration: $duration, ')
          ..write('recipientCount: $recipientCount, ')
          ..write('replyCount: $replyCount, ')
          ..write('isExpired: $isExpired, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('isRead: $isRead, ')
          ..write('isListened: $isListened, ')
          ..write('expiredAt: $expiredAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('cachedAt: $cachedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    senderNickname,
    senderGender,
    content,
    audioUrl,
    duration,
    recipientCount,
    replyCount,
    isExpired,
    isFavorite,
    isRead,
    isListened,
    expiredAt,
    createdAt,
    cachedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedBroadcast &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.senderNickname == this.senderNickname &&
          other.senderGender == this.senderGender &&
          other.content == this.content &&
          other.audioUrl == this.audioUrl &&
          other.duration == this.duration &&
          other.recipientCount == this.recipientCount &&
          other.replyCount == this.replyCount &&
          other.isExpired == this.isExpired &&
          other.isFavorite == this.isFavorite &&
          other.isRead == this.isRead &&
          other.isListened == this.isListened &&
          other.expiredAt == this.expiredAt &&
          other.createdAt == this.createdAt &&
          other.cachedAt == this.cachedAt);
}

class CachedBroadcastsCompanion extends UpdateCompanion<CachedBroadcast> {
  final Value<int> id;
  final Value<int> userId;
  final Value<String?> senderNickname;
  final Value<String?> senderGender;
  final Value<String?> content;
  final Value<String?> audioUrl;
  final Value<int?> duration;
  final Value<int> recipientCount;
  final Value<int> replyCount;
  final Value<bool> isExpired;
  final Value<bool> isFavorite;
  final Value<bool> isRead;
  final Value<bool> isListened;
  final Value<DateTime?> expiredAt;
  final Value<DateTime> createdAt;
  final Value<DateTime> cachedAt;
  const CachedBroadcastsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.senderNickname = const Value.absent(),
    this.senderGender = const Value.absent(),
    this.content = const Value.absent(),
    this.audioUrl = const Value.absent(),
    this.duration = const Value.absent(),
    this.recipientCount = const Value.absent(),
    this.replyCount = const Value.absent(),
    this.isExpired = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.isRead = const Value.absent(),
    this.isListened = const Value.absent(),
    this.expiredAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.cachedAt = const Value.absent(),
  });
  CachedBroadcastsCompanion.insert({
    this.id = const Value.absent(),
    required int userId,
    this.senderNickname = const Value.absent(),
    this.senderGender = const Value.absent(),
    this.content = const Value.absent(),
    this.audioUrl = const Value.absent(),
    this.duration = const Value.absent(),
    this.recipientCount = const Value.absent(),
    this.replyCount = const Value.absent(),
    this.isExpired = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.isRead = const Value.absent(),
    this.isListened = const Value.absent(),
    this.expiredAt = const Value.absent(),
    required DateTime createdAt,
    required DateTime cachedAt,
  }) : userId = Value(userId),
       createdAt = Value(createdAt),
       cachedAt = Value(cachedAt);
  static Insertable<CachedBroadcast> custom({
    Expression<int>? id,
    Expression<int>? userId,
    Expression<String>? senderNickname,
    Expression<String>? senderGender,
    Expression<String>? content,
    Expression<String>? audioUrl,
    Expression<int>? duration,
    Expression<int>? recipientCount,
    Expression<int>? replyCount,
    Expression<bool>? isExpired,
    Expression<bool>? isFavorite,
    Expression<bool>? isRead,
    Expression<bool>? isListened,
    Expression<DateTime>? expiredAt,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? cachedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (senderNickname != null) 'sender_nickname': senderNickname,
      if (senderGender != null) 'sender_gender': senderGender,
      if (content != null) 'content': content,
      if (audioUrl != null) 'audio_url': audioUrl,
      if (duration != null) 'duration': duration,
      if (recipientCount != null) 'recipient_count': recipientCount,
      if (replyCount != null) 'reply_count': replyCount,
      if (isExpired != null) 'is_expired': isExpired,
      if (isFavorite != null) 'is_favorite': isFavorite,
      if (isRead != null) 'is_read': isRead,
      if (isListened != null) 'is_listened': isListened,
      if (expiredAt != null) 'expired_at': expiredAt,
      if (createdAt != null) 'created_at': createdAt,
      if (cachedAt != null) 'cached_at': cachedAt,
    });
  }

  CachedBroadcastsCompanion copyWith({
    Value<int>? id,
    Value<int>? userId,
    Value<String?>? senderNickname,
    Value<String?>? senderGender,
    Value<String?>? content,
    Value<String?>? audioUrl,
    Value<int?>? duration,
    Value<int>? recipientCount,
    Value<int>? replyCount,
    Value<bool>? isExpired,
    Value<bool>? isFavorite,
    Value<bool>? isRead,
    Value<bool>? isListened,
    Value<DateTime?>? expiredAt,
    Value<DateTime>? createdAt,
    Value<DateTime>? cachedAt,
  }) {
    return CachedBroadcastsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      senderNickname: senderNickname ?? this.senderNickname,
      senderGender: senderGender ?? this.senderGender,
      content: content ?? this.content,
      audioUrl: audioUrl ?? this.audioUrl,
      duration: duration ?? this.duration,
      recipientCount: recipientCount ?? this.recipientCount,
      replyCount: replyCount ?? this.replyCount,
      isExpired: isExpired ?? this.isExpired,
      isFavorite: isFavorite ?? this.isFavorite,
      isRead: isRead ?? this.isRead,
      isListened: isListened ?? this.isListened,
      expiredAt: expiredAt ?? this.expiredAt,
      createdAt: createdAt ?? this.createdAt,
      cachedAt: cachedAt ?? this.cachedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<int>(userId.value);
    }
    if (senderNickname.present) {
      map['sender_nickname'] = Variable<String>(senderNickname.value);
    }
    if (senderGender.present) {
      map['sender_gender'] = Variable<String>(senderGender.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (audioUrl.present) {
      map['audio_url'] = Variable<String>(audioUrl.value);
    }
    if (duration.present) {
      map['duration'] = Variable<int>(duration.value);
    }
    if (recipientCount.present) {
      map['recipient_count'] = Variable<int>(recipientCount.value);
    }
    if (replyCount.present) {
      map['reply_count'] = Variable<int>(replyCount.value);
    }
    if (isExpired.present) {
      map['is_expired'] = Variable<bool>(isExpired.value);
    }
    if (isFavorite.present) {
      map['is_favorite'] = Variable<bool>(isFavorite.value);
    }
    if (isRead.present) {
      map['is_read'] = Variable<bool>(isRead.value);
    }
    if (isListened.present) {
      map['is_listened'] = Variable<bool>(isListened.value);
    }
    if (expiredAt.present) {
      map['expired_at'] = Variable<DateTime>(expiredAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (cachedAt.present) {
      map['cached_at'] = Variable<DateTime>(cachedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedBroadcastsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('senderNickname: $senderNickname, ')
          ..write('senderGender: $senderGender, ')
          ..write('content: $content, ')
          ..write('audioUrl: $audioUrl, ')
          ..write('duration: $duration, ')
          ..write('recipientCount: $recipientCount, ')
          ..write('replyCount: $replyCount, ')
          ..write('isExpired: $isExpired, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('isRead: $isRead, ')
          ..write('isListened: $isListened, ')
          ..write('expiredAt: $expiredAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('cachedAt: $cachedAt')
          ..write(')'))
        .toString();
  }
}

class $CachedConversationsTable extends CachedConversations
    with TableInfo<$CachedConversationsTable, CachedConversation> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedConversationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _partnerUserIdMeta = const VerificationMeta(
    'partnerUserId',
  );
  @override
  late final GeneratedColumn<int> partnerUserId = GeneratedColumn<int>(
    'partner_user_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _partnerNicknameMeta = const VerificationMeta(
    'partnerNickname',
  );
  @override
  late final GeneratedColumn<String> partnerNickname = GeneratedColumn<String>(
    'partner_nickname',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _partnerGenderMeta = const VerificationMeta(
    'partnerGender',
  );
  @override
  late final GeneratedColumn<String> partnerGender = GeneratedColumn<String>(
    'partner_gender',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _partnerProfileImageUrlMeta =
      const VerificationMeta('partnerProfileImageUrl');
  @override
  late final GeneratedColumn<String> partnerProfileImageUrl =
      GeneratedColumn<String>(
        'partner_profile_image_url',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _broadcastIdMeta = const VerificationMeta(
    'broadcastId',
  );
  @override
  late final GeneratedColumn<int> broadcastId = GeneratedColumn<int>(
    'broadcast_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isFavoriteMeta = const VerificationMeta(
    'isFavorite',
  );
  @override
  late final GeneratedColumn<bool> isFavorite = GeneratedColumn<bool>(
    'is_favorite',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_favorite" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _hasUnreadMessagesMeta = const VerificationMeta(
    'hasUnreadMessages',
  );
  @override
  late final GeneratedColumn<bool> hasUnreadMessages = GeneratedColumn<bool>(
    'has_unread_messages',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("has_unread_messages" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _unreadCountMeta = const VerificationMeta(
    'unreadCount',
  );
  @override
  late final GeneratedColumn<int> unreadCount = GeneratedColumn<int>(
    'unread_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastMessagePreviewMeta =
      const VerificationMeta('lastMessagePreview');
  @override
  late final GeneratedColumn<String> lastMessagePreview =
      GeneratedColumn<String>(
        'last_message_preview',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _lastMessageAtMeta = const VerificationMeta(
    'lastMessageAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastMessageAt =
      GeneratedColumn<DateTime>(
        'last_message_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cachedAtMeta = const VerificationMeta(
    'cachedAt',
  );
  @override
  late final GeneratedColumn<DateTime> cachedAt = GeneratedColumn<DateTime>(
    'cached_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    partnerUserId,
    partnerNickname,
    partnerGender,
    partnerProfileImageUrl,
    broadcastId,
    isFavorite,
    hasUnreadMessages,
    unreadCount,
    lastMessagePreview,
    lastMessageAt,
    createdAt,
    updatedAt,
    cachedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_conversations';
  @override
  VerificationContext validateIntegrity(
    Insertable<CachedConversation> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('partner_user_id')) {
      context.handle(
        _partnerUserIdMeta,
        partnerUserId.isAcceptableOrUnknown(
          data['partner_user_id']!,
          _partnerUserIdMeta,
        ),
      );
    }
    if (data.containsKey('partner_nickname')) {
      context.handle(
        _partnerNicknameMeta,
        partnerNickname.isAcceptableOrUnknown(
          data['partner_nickname']!,
          _partnerNicknameMeta,
        ),
      );
    }
    if (data.containsKey('partner_gender')) {
      context.handle(
        _partnerGenderMeta,
        partnerGender.isAcceptableOrUnknown(
          data['partner_gender']!,
          _partnerGenderMeta,
        ),
      );
    }
    if (data.containsKey('partner_profile_image_url')) {
      context.handle(
        _partnerProfileImageUrlMeta,
        partnerProfileImageUrl.isAcceptableOrUnknown(
          data['partner_profile_image_url']!,
          _partnerProfileImageUrlMeta,
        ),
      );
    }
    if (data.containsKey('broadcast_id')) {
      context.handle(
        _broadcastIdMeta,
        broadcastId.isAcceptableOrUnknown(
          data['broadcast_id']!,
          _broadcastIdMeta,
        ),
      );
    }
    if (data.containsKey('is_favorite')) {
      context.handle(
        _isFavoriteMeta,
        isFavorite.isAcceptableOrUnknown(data['is_favorite']!, _isFavoriteMeta),
      );
    }
    if (data.containsKey('has_unread_messages')) {
      context.handle(
        _hasUnreadMessagesMeta,
        hasUnreadMessages.isAcceptableOrUnknown(
          data['has_unread_messages']!,
          _hasUnreadMessagesMeta,
        ),
      );
    }
    if (data.containsKey('unread_count')) {
      context.handle(
        _unreadCountMeta,
        unreadCount.isAcceptableOrUnknown(
          data['unread_count']!,
          _unreadCountMeta,
        ),
      );
    }
    if (data.containsKey('last_message_preview')) {
      context.handle(
        _lastMessagePreviewMeta,
        lastMessagePreview.isAcceptableOrUnknown(
          data['last_message_preview']!,
          _lastMessagePreviewMeta,
        ),
      );
    }
    if (data.containsKey('last_message_at')) {
      context.handle(
        _lastMessageAtMeta,
        lastMessageAt.isAcceptableOrUnknown(
          data['last_message_at']!,
          _lastMessageAtMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('cached_at')) {
      context.handle(
        _cachedAtMeta,
        cachedAt.isAcceptableOrUnknown(data['cached_at']!, _cachedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_cachedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CachedConversation map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedConversation(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      partnerUserId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}partner_user_id'],
      ),
      partnerNickname: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}partner_nickname'],
      ),
      partnerGender: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}partner_gender'],
      ),
      partnerProfileImageUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}partner_profile_image_url'],
      ),
      broadcastId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}broadcast_id'],
      ),
      isFavorite: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_favorite'],
      )!,
      hasUnreadMessages: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}has_unread_messages'],
      )!,
      unreadCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}unread_count'],
      )!,
      lastMessagePreview: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_message_preview'],
      ),
      lastMessageAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_message_at'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      ),
      cachedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}cached_at'],
      )!,
    );
  }

  @override
  $CachedConversationsTable createAlias(String alias) {
    return $CachedConversationsTable(attachedDatabase, alias);
  }
}

class CachedConversation extends DataClass
    implements Insertable<CachedConversation> {
  final int id;
  final int? partnerUserId;
  final String? partnerNickname;
  final String? partnerGender;
  final String? partnerProfileImageUrl;
  final int? broadcastId;
  final bool isFavorite;
  final bool hasUnreadMessages;
  final int unreadCount;
  final String? lastMessagePreview;
  final DateTime? lastMessageAt;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime cachedAt;
  const CachedConversation({
    required this.id,
    this.partnerUserId,
    this.partnerNickname,
    this.partnerGender,
    this.partnerProfileImageUrl,
    this.broadcastId,
    required this.isFavorite,
    required this.hasUnreadMessages,
    required this.unreadCount,
    this.lastMessagePreview,
    this.lastMessageAt,
    required this.createdAt,
    this.updatedAt,
    required this.cachedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || partnerUserId != null) {
      map['partner_user_id'] = Variable<int>(partnerUserId);
    }
    if (!nullToAbsent || partnerNickname != null) {
      map['partner_nickname'] = Variable<String>(partnerNickname);
    }
    if (!nullToAbsent || partnerGender != null) {
      map['partner_gender'] = Variable<String>(partnerGender);
    }
    if (!nullToAbsent || partnerProfileImageUrl != null) {
      map['partner_profile_image_url'] = Variable<String>(
        partnerProfileImageUrl,
      );
    }
    if (!nullToAbsent || broadcastId != null) {
      map['broadcast_id'] = Variable<int>(broadcastId);
    }
    map['is_favorite'] = Variable<bool>(isFavorite);
    map['has_unread_messages'] = Variable<bool>(hasUnreadMessages);
    map['unread_count'] = Variable<int>(unreadCount);
    if (!nullToAbsent || lastMessagePreview != null) {
      map['last_message_preview'] = Variable<String>(lastMessagePreview);
    }
    if (!nullToAbsent || lastMessageAt != null) {
      map['last_message_at'] = Variable<DateTime>(lastMessageAt);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    map['cached_at'] = Variable<DateTime>(cachedAt);
    return map;
  }

  CachedConversationsCompanion toCompanion(bool nullToAbsent) {
    return CachedConversationsCompanion(
      id: Value(id),
      partnerUserId: partnerUserId == null && nullToAbsent
          ? const Value.absent()
          : Value(partnerUserId),
      partnerNickname: partnerNickname == null && nullToAbsent
          ? const Value.absent()
          : Value(partnerNickname),
      partnerGender: partnerGender == null && nullToAbsent
          ? const Value.absent()
          : Value(partnerGender),
      partnerProfileImageUrl: partnerProfileImageUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(partnerProfileImageUrl),
      broadcastId: broadcastId == null && nullToAbsent
          ? const Value.absent()
          : Value(broadcastId),
      isFavorite: Value(isFavorite),
      hasUnreadMessages: Value(hasUnreadMessages),
      unreadCount: Value(unreadCount),
      lastMessagePreview: lastMessagePreview == null && nullToAbsent
          ? const Value.absent()
          : Value(lastMessagePreview),
      lastMessageAt: lastMessageAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastMessageAt),
      createdAt: Value(createdAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
      cachedAt: Value(cachedAt),
    );
  }

  factory CachedConversation.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedConversation(
      id: serializer.fromJson<int>(json['id']),
      partnerUserId: serializer.fromJson<int?>(json['partnerUserId']),
      partnerNickname: serializer.fromJson<String?>(json['partnerNickname']),
      partnerGender: serializer.fromJson<String?>(json['partnerGender']),
      partnerProfileImageUrl: serializer.fromJson<String?>(
        json['partnerProfileImageUrl'],
      ),
      broadcastId: serializer.fromJson<int?>(json['broadcastId']),
      isFavorite: serializer.fromJson<bool>(json['isFavorite']),
      hasUnreadMessages: serializer.fromJson<bool>(json['hasUnreadMessages']),
      unreadCount: serializer.fromJson<int>(json['unreadCount']),
      lastMessagePreview: serializer.fromJson<String?>(
        json['lastMessagePreview'],
      ),
      lastMessageAt: serializer.fromJson<DateTime?>(json['lastMessageAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
      cachedAt: serializer.fromJson<DateTime>(json['cachedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'partnerUserId': serializer.toJson<int?>(partnerUserId),
      'partnerNickname': serializer.toJson<String?>(partnerNickname),
      'partnerGender': serializer.toJson<String?>(partnerGender),
      'partnerProfileImageUrl': serializer.toJson<String?>(
        partnerProfileImageUrl,
      ),
      'broadcastId': serializer.toJson<int?>(broadcastId),
      'isFavorite': serializer.toJson<bool>(isFavorite),
      'hasUnreadMessages': serializer.toJson<bool>(hasUnreadMessages),
      'unreadCount': serializer.toJson<int>(unreadCount),
      'lastMessagePreview': serializer.toJson<String?>(lastMessagePreview),
      'lastMessageAt': serializer.toJson<DateTime?>(lastMessageAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
      'cachedAt': serializer.toJson<DateTime>(cachedAt),
    };
  }

  CachedConversation copyWith({
    int? id,
    Value<int?> partnerUserId = const Value.absent(),
    Value<String?> partnerNickname = const Value.absent(),
    Value<String?> partnerGender = const Value.absent(),
    Value<String?> partnerProfileImageUrl = const Value.absent(),
    Value<int?> broadcastId = const Value.absent(),
    bool? isFavorite,
    bool? hasUnreadMessages,
    int? unreadCount,
    Value<String?> lastMessagePreview = const Value.absent(),
    Value<DateTime?> lastMessageAt = const Value.absent(),
    DateTime? createdAt,
    Value<DateTime?> updatedAt = const Value.absent(),
    DateTime? cachedAt,
  }) => CachedConversation(
    id: id ?? this.id,
    partnerUserId: partnerUserId.present
        ? partnerUserId.value
        : this.partnerUserId,
    partnerNickname: partnerNickname.present
        ? partnerNickname.value
        : this.partnerNickname,
    partnerGender: partnerGender.present
        ? partnerGender.value
        : this.partnerGender,
    partnerProfileImageUrl: partnerProfileImageUrl.present
        ? partnerProfileImageUrl.value
        : this.partnerProfileImageUrl,
    broadcastId: broadcastId.present ? broadcastId.value : this.broadcastId,
    isFavorite: isFavorite ?? this.isFavorite,
    hasUnreadMessages: hasUnreadMessages ?? this.hasUnreadMessages,
    unreadCount: unreadCount ?? this.unreadCount,
    lastMessagePreview: lastMessagePreview.present
        ? lastMessagePreview.value
        : this.lastMessagePreview,
    lastMessageAt: lastMessageAt.present
        ? lastMessageAt.value
        : this.lastMessageAt,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
    cachedAt: cachedAt ?? this.cachedAt,
  );
  CachedConversation copyWithCompanion(CachedConversationsCompanion data) {
    return CachedConversation(
      id: data.id.present ? data.id.value : this.id,
      partnerUserId: data.partnerUserId.present
          ? data.partnerUserId.value
          : this.partnerUserId,
      partnerNickname: data.partnerNickname.present
          ? data.partnerNickname.value
          : this.partnerNickname,
      partnerGender: data.partnerGender.present
          ? data.partnerGender.value
          : this.partnerGender,
      partnerProfileImageUrl: data.partnerProfileImageUrl.present
          ? data.partnerProfileImageUrl.value
          : this.partnerProfileImageUrl,
      broadcastId: data.broadcastId.present
          ? data.broadcastId.value
          : this.broadcastId,
      isFavorite: data.isFavorite.present
          ? data.isFavorite.value
          : this.isFavorite,
      hasUnreadMessages: data.hasUnreadMessages.present
          ? data.hasUnreadMessages.value
          : this.hasUnreadMessages,
      unreadCount: data.unreadCount.present
          ? data.unreadCount.value
          : this.unreadCount,
      lastMessagePreview: data.lastMessagePreview.present
          ? data.lastMessagePreview.value
          : this.lastMessagePreview,
      lastMessageAt: data.lastMessageAt.present
          ? data.lastMessageAt.value
          : this.lastMessageAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      cachedAt: data.cachedAt.present ? data.cachedAt.value : this.cachedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedConversation(')
          ..write('id: $id, ')
          ..write('partnerUserId: $partnerUserId, ')
          ..write('partnerNickname: $partnerNickname, ')
          ..write('partnerGender: $partnerGender, ')
          ..write('partnerProfileImageUrl: $partnerProfileImageUrl, ')
          ..write('broadcastId: $broadcastId, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('hasUnreadMessages: $hasUnreadMessages, ')
          ..write('unreadCount: $unreadCount, ')
          ..write('lastMessagePreview: $lastMessagePreview, ')
          ..write('lastMessageAt: $lastMessageAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('cachedAt: $cachedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    partnerUserId,
    partnerNickname,
    partnerGender,
    partnerProfileImageUrl,
    broadcastId,
    isFavorite,
    hasUnreadMessages,
    unreadCount,
    lastMessagePreview,
    lastMessageAt,
    createdAt,
    updatedAt,
    cachedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedConversation &&
          other.id == this.id &&
          other.partnerUserId == this.partnerUserId &&
          other.partnerNickname == this.partnerNickname &&
          other.partnerGender == this.partnerGender &&
          other.partnerProfileImageUrl == this.partnerProfileImageUrl &&
          other.broadcastId == this.broadcastId &&
          other.isFavorite == this.isFavorite &&
          other.hasUnreadMessages == this.hasUnreadMessages &&
          other.unreadCount == this.unreadCount &&
          other.lastMessagePreview == this.lastMessagePreview &&
          other.lastMessageAt == this.lastMessageAt &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.cachedAt == this.cachedAt);
}

class CachedConversationsCompanion extends UpdateCompanion<CachedConversation> {
  final Value<int> id;
  final Value<int?> partnerUserId;
  final Value<String?> partnerNickname;
  final Value<String?> partnerGender;
  final Value<String?> partnerProfileImageUrl;
  final Value<int?> broadcastId;
  final Value<bool> isFavorite;
  final Value<bool> hasUnreadMessages;
  final Value<int> unreadCount;
  final Value<String?> lastMessagePreview;
  final Value<DateTime?> lastMessageAt;
  final Value<DateTime> createdAt;
  final Value<DateTime?> updatedAt;
  final Value<DateTime> cachedAt;
  const CachedConversationsCompanion({
    this.id = const Value.absent(),
    this.partnerUserId = const Value.absent(),
    this.partnerNickname = const Value.absent(),
    this.partnerGender = const Value.absent(),
    this.partnerProfileImageUrl = const Value.absent(),
    this.broadcastId = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.hasUnreadMessages = const Value.absent(),
    this.unreadCount = const Value.absent(),
    this.lastMessagePreview = const Value.absent(),
    this.lastMessageAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.cachedAt = const Value.absent(),
  });
  CachedConversationsCompanion.insert({
    this.id = const Value.absent(),
    this.partnerUserId = const Value.absent(),
    this.partnerNickname = const Value.absent(),
    this.partnerGender = const Value.absent(),
    this.partnerProfileImageUrl = const Value.absent(),
    this.broadcastId = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.hasUnreadMessages = const Value.absent(),
    this.unreadCount = const Value.absent(),
    this.lastMessagePreview = const Value.absent(),
    this.lastMessageAt = const Value.absent(),
    required DateTime createdAt,
    this.updatedAt = const Value.absent(),
    required DateTime cachedAt,
  }) : createdAt = Value(createdAt),
       cachedAt = Value(cachedAt);
  static Insertable<CachedConversation> custom({
    Expression<int>? id,
    Expression<int>? partnerUserId,
    Expression<String>? partnerNickname,
    Expression<String>? partnerGender,
    Expression<String>? partnerProfileImageUrl,
    Expression<int>? broadcastId,
    Expression<bool>? isFavorite,
    Expression<bool>? hasUnreadMessages,
    Expression<int>? unreadCount,
    Expression<String>? lastMessagePreview,
    Expression<DateTime>? lastMessageAt,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? cachedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (partnerUserId != null) 'partner_user_id': partnerUserId,
      if (partnerNickname != null) 'partner_nickname': partnerNickname,
      if (partnerGender != null) 'partner_gender': partnerGender,
      if (partnerProfileImageUrl != null)
        'partner_profile_image_url': partnerProfileImageUrl,
      if (broadcastId != null) 'broadcast_id': broadcastId,
      if (isFavorite != null) 'is_favorite': isFavorite,
      if (hasUnreadMessages != null) 'has_unread_messages': hasUnreadMessages,
      if (unreadCount != null) 'unread_count': unreadCount,
      if (lastMessagePreview != null)
        'last_message_preview': lastMessagePreview,
      if (lastMessageAt != null) 'last_message_at': lastMessageAt,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (cachedAt != null) 'cached_at': cachedAt,
    });
  }

  CachedConversationsCompanion copyWith({
    Value<int>? id,
    Value<int?>? partnerUserId,
    Value<String?>? partnerNickname,
    Value<String?>? partnerGender,
    Value<String?>? partnerProfileImageUrl,
    Value<int?>? broadcastId,
    Value<bool>? isFavorite,
    Value<bool>? hasUnreadMessages,
    Value<int>? unreadCount,
    Value<String?>? lastMessagePreview,
    Value<DateTime?>? lastMessageAt,
    Value<DateTime>? createdAt,
    Value<DateTime?>? updatedAt,
    Value<DateTime>? cachedAt,
  }) {
    return CachedConversationsCompanion(
      id: id ?? this.id,
      partnerUserId: partnerUserId ?? this.partnerUserId,
      partnerNickname: partnerNickname ?? this.partnerNickname,
      partnerGender: partnerGender ?? this.partnerGender,
      partnerProfileImageUrl:
          partnerProfileImageUrl ?? this.partnerProfileImageUrl,
      broadcastId: broadcastId ?? this.broadcastId,
      isFavorite: isFavorite ?? this.isFavorite,
      hasUnreadMessages: hasUnreadMessages ?? this.hasUnreadMessages,
      unreadCount: unreadCount ?? this.unreadCount,
      lastMessagePreview: lastMessagePreview ?? this.lastMessagePreview,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      cachedAt: cachedAt ?? this.cachedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (partnerUserId.present) {
      map['partner_user_id'] = Variable<int>(partnerUserId.value);
    }
    if (partnerNickname.present) {
      map['partner_nickname'] = Variable<String>(partnerNickname.value);
    }
    if (partnerGender.present) {
      map['partner_gender'] = Variable<String>(partnerGender.value);
    }
    if (partnerProfileImageUrl.present) {
      map['partner_profile_image_url'] = Variable<String>(
        partnerProfileImageUrl.value,
      );
    }
    if (broadcastId.present) {
      map['broadcast_id'] = Variable<int>(broadcastId.value);
    }
    if (isFavorite.present) {
      map['is_favorite'] = Variable<bool>(isFavorite.value);
    }
    if (hasUnreadMessages.present) {
      map['has_unread_messages'] = Variable<bool>(hasUnreadMessages.value);
    }
    if (unreadCount.present) {
      map['unread_count'] = Variable<int>(unreadCount.value);
    }
    if (lastMessagePreview.present) {
      map['last_message_preview'] = Variable<String>(lastMessagePreview.value);
    }
    if (lastMessageAt.present) {
      map['last_message_at'] = Variable<DateTime>(lastMessageAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (cachedAt.present) {
      map['cached_at'] = Variable<DateTime>(cachedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedConversationsCompanion(')
          ..write('id: $id, ')
          ..write('partnerUserId: $partnerUserId, ')
          ..write('partnerNickname: $partnerNickname, ')
          ..write('partnerGender: $partnerGender, ')
          ..write('partnerProfileImageUrl: $partnerProfileImageUrl, ')
          ..write('broadcastId: $broadcastId, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('hasUnreadMessages: $hasUnreadMessages, ')
          ..write('unreadCount: $unreadCount, ')
          ..write('lastMessagePreview: $lastMessagePreview, ')
          ..write('lastMessageAt: $lastMessageAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('cachedAt: $cachedAt')
          ..write(')'))
        .toString();
  }
}

class $CachedMessagesTable extends CachedMessages
    with TableInfo<$CachedMessagesTable, CachedMessage> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedMessagesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _conversationIdMeta = const VerificationMeta(
    'conversationId',
  );
  @override
  late final GeneratedColumn<int> conversationId = GeneratedColumn<int>(
    'conversation_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _senderIdMeta = const VerificationMeta(
    'senderId',
  );
  @override
  late final GeneratedColumn<int> senderId = GeneratedColumn<int>(
    'sender_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _voiceUrlMeta = const VerificationMeta(
    'voiceUrl',
  );
  @override
  late final GeneratedColumn<String> voiceUrl = GeneratedColumn<String>(
    'voice_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _durationMeta = const VerificationMeta(
    'duration',
  );
  @override
  late final GeneratedColumn<int> duration = GeneratedColumn<int>(
    'duration',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _messageTypeMeta = const VerificationMeta(
    'messageType',
  );
  @override
  late final GeneratedColumn<String> messageType = GeneratedColumn<String>(
    'message_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('text'),
  );
  static const VerificationMeta _broadcastIdMeta = const VerificationMeta(
    'broadcastId',
  );
  @override
  late final GeneratedColumn<int> broadcastId = GeneratedColumn<int>(
    'broadcast_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isReadMeta = const VerificationMeta('isRead');
  @override
  late final GeneratedColumn<bool> isRead = GeneratedColumn<bool>(
    'is_read',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_read" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cachedAtMeta = const VerificationMeta(
    'cachedAt',
  );
  @override
  late final GeneratedColumn<DateTime> cachedAt = GeneratedColumn<DateTime>(
    'cached_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    conversationId,
    senderId,
    content,
    voiceUrl,
    duration,
    messageType,
    broadcastId,
    isRead,
    createdAt,
    updatedAt,
    cachedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_messages';
  @override
  VerificationContext validateIntegrity(
    Insertable<CachedMessage> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('conversation_id')) {
      context.handle(
        _conversationIdMeta,
        conversationId.isAcceptableOrUnknown(
          data['conversation_id']!,
          _conversationIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_conversationIdMeta);
    }
    if (data.containsKey('sender_id')) {
      context.handle(
        _senderIdMeta,
        senderId.isAcceptableOrUnknown(data['sender_id']!, _senderIdMeta),
      );
    } else if (isInserting) {
      context.missing(_senderIdMeta);
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    }
    if (data.containsKey('voice_url')) {
      context.handle(
        _voiceUrlMeta,
        voiceUrl.isAcceptableOrUnknown(data['voice_url']!, _voiceUrlMeta),
      );
    }
    if (data.containsKey('duration')) {
      context.handle(
        _durationMeta,
        duration.isAcceptableOrUnknown(data['duration']!, _durationMeta),
      );
    }
    if (data.containsKey('message_type')) {
      context.handle(
        _messageTypeMeta,
        messageType.isAcceptableOrUnknown(
          data['message_type']!,
          _messageTypeMeta,
        ),
      );
    }
    if (data.containsKey('broadcast_id')) {
      context.handle(
        _broadcastIdMeta,
        broadcastId.isAcceptableOrUnknown(
          data['broadcast_id']!,
          _broadcastIdMeta,
        ),
      );
    }
    if (data.containsKey('is_read')) {
      context.handle(
        _isReadMeta,
        isRead.isAcceptableOrUnknown(data['is_read']!, _isReadMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('cached_at')) {
      context.handle(
        _cachedAtMeta,
        cachedAt.isAcceptableOrUnknown(data['cached_at']!, _cachedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_cachedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CachedMessage map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedMessage(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      conversationId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}conversation_id'],
      )!,
      senderId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sender_id'],
      )!,
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content'],
      ),
      voiceUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}voice_url'],
      ),
      duration: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration'],
      ),
      messageType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}message_type'],
      )!,
      broadcastId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}broadcast_id'],
      ),
      isRead: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_read'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      ),
      cachedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}cached_at'],
      )!,
    );
  }

  @override
  $CachedMessagesTable createAlias(String alias) {
    return $CachedMessagesTable(attachedDatabase, alias);
  }
}

class CachedMessage extends DataClass implements Insertable<CachedMessage> {
  final int id;
  final int conversationId;
  final int senderId;
  final String? content;
  final String? voiceUrl;
  final int? duration;
  final String messageType;
  final int? broadcastId;
  final bool isRead;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime cachedAt;
  const CachedMessage({
    required this.id,
    required this.conversationId,
    required this.senderId,
    this.content,
    this.voiceUrl,
    this.duration,
    required this.messageType,
    this.broadcastId,
    required this.isRead,
    required this.createdAt,
    this.updatedAt,
    required this.cachedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['conversation_id'] = Variable<int>(conversationId);
    map['sender_id'] = Variable<int>(senderId);
    if (!nullToAbsent || content != null) {
      map['content'] = Variable<String>(content);
    }
    if (!nullToAbsent || voiceUrl != null) {
      map['voice_url'] = Variable<String>(voiceUrl);
    }
    if (!nullToAbsent || duration != null) {
      map['duration'] = Variable<int>(duration);
    }
    map['message_type'] = Variable<String>(messageType);
    if (!nullToAbsent || broadcastId != null) {
      map['broadcast_id'] = Variable<int>(broadcastId);
    }
    map['is_read'] = Variable<bool>(isRead);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    map['cached_at'] = Variable<DateTime>(cachedAt);
    return map;
  }

  CachedMessagesCompanion toCompanion(bool nullToAbsent) {
    return CachedMessagesCompanion(
      id: Value(id),
      conversationId: Value(conversationId),
      senderId: Value(senderId),
      content: content == null && nullToAbsent
          ? const Value.absent()
          : Value(content),
      voiceUrl: voiceUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(voiceUrl),
      duration: duration == null && nullToAbsent
          ? const Value.absent()
          : Value(duration),
      messageType: Value(messageType),
      broadcastId: broadcastId == null && nullToAbsent
          ? const Value.absent()
          : Value(broadcastId),
      isRead: Value(isRead),
      createdAt: Value(createdAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
      cachedAt: Value(cachedAt),
    );
  }

  factory CachedMessage.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedMessage(
      id: serializer.fromJson<int>(json['id']),
      conversationId: serializer.fromJson<int>(json['conversationId']),
      senderId: serializer.fromJson<int>(json['senderId']),
      content: serializer.fromJson<String?>(json['content']),
      voiceUrl: serializer.fromJson<String?>(json['voiceUrl']),
      duration: serializer.fromJson<int?>(json['duration']),
      messageType: serializer.fromJson<String>(json['messageType']),
      broadcastId: serializer.fromJson<int?>(json['broadcastId']),
      isRead: serializer.fromJson<bool>(json['isRead']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
      cachedAt: serializer.fromJson<DateTime>(json['cachedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'conversationId': serializer.toJson<int>(conversationId),
      'senderId': serializer.toJson<int>(senderId),
      'content': serializer.toJson<String?>(content),
      'voiceUrl': serializer.toJson<String?>(voiceUrl),
      'duration': serializer.toJson<int?>(duration),
      'messageType': serializer.toJson<String>(messageType),
      'broadcastId': serializer.toJson<int?>(broadcastId),
      'isRead': serializer.toJson<bool>(isRead),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
      'cachedAt': serializer.toJson<DateTime>(cachedAt),
    };
  }

  CachedMessage copyWith({
    int? id,
    int? conversationId,
    int? senderId,
    Value<String?> content = const Value.absent(),
    Value<String?> voiceUrl = const Value.absent(),
    Value<int?> duration = const Value.absent(),
    String? messageType,
    Value<int?> broadcastId = const Value.absent(),
    bool? isRead,
    DateTime? createdAt,
    Value<DateTime?> updatedAt = const Value.absent(),
    DateTime? cachedAt,
  }) => CachedMessage(
    id: id ?? this.id,
    conversationId: conversationId ?? this.conversationId,
    senderId: senderId ?? this.senderId,
    content: content.present ? content.value : this.content,
    voiceUrl: voiceUrl.present ? voiceUrl.value : this.voiceUrl,
    duration: duration.present ? duration.value : this.duration,
    messageType: messageType ?? this.messageType,
    broadcastId: broadcastId.present ? broadcastId.value : this.broadcastId,
    isRead: isRead ?? this.isRead,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
    cachedAt: cachedAt ?? this.cachedAt,
  );
  CachedMessage copyWithCompanion(CachedMessagesCompanion data) {
    return CachedMessage(
      id: data.id.present ? data.id.value : this.id,
      conversationId: data.conversationId.present
          ? data.conversationId.value
          : this.conversationId,
      senderId: data.senderId.present ? data.senderId.value : this.senderId,
      content: data.content.present ? data.content.value : this.content,
      voiceUrl: data.voiceUrl.present ? data.voiceUrl.value : this.voiceUrl,
      duration: data.duration.present ? data.duration.value : this.duration,
      messageType: data.messageType.present
          ? data.messageType.value
          : this.messageType,
      broadcastId: data.broadcastId.present
          ? data.broadcastId.value
          : this.broadcastId,
      isRead: data.isRead.present ? data.isRead.value : this.isRead,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      cachedAt: data.cachedAt.present ? data.cachedAt.value : this.cachedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedMessage(')
          ..write('id: $id, ')
          ..write('conversationId: $conversationId, ')
          ..write('senderId: $senderId, ')
          ..write('content: $content, ')
          ..write('voiceUrl: $voiceUrl, ')
          ..write('duration: $duration, ')
          ..write('messageType: $messageType, ')
          ..write('broadcastId: $broadcastId, ')
          ..write('isRead: $isRead, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('cachedAt: $cachedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    conversationId,
    senderId,
    content,
    voiceUrl,
    duration,
    messageType,
    broadcastId,
    isRead,
    createdAt,
    updatedAt,
    cachedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedMessage &&
          other.id == this.id &&
          other.conversationId == this.conversationId &&
          other.senderId == this.senderId &&
          other.content == this.content &&
          other.voiceUrl == this.voiceUrl &&
          other.duration == this.duration &&
          other.messageType == this.messageType &&
          other.broadcastId == this.broadcastId &&
          other.isRead == this.isRead &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.cachedAt == this.cachedAt);
}

class CachedMessagesCompanion extends UpdateCompanion<CachedMessage> {
  final Value<int> id;
  final Value<int> conversationId;
  final Value<int> senderId;
  final Value<String?> content;
  final Value<String?> voiceUrl;
  final Value<int?> duration;
  final Value<String> messageType;
  final Value<int?> broadcastId;
  final Value<bool> isRead;
  final Value<DateTime> createdAt;
  final Value<DateTime?> updatedAt;
  final Value<DateTime> cachedAt;
  const CachedMessagesCompanion({
    this.id = const Value.absent(),
    this.conversationId = const Value.absent(),
    this.senderId = const Value.absent(),
    this.content = const Value.absent(),
    this.voiceUrl = const Value.absent(),
    this.duration = const Value.absent(),
    this.messageType = const Value.absent(),
    this.broadcastId = const Value.absent(),
    this.isRead = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.cachedAt = const Value.absent(),
  });
  CachedMessagesCompanion.insert({
    this.id = const Value.absent(),
    required int conversationId,
    required int senderId,
    this.content = const Value.absent(),
    this.voiceUrl = const Value.absent(),
    this.duration = const Value.absent(),
    this.messageType = const Value.absent(),
    this.broadcastId = const Value.absent(),
    this.isRead = const Value.absent(),
    required DateTime createdAt,
    this.updatedAt = const Value.absent(),
    required DateTime cachedAt,
  }) : conversationId = Value(conversationId),
       senderId = Value(senderId),
       createdAt = Value(createdAt),
       cachedAt = Value(cachedAt);
  static Insertable<CachedMessage> custom({
    Expression<int>? id,
    Expression<int>? conversationId,
    Expression<int>? senderId,
    Expression<String>? content,
    Expression<String>? voiceUrl,
    Expression<int>? duration,
    Expression<String>? messageType,
    Expression<int>? broadcastId,
    Expression<bool>? isRead,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? cachedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (conversationId != null) 'conversation_id': conversationId,
      if (senderId != null) 'sender_id': senderId,
      if (content != null) 'content': content,
      if (voiceUrl != null) 'voice_url': voiceUrl,
      if (duration != null) 'duration': duration,
      if (messageType != null) 'message_type': messageType,
      if (broadcastId != null) 'broadcast_id': broadcastId,
      if (isRead != null) 'is_read': isRead,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (cachedAt != null) 'cached_at': cachedAt,
    });
  }

  CachedMessagesCompanion copyWith({
    Value<int>? id,
    Value<int>? conversationId,
    Value<int>? senderId,
    Value<String?>? content,
    Value<String?>? voiceUrl,
    Value<int?>? duration,
    Value<String>? messageType,
    Value<int?>? broadcastId,
    Value<bool>? isRead,
    Value<DateTime>? createdAt,
    Value<DateTime?>? updatedAt,
    Value<DateTime>? cachedAt,
  }) {
    return CachedMessagesCompanion(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      senderId: senderId ?? this.senderId,
      content: content ?? this.content,
      voiceUrl: voiceUrl ?? this.voiceUrl,
      duration: duration ?? this.duration,
      messageType: messageType ?? this.messageType,
      broadcastId: broadcastId ?? this.broadcastId,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      cachedAt: cachedAt ?? this.cachedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (conversationId.present) {
      map['conversation_id'] = Variable<int>(conversationId.value);
    }
    if (senderId.present) {
      map['sender_id'] = Variable<int>(senderId.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (voiceUrl.present) {
      map['voice_url'] = Variable<String>(voiceUrl.value);
    }
    if (duration.present) {
      map['duration'] = Variable<int>(duration.value);
    }
    if (messageType.present) {
      map['message_type'] = Variable<String>(messageType.value);
    }
    if (broadcastId.present) {
      map['broadcast_id'] = Variable<int>(broadcastId.value);
    }
    if (isRead.present) {
      map['is_read'] = Variable<bool>(isRead.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (cachedAt.present) {
      map['cached_at'] = Variable<DateTime>(cachedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedMessagesCompanion(')
          ..write('id: $id, ')
          ..write('conversationId: $conversationId, ')
          ..write('senderId: $senderId, ')
          ..write('content: $content, ')
          ..write('voiceUrl: $voiceUrl, ')
          ..write('duration: $duration, ')
          ..write('messageType: $messageType, ')
          ..write('broadcastId: $broadcastId, ')
          ..write('isRead: $isRead, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('cachedAt: $cachedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $AudioCacheEntriesTable audioCacheEntries =
      $AudioCacheEntriesTable(this);
  late final $CachedBroadcastsTable cachedBroadcasts = $CachedBroadcastsTable(
    this,
  );
  late final $CachedConversationsTable cachedConversations =
      $CachedConversationsTable(this);
  late final $CachedMessagesTable cachedMessages = $CachedMessagesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    audioCacheEntries,
    cachedBroadcasts,
    cachedConversations,
    cachedMessages,
  ];
}

typedef $$AudioCacheEntriesTableCreateCompanionBuilder =
    AudioCacheEntriesCompanion Function({
      Value<int> id,
      required String sourceType,
      required int sourceId,
      required String remoteUrl,
      required String localPath,
      required int fileSize,
      Value<int?> durationSeconds,
      Value<DateTime?> expiresAt,
      required DateTime cachedAt,
      Value<DateTime?> lastAccessedAt,
    });
typedef $$AudioCacheEntriesTableUpdateCompanionBuilder =
    AudioCacheEntriesCompanion Function({
      Value<int> id,
      Value<String> sourceType,
      Value<int> sourceId,
      Value<String> remoteUrl,
      Value<String> localPath,
      Value<int> fileSize,
      Value<int?> durationSeconds,
      Value<DateTime?> expiresAt,
      Value<DateTime> cachedAt,
      Value<DateTime?> lastAccessedAt,
    });

class $$AudioCacheEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $AudioCacheEntriesTable> {
  $$AudioCacheEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceType => $composableBuilder(
    column: $table.sourceType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sourceId => $composableBuilder(
    column: $table.sourceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get remoteUrl => $composableBuilder(
    column: $table.remoteUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localPath => $composableBuilder(
    column: $table.localPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fileSize => $composableBuilder(
    column: $table.fileSize,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get expiresAt => $composableBuilder(
    column: $table.expiresAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get cachedAt => $composableBuilder(
    column: $table.cachedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastAccessedAt => $composableBuilder(
    column: $table.lastAccessedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AudioCacheEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $AudioCacheEntriesTable> {
  $$AudioCacheEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceType => $composableBuilder(
    column: $table.sourceType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sourceId => $composableBuilder(
    column: $table.sourceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get remoteUrl => $composableBuilder(
    column: $table.remoteUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localPath => $composableBuilder(
    column: $table.localPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fileSize => $composableBuilder(
    column: $table.fileSize,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get expiresAt => $composableBuilder(
    column: $table.expiresAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get cachedAt => $composableBuilder(
    column: $table.cachedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastAccessedAt => $composableBuilder(
    column: $table.lastAccessedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AudioCacheEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $AudioCacheEntriesTable> {
  $$AudioCacheEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get sourceType => $composableBuilder(
    column: $table.sourceType,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sourceId =>
      $composableBuilder(column: $table.sourceId, builder: (column) => column);

  GeneratedColumn<String> get remoteUrl =>
      $composableBuilder(column: $table.remoteUrl, builder: (column) => column);

  GeneratedColumn<String> get localPath =>
      $composableBuilder(column: $table.localPath, builder: (column) => column);

  GeneratedColumn<int> get fileSize =>
      $composableBuilder(column: $table.fileSize, builder: (column) => column);

  GeneratedColumn<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get expiresAt =>
      $composableBuilder(column: $table.expiresAt, builder: (column) => column);

  GeneratedColumn<DateTime> get cachedAt =>
      $composableBuilder(column: $table.cachedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastAccessedAt => $composableBuilder(
    column: $table.lastAccessedAt,
    builder: (column) => column,
  );
}

class $$AudioCacheEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AudioCacheEntriesTable,
          AudioCacheEntry,
          $$AudioCacheEntriesTableFilterComposer,
          $$AudioCacheEntriesTableOrderingComposer,
          $$AudioCacheEntriesTableAnnotationComposer,
          $$AudioCacheEntriesTableCreateCompanionBuilder,
          $$AudioCacheEntriesTableUpdateCompanionBuilder,
          (
            AudioCacheEntry,
            BaseReferences<
              _$AppDatabase,
              $AudioCacheEntriesTable,
              AudioCacheEntry
            >,
          ),
          AudioCacheEntry,
          PrefetchHooks Function()
        > {
  $$AudioCacheEntriesTableTableManager(
    _$AppDatabase db,
    $AudioCacheEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AudioCacheEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AudioCacheEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AudioCacheEntriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> sourceType = const Value.absent(),
                Value<int> sourceId = const Value.absent(),
                Value<String> remoteUrl = const Value.absent(),
                Value<String> localPath = const Value.absent(),
                Value<int> fileSize = const Value.absent(),
                Value<int?> durationSeconds = const Value.absent(),
                Value<DateTime?> expiresAt = const Value.absent(),
                Value<DateTime> cachedAt = const Value.absent(),
                Value<DateTime?> lastAccessedAt = const Value.absent(),
              }) => AudioCacheEntriesCompanion(
                id: id,
                sourceType: sourceType,
                sourceId: sourceId,
                remoteUrl: remoteUrl,
                localPath: localPath,
                fileSize: fileSize,
                durationSeconds: durationSeconds,
                expiresAt: expiresAt,
                cachedAt: cachedAt,
                lastAccessedAt: lastAccessedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String sourceType,
                required int sourceId,
                required String remoteUrl,
                required String localPath,
                required int fileSize,
                Value<int?> durationSeconds = const Value.absent(),
                Value<DateTime?> expiresAt = const Value.absent(),
                required DateTime cachedAt,
                Value<DateTime?> lastAccessedAt = const Value.absent(),
              }) => AudioCacheEntriesCompanion.insert(
                id: id,
                sourceType: sourceType,
                sourceId: sourceId,
                remoteUrl: remoteUrl,
                localPath: localPath,
                fileSize: fileSize,
                durationSeconds: durationSeconds,
                expiresAt: expiresAt,
                cachedAt: cachedAt,
                lastAccessedAt: lastAccessedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AudioCacheEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AudioCacheEntriesTable,
      AudioCacheEntry,
      $$AudioCacheEntriesTableFilterComposer,
      $$AudioCacheEntriesTableOrderingComposer,
      $$AudioCacheEntriesTableAnnotationComposer,
      $$AudioCacheEntriesTableCreateCompanionBuilder,
      $$AudioCacheEntriesTableUpdateCompanionBuilder,
      (
        AudioCacheEntry,
        BaseReferences<_$AppDatabase, $AudioCacheEntriesTable, AudioCacheEntry>,
      ),
      AudioCacheEntry,
      PrefetchHooks Function()
    >;
typedef $$CachedBroadcastsTableCreateCompanionBuilder =
    CachedBroadcastsCompanion Function({
      Value<int> id,
      required int userId,
      Value<String?> senderNickname,
      Value<String?> senderGender,
      Value<String?> content,
      Value<String?> audioUrl,
      Value<int?> duration,
      Value<int> recipientCount,
      Value<int> replyCount,
      Value<bool> isExpired,
      Value<bool> isFavorite,
      Value<bool> isRead,
      Value<bool> isListened,
      Value<DateTime?> expiredAt,
      required DateTime createdAt,
      required DateTime cachedAt,
    });
typedef $$CachedBroadcastsTableUpdateCompanionBuilder =
    CachedBroadcastsCompanion Function({
      Value<int> id,
      Value<int> userId,
      Value<String?> senderNickname,
      Value<String?> senderGender,
      Value<String?> content,
      Value<String?> audioUrl,
      Value<int?> duration,
      Value<int> recipientCount,
      Value<int> replyCount,
      Value<bool> isExpired,
      Value<bool> isFavorite,
      Value<bool> isRead,
      Value<bool> isListened,
      Value<DateTime?> expiredAt,
      Value<DateTime> createdAt,
      Value<DateTime> cachedAt,
    });

class $$CachedBroadcastsTableFilterComposer
    extends Composer<_$AppDatabase, $CachedBroadcastsTable> {
  $$CachedBroadcastsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get senderNickname => $composableBuilder(
    column: $table.senderNickname,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get senderGender => $composableBuilder(
    column: $table.senderGender,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get audioUrl => $composableBuilder(
    column: $table.audioUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get duration => $composableBuilder(
    column: $table.duration,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get recipientCount => $composableBuilder(
    column: $table.recipientCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get replyCount => $composableBuilder(
    column: $table.replyCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isExpired => $composableBuilder(
    column: $table.isExpired,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isRead => $composableBuilder(
    column: $table.isRead,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isListened => $composableBuilder(
    column: $table.isListened,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get expiredAt => $composableBuilder(
    column: $table.expiredAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get cachedAt => $composableBuilder(
    column: $table.cachedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CachedBroadcastsTableOrderingComposer
    extends Composer<_$AppDatabase, $CachedBroadcastsTable> {
  $$CachedBroadcastsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get senderNickname => $composableBuilder(
    column: $table.senderNickname,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get senderGender => $composableBuilder(
    column: $table.senderGender,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get audioUrl => $composableBuilder(
    column: $table.audioUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get duration => $composableBuilder(
    column: $table.duration,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get recipientCount => $composableBuilder(
    column: $table.recipientCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get replyCount => $composableBuilder(
    column: $table.replyCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isExpired => $composableBuilder(
    column: $table.isExpired,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isRead => $composableBuilder(
    column: $table.isRead,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isListened => $composableBuilder(
    column: $table.isListened,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get expiredAt => $composableBuilder(
    column: $table.expiredAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get cachedAt => $composableBuilder(
    column: $table.cachedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CachedBroadcastsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CachedBroadcastsTable> {
  $$CachedBroadcastsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get senderNickname => $composableBuilder(
    column: $table.senderNickname,
    builder: (column) => column,
  );

  GeneratedColumn<String> get senderGender => $composableBuilder(
    column: $table.senderGender,
    builder: (column) => column,
  );

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<String> get audioUrl =>
      $composableBuilder(column: $table.audioUrl, builder: (column) => column);

  GeneratedColumn<int> get duration =>
      $composableBuilder(column: $table.duration, builder: (column) => column);

  GeneratedColumn<int> get recipientCount => $composableBuilder(
    column: $table.recipientCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get replyCount => $composableBuilder(
    column: $table.replyCount,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isExpired =>
      $composableBuilder(column: $table.isExpired, builder: (column) => column);

  GeneratedColumn<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isRead =>
      $composableBuilder(column: $table.isRead, builder: (column) => column);

  GeneratedColumn<bool> get isListened => $composableBuilder(
    column: $table.isListened,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get expiredAt =>
      $composableBuilder(column: $table.expiredAt, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get cachedAt =>
      $composableBuilder(column: $table.cachedAt, builder: (column) => column);
}

class $$CachedBroadcastsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CachedBroadcastsTable,
          CachedBroadcast,
          $$CachedBroadcastsTableFilterComposer,
          $$CachedBroadcastsTableOrderingComposer,
          $$CachedBroadcastsTableAnnotationComposer,
          $$CachedBroadcastsTableCreateCompanionBuilder,
          $$CachedBroadcastsTableUpdateCompanionBuilder,
          (
            CachedBroadcast,
            BaseReferences<
              _$AppDatabase,
              $CachedBroadcastsTable,
              CachedBroadcast
            >,
          ),
          CachedBroadcast,
          PrefetchHooks Function()
        > {
  $$CachedBroadcastsTableTableManager(
    _$AppDatabase db,
    $CachedBroadcastsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CachedBroadcastsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CachedBroadcastsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CachedBroadcastsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> userId = const Value.absent(),
                Value<String?> senderNickname = const Value.absent(),
                Value<String?> senderGender = const Value.absent(),
                Value<String?> content = const Value.absent(),
                Value<String?> audioUrl = const Value.absent(),
                Value<int?> duration = const Value.absent(),
                Value<int> recipientCount = const Value.absent(),
                Value<int> replyCount = const Value.absent(),
                Value<bool> isExpired = const Value.absent(),
                Value<bool> isFavorite = const Value.absent(),
                Value<bool> isRead = const Value.absent(),
                Value<bool> isListened = const Value.absent(),
                Value<DateTime?> expiredAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> cachedAt = const Value.absent(),
              }) => CachedBroadcastsCompanion(
                id: id,
                userId: userId,
                senderNickname: senderNickname,
                senderGender: senderGender,
                content: content,
                audioUrl: audioUrl,
                duration: duration,
                recipientCount: recipientCount,
                replyCount: replyCount,
                isExpired: isExpired,
                isFavorite: isFavorite,
                isRead: isRead,
                isListened: isListened,
                expiredAt: expiredAt,
                createdAt: createdAt,
                cachedAt: cachedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int userId,
                Value<String?> senderNickname = const Value.absent(),
                Value<String?> senderGender = const Value.absent(),
                Value<String?> content = const Value.absent(),
                Value<String?> audioUrl = const Value.absent(),
                Value<int?> duration = const Value.absent(),
                Value<int> recipientCount = const Value.absent(),
                Value<int> replyCount = const Value.absent(),
                Value<bool> isExpired = const Value.absent(),
                Value<bool> isFavorite = const Value.absent(),
                Value<bool> isRead = const Value.absent(),
                Value<bool> isListened = const Value.absent(),
                Value<DateTime?> expiredAt = const Value.absent(),
                required DateTime createdAt,
                required DateTime cachedAt,
              }) => CachedBroadcastsCompanion.insert(
                id: id,
                userId: userId,
                senderNickname: senderNickname,
                senderGender: senderGender,
                content: content,
                audioUrl: audioUrl,
                duration: duration,
                recipientCount: recipientCount,
                replyCount: replyCount,
                isExpired: isExpired,
                isFavorite: isFavorite,
                isRead: isRead,
                isListened: isListened,
                expiredAt: expiredAt,
                createdAt: createdAt,
                cachedAt: cachedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CachedBroadcastsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CachedBroadcastsTable,
      CachedBroadcast,
      $$CachedBroadcastsTableFilterComposer,
      $$CachedBroadcastsTableOrderingComposer,
      $$CachedBroadcastsTableAnnotationComposer,
      $$CachedBroadcastsTableCreateCompanionBuilder,
      $$CachedBroadcastsTableUpdateCompanionBuilder,
      (
        CachedBroadcast,
        BaseReferences<_$AppDatabase, $CachedBroadcastsTable, CachedBroadcast>,
      ),
      CachedBroadcast,
      PrefetchHooks Function()
    >;
typedef $$CachedConversationsTableCreateCompanionBuilder =
    CachedConversationsCompanion Function({
      Value<int> id,
      Value<int?> partnerUserId,
      Value<String?> partnerNickname,
      Value<String?> partnerGender,
      Value<String?> partnerProfileImageUrl,
      Value<int?> broadcastId,
      Value<bool> isFavorite,
      Value<bool> hasUnreadMessages,
      Value<int> unreadCount,
      Value<String?> lastMessagePreview,
      Value<DateTime?> lastMessageAt,
      required DateTime createdAt,
      Value<DateTime?> updatedAt,
      required DateTime cachedAt,
    });
typedef $$CachedConversationsTableUpdateCompanionBuilder =
    CachedConversationsCompanion Function({
      Value<int> id,
      Value<int?> partnerUserId,
      Value<String?> partnerNickname,
      Value<String?> partnerGender,
      Value<String?> partnerProfileImageUrl,
      Value<int?> broadcastId,
      Value<bool> isFavorite,
      Value<bool> hasUnreadMessages,
      Value<int> unreadCount,
      Value<String?> lastMessagePreview,
      Value<DateTime?> lastMessageAt,
      Value<DateTime> createdAt,
      Value<DateTime?> updatedAt,
      Value<DateTime> cachedAt,
    });

class $$CachedConversationsTableFilterComposer
    extends Composer<_$AppDatabase, $CachedConversationsTable> {
  $$CachedConversationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get partnerUserId => $composableBuilder(
    column: $table.partnerUserId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get partnerNickname => $composableBuilder(
    column: $table.partnerNickname,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get partnerGender => $composableBuilder(
    column: $table.partnerGender,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get partnerProfileImageUrl => $composableBuilder(
    column: $table.partnerProfileImageUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get broadcastId => $composableBuilder(
    column: $table.broadcastId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get hasUnreadMessages => $composableBuilder(
    column: $table.hasUnreadMessages,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get unreadCount => $composableBuilder(
    column: $table.unreadCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastMessagePreview => $composableBuilder(
    column: $table.lastMessagePreview,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastMessageAt => $composableBuilder(
    column: $table.lastMessageAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get cachedAt => $composableBuilder(
    column: $table.cachedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CachedConversationsTableOrderingComposer
    extends Composer<_$AppDatabase, $CachedConversationsTable> {
  $$CachedConversationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get partnerUserId => $composableBuilder(
    column: $table.partnerUserId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get partnerNickname => $composableBuilder(
    column: $table.partnerNickname,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get partnerGender => $composableBuilder(
    column: $table.partnerGender,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get partnerProfileImageUrl => $composableBuilder(
    column: $table.partnerProfileImageUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get broadcastId => $composableBuilder(
    column: $table.broadcastId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get hasUnreadMessages => $composableBuilder(
    column: $table.hasUnreadMessages,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get unreadCount => $composableBuilder(
    column: $table.unreadCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastMessagePreview => $composableBuilder(
    column: $table.lastMessagePreview,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastMessageAt => $composableBuilder(
    column: $table.lastMessageAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get cachedAt => $composableBuilder(
    column: $table.cachedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CachedConversationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CachedConversationsTable> {
  $$CachedConversationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get partnerUserId => $composableBuilder(
    column: $table.partnerUserId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get partnerNickname => $composableBuilder(
    column: $table.partnerNickname,
    builder: (column) => column,
  );

  GeneratedColumn<String> get partnerGender => $composableBuilder(
    column: $table.partnerGender,
    builder: (column) => column,
  );

  GeneratedColumn<String> get partnerProfileImageUrl => $composableBuilder(
    column: $table.partnerProfileImageUrl,
    builder: (column) => column,
  );

  GeneratedColumn<int> get broadcastId => $composableBuilder(
    column: $table.broadcastId,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get hasUnreadMessages => $composableBuilder(
    column: $table.hasUnreadMessages,
    builder: (column) => column,
  );

  GeneratedColumn<int> get unreadCount => $composableBuilder(
    column: $table.unreadCount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastMessagePreview => $composableBuilder(
    column: $table.lastMessagePreview,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastMessageAt => $composableBuilder(
    column: $table.lastMessageAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get cachedAt =>
      $composableBuilder(column: $table.cachedAt, builder: (column) => column);
}

class $$CachedConversationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CachedConversationsTable,
          CachedConversation,
          $$CachedConversationsTableFilterComposer,
          $$CachedConversationsTableOrderingComposer,
          $$CachedConversationsTableAnnotationComposer,
          $$CachedConversationsTableCreateCompanionBuilder,
          $$CachedConversationsTableUpdateCompanionBuilder,
          (
            CachedConversation,
            BaseReferences<
              _$AppDatabase,
              $CachedConversationsTable,
              CachedConversation
            >,
          ),
          CachedConversation,
          PrefetchHooks Function()
        > {
  $$CachedConversationsTableTableManager(
    _$AppDatabase db,
    $CachedConversationsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CachedConversationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CachedConversationsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$CachedConversationsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> partnerUserId = const Value.absent(),
                Value<String?> partnerNickname = const Value.absent(),
                Value<String?> partnerGender = const Value.absent(),
                Value<String?> partnerProfileImageUrl = const Value.absent(),
                Value<int?> broadcastId = const Value.absent(),
                Value<bool> isFavorite = const Value.absent(),
                Value<bool> hasUnreadMessages = const Value.absent(),
                Value<int> unreadCount = const Value.absent(),
                Value<String?> lastMessagePreview = const Value.absent(),
                Value<DateTime?> lastMessageAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<DateTime> cachedAt = const Value.absent(),
              }) => CachedConversationsCompanion(
                id: id,
                partnerUserId: partnerUserId,
                partnerNickname: partnerNickname,
                partnerGender: partnerGender,
                partnerProfileImageUrl: partnerProfileImageUrl,
                broadcastId: broadcastId,
                isFavorite: isFavorite,
                hasUnreadMessages: hasUnreadMessages,
                unreadCount: unreadCount,
                lastMessagePreview: lastMessagePreview,
                lastMessageAt: lastMessageAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                cachedAt: cachedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> partnerUserId = const Value.absent(),
                Value<String?> partnerNickname = const Value.absent(),
                Value<String?> partnerGender = const Value.absent(),
                Value<String?> partnerProfileImageUrl = const Value.absent(),
                Value<int?> broadcastId = const Value.absent(),
                Value<bool> isFavorite = const Value.absent(),
                Value<bool> hasUnreadMessages = const Value.absent(),
                Value<int> unreadCount = const Value.absent(),
                Value<String?> lastMessagePreview = const Value.absent(),
                Value<DateTime?> lastMessageAt = const Value.absent(),
                required DateTime createdAt,
                Value<DateTime?> updatedAt = const Value.absent(),
                required DateTime cachedAt,
              }) => CachedConversationsCompanion.insert(
                id: id,
                partnerUserId: partnerUserId,
                partnerNickname: partnerNickname,
                partnerGender: partnerGender,
                partnerProfileImageUrl: partnerProfileImageUrl,
                broadcastId: broadcastId,
                isFavorite: isFavorite,
                hasUnreadMessages: hasUnreadMessages,
                unreadCount: unreadCount,
                lastMessagePreview: lastMessagePreview,
                lastMessageAt: lastMessageAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                cachedAt: cachedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CachedConversationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CachedConversationsTable,
      CachedConversation,
      $$CachedConversationsTableFilterComposer,
      $$CachedConversationsTableOrderingComposer,
      $$CachedConversationsTableAnnotationComposer,
      $$CachedConversationsTableCreateCompanionBuilder,
      $$CachedConversationsTableUpdateCompanionBuilder,
      (
        CachedConversation,
        BaseReferences<
          _$AppDatabase,
          $CachedConversationsTable,
          CachedConversation
        >,
      ),
      CachedConversation,
      PrefetchHooks Function()
    >;
typedef $$CachedMessagesTableCreateCompanionBuilder =
    CachedMessagesCompanion Function({
      Value<int> id,
      required int conversationId,
      required int senderId,
      Value<String?> content,
      Value<String?> voiceUrl,
      Value<int?> duration,
      Value<String> messageType,
      Value<int?> broadcastId,
      Value<bool> isRead,
      required DateTime createdAt,
      Value<DateTime?> updatedAt,
      required DateTime cachedAt,
    });
typedef $$CachedMessagesTableUpdateCompanionBuilder =
    CachedMessagesCompanion Function({
      Value<int> id,
      Value<int> conversationId,
      Value<int> senderId,
      Value<String?> content,
      Value<String?> voiceUrl,
      Value<int?> duration,
      Value<String> messageType,
      Value<int?> broadcastId,
      Value<bool> isRead,
      Value<DateTime> createdAt,
      Value<DateTime?> updatedAt,
      Value<DateTime> cachedAt,
    });

class $$CachedMessagesTableFilterComposer
    extends Composer<_$AppDatabase, $CachedMessagesTable> {
  $$CachedMessagesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get conversationId => $composableBuilder(
    column: $table.conversationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get senderId => $composableBuilder(
    column: $table.senderId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get voiceUrl => $composableBuilder(
    column: $table.voiceUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get duration => $composableBuilder(
    column: $table.duration,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get messageType => $composableBuilder(
    column: $table.messageType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get broadcastId => $composableBuilder(
    column: $table.broadcastId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isRead => $composableBuilder(
    column: $table.isRead,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get cachedAt => $composableBuilder(
    column: $table.cachedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CachedMessagesTableOrderingComposer
    extends Composer<_$AppDatabase, $CachedMessagesTable> {
  $$CachedMessagesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get conversationId => $composableBuilder(
    column: $table.conversationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get senderId => $composableBuilder(
    column: $table.senderId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get voiceUrl => $composableBuilder(
    column: $table.voiceUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get duration => $composableBuilder(
    column: $table.duration,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get messageType => $composableBuilder(
    column: $table.messageType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get broadcastId => $composableBuilder(
    column: $table.broadcastId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isRead => $composableBuilder(
    column: $table.isRead,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get cachedAt => $composableBuilder(
    column: $table.cachedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CachedMessagesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CachedMessagesTable> {
  $$CachedMessagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get conversationId => $composableBuilder(
    column: $table.conversationId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get senderId =>
      $composableBuilder(column: $table.senderId, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<String> get voiceUrl =>
      $composableBuilder(column: $table.voiceUrl, builder: (column) => column);

  GeneratedColumn<int> get duration =>
      $composableBuilder(column: $table.duration, builder: (column) => column);

  GeneratedColumn<String> get messageType => $composableBuilder(
    column: $table.messageType,
    builder: (column) => column,
  );

  GeneratedColumn<int> get broadcastId => $composableBuilder(
    column: $table.broadcastId,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isRead =>
      $composableBuilder(column: $table.isRead, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get cachedAt =>
      $composableBuilder(column: $table.cachedAt, builder: (column) => column);
}

class $$CachedMessagesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CachedMessagesTable,
          CachedMessage,
          $$CachedMessagesTableFilterComposer,
          $$CachedMessagesTableOrderingComposer,
          $$CachedMessagesTableAnnotationComposer,
          $$CachedMessagesTableCreateCompanionBuilder,
          $$CachedMessagesTableUpdateCompanionBuilder,
          (
            CachedMessage,
            BaseReferences<_$AppDatabase, $CachedMessagesTable, CachedMessage>,
          ),
          CachedMessage,
          PrefetchHooks Function()
        > {
  $$CachedMessagesTableTableManager(
    _$AppDatabase db,
    $CachedMessagesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CachedMessagesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CachedMessagesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CachedMessagesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> conversationId = const Value.absent(),
                Value<int> senderId = const Value.absent(),
                Value<String?> content = const Value.absent(),
                Value<String?> voiceUrl = const Value.absent(),
                Value<int?> duration = const Value.absent(),
                Value<String> messageType = const Value.absent(),
                Value<int?> broadcastId = const Value.absent(),
                Value<bool> isRead = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<DateTime> cachedAt = const Value.absent(),
              }) => CachedMessagesCompanion(
                id: id,
                conversationId: conversationId,
                senderId: senderId,
                content: content,
                voiceUrl: voiceUrl,
                duration: duration,
                messageType: messageType,
                broadcastId: broadcastId,
                isRead: isRead,
                createdAt: createdAt,
                updatedAt: updatedAt,
                cachedAt: cachedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int conversationId,
                required int senderId,
                Value<String?> content = const Value.absent(),
                Value<String?> voiceUrl = const Value.absent(),
                Value<int?> duration = const Value.absent(),
                Value<String> messageType = const Value.absent(),
                Value<int?> broadcastId = const Value.absent(),
                Value<bool> isRead = const Value.absent(),
                required DateTime createdAt,
                Value<DateTime?> updatedAt = const Value.absent(),
                required DateTime cachedAt,
              }) => CachedMessagesCompanion.insert(
                id: id,
                conversationId: conversationId,
                senderId: senderId,
                content: content,
                voiceUrl: voiceUrl,
                duration: duration,
                messageType: messageType,
                broadcastId: broadcastId,
                isRead: isRead,
                createdAt: createdAt,
                updatedAt: updatedAt,
                cachedAt: cachedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CachedMessagesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CachedMessagesTable,
      CachedMessage,
      $$CachedMessagesTableFilterComposer,
      $$CachedMessagesTableOrderingComposer,
      $$CachedMessagesTableAnnotationComposer,
      $$CachedMessagesTableCreateCompanionBuilder,
      $$CachedMessagesTableUpdateCompanionBuilder,
      (
        CachedMessage,
        BaseReferences<_$AppDatabase, $CachedMessagesTable, CachedMessage>,
      ),
      CachedMessage,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$AudioCacheEntriesTableTableManager get audioCacheEntries =>
      $$AudioCacheEntriesTableTableManager(_db, _db.audioCacheEntries);
  $$CachedBroadcastsTableTableManager get cachedBroadcasts =>
      $$CachedBroadcastsTableTableManager(_db, _db.cachedBroadcasts);
  $$CachedConversationsTableTableManager get cachedConversations =>
      $$CachedConversationsTableTableManager(_db, _db.cachedConversations);
  $$CachedMessagesTableTableManager get cachedMessages =>
      $$CachedMessagesTableTableManager(_db, _db.cachedMessages);
}
