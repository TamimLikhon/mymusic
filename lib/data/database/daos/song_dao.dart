import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/songs_table.dart';

part 'song_dao.g.dart';

@DriftAccessor(tables: [Songs])
class SongDao extends DatabaseAccessor<AppDatabase> with _$SongDaoMixin {
  SongDao(super.db);

  Future<List<Song>> getAllSongs() => select(songs).get();

  Stream<List<Song>> watchAllSongs() => select(songs).watch();

  Future<List<Song>> getRecentlyPlayed({int limit = 10}) {
    return (select(songs)
          ..where((s) => s.last_played.isNotNull())
          ..orderBy([(s) => OrderingTerm.desc(s.last_played)])
          ..limit(limit))
        .get();
  }

  Future<int> insertSong(SongsCompanion entry) =>
      into(songs).insert(entry, mode: InsertMode.insertOrReplace);

  Future<void> updateLastPlayed(String songId) {
    return (update(songs)..where((s) => s.id.equals(songId)))
        .write(SongsCompanion(
      last_played: Value(DateTime.now().millisecondsSinceEpoch),
    ));
  }

  Future<void> updateCustomArt(String songId, String? artPath) {
    return (update(songs)..where((s) => s.id.equals(songId)))
        .write(SongsCompanion(custom_art_path: Value(artPath)));
  }

  Future<int> deleteSong(String songId) =>
      (delete(songs)..where((s) => s.id.equals(songId))).go();

  Future<int> deleteAllSongs() => delete(songs).go();
}
