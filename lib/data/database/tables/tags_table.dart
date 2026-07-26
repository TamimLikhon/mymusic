import 'package:drift/drift.dart';

// ignore_for_file: non_constant_identifier_names

class Tags extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  IntColumn get color => integer().withDefault(const Constant(0xFFE8A838))();
  TextColumn get icon => text().nullable()();
  IntColumn get created_at => integer()();
  IntColumn get updated_at => integer()();

  @override
  Set<Column> get primaryKey => {id};
}
