import 'package:drift_dev/api/migrations_native.dart';
import 'package:field_service_tracker/core/errors/app_exception.dart';
import 'package:field_service_tracker/core/utils/calendar_date.dart';
import 'package:field_service_tracker/database/app_database.dart';
import 'package:field_service_tracker/database/database_error_mapper.dart';
import 'package:field_service_tracker/features/maintenance/domain/filter_type.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_database.dart';
import 'generated_schema/schema.dart';

/// Raw inserts bypass repositories on purpose: these tests prove that the
/// *schema* enforces integrity even if application validation were skipped.
void main() {
  late AppDatabase db;
  final now = DateTime.utc(2026, 1, 15, 10);
  final day = CalendarDate(2026, 1, 15);

  setUp(() => db = createTestDatabase());
  tearDown(() => db.close());

  Future<int> insertCustomer({String number = 'FST-0001'}) => db
      .into(db.customers)
      .insert(
        CustomersCompanion.insert(
          customerNumber: number,
          firstName: 'Ali',
          lastName: 'Kaya',
          searchKey: 'ali kaya',
          createdAt: now,
          updatedAt: now,
        ),
      );

  Future<int> insertDevice(int customerId) => db
      .into(db.devices)
      .insert(
        DevicesCompanion.insert(
          customerId: customerId,
          model: 'AquaPure',
          installedAt: day,
          createdAt: now,
        ),
      );

  Future<int> insertRecord(
    int deviceId, {
    int price = 50000,
    CalendarDate? next,
  }) => db
      .into(db.maintenanceRecords)
      .insert(
        MaintenanceRecordsCompanion.insert(
          deviceId: deviceId,
          maintenanceDate: day,
          nextMaintenanceDate: next ?? day.addMonths(6),
          priceKurus: price,
          createdAt: now,
        ),
      );

  Matcher throwsConstraint(ConstraintKind kind) => throwsA(
    isA<Object>().having(
      (e) => mapDatabaseError(e, StackTrace.empty),
      'mapped',
      isA<ConstraintViolationException>().having((e) => e.kind, 'kind', kind),
    ),
  );

  test('foreign key enforcement is enabled on open', () async {
    expect(await db.foreignKeysEnabled(), isTrue);
  });

  group('constraints', () {
    test('customer number is unique', () async {
      await insertCustomer();
      expect(insertCustomer(), throwsConstraint(ConstraintKind.unique));
    });

    test('blank names are rejected by CHECK', () async {
      expect(
        db
            .into(db.customers)
            .insert(
              CustomersCompanion.insert(
                customerNumber: 'FST-9',
                firstName: '   ',
                lastName: 'Kaya',
                searchKey: 'k',
                createdAt: now,
                updatedAt: now,
              ),
            ),
        throwsConstraint(ConstraintKind.check),
      );
    });

    test('device needs an existing customer', () async {
      expect(insertDevice(999), throwsConstraint(ConstraintKind.foreignKey));
    });

    test('maintenance record needs an existing device', () async {
      expect(insertRecord(999), throwsConstraint(ConstraintKind.foreignKey));
    });

    test('negative price is rejected', () async {
      final device = await insertDevice(await insertCustomer());
      expect(
        insertRecord(device, price: -1),
        throwsConstraint(ConstraintKind.check),
      );
    });

    test('next date before maintenance date is rejected', () async {
      final device = await insertDevice(await insertCustomer());
      expect(
        insertRecord(device, next: day.addDays(-1)),
        throwsConstraint(ConstraintKind.check),
      );
    });

    test('same filter twice in one record is rejected', () async {
      final device = await insertDevice(await insertCustomer());
      final record = await insertRecord(device);
      final row = FilterReplacementsCompanion.insert(
        maintenanceRecordId: record,
        filterType: FilterType.gac,
      );
      await db.into(db.filterReplacements).insert(row);
      expect(
        db.into(db.filterReplacements).insert(row),
        throwsConstraint(ConstraintKind.unique),
      );
    });

    test('ON DELETE RESTRICT protects children of a customer', () async {
      final customer = await insertCustomer();
      await insertDevice(customer);
      expect(
        (db.delete(db.customers)..where((c) => c.id.equals(customer))).go(),
        throwsConstraint(ConstraintKind.foreignKey),
      );
    });

    test('ON DELETE RESTRICT protects records of a device', () async {
      final device = await insertDevice(await insertCustomer());
      await insertRecord(device);
      expect(
        (db.delete(db.devices)..where((d) => d.id.equals(device))).go(),
        throwsConstraint(ConstraintKind.foreignKey),
      );
    });
  });

  test('deleteAllData empties tables and restarts ids', () async {
    final device = await insertDevice(await insertCustomer());
    await insertRecord(device);
    await db.transaction(db.deleteAllData);

    expect(await db.select(db.customers).get(), isEmpty);
    expect(await db.select(db.maintenanceRecords).get(), isEmpty);
    expect(await insertCustomer(number: 'NEW-1'), 1);
  });

  group('schema migrations', () {
    test('v1 created by the app matches the exported schema', () async {
      final verifier = SchemaVerifier(GeneratedHelper());
      final connection = await verifier.startAt(1);
      final migrated = AppDatabase(connection);
      await verifier.migrateAndValidate(migrated, 1);
      await migrated.close();
    });
  });
}
