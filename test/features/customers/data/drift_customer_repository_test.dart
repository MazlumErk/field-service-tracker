import 'package:field_service_tracker/core/errors/app_exception.dart';
import 'package:field_service_tracker/core/utils/calendar_date.dart';
import 'package:field_service_tracker/core/validation/validation_result.dart';
import 'package:field_service_tracker/database/app_database.dart';
import 'package:field_service_tracker/features/customers/data/drift_customer_repository.dart';
import 'package:field_service_tracker/features/customers/domain/customer.dart';
import 'package:field_service_tracker/features/customers/domain/customer_draft.dart';
import 'package:field_service_tracker/features/customers/domain/customer_validator.dart';
import 'package:field_service_tracker/features/devices/data/drift_device_repository.dart';
import 'package:field_service_tracker/features/devices/domain/device.dart';
import 'package:field_service_tracker/features/maintenance/data/drift_maintenance_repository.dart';
import 'package:field_service_tracker/features/maintenance/domain/filter_type.dart';
import 'package:field_service_tracker/features/maintenance/domain/maintenance_record.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fixed_clock.dart';
import '../../../helpers/stream_recorder.dart';
import '../../../helpers/test_database.dart';

CustomerDraft _draft(
  String number, {
  String first = 'Ayşe',
  String last = 'Yılmaz',
  String? phone,
}) => CustomerDraft(
  customerNumber: number,
  firstName: first,
  lastName: last,
  phone: phone,
);

void main() {
  late AppDatabase db;
  late FixedClock clock;
  late DriftCustomerRepository customers;
  late DriftDeviceRepository devices;
  late DriftMaintenanceRepository maintenance;

  setUp(() {
    db = createTestDatabase();
    clock = FixedClock(DateTime(2026, 1, 15, 10));
    customers = DriftCustomerRepository(db, clock);
    devices = DriftDeviceRepository(db, clock);
    maintenance = DriftMaintenanceRepository(db, clock);
  });
  tearDown(() => db.close());

  group('create / read / update', () {
    test('create normalizes input and stamps timestamps', () async {
      final created = await customers.createCustomer(
        _draft(' fst - 0001 ', first: '  Ali  Rıza ', phone: ' '),
      );

      expect(created.id, greaterThan(0));
      expect(created.customerNumber, 'FST-0001');
      expect(created.firstName, 'Ali Rıza');
      expect(created.phone, isNull);
      expect(created.createdAt, clock.now().toUtc());
      expect(await customers.getCustomer(created.id), created);
    });

    test(
      'invalid input throws ValidationException and writes nothing',
      () async {
        await expectLater(
          customers.createCustomer(_draft('FST-1', first: ' ')),
          throwsA(
            isA<ValidationException>().having(
              (e) => e.errors[CustomerField.firstName],
              'firstName',
              ValidationError.required,
            ),
          ),
        );
        expect(await customers.watchCustomers().first, isEmpty);
      },
    );

    test('update changes fields and updatedAt only', () async {
      final created = await customers.createCustomer(_draft('FST-1'));
      clock = FixedClock(DateTime(2026, 2, 1, 9));
      customers = DriftCustomerRepository(db, clock);

      final updated = await customers.updateCustomer(
        created.id,
        _draft('fst-1', last: 'Kaya', phone: '0500 000 00 99'),
      );

      expect(updated.lastName, 'Kaya');
      expect(updated.phone, '0500 000 00 99');
      expect(updated.createdAt, created.createdAt);
      expect(updated.updatedAt, clock.now().toUtc());
    });

    test('missing records throw NotFoundException', () async {
      expect(customers.getCustomer(42), throwsA(isA<NotFoundException>()));
      expect(
        customers.updateCustomer(42, _draft('X-1')),
        throwsA(isA<NotFoundException>()),
      );
      expect(customers.deleteCustomer(42), throwsA(isA<NotFoundException>()));
      expect(
        customers.getDeletionImpact(42),
        throwsA(isA<NotFoundException>()),
      );
    });
  });

  group('customer number uniqueness', () {
    test('rejects a duplicate after normalization', () async {
      await customers.createCustomer(_draft('FST-0001'));
      await expectLater(
        customers.createCustomer(_draft(' fst-0001 ')),
        throwsA(
          isA<DuplicateCustomerNumberException>().having(
            (e) => e.customerNumber,
            'customerNumber',
            'FST-0001',
          ),
        ),
      );
    });

    test('update may keep its own number but not take another one', () async {
      final a = await customers.createCustomer(_draft('A-1'));
      await customers.createCustomer(_draft('B-1'));

      await customers.updateCustomer(a.id, _draft('a-1', first: 'Yeni'));
      expect(
        customers.updateCustomer(a.id, _draft('B-1')),
        throwsA(isA<DuplicateCustomerNumberException>()),
      );
    });

    test('isCustomerNumberTaken normalizes and can exclude an id', () async {
      final a = await customers.createCustomer(_draft('A-1'));
      expect(await customers.isCustomerNumberTaken(' a-1 '), isTrue);
      expect(
        await customers.isCustomerNumberTaken('A-1', excludingId: a.id),
        isFalse,
      );
      expect(await customers.isCustomerNumberTaken('Z-9'), isFalse);
    });
  });

  group('search', () {
    setUp(() async {
      await customers.createCustomer(
        _draft('FST-0001', first: 'Şeyma', last: 'Çelik'),
      );
      await customers.createCustomer(
        _draft('FST-0002', first: 'Ömer', last: 'Işık'),
      );
      await customers.createCustomer(
        _draft('ABC-7', first: 'Can', last: 'Demir'),
      );
    });

    Future<List<String>> search(String query) async => [
      for (final item in await customers.watchCustomers(query: query).first)
        item.customer.lastName,
    ];

    test('empty query lists everyone in Turkish alphabetical order', () async {
      expect(await search(''), ['Çelik', 'Demir', 'Işık']);
    });

    test(
      'matches first name, last name and number case-insensitively',
      () async {
        expect(await search('ŞEYMA'), ['Çelik']);
        expect(await search('çelik'), ['Çelik']);
        expect(await search('abc-7'), ['Demir']);
        expect(await search('fst'), ['Çelik', 'Işık']);
      },
    );

    test('works without Turkish characters', () async {
      expect(await search('seyma celik'), ['Çelik']);
      expect(await search('isik'), ['Işık']);
      expect(await search('omer'), ['Işık']);
    });

    test('every word must match, in any order', () async {
      expect(await search('çelik şeyma'), ['Çelik']);
      expect(await search('seyma demir'), isEmpty);
    });

    test('LIKE wildcards in the query are treated literally', () async {
      expect(await search('%'), isEmpty);
      expect(await search('_'), isEmpty);
    });

    test('no match returns an empty list', () async {
      expect(await search('zzz'), isEmpty);
    });
  });

  group('delete with explicit cascade', () {
    late Customer customer;
    late Device device;

    setUp(() async {
      customer = await customers.createCustomer(_draft('DEL-1'));
      device = await devices.createDevice(
        customer.id,
        DeviceDraft(model: 'AquaPure', installedAt: CalendarDate(2025, 1, 1)),
      );
      for (final date in [
        CalendarDate(2025, 6, 1),
        CalendarDate(2025, 12, 1),
      ]) {
        await maintenance.createRecord(
          device.id,
          MaintenanceRecordDraft(
            maintenanceDate: date,
            nextMaintenanceDate: date.addMonths(6),
            priceKurus: 50000,
            filters: {FilterType.sediment, FilterType.gac},
          ),
        );
      }
    });

    test('impact reports what will be removed', () async {
      final impact = await customers.getDeletionImpact(customer.id);
      expect(impact.deviceCount, 1);
      expect(impact.maintenanceRecordCount, 2);
      expect(impact.hasRelatedRecords, isTrue);
    });

    test('removes customer, devices, records and filters', () async {
      final other = await customers.createCustomer(_draft('KEEP-1'));

      await customers.deleteCustomer(customer.id);

      expect(await db.select(db.customers).get(), hasLength(1));
      expect((await db.select(db.customers).getSingle()).id, other.id);
      expect(await db.select(db.devices).get(), isEmpty);
      expect(await db.select(db.maintenanceRecords).get(), isEmpty);
      expect(await db.select(db.filterReplacements).get(), isEmpty);
    });

    test('rolls back everything when the last step fails', () async {
      // Simulate a failure at the very end of the transaction.
      await db.customStatement(
        'CREATE TRIGGER fail_customer_delete BEFORE DELETE ON customers '
        "BEGIN SELECT RAISE(ABORT, 'forced failure'); END",
      );

      await expectLater(
        customers.deleteCustomer(customer.id),
        throwsA(isA<AppException>()),
      );

      expect(await db.select(db.customers).get(), hasLength(1));
      expect(await db.select(db.devices).get(), hasLength(1));
      expect(await db.select(db.maintenanceRecords).get(), hasLength(2));
      expect(await db.select(db.filterReplacements).get(), hasLength(4));
    });
  });

  group('reactive streams', () {
    test(
      'customer list re-emits on create, update, delete and device add',
      () async {
        final recorder = StreamRecorder(customers.watchCustomers());
        await recorder.waitForValues(1);
        expect(recorder.last, isEmpty);

        final created = await customers.createCustomer(_draft('R-1'));
        await recorder.waitFor((list) => list.length == 1);

        await devices.createDevice(
          created.id,
          DeviceDraft(
            model: 'ClearFlow',
            installedAt: CalendarDate(2025, 5, 1),
          ),
        );
        await recorder.waitFor(
          (list) => list.length == 1 && list.single.deviceCount == 1,
        );

        await customers.updateCustomer(
          created.id,
          _draft('R-1', last: 'Arslan'),
        );
        await recorder.waitFor(
          (list) =>
              list.length == 1 && list.single.customer.lastName == 'Arslan',
        );

        await customers.deleteCustomer(created.id);
        await recorder.waitFor(
          (list) => list.isEmpty && recorder.values.length > 4,
        );

        await recorder.cancel();
      },
    );

    test('single customer stream emits null after deletion', () async {
      final created = await customers.createCustomer(_draft('S-1'));
      final recorder = StreamRecorder(customers.watchCustomer(created.id));
      await recorder.waitFor((c) => c != null);

      await customers.deleteCustomer(created.id);
      await recorder.waitFor((c) => c == null);
      await recorder.cancel();
    });

    test('count stream follows inserts', () async {
      final recorder = StreamRecorder(customers.watchCustomerCount());
      await recorder.waitFor((count) => count == 0);
      await customers.createCustomer(_draft('C-1'));
      await customers.createCustomer(_draft('C-2'));
      await recorder.waitFor((count) => count == 2);
      await recorder.cancel();
    });

    test('streams complete without error when the database closes', () async {
      final recorder = StreamRecorder(customers.watchCustomers());
      await recorder.waitForValues(1);
      await db.close();
      expect(recorder.errors, isEmpty);
      await recorder.cancel();
    });
  });
}
