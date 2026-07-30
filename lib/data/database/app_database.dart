import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'dart:io';

import 'tables/songs_table.dart';
import 'tables/tags_table.dart';
import 'tables/song_tags_table.dart';
import 'daos/song_dao.dart';
import 'daos/tag_dao.dart';
import 'daos/song_tag_dao.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [Songs, Tags, SongTags], daos: [SongDao, TagDao, SongTagDao])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onUpgrade: (migrator, from, to) async {
          if (from < 2) {
            await migrator.addColumn(songs, songs.custom_art_path);
          }
        },
      );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'mymusic.sqlite'));
    return NativeDatabase(file);
  });
}
