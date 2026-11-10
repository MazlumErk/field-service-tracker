import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:field_service_tracker/database/app_database.dart';

/// Fresh in-memory SQLite database (same schema and pragmas as production).
///
/// [seeder] runs on creation exactly like on a first install.
AppDatabase createTestDatabase({DatabaseSeeder? seeder}) {
  // Every test creates its own database on purpose.
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  return AppDatabase(NativeDatabase.memory(), seeder: seeder);
}
