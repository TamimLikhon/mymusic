import 'package:drift/drift.dart';

// ignore_for_file: non_constant_identifier_names

class Songs extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get artist => text().withDefault(const Constant('Unknown'))();
  TextColumn get album => text().withDefault(const Constant('Unknown'))();
  IntColumn get duration => integer()();
  TextColumn get file_path => text()();
  IntColumn get file_size => integer().withDefault(const Constant(0))();
  IntColumn get added_at => integer()();
  IntColumn get last_played => integer().nullable()();
  TextColumn get custom_art_path => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
