// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'song_dao.dart';

// ignore_for_file: type=lint
mixin _$SongDaoMixin on DatabaseAccessor<AppDatabase> {
  $SongsTable get songs => attachedDatabase.songs;
  SongDaoManager get managers => SongDaoManager(this);
}

class SongDaoManager {
  final _$SongDaoMixin _db;
  SongDaoManager(this._db);
  $$SongsTableTableManager get songs =>
      $$SongsTableTableManager(_db.attachedDatabase, _db.songs);
}
