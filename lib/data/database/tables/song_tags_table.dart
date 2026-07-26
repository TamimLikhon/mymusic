import 'package:drift/drift.dart';
import 'songs_table.dart';
import 'tags_table.dart';

// ignore_for_file: non_constant_identifier_names

class SongTags extends Table {
  TextColumn get song_id => text().references(Songs, #id)();
  TextColumn get tag_id => text().references(Tags, #id)();
  IntColumn get added_at => integer()();

  @override
  Set<Column> get primaryKey => {song_id};
}
