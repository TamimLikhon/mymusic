import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/tags_table.dart';

part 'tag_dao.g.dart';

@DriftAccessor(tables: [Tags])
class TagDao extends DatabaseAccessor<AppDatabase> with _$TagDaoMixin {
  TagDao(super.db);

  Future<List<Tag>> getAllTags() => select(tags).get();

  Stream<List<Tag>> watchAllTags() => select(tags).watch();

  Future<Tag?> getTagById(String id) =>
      (select(tags)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<int> insertTag(TagsCompanion entry) =>
      into(tags).insert(entry, mode: InsertMode.insertOrReplace);

  Future<int> updateTag(String id, TagsCompanion entry) =>
      (update(tags)..where((t) => t.id.equals(id))).write(entry);

  Future<int> deleteTag(String id) =>
      (delete(tags)..where((t) => t.id.equals(id))).go();

  Future<int> deleteAllTags() => delete(tags).go();
}
