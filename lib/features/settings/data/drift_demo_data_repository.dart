import 'package:field_service_tracker/database/app_database.dart';
import 'package:field_service_tracker/database/database_error_mapper.dart';
import 'package:field_service_tracker/features/settings/domain/demo_data_repository.dart';

/// Drift implementation of [DemoDataRepository].
final class DriftDemoDataRepository implements DemoDataRepository {
  DriftDemoDataRepository(this._database, this._seed);

  final AppDatabase _database;
  final DatabaseSeeder _seed;

  @override
  Future<void> resetDemoData() => guardDatabase(
    // One transaction: if seeding fails, the deletions roll back too and the
    // user keeps the previous data.
    () => _database.transaction(() async {
      await _database.deleteAllData();
      await _seed(_database);
    }),
  );
}
