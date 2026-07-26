import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/songs_table.dart';
import '../tables/tags_table.dart';
import '../tables/song_tags_table.dart';

part 'song_tag_dao.g.dart';

@DriftAccessor(tables: [SongTags, Songs, Tags])
class SongTagDao extends DatabaseAccessor<AppDatabase> with _$SongTagDaoMixin {
  SongTagDao(super.db);

  Future<void> assignSongToTag(String songId, String tagId) {
    return into(songTags).insert(
      SongTagsCompanion(
        song_id: Value(songId),
        tag_id: Value(tagId),
        added_at: Value(DateTime.now().millisecondsSinceEpoch),
      ),
      mode: InsertMode.insertOrReplace,
    );
  }

  Future<void> removeSongFromTag(String songId) {
    return (delete(songTags)..where((st) => st.song_id.equals(songId))).go();
  }

  Future<int> deleteAllSongTags() => delete(songTags).go();

  Future<List<Song>> getSongsForTag(String tagId) async {
    final query = select(songs).join([
      innerJoin(songTags, songTags.song_id.equalsExp(songs.id)),
    ])
      ..where(songTags.tag_id.equals(tagId))
      ..orderBy([OrderingTerm.desc(songTags.added_at)]);

    final results = await query.get();
    return results.map((row) => row.readTable(songs)).toList();
  }

  Future<Tag?> getTagForSong(String songId) async {
    final query = select(tags).join([
      innerJoin(songTags, songTags.tag_id.equalsExp(tags.id)),
    ])
      ..where(songTags.song_id.equals(songId));

    final results = await query.get();
    if (results.isEmpty) return null;
    return results.first.readTable(tags);
  }

  Future<Map<String, int>> getTagSongCounts() async {
    final query = select(songTags).join([
      innerJoin(tags, tags.id.equalsExp(songTags.tag_id)),
    ]);

    final results = await query.get();
    final counts = <String, int>{};
    for (final row in results) {
      final tagId = row.readTable(songTags).tag_id;
      counts[tagId] = (counts[tagId] ?? 0) + 1;
    }
    return counts;
  }
}
