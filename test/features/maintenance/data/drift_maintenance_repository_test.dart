import 'package:field_service_tracker/core/errors/app_exception.dart';
import 'package:field_service_tracker/core/utils/calendar_date.dart';
import 'package:field_service_tracker/database/app_database.dart';
import 'package:field_service_tracker/features/customers/data/drift_customer_repository.dart';
import 'package:field_service_tracker/features/customers/domain/customer_draft.dart';
import 'package:field_service_tracker/features/devices/data/drift_device_repository.dart';
import 'package:field_service_tracker/features/devices/domain/device.dart';
import 'package:field_service_tracker/features/maintenance/data/drift_maintenance_repository.dart';
import 'package:field_service_tracker/features/maintenance/domain/filter_type.dart';
import 'package:field_service_tracker/features/maintenance/domain/maintenance_record.dart';
import 'package:field_service_tracker/features/maintenance/domain/maintenance_status.dart';
import 'package:field_service_tracker/features/maintenance/domain/maintenance_validator.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fixed_clock.dart';
import '../../../helpers/stream_recorder.dart';
import '../../../helpers/test_database.dart';

void main() {
  late AppDatabase db;
  late FixedClock clock;
  late DriftDeviceRepository devices;
  late DriftMaintenanceRepository maintenance;
  late int customerId;
  final today = CalendarDate(2026, 1, 15);

  MaintenanceRecordDraft draft(
    CalendarDate date, {
    CalendarDate? next,
    Set<FilterType> filters = const {FilterType.sediment},
    int price = 60000,
    String? notes,
  }) => MaintenanceRecordDraft(
    maintenanceDate: date,
    nextMaintenanceDate: next ?? date.addMonths(6),
    priceKurus: price,
    filters: filters,
    notes: notes,
  );

  Future<Device> addDevice([String model = 'AquaPure RO-5']) =>
      devices.createDevice(
        customerId,
        DeviceDraft(model: model, installedAt: CalendarDate(2024, 1, 10)),
      );

  setUp(() async {
    db = createTestDatabase();
    clock = FixedClock(DateTime(2026, 1, 15, 10));
    devices = DriftDeviceRepository(db, clock);
    maintenance = DriftMaintenanceRepository(db, clock);
    final customer = await DriftCustomerRepository(db, clock).createCustomer(
      const CustomerDraft(
        customerNumber: 'FST-1',
        firstName: 'Zeynep',
        lastName: 'Arslan',
      ),
    );
    customerId = customer.id;
  });
  tearDown(() => db.close());

  group('devices', () {
    test('create, read and update a device', () async {
      final device = await addDevice();
      expect(device.customerId, customerId);
      expect(await devices.getDevice(device.id), device);

      final updated = await devices.updateDevice(
        device.id,
        DeviceDraft(
          model: ' ClearFlow 7 ',
          serialNumber: 'SN-1',
          installedAt: CalendarDate(2024, 2, 1),
        ),
      );
      expect(updated.model, 'ClearFlow 7');
      expect(updated.serialNumber, 'SN-1');
      expect(updated.createdAt, device.createdAt);
    });

    test('unknown customer or device throws NotFoundException', () async {
      expect(
        devices.createDevice(999, DeviceDraft(model: 'X', installedAt: today)),
        throwsA(isA<NotFoundException>()),
      );
      expect(devices.getDevice(999), throwsA(isA<NotFoundException>()));
      expect(
        devices.updateDevice(999, DeviceDraft(model: 'X', installedAt: today)),
        throwsA(isA<NotFoundException>()),
      );
    });

    test('invalid device input throws ValidationException', () async {
      expect(
        devices.createDevice(
          customerId,
          DeviceDraft(model: ' ', installedAt: today.addDays(1)),
        ),
        throwsA(isA<ValidationException>()),
      );
    });
  });

  group('createRecord', () {
    test('stores the record with its filters in enum order', () async {
      final device = await addDevice();
      final record = await maintenance.createRecord(
        device.id,
        draft(
          CalendarDate(2025, 12, 1),
          filters: {FilterType.membrane, FilterType.sediment, FilterType.gac},
          notes: '  Filtre değişti ',
        ),
      );

      expect(record.filters, [
        FilterType.sediment,
        FilterType.gac,
        FilterType.membrane,
      ]);
      expect(record.notes, 'Filtre değişti');
      expect(record.priceKurus, 60000);
      expect(await db.select(db.filterReplacements).get(), hasLength(3));
    });

    test('only selected filters get rows', () async {
      final device = await addDevice();
      await maintenance.createRecord(device.id, draft(today));
      final rows = await db.select(db.filterReplacements).get();
      expect(rows.map((r) => r.filterType), [FilterType.sediment]);
    });

    test('validation failures write nothing', () async {
      final device = await addDevice();
      await expectLater(
        maintenance.createRecord(device.id, draft(today, filters: {})),
        throwsA(
          isA<ValidationException>().having(
            (e) => e.errors.keys,
            'fields',
            contains(MaintenanceField.filters),
          ),
        ),
      );
      expect(await db.select(db.maintenanceRecords).get(), isEmpty);
    });

    test('unknown device throws NotFoundException', () async {
      expect(
        maintenance.createRecord(999, draft(today)),
        throwsA(isA<NotFoundException>()),
      );
    });

    test('rolls back the record when a filter insert fails', () async {
      final device = await addDevice();
      await db.customStatement(
        'CREATE TRIGGER fail_filter_insert BEFORE INSERT ON filter_replacements '
        "WHEN NEW.filter_type = 'membrane' "
        "BEGIN SELECT RAISE(ABORT, 'forced failure'); END",
      );

      await expectLater(
        maintenance.createRecord(
          device.id,
          draft(today, filters: {FilterType.sediment, FilterType.membrane}),
        ),
        throwsA(isA<AppException>()),
      );

      expect(await db.select(db.maintenanceRecords).get(), isEmpty);
      expect(await db.select(db.filterReplacements).get(), isEmpty);
    });
  });

  group('history and latest record', () {
    test('history is newest first; same-day ties use creation order', () async {
      final device = await addDevice();
      final sameDay = CalendarDate(2025, 10, 1);

      final older = await maintenance.createRecord(
        device.id,
        draft(CalendarDate(2025, 4, 1)),
      );
      final first = await maintenance.createRecord(
        device.id,
        draft(sameDay, next: CalendarDate(2026, 2, 1)),
      );
      // Second visit on the same day, saved one hour later.
      clock = FixedClock(DateTime(2026, 1, 15, 11));
      maintenance = DriftMaintenanceRepository(db, clock);
      final second = await maintenance.createRecord(
        device.id,
        draft(sameDay, next: CalendarDate(2026, 3, 1)),
      );

      final history = await maintenance.watchHistory(device.id).first;
      expect(history.map((r) => r.id), [second.id, first.id, older.id]);

      final overview = await maintenance.watchDeviceOverview(device.id).first;
      expect(overview!.nextMaintenanceDate, CalendarDate(2026, 3, 1));
    });

    test('identical date and timestamp fall back to the higher id', () async {
      final device = await addDevice();
      final date = CalendarDate(2025, 10, 1);
      await maintenance.createRecord(
        device.id,
        draft(date, next: CalendarDate(2026, 1, 1)),
      );
      final later = await maintenance.createRecord(
        device.id,
        draft(date, next: CalendarDate(2026, 5, 1)),
      );

      final history = await maintenance.watchHistory(device.id).first;
      expect(history.first.id, later.id);
      final overview = await maintenance.watchDeviceOverview(device.id).first;
      expect(overview!.nextMaintenanceDate, CalendarDate(2026, 5, 1));
    });

    test('a back-dated entry does not become the latest record', () async {
      final device = await addDevice();
      await maintenance.createRecord(
        device.id,
        draft(CalendarDate(2025, 12, 1), next: CalendarDate(2026, 6, 1)),
      );
      await maintenance.createRecord(
        device.id,
        draft(CalendarDate(2025, 6, 1), next: CalendarDate(2025, 12, 1)),
      );

      final overview = await maintenance.watchDeviceOverview(device.id).first;
      expect(overview!.lastMaintenanceDate, CalendarDate(2025, 12, 1));
    });
  });

  group('overview', () {
    test('includes devices without records as noMaintenance', () async {
      final serviced = await addDevice('Serviced');
      final fresh = await addDevice('Fresh');
      await maintenance.createRecord(
        serviced.id,
        draft(CalendarDate(2025, 7, 1), next: today.addDays(-1)),
      );

      final overview = await maintenance.watchOverview().first;
      final byModel = {for (final o in overview) o.device.model: o};

      expect(byModel['Serviced']!.statusOn(today), MaintenanceStatus.overdue);
      expect(byModel['Serviced']!.customerFullName, 'Zeynep Arslan');
      expect(
        byModel['Fresh']!.statusOn(today),
        MaintenanceStatus.noMaintenance,
      );
      expect(byModel['Fresh']!.lastMaintenanceDate, isNull);
      expect(fresh.id, isNot(serviced.id));
    });

    test('customer overview only contains that customer', () async {
      await addDevice();
      final otherCustomer = await DriftCustomerRepository(db, clock)
          .createCustomer(
            const CustomerDraft(
              customerNumber: 'FST-2',
              firstName: 'Can',
              lastName: 'Koç',
            ),
          );
      await devices.createDevice(
        otherCustomer.id,
        DeviceDraft(model: 'Other', installedAt: today),
      );

      final mine = await maintenance.watchCustomerOverview(customerId).first;
      expect(mine.map((o) => o.customerId).toSet(), {customerId});
      expect(await maintenance.watchOverview().first, hasLength(2));
    });

    test('device overview emits null for unknown devices', () async {
      expect(await maintenance.watchDeviceOverview(999).first, isNull);
    });

    test('overview stream reacts to a new maintenance record', () async {
      final device = await addDevice();
      final recorder = StreamRecorder(maintenance.watchOverview());
      await recorder.waitFor(
        (list) =>
            list.single.statusOn(today) == MaintenanceStatus.noMaintenance,
      );

      await maintenance.createRecord(
        device.id,
        draft(today, next: today.addDays(10)),
      );

      await recorder.waitFor(
        (list) => list.single.statusOn(today) == MaintenanceStatus.upcoming,
      );
      await recorder.cancel();
    });

    test('history stream reacts to a new record', () async {
      final device = await addDevice();
      final recorder = StreamRecorder(maintenance.watchHistory(device.id));
      await recorder.waitFor((list) => list.isEmpty);

      await maintenance.createRecord(device.id, draft(today));
      await recorder.waitFor((list) => list.length == 1);
      await recorder.cancel();
    });

    test('device stream reacts to an update', () async {
      final device = await addDevice();
      final recorder = StreamRecorder(devices.watchDevice(device.id));
      await recorder.waitFor((d) => d?.model == 'AquaPure RO-5');

      await devices.updateDevice(
        device.id,
        DeviceDraft(model: 'Crystal RO-6', installedAt: device.installedAt),
      );
      await recorder.waitFor((d) => d?.model == 'Crystal RO-6');
      await recorder.cancel();
    });
  });
}
