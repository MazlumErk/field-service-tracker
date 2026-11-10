import 'package:field_service_tracker/core/clock/app_clock.dart';
import 'package:field_service_tracker/database/app_database.dart';
import 'package:field_service_tracker/database/seed/demo_seeder.dart';
import 'package:field_service_tracker/features/customers/data/drift_customer_repository.dart';
import 'package:field_service_tracker/features/customers/domain/customer_repository.dart';
import 'package:field_service_tracker/features/devices/data/drift_device_repository.dart';
import 'package:field_service_tracker/features/devices/domain/device_repository.dart';
import 'package:field_service_tracker/features/maintenance/data/drift_maintenance_repository.dart';
import 'package:field_service_tracker/features/maintenance/domain/maintenance_repository.dart';
import 'package:field_service_tracker/features/settings/data/drift_demo_data_repository.dart';
import 'package:field_service_tracker/features/settings/domain/demo_data_repository.dart';

/// App-wide singletons: the database and the repositories built on it.
///
/// Created once in `main` (or in tests with an in-memory database) and
/// exposed to the widget tree through `RepositoryProvider`s typed by their
/// *interfaces*, so presentation code never sees Drift.
final class AppDependencies {
  AppDependencies({required this.database, required AppClock clock})
    : customerRepository = DriftCustomerRepository(database, clock),
      deviceRepository = DriftDeviceRepository(database, clock),
      maintenanceRepository = DriftMaintenanceRepository(database, clock),
      demoDataRepository = DriftDemoDataRepository(
        database,
        DemoSeeder(clock).call,
      );

  /// Opens the on-device database (seeding it on first creation) and forces
  /// the connection open so that a broken database fails at startup, not on
  /// the first screen.
  static Future<AppDependencies> open({required AppClock clock}) async {
    final database = AppDatabase.open(seeder: DemoSeeder(clock).call);
    try {
      if (!await database.foreignKeysEnabled()) {
        throw StateError('SQLite foreign key enforcement is not active');
      }
    } catch (_) {
      await database.close();
      rethrow;
    }
    return AppDependencies(database: database, clock: clock);
  }

  final AppDatabase database;
  final CustomerRepository customerRepository;
  final DeviceRepository deviceRepository;
  final MaintenanceRepository maintenanceRepository;
  final DemoDataRepository demoDataRepository;

  /// Closes the database; open watch streams complete.
  Future<void> dispose() => database.close();
}
