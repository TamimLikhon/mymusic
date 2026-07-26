// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'song_tag_dao.dart';

// ignore_for_file: type=lint
mixin _$SongTagDaoMixin on DatabaseAccessor<AppDatabase> {
  $SongsTable get songs => attachedDatabase.songs;
  $TagsTable get tags => attachedDatabase.tags;
  $SongTagsTable get songTags => attachedDatabase.songTags;
  SongTagDaoManager get managers => SongTagDaoManager(this);
}

class SongTagDaoManager {
  final _$SongTagDaoMixin _db;
  SongTagDaoManager(this._db);
  $$SongsTableTableManager get songs =>
      $$SongsTableTableManager(_db.attachedDatabase, _db.songs);
  $$TagsTableTableManager get tags =>
      $$TagsTableTableManager(_db.attachedDatabase, _db.tags);
  $$SongTagsTableTableManager get songTags =>
      $$SongTagsTableTableManager(_db.attachedDatabase, _db.songTags);
}
