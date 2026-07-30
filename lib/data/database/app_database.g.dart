// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $SongsTable extends Songs with TableInfo<$SongsTable, Song> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SongsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _artistMeta = const VerificationMeta('artist');
  @override
  late final GeneratedColumn<String> artist = GeneratedColumn<String>(
    'artist',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('Unknown'),
  );
  static const VerificationMeta _albumMeta = const VerificationMeta('album');
  @override
  late final GeneratedColumn<String> album = GeneratedColumn<String>(
    'album',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('Unknown'),
  );
  static const VerificationMeta _durationMeta = const VerificationMeta(
    'duration',
  );
  @override
  late final GeneratedColumn<int> duration = GeneratedColumn<int>(
    'duration',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _file_pathMeta = const VerificationMeta(
    'file_path',
  );
  @override
  late final GeneratedColumn<String> file_path = GeneratedColumn<String>(
    'file_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _file_sizeMeta = const VerificationMeta(
    'file_size',
  );
  @override
  late final GeneratedColumn<int> file_size = GeneratedColumn<int>(
    'file_size',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _added_atMeta = const VerificationMeta(
    'added_at',
  );
  @override
  late final GeneratedColumn<int> added_at = GeneratedColumn<int>(
    'added_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _last_playedMeta = const VerificationMeta(
    'last_played',
  );
  @override
  late final GeneratedColumn<int> last_played = GeneratedColumn<int>(
    'last_played',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _custom_art_pathMeta = const VerificationMeta(
    'custom_art_path',
  );
  @override
  late final GeneratedColumn<String> custom_art_path = GeneratedColumn<String>(
    'custom_art_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    artist,
    album,
    duration,
    file_path,
    file_size,
    added_at,
    last_played,
    custom_art_path,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'songs';
  @override
  VerificationContext validateIntegrity(
    Insertable<Song> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('artist')) {
      context.handle(
        _artistMeta,
        artist.isAcceptableOrUnknown(data['artist']!, _artistMeta),
      );
    }
    if (data.containsKey('album')) {
      context.handle(
        _albumMeta,
        album.isAcceptableOrUnknown(data['album']!, _albumMeta),
      );
    }
    if (data.containsKey('duration')) {
      context.handle(
        _durationMeta,
        duration.isAcceptableOrUnknown(data['duration']!, _durationMeta),
      );
    } else if (isInserting) {
      context.missing(_durationMeta);
    }
    if (data.containsKey('file_path')) {
      context.handle(
        _file_pathMeta,
        file_path.isAcceptableOrUnknown(data['file_path']!, _file_pathMeta),
      );
    } else if (isInserting) {
      context.missing(_file_pathMeta);
    }
    if (data.containsKey('file_size')) {
      context.handle(
        _file_sizeMeta,
        file_size.isAcceptableOrUnknown(data['file_size']!, _file_sizeMeta),
      );
    }
    if (data.containsKey('added_at')) {
      context.handle(
        _added_atMeta,
        added_at.isAcceptableOrUnknown(data['added_at']!, _added_atMeta),
      );
    } else if (isInserting) {
      context.missing(_added_atMeta);
    }
    if (data.containsKey('last_played')) {
      context.handle(
        _last_playedMeta,
        last_played.isAcceptableOrUnknown(
          data['last_played']!,
          _last_playedMeta,
        ),
      );
    }
    if (data.containsKey('custom_art_path')) {
      context.handle(
        _custom_art_pathMeta,
        custom_art_path.isAcceptableOrUnknown(
          data['custom_art_path']!,
          _custom_art_pathMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Song map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Song(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      artist: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}artist'],
      )!,
      album: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}album'],
      )!,
      duration: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration'],
      )!,
      file_path: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_path'],
      )!,
      file_size: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}file_size'],
      )!,
      added_at: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}added_at'],
      )!,
      last_played: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_played'],
      ),
      custom_art_path: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}custom_art_path'],
      ),
    );
  }

  @override
  $SongsTable createAlias(String alias) {
    return $SongsTable(attachedDatabase, alias);
  }
}

class Song extends DataClass implements Insertable<Song> {
  final String id;
  final String title;
  final String artist;
  final String album;
  final int duration;
  final String file_path;
  final int file_size;
  final int added_at;
  final int? last_played;
  final String? custom_art_path;
  const Song({
    required this.id,
    required this.title,
    required this.artist,
    required this.album,
    required this.duration,
    required this.file_path,
    required this.file_size,
    required this.added_at,
    this.last_played,
    this.custom_art_path,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['artist'] = Variable<String>(artist);
    map['album'] = Variable<String>(album);
    map['duration'] = Variable<int>(duration);
    map['file_path'] = Variable<String>(file_path);
    map['file_size'] = Variable<int>(file_size);
    map['added_at'] = Variable<int>(added_at);
    if (!nullToAbsent || last_played != null) {
      map['last_played'] = Variable<int>(last_played);
    }
    if (!nullToAbsent || custom_art_path != null) {
      map['custom_art_path'] = Variable<String>(custom_art_path);
    }
    return map;
  }

  SongsCompanion toCompanion(bool nullToAbsent) {
    return SongsCompanion(
      id: Value(id),
      title: Value(title),
      artist: Value(artist),
      album: Value(album),
      duration: Value(duration),
      file_path: Value(file_path),
      file_size: Value(file_size),
      added_at: Value(added_at),
      last_played: last_played == null && nullToAbsent
          ? const Value.absent()
          : Value(last_played),
      custom_art_path: custom_art_path == null && nullToAbsent
          ? const Value.absent()
          : Value(custom_art_path),
    );
  }

  factory Song.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Song(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      artist: serializer.fromJson<String>(json['artist']),
      album: serializer.fromJson<String>(json['album']),
      duration: serializer.fromJson<int>(json['duration']),
      file_path: serializer.fromJson<String>(json['file_path']),
      file_size: serializer.fromJson<int>(json['file_size']),
      added_at: serializer.fromJson<int>(json['added_at']),
      last_played: serializer.fromJson<int?>(json['last_played']),
      custom_art_path: serializer.fromJson<String?>(json['custom_art_path']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'artist': serializer.toJson<String>(artist),
      'album': serializer.toJson<String>(album),
      'duration': serializer.toJson<int>(duration),
      'file_path': serializer.toJson<String>(file_path),
      'file_size': serializer.toJson<int>(file_size),
      'added_at': serializer.toJson<int>(added_at),
      'last_played': serializer.toJson<int?>(last_played),
      'custom_art_path': serializer.toJson<String?>(custom_art_path),
    };
  }

  Song copyWith({
    String? id,
    String? title,
    String? artist,
    String? album,
    int? duration,
    String? file_path,
    int? file_size,
    int? added_at,
    Value<int?> last_played = const Value.absent(),
    Value<String?> custom_art_path = const Value.absent(),
  }) => Song(
    id: id ?? this.id,
    title: title ?? this.title,
    artist: artist ?? this.artist,
    album: album ?? this.album,
    duration: duration ?? this.duration,
    file_path: file_path ?? this.file_path,
    file_size: file_size ?? this.file_size,
    added_at: added_at ?? this.added_at,
    last_played: last_played.present ? last_played.value : this.last_played,
    custom_art_path: custom_art_path.present
        ? custom_art_path.value
        : this.custom_art_path,
  );
  Song copyWithCompanion(SongsCompanion data) {
    return Song(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      artist: data.artist.present ? data.artist.value : this.artist,
      album: data.album.present ? data.album.value : this.album,
      duration: data.duration.present ? data.duration.value : this.duration,
      file_path: data.file_path.present ? data.file_path.value : this.file_path,
      file_size: data.file_size.present ? data.file_size.value : this.file_size,
      added_at: data.added_at.present ? data.added_at.value : this.added_at,
      last_played: data.last_played.present
          ? data.last_played.value
          : this.last_played,
      custom_art_path: data.custom_art_path.present
          ? data.custom_art_path.value
          : this.custom_art_path,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Song(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('artist: $artist, ')
          ..write('album: $album, ')
          ..write('duration: $duration, ')
          ..write('file_path: $file_path, ')
          ..write('file_size: $file_size, ')
          ..write('added_at: $added_at, ')
          ..write('last_played: $last_played, ')
          ..write('custom_art_path: $custom_art_path')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    artist,
    album,
    duration,
    file_path,
    file_size,
    added_at,
    last_played,
    custom_art_path,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Song &&
          other.id == this.id &&
          other.title == this.title &&
          other.artist == this.artist &&
          other.album == this.album &&
          other.duration == this.duration &&
          other.file_path == this.file_path &&
          other.file_size == this.file_size &&
          other.added_at == this.added_at &&
          other.last_played == this.last_played &&
          other.custom_art_path == this.custom_art_path);
}

class SongsCompanion extends UpdateCompanion<Song> {
  final Value<String> id;
  final Value<String> title;
  final Value<String> artist;
  final Value<String> album;
  final Value<int> duration;
  final Value<String> file_path;
  final Value<int> file_size;
  final Value<int> added_at;
  final Value<int?> last_played;
  final Value<String?> custom_art_path;
  final Value<int> rowid;
  const SongsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.artist = const Value.absent(),
    this.album = const Value.absent(),
    this.duration = const Value.absent(),
    this.file_path = const Value.absent(),
    this.file_size = const Value.absent(),
    this.added_at = const Value.absent(),
    this.last_played = const Value.absent(),
    this.custom_art_path = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SongsCompanion.insert({
    required String id,
    required String title,
    this.artist = const Value.absent(),
    this.album = const Value.absent(),
    required int duration,
    required String file_path,
    this.file_size = const Value.absent(),
    required int added_at,
    this.last_played = const Value.absent(),
    this.custom_art_path = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       duration = Value(duration),
       file_path = Value(file_path),
       added_at = Value(added_at);
  static Insertable<Song> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? artist,
    Expression<String>? album,
    Expression<int>? duration,
    Expression<String>? file_path,
    Expression<int>? file_size,
    Expression<int>? added_at,
    Expression<int>? last_played,
    Expression<String>? custom_art_path,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (artist != null) 'artist': artist,
      if (album != null) 'album': album,
      if (duration != null) 'duration': duration,
      if (file_path != null) 'file_path': file_path,
      if (file_size != null) 'file_size': file_size,
      if (added_at != null) 'added_at': added_at,
      if (last_played != null) 'last_played': last_played,
      if (custom_art_path != null) 'custom_art_path': custom_art_path,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SongsCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<String>? artist,
    Value<String>? album,
    Value<int>? duration,
    Value<String>? file_path,
    Value<int>? file_size,
    Value<int>? added_at,
    Value<int?>? last_played,
    Value<String?>? custom_art_path,
    Value<int>? rowid,
  }) {
    return SongsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      album: album ?? this.album,
      duration: duration ?? this.duration,
      file_path: file_path ?? this.file_path,
      file_size: file_size ?? this.file_size,
      added_at: added_at ?? this.added_at,
      last_played: last_played ?? this.last_played,
      custom_art_path: custom_art_path ?? this.custom_art_path,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (artist.present) {
      map['artist'] = Variable<String>(artist.value);
    }
    if (album.present) {
      map['album'] = Variable<String>(album.value);
    }
    if (duration.present) {
      map['duration'] = Variable<int>(duration.value);
    }
    if (file_path.present) {
      map['file_path'] = Variable<String>(file_path.value);
    }
    if (file_size.present) {
      map['file_size'] = Variable<int>(file_size.value);
    }
    if (added_at.present) {
      map['added_at'] = Variable<int>(added_at.value);
    }
    if (last_played.present) {
      map['last_played'] = Variable<int>(last_played.value);
    }
    if (custom_art_path.present) {
      map['custom_art_path'] = Variable<String>(custom_art_path.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SongsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('artist: $artist, ')
          ..write('album: $album, ')
          ..write('duration: $duration, ')
          ..write('file_path: $file_path, ')
          ..write('file_size: $file_size, ')
          ..write('added_at: $added_at, ')
          ..write('last_played: $last_played, ')
          ..write('custom_art_path: $custom_art_path, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TagsTable extends Tags with TableInfo<$TagsTable, Tag> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TagsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<int> color = GeneratedColumn<int>(
    'color',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0xFFE8A838),
  );
  static const VerificationMeta _iconMeta = const VerificationMeta('icon');
  @override
  late final GeneratedColumn<String> icon = GeneratedColumn<String>(
    'icon',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _created_atMeta = const VerificationMeta(
    'created_at',
  );
  @override
  late final GeneratedColumn<int> created_at = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updated_atMeta = const VerificationMeta(
    'updated_at',
  );
  @override
  late final GeneratedColumn<int> updated_at = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    color,
    icon,
    created_at,
    updated_at,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tags';
  @override
  VerificationContext validateIntegrity(
    Insertable<Tag> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('color')) {
      context.handle(
        _colorMeta,
        color.isAcceptableOrUnknown(data['color']!, _colorMeta),
      );
    }
    if (data.containsKey('icon')) {
      context.handle(
        _iconMeta,
        icon.isAcceptableOrUnknown(data['icon']!, _iconMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _created_atMeta,
        created_at.isAcceptableOrUnknown(data['created_at']!, _created_atMeta),
      );
    } else if (isInserting) {
      context.missing(_created_atMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updated_atMeta,
        updated_at.isAcceptableOrUnknown(data['updated_at']!, _updated_atMeta),
      );
    } else if (isInserting) {
      context.missing(_updated_atMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Tag map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Tag(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      color: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}color'],
      )!,
      icon: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon'],
      ),
      created_at: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updated_at: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $TagsTable createAlias(String alias) {
    return $TagsTable(attachedDatabase, alias);
  }
}

class Tag extends DataClass implements Insertable<Tag> {
  final String id;
  final String name;
  final int color;
  final String? icon;
  final int created_at;
  final int updated_at;
  const Tag({
    required this.id,
    required this.name,
    required this.color,
    this.icon,
    required this.created_at,
    required this.updated_at,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['color'] = Variable<int>(color);
    if (!nullToAbsent || icon != null) {
      map['icon'] = Variable<String>(icon);
    }
    map['created_at'] = Variable<int>(created_at);
    map['updated_at'] = Variable<int>(updated_at);
    return map;
  }

  TagsCompanion toCompanion(bool nullToAbsent) {
    return TagsCompanion(
      id: Value(id),
      name: Value(name),
      color: Value(color),
      icon: icon == null && nullToAbsent ? const Value.absent() : Value(icon),
      created_at: Value(created_at),
      updated_at: Value(updated_at),
    );
  }

  factory Tag.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Tag(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      color: serializer.fromJson<int>(json['color']),
      icon: serializer.fromJson<String?>(json['icon']),
      created_at: serializer.fromJson<int>(json['created_at']),
      updated_at: serializer.fromJson<int>(json['updated_at']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'color': serializer.toJson<int>(color),
      'icon': serializer.toJson<String?>(icon),
      'created_at': serializer.toJson<int>(created_at),
      'updated_at': serializer.toJson<int>(updated_at),
    };
  }

  Tag copyWith({
    String? id,
    String? name,
    int? color,
    Value<String?> icon = const Value.absent(),
    int? created_at,
    int? updated_at,
  }) => Tag(
    id: id ?? this.id,
    name: name ?? this.name,
    color: color ?? this.color,
    icon: icon.present ? icon.value : this.icon,
    created_at: created_at ?? this.created_at,
    updated_at: updated_at ?? this.updated_at,
  );
  Tag copyWithCompanion(TagsCompanion data) {
    return Tag(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      color: data.color.present ? data.color.value : this.color,
      icon: data.icon.present ? data.icon.value : this.icon,
      created_at: data.created_at.present
          ? data.created_at.value
          : this.created_at,
      updated_at: data.updated_at.present
          ? data.updated_at.value
          : this.updated_at,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Tag(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('color: $color, ')
          ..write('icon: $icon, ')
          ..write('created_at: $created_at, ')
          ..write('updated_at: $updated_at')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, color, icon, created_at, updated_at);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Tag &&
          other.id == this.id &&
          other.name == this.name &&
          other.color == this.color &&
          other.icon == this.icon &&
          other.created_at == this.created_at &&
          other.updated_at == this.updated_at);
}

class TagsCompanion extends UpdateCompanion<Tag> {
  final Value<String> id;
  final Value<String> name;
  final Value<int> color;
  final Value<String?> icon;
  final Value<int> created_at;
  final Value<int> updated_at;
  final Value<int> rowid;
  const TagsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.color = const Value.absent(),
    this.icon = const Value.absent(),
    this.created_at = const Value.absent(),
    this.updated_at = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TagsCompanion.insert({
    required String id,
    required String name,
    this.color = const Value.absent(),
    this.icon = const Value.absent(),
    required int created_at,
    required int updated_at,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       created_at = Value(created_at),
       updated_at = Value(updated_at);
  static Insertable<Tag> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<int>? color,
    Expression<String>? icon,
    Expression<int>? created_at,
    Expression<int>? updated_at,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (color != null) 'color': color,
      if (icon != null) 'icon': icon,
      if (created_at != null) 'created_at': created_at,
      if (updated_at != null) 'updated_at': updated_at,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TagsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<int>? color,
    Value<String?>? icon,
    Value<int>? created_at,
    Value<int>? updated_at,
    Value<int>? rowid,
  }) {
    return TagsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      created_at: created_at ?? this.created_at,
      updated_at: updated_at ?? this.updated_at,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (color.present) {
      map['color'] = Variable<int>(color.value);
    }
    if (icon.present) {
      map['icon'] = Variable<String>(icon.value);
    }
    if (created_at.present) {
      map['created_at'] = Variable<int>(created_at.value);
    }
    if (updated_at.present) {
      map['updated_at'] = Variable<int>(updated_at.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TagsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('color: $color, ')
          ..write('icon: $icon, ')
          ..write('created_at: $created_at, ')
          ..write('updated_at: $updated_at, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SongTagsTable extends SongTags with TableInfo<$SongTagsTable, SongTag> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SongTagsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _song_idMeta = const VerificationMeta(
    'song_id',
  );
  @override
  late final GeneratedColumn<String> song_id = GeneratedColumn<String>(
    'song_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES songs (id)',
    ),
  );
  static const VerificationMeta _tag_idMeta = const VerificationMeta('tag_id');
  @override
  late final GeneratedColumn<String> tag_id = GeneratedColumn<String>(
    'tag_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES tags (id)',
    ),
  );
  static const VerificationMeta _added_atMeta = const VerificationMeta(
    'added_at',
  );
  @override
  late final GeneratedColumn<int> added_at = GeneratedColumn<int>(
    'added_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [song_id, tag_id, added_at];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'song_tags';
  @override
  VerificationContext validateIntegrity(
    Insertable<SongTag> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('song_id')) {
      context.handle(
        _song_idMeta,
        song_id.isAcceptableOrUnknown(data['song_id']!, _song_idMeta),
      );
    } else if (isInserting) {
      context.missing(_song_idMeta);
    }
    if (data.containsKey('tag_id')) {
      context.handle(
        _tag_idMeta,
        tag_id.isAcceptableOrUnknown(data['tag_id']!, _tag_idMeta),
      );
    } else if (isInserting) {
      context.missing(_tag_idMeta);
    }
    if (data.containsKey('added_at')) {
      context.handle(
        _added_atMeta,
        added_at.isAcceptableOrUnknown(data['added_at']!, _added_atMeta),
      );
    } else if (isInserting) {
      context.missing(_added_atMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {song_id};
  @override
  SongTag map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SongTag(
      song_id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}song_id'],
      )!,
      tag_id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tag_id'],
      )!,
      added_at: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}added_at'],
      )!,
    );
  }

  @override
  $SongTagsTable createAlias(String alias) {
    return $SongTagsTable(attachedDatabase, alias);
  }
}

class SongTag extends DataClass implements Insertable<SongTag> {
  final String song_id;
  final String tag_id;
  final int added_at;
  const SongTag({
    required this.song_id,
    required this.tag_id,
    required this.added_at,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['song_id'] = Variable<String>(song_id);
    map['tag_id'] = Variable<String>(tag_id);
    map['added_at'] = Variable<int>(added_at);
    return map;
  }

  SongTagsCompanion toCompanion(bool nullToAbsent) {
    return SongTagsCompanion(
      song_id: Value(song_id),
      tag_id: Value(tag_id),
      added_at: Value(added_at),
    );
  }

  factory SongTag.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SongTag(
      song_id: serializer.fromJson<String>(json['song_id']),
      tag_id: serializer.fromJson<String>(json['tag_id']),
      added_at: serializer.fromJson<int>(json['added_at']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'song_id': serializer.toJson<String>(song_id),
      'tag_id': serializer.toJson<String>(tag_id),
      'added_at': serializer.toJson<int>(added_at),
    };
  }

  SongTag copyWith({String? song_id, String? tag_id, int? added_at}) => SongTag(
    song_id: song_id ?? this.song_id,
    tag_id: tag_id ?? this.tag_id,
    added_at: added_at ?? this.added_at,
  );
  SongTag copyWithCompanion(SongTagsCompanion data) {
    return SongTag(
      song_id: data.song_id.present ? data.song_id.value : this.song_id,
      tag_id: data.tag_id.present ? data.tag_id.value : this.tag_id,
      added_at: data.added_at.present ? data.added_at.value : this.added_at,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SongTag(')
          ..write('song_id: $song_id, ')
          ..write('tag_id: $tag_id, ')
          ..write('added_at: $added_at')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(song_id, tag_id, added_at);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SongTag &&
          other.song_id == this.song_id &&
          other.tag_id == this.tag_id &&
          other.added_at == this.added_at);
}

class SongTagsCompanion extends UpdateCompanion<SongTag> {
  final Value<String> song_id;
  final Value<String> tag_id;
  final Value<int> added_at;
  final Value<int> rowid;
  const SongTagsCompanion({
    this.song_id = const Value.absent(),
    this.tag_id = const Value.absent(),
    this.added_at = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SongTagsCompanion.insert({
    required String song_id,
    required String tag_id,
    required int added_at,
    this.rowid = const Value.absent(),
  }) : song_id = Value(song_id),
       tag_id = Value(tag_id),
       added_at = Value(added_at);
  static Insertable<SongTag> custom({
    Expression<String>? song_id,
    Expression<String>? tag_id,
    Expression<int>? added_at,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (song_id != null) 'song_id': song_id,
      if (tag_id != null) 'tag_id': tag_id,
      if (added_at != null) 'added_at': added_at,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SongTagsCompanion copyWith({
    Value<String>? song_id,
    Value<String>? tag_id,
    Value<int>? added_at,
    Value<int>? rowid,
  }) {
    return SongTagsCompanion(
      song_id: song_id ?? this.song_id,
      tag_id: tag_id ?? this.tag_id,
      added_at: added_at ?? this.added_at,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (song_id.present) {
      map['song_id'] = Variable<String>(song_id.value);
    }
    if (tag_id.present) {
      map['tag_id'] = Variable<String>(tag_id.value);
    }
    if (added_at.present) {
      map['added_at'] = Variable<int>(added_at.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SongTagsCompanion(')
          ..write('song_id: $song_id, ')
          ..write('tag_id: $tag_id, ')
          ..write('added_at: $added_at, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $SongsTable songs = $SongsTable(this);
  late final $TagsTable tags = $TagsTable(this);
  late final $SongTagsTable songTags = $SongTagsTable(this);
  late final SongDao songDao = SongDao(this as AppDatabase);
  late final TagDao tagDao = TagDao(this as AppDatabase);
  late final SongTagDao songTagDao = SongTagDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [songs, tags, songTags];
}

typedef $$SongsTableCreateCompanionBuilder =
    SongsCompanion Function({
      required String id,
      required String title,
      Value<String> artist,
      Value<String> album,
      required int duration,
      required String file_path,
      Value<int> file_size,
      required int added_at,
      Value<int?> last_played,
      Value<String?> custom_art_path,
      Value<int> rowid,
    });
typedef $$SongsTableUpdateCompanionBuilder =
    SongsCompanion Function({
      Value<String> id,
      Value<String> title,
      Value<String> artist,
      Value<String> album,
      Value<int> duration,
      Value<String> file_path,
      Value<int> file_size,
      Value<int> added_at,
      Value<int?> last_played,
      Value<String?> custom_art_path,
      Value<int> rowid,
    });

final class $$SongsTableReferences
    extends BaseReferences<_$AppDatabase, $SongsTable, Song> {
  $$SongsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$SongTagsTable, List<SongTag>> _songTagsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.songTags,
    aliasName: 'songs__id__song_tags__song_id',
  );

  $$SongTagsTableProcessedTableManager get songTagsRefs {
    final manager = $$SongTagsTableTableManager(
      $_db,
      $_db.songTags,
    ).filter((f) => f.song_id.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_songTagsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$SongsTableFilterComposer extends Composer<_$AppDatabase, $SongsTable> {
  $$SongsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get artist => $composableBuilder(
    column: $table.artist,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get album => $composableBuilder(
    column: $table.album,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get duration => $composableBuilder(
    column: $table.duration,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get file_path => $composableBuilder(
    column: $table.file_path,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get file_size => $composableBuilder(
    column: $table.file_size,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get added_at => $composableBuilder(
    column: $table.added_at,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get last_played => $composableBuilder(
    column: $table.last_played,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get custom_art_path => $composableBuilder(
    column: $table.custom_art_path,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> songTagsRefs(
    Expression<bool> Function($$SongTagsTableFilterComposer f) f,
  ) {
    final $$SongTagsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.songTags,
      getReferencedColumn: (t) => t.song_id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SongTagsTableFilterComposer(
            $db: $db,
            $table: $db.songTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SongsTableOrderingComposer
    extends Composer<_$AppDatabase, $SongsTable> {
  $$SongsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get artist => $composableBuilder(
    column: $table.artist,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get album => $composableBuilder(
    column: $table.album,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get duration => $composableBuilder(
    column: $table.duration,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get file_path => $composableBuilder(
    column: $table.file_path,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get file_size => $composableBuilder(
    column: $table.file_size,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get added_at => $composableBuilder(
    column: $table.added_at,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get last_played => $composableBuilder(
    column: $table.last_played,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get custom_art_path => $composableBuilder(
    column: $table.custom_art_path,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SongsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SongsTable> {
  $$SongsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get artist =>
      $composableBuilder(column: $table.artist, builder: (column) => column);

  GeneratedColumn<String> get album =>
      $composableBuilder(column: $table.album, builder: (column) => column);

  GeneratedColumn<int> get duration =>
      $composableBuilder(column: $table.duration, builder: (column) => column);

  GeneratedColumn<String> get file_path =>
      $composableBuilder(column: $table.file_path, builder: (column) => column);

  GeneratedColumn<int> get file_size =>
      $composableBuilder(column: $table.file_size, builder: (column) => column);

  GeneratedColumn<int> get added_at =>
      $composableBuilder(column: $table.added_at, builder: (column) => column);

  GeneratedColumn<int> get last_played => $composableBuilder(
    column: $table.last_played,
    builder: (column) => column,
  );

  GeneratedColumn<String> get custom_art_path => $composableBuilder(
    column: $table.custom_art_path,
    builder: (column) => column,
  );

  Expression<T> songTagsRefs<T extends Object>(
    Expression<T> Function($$SongTagsTableAnnotationComposer a) f,
  ) {
    final $$SongTagsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.songTags,
      getReferencedColumn: (t) => t.song_id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SongTagsTableAnnotationComposer(
            $db: $db,
            $table: $db.songTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SongsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SongsTable,
          Song,
          $$SongsTableFilterComposer,
          $$SongsTableOrderingComposer,
          $$SongsTableAnnotationComposer,
          $$SongsTableCreateCompanionBuilder,
          $$SongsTableUpdateCompanionBuilder,
          (Song, $$SongsTableReferences),
          Song,
          PrefetchHooks Function({bool songTagsRefs})
        > {
  $$SongsTableTableManager(_$AppDatabase db, $SongsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SongsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SongsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SongsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> artist = const Value.absent(),
                Value<String> album = const Value.absent(),
                Value<int> duration = const Value.absent(),
                Value<String> file_path = const Value.absent(),
                Value<int> file_size = const Value.absent(),
                Value<int> added_at = const Value.absent(),
                Value<int?> last_played = const Value.absent(),
                Value<String?> custom_art_path = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SongsCompanion(
                id: id,
                title: title,
                artist: artist,
                album: album,
                duration: duration,
                file_path: file_path,
                file_size: file_size,
                added_at: added_at,
                last_played: last_played,
                custom_art_path: custom_art_path,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                Value<String> artist = const Value.absent(),
                Value<String> album = const Value.absent(),
                required int duration,
                required String file_path,
                Value<int> file_size = const Value.absent(),
                required int added_at,
                Value<int?> last_played = const Value.absent(),
                Value<String?> custom_art_path = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SongsCompanion.insert(
                id: id,
                title: title,
                artist: artist,
                album: album,
                duration: duration,
                file_path: file_path,
                file_size: file_size,
                added_at: added_at,
                last_played: last_played,
                custom_art_path: custom_art_path,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$SongsTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({songTagsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (songTagsRefs) db.songTags],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (songTagsRefs)
                    await $_getPrefetchedData<Song, $SongsTable, SongTag>(
                      currentTable: table,
                      referencedTable: $$SongsTableReferences
                          ._songTagsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$SongsTableReferences(db, table, p0).songTagsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.song_id == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$SongsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SongsTable,
      Song,
      $$SongsTableFilterComposer,
      $$SongsTableOrderingComposer,
      $$SongsTableAnnotationComposer,
      $$SongsTableCreateCompanionBuilder,
      $$SongsTableUpdateCompanionBuilder,
      (Song, $$SongsTableReferences),
      Song,
      PrefetchHooks Function({bool songTagsRefs})
    >;
typedef $$TagsTableCreateCompanionBuilder =
    TagsCompanion Function({
      required String id,
      required String name,
      Value<int> color,
      Value<String?> icon,
      required int created_at,
      required int updated_at,
      Value<int> rowid,
    });
typedef $$TagsTableUpdateCompanionBuilder =
    TagsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<int> color,
      Value<String?> icon,
      Value<int> created_at,
      Value<int> updated_at,
      Value<int> rowid,
    });

final class $$TagsTableReferences
    extends BaseReferences<_$AppDatabase, $TagsTable, Tag> {
  $$TagsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$SongTagsTable, List<SongTag>> _songTagsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.songTags,
    aliasName: 'tags__id__song_tags__tag_id',
  );

  $$SongTagsTableProcessedTableManager get songTagsRefs {
    final manager = $$SongTagsTableTableManager(
      $_db,
      $_db.songTags,
    ).filter((f) => f.tag_id.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_songTagsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TagsTableFilterComposer extends Composer<_$AppDatabase, $TagsTable> {
  $$TagsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get created_at => $composableBuilder(
    column: $table.created_at,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updated_at => $composableBuilder(
    column: $table.updated_at,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> songTagsRefs(
    Expression<bool> Function($$SongTagsTableFilterComposer f) f,
  ) {
    final $$SongTagsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.songTags,
      getReferencedColumn: (t) => t.tag_id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SongTagsTableFilterComposer(
            $db: $db,
            $table: $db.songTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TagsTableOrderingComposer extends Composer<_$AppDatabase, $TagsTable> {
  $$TagsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get created_at => $composableBuilder(
    column: $table.created_at,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updated_at => $composableBuilder(
    column: $table.updated_at,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TagsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TagsTable> {
  $$TagsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<String> get icon =>
      $composableBuilder(column: $table.icon, builder: (column) => column);

  GeneratedColumn<int> get created_at => $composableBuilder(
    column: $table.created_at,
    builder: (column) => column,
  );

  GeneratedColumn<int> get updated_at => $composableBuilder(
    column: $table.updated_at,
    builder: (column) => column,
  );

  Expression<T> songTagsRefs<T extends Object>(
    Expression<T> Function($$SongTagsTableAnnotationComposer a) f,
  ) {
    final $$SongTagsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.songTags,
      getReferencedColumn: (t) => t.tag_id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SongTagsTableAnnotationComposer(
            $db: $db,
            $table: $db.songTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TagsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TagsTable,
          Tag,
          $$TagsTableFilterComposer,
          $$TagsTableOrderingComposer,
          $$TagsTableAnnotationComposer,
          $$TagsTableCreateCompanionBuilder,
          $$TagsTableUpdateCompanionBuilder,
          (Tag, $$TagsTableReferences),
          Tag,
          PrefetchHooks Function({bool songTagsRefs})
        > {
  $$TagsTableTableManager(_$AppDatabase db, $TagsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TagsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TagsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TagsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> color = const Value.absent(),
                Value<String?> icon = const Value.absent(),
                Value<int> created_at = const Value.absent(),
                Value<int> updated_at = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TagsCompanion(
                id: id,
                name: name,
                color: color,
                icon: icon,
                created_at: created_at,
                updated_at: updated_at,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<int> color = const Value.absent(),
                Value<String?> icon = const Value.absent(),
                required int created_at,
                required int updated_at,
                Value<int> rowid = const Value.absent(),
              }) => TagsCompanion.insert(
                id: id,
                name: name,
                color: color,
                icon: icon,
                created_at: created_at,
                updated_at: updated_at,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$TagsTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({songTagsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (songTagsRefs) db.songTags],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (songTagsRefs)
                    await $_getPrefetchedData<Tag, $TagsTable, SongTag>(
                      currentTable: table,
                      referencedTable: $$TagsTableReferences._songTagsRefsTable(
                        db,
                      ),
                      managerFromTypedResult: (p0) =>
                          $$TagsTableReferences(db, table, p0).songTagsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.tag_id == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$TagsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TagsTable,
      Tag,
      $$TagsTableFilterComposer,
      $$TagsTableOrderingComposer,
      $$TagsTableAnnotationComposer,
      $$TagsTableCreateCompanionBuilder,
      $$TagsTableUpdateCompanionBuilder,
      (Tag, $$TagsTableReferences),
      Tag,
      PrefetchHooks Function({bool songTagsRefs})
    >;
typedef $$SongTagsTableCreateCompanionBuilder =
    SongTagsCompanion Function({
      required String song_id,
      required String tag_id,
      required int added_at,
      Value<int> rowid,
    });
typedef $$SongTagsTableUpdateCompanionBuilder =
    SongTagsCompanion Function({
      Value<String> song_id,
      Value<String> tag_id,
      Value<int> added_at,
      Value<int> rowid,
    });

final class $$SongTagsTableReferences
    extends BaseReferences<_$AppDatabase, $SongTagsTable, SongTag> {
  $$SongTagsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SongsTable _song_idTable(_$AppDatabase db) =>
      db.songs.createAlias('song_tags__song_id__songs__id');

  $$SongsTableProcessedTableManager get song_id {
    final $_column = $_itemColumn<String>('song_id')!;

    final manager = $$SongsTableTableManager(
      $_db,
      $_db.songs,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_song_idTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $TagsTable _tag_idTable(_$AppDatabase db) =>
      db.tags.createAlias('song_tags__tag_id__tags__id');

  $$TagsTableProcessedTableManager get tag_id {
    final $_column = $_itemColumn<String>('tag_id')!;

    final manager = $$TagsTableTableManager(
      $_db,
      $_db.tags,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_tag_idTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$SongTagsTableFilterComposer
    extends Composer<_$AppDatabase, $SongTagsTable> {
  $$SongTagsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get added_at => $composableBuilder(
    column: $table.added_at,
    builder: (column) => ColumnFilters(column),
  );

  $$SongsTableFilterComposer get song_id {
    final $$SongsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.song_id,
      referencedTable: $db.songs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SongsTableFilterComposer(
            $db: $db,
            $table: $db.songs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TagsTableFilterComposer get tag_id {
    final $$TagsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tag_id,
      referencedTable: $db.tags,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TagsTableFilterComposer(
            $db: $db,
            $table: $db.tags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SongTagsTableOrderingComposer
    extends Composer<_$AppDatabase, $SongTagsTable> {
  $$SongTagsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get added_at => $composableBuilder(
    column: $table.added_at,
    builder: (column) => ColumnOrderings(column),
  );

  $$SongsTableOrderingComposer get song_id {
    final $$SongsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.song_id,
      referencedTable: $db.songs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SongsTableOrderingComposer(
            $db: $db,
            $table: $db.songs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TagsTableOrderingComposer get tag_id {
    final $$TagsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tag_id,
      referencedTable: $db.tags,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TagsTableOrderingComposer(
            $db: $db,
            $table: $db.tags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SongTagsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SongTagsTable> {
  $$SongTagsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get added_at =>
      $composableBuilder(column: $table.added_at, builder: (column) => column);

  $$SongsTableAnnotationComposer get song_id {
    final $$SongsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.song_id,
      referencedTable: $db.songs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SongsTableAnnotationComposer(
            $db: $db,
            $table: $db.songs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TagsTableAnnotationComposer get tag_id {
    final $$TagsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tag_id,
      referencedTable: $db.tags,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TagsTableAnnotationComposer(
            $db: $db,
            $table: $db.tags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SongTagsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SongTagsTable,
          SongTag,
          $$SongTagsTableFilterComposer,
          $$SongTagsTableOrderingComposer,
          $$SongTagsTableAnnotationComposer,
          $$SongTagsTableCreateCompanionBuilder,
          $$SongTagsTableUpdateCompanionBuilder,
          (SongTag, $$SongTagsTableReferences),
          SongTag,
          PrefetchHooks Function({bool song_id, bool tag_id})
        > {
  $$SongTagsTableTableManager(_$AppDatabase db, $SongTagsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SongTagsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SongTagsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SongTagsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> song_id = const Value.absent(),
                Value<String> tag_id = const Value.absent(),
                Value<int> added_at = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SongTagsCompanion(
                song_id: song_id,
                tag_id: tag_id,
                added_at: added_at,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String song_id,
                required String tag_id,
                required int added_at,
                Value<int> rowid = const Value.absent(),
              }) => SongTagsCompanion.insert(
                song_id: song_id,
                tag_id: tag_id,
                added_at: added_at,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SongTagsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({song_id = false, tag_id = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (song_id) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.song_id,
                                referencedTable: $$SongTagsTableReferences
                                    ._song_idTable(db),
                                referencedColumn: $$SongTagsTableReferences
                                    ._song_idTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (tag_id) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.tag_id,
                                referencedTable: $$SongTagsTableReferences
                                    ._tag_idTable(db),
                                referencedColumn: $$SongTagsTableReferences
                                    ._tag_idTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$SongTagsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SongTagsTable,
      SongTag,
      $$SongTagsTableFilterComposer,
      $$SongTagsTableOrderingComposer,
      $$SongTagsTableAnnotationComposer,
      $$SongTagsTableCreateCompanionBuilder,
      $$SongTagsTableUpdateCompanionBuilder,
      (SongTag, $$SongTagsTableReferences),
      SongTag,
      PrefetchHooks Function({bool song_id, bool tag_id})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$SongsTableTableManager get songs =>
      $$SongsTableTableManager(_db, _db.songs);
  $$TagsTableTableManager get tags => $$TagsTableTableManager(_db, _db.tags);
  $$SongTagsTableTableManager get songTags =>
      $$SongTagsTableTableManager(_db, _db.songTags);
}
