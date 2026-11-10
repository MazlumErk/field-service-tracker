import 'dart:io';

import 'package:drift/native.dart';
import 'package:field_service_tracker/core/errors/app_exception.dart';
import 'package:field_service_tracker/core/utils/calendar_date.dart';
import 'package:field_service_tracker/database/app_database.dart';
import 'package:field_service_tracker/database/seed/demo_seeder.dart';
import 'package:field_service_tracker/features/customers/data/drift_customer_repository.dart';
import 'package:field_service_tracker/features/customers/domain/customer_draft.dart';
import 'package:field_service_tracker/features/customers/domain/customer_validator.dart';
import 'package:field_service_tracker/features/maintenance/data/drift_maintenance_repository.dart';
import 'package:field_service_tracker/features/maintenance/domain/maintenance_status.dart';
import 'package:field_service_tracker/features/settings/data/drift_demo_data_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fixed_clock.dart';
import '../helpers/test_database.dart';

void main() {
  final clock = FixedClock(DateTime(2026, 1, 15, 10));
  final today = CalendarDate(2026, 1, 15);
  final seeder = DemoSeeder(clock);

  group('buildDemoData', () {
    final data = buildDemoData(today: today, now: clock.now().toUtc());

    test('creates about 20 customers with valid, fictional data', () {
      expect(data.customers, hasLength(demoCustomerCount));
      for (final row in data.customers) {
        final draft = CustomerDraft(
          customerNumber: row.customerNumber.value,
          firstName: row.firstName.value,
          lastName: row.lastName.value,
          phone: row.phone.value,
          address: row.address.value,
        );
        expect(CustomerValidator.validate(draft).isValid, isTrue);
        final phone = row.phone.value;
        if (phone != null) expect(phone, startsWith('0500 000 00 '));
      }
    });

    test('is deterministic for the same day', () {
      final again = buildDemoData(today: today, now: clock.now().toUtc());
      expect(again.records.length, data.records.length);
      for (var i = 0; i < data.records.length; i++) {
        expect(
          again.records[i].nextMaintenanceDate,
          data.records[i].nextMaintenanceDate,
        );
      }
    });

    test('no maintenance happens in the future and dates are ordered', () {
      for (final record in data.records) {
        final date = record.maintenanceDate.value;
        expect(date.isAfter(today), isFalse);
        expect(record.nextMaintenanceDate.value.isBefore(date), isFalse);
        expect(record.priceKurus.value, greaterThanOrEqualTo(0));
      }
    });
  });

  group('seeded database', () {
    late AppDatabase db;
    setUp(() => db = createTestDatabase(seeder: seeder.call));
    tearDown(() => db.close());

    test('covers every maintenance situation', () async {
      final overview = await DriftMaintenanceRepository(
        db,
        clock,
      ).watchOverview().first;
      final days = [
        for (final o in overview)
          if (o.nextMaintenanceDate != null)
            today.daysUntil(o.nextMaintenanceDate!),
      ];
      final statuses = overview.map((o) => o.statusOn(today)).toSet();

      expect(statuses, MaintenanceStatus.values.toSet());
      expect(days, contains(0), reason: 'due today');
      expect(days.where((d) => d > 0 && d <= 7), isNotEmpty);
      expect(days.where((d) => d > 7 && d <= 30), isNotEmpty);
      expect(days.where((d) => d > 30), isNotEmpty);
      expect(days.where((d) => d < 0), isNotEmpty);
    });

    test('customers have different numbers of devices, one has none', () async {
      final list = await DriftCustomerRepository(
        db,
        clock,
      ).watchCustomers().first;
      final counts = list.map((c) => c.deviceCount).toSet();
      expect(list, hasLength(demoCustomerCount));
      expect(counts, containsAll([0, 1, 2, 3]));
    });

    test('every record has at least one filter', () async {
      final orphans = await db
          .customSelect(
            'SELECT COUNT(*) AS n FROM maintenance_records r WHERE NOT EXISTS '
            '(SELECT 1 FROM filter_replacements f '
            ' WHERE f.maintenance_record_id = r.id)',
          )
          .getSingle();
      expect(orphans.read<int>('n'), 0);
    });
  });

  group('seed runs only on first install', () {
    late Directory dir;
    late File file;

    setUp(() async {
      dir = await Directory.systemTemp.createTemp('fst_seed_test');
      file = File('${dir.path}/app.sqlite');
    });
    tearDown(() => dir.delete(recursive: true));

    AppDatabase openFile() =>
        AppDatabase(NativeDatabase(file), seeder: seeder.call);

    test('reopening keeps user changes and does not duplicate data', () async {
      var db = openFile();
      final repo = DriftCustomerRepository(db, clock);
      expect(await repo.watchCustomerCount().first, demoCustomerCount);

      // User edits: delete the customer without devices, add a new one.
      final empty = (await repo.watchCustomers().first).firstWhere(
        (c) => c.deviceCount == 0,
      );
      await repo.deleteCustomer(empty.customer.id);
      await repo.createCustomer(
        const CustomerDraft(
          customerNumber: 'USER-1',
          firstName: 'Kullanıcı',
          lastName: 'Kaydı',
        ),
      );
      await db.close();

      db = openFile();
      final reopened = DriftCustomerRepository(db, clock);
      final numbers = [
        for (final c in await reopened.watchCustomers().first)
          c.customer.customerNumber,
      ];
      expect(numbers, hasLength(demoCustomerCount));
      expect(numbers, contains('USER-1'));
      expect(numbers, isNot(contains(empty.customer.customerNumber)));
      await db.close();
    });
  });

  group('DriftDemoDataRepository.resetDemoData', () {
    late AppDatabase db;
    setUp(() => db = createTestDatabase(seeder: seeder.call));
    tearDown(() => db.close());

    Future<List<String>> numbers() async => [
      for (final c in await DriftCustomerRepository(
        db,
        clock,
      ).watchCustomers().first)
        c.customer.customerNumber,
    ];

    test('restores the initial data set and removes user data', () async {
      final initial = await numbers();
      final repo = DriftCustomerRepository(db, clock);
      await repo.createCustomer(
        const CustomerDraft(
          customerNumber: 'USER-1',
          firstName: 'Ek',
          lastName: 'Müşteri',
        ),
      );
      final firstWithDevices = (await repo.watchCustomers().first).firstWhere(
        (c) => c.deviceCount > 0,
      );
      await repo.deleteCustomer(firstWithDevices.customer.id);

      await DriftDemoDataRepository(db, seeder.call).resetDemoData();

      expect(await numbers(), initial);
      expect((await db.select(db.devices).get()).first.id, 1);
    });

    test('keeps the previous data when re-seeding fails', () async {
      final repo = DriftCustomerRepository(db, clock);
      await repo.createCustomer(
        const CustomerDraft(
          customerNumber: 'USER-1',
          firstName: 'Ek',
          lastName: 'Müşteri',
        ),
      );
      final before = await numbers();

      Future<void> failingSeed(AppDatabase database) async {
        await seeder.seed(database);
        throw StateError('seed failed half way');
      }

      await expectLater(
        DriftDemoDataRepository(db, failingSeed).resetDemoData(),
        throwsA(isA<DatabaseException>()),
      );
      expect(await numbers(), before);
    });
  });
}
