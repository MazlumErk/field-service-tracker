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
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fixed_clock.dart';
import '../../../helpers/stream_recorder.dart';
import '../../../helpers/test_database.dart';

void main() {
  late AppDatabase db;
  late DriftCustomerRepository customers;
  late DriftDeviceRepository devices;
  late DriftMaintenanceRepository maintenance;
  late int customerId;
  final clock = FixedClock(DateTime(2026, 1, 15, 10));

  Future<Device> addDevice(String model) => devices.createDevice(
    customerId,
    DeviceDraft(model: model, installedAt: CalendarDate(2024, 1, 1)),
  );

  Future<void> addRecord(int deviceId, CalendarDate date, Set<FilterType> f) =>
      maintenance.createRecord(
        deviceId,
        MaintenanceRecordDraft(
          maintenanceDate: date,
          nextMaintenanceDate: date.addMonths(6),
          priceKurus: 50000,
          filters: f,
        ),
      );

  setUp(() async {
    db = createTestDatabase();
    customers = DriftCustomerRepository(db, clock);
    devices = DriftDeviceRepository(db, clock);
    maintenance = DriftMaintenanceRepository(db, clock);
    customerId = (await customers.createCustomer(
      const CustomerDraft(
        customerNumber: 'DEV-1',
        firstName: 'Elif',
        lastName: 'Kurt',
      ),
    )).id;
  });
  tearDown(() => db.close());

  test('update never changes the owning customer', () async {
    final device = await addDevice('AquaPure');
    final updated = await devices.updateDevice(
      device.id,
      DeviceDraft(
        model: 'ClearFlow',
        serialNumber: ' SN-9 ',
        installedAt: CalendarDate(2024, 6, 1),
      ),
    );
    expect(updated.customerId, customerId);
    expect(updated.serialNumber, 'SN-9');
  });

  group('deletion impact', () {
    test('counts maintenance records and filter replacements', () async {
      final device = await addDevice('AquaPure');
      await addRecord(device.id, CalendarDate(2025, 1, 10), {
        FilterType.sediment,
        FilterType.gac,
      });
      await addRecord(
        device.id,
        CalendarDate(2025, 7, 10),
        FilterType.values.toSet(),
      );

      final impact = await devices.getDeletionImpact(device.id);
      expect(impact.maintenanceRecordCount, 2);
      expect(impact.filterReplacementCount, 7);
      expect(impact.hasMaintenanceHistory, isTrue);
    });

    test('device without history has an empty impact', () async {
      final device = await addDevice('Fresh');
      final impact = await devices.getDeletionImpact(device.id);
      expect(impact.hasMaintenanceHistory, isFalse);
      expect(impact.filterReplacementCount, 0);
    });

    test('unknown device throws NotFoundException', () async {
      expect(devices.getDeletionImpact(99), throwsA(isA<NotFoundException>()));
    });
  });

  group('deleteDevice', () {
    test('removes the device, its records and filters only', () async {
      final doomed = await addDevice('Doomed');
      final kept = await addDevice('Kept');
      await addRecord(doomed.id, CalendarDate(2025, 1, 10), {
        FilterType.sediment,
      });
      await addRecord(kept.id, CalendarDate(2025, 2, 10), {FilterType.post});

      await devices.deleteDevice(doomed.id);

      final remainingDevices = await db.select(db.devices).get();
      expect(remainingDevices.map((d) => d.id), [kept.id]);
      final records = await db.select(db.maintenanceRecords).get();
      expect(records.map((r) => r.deviceId), [kept.id]);
      expect(await db.select(db.filterReplacements).get(), hasLength(1));
      expect(await customers.getCustomer(customerId), isNotNull);
    });

    test('unknown device throws NotFoundException', () async {
      expect(devices.deleteDevice(99), throwsA(isA<NotFoundException>()));
    });

    test('rolls back everything when the last step fails', () async {
      final device = await addDevice('Protected');
      await addRecord(device.id, CalendarDate(2025, 1, 10), {
        FilterType.sediment,
        FilterType.cto,
      });
      await db.customStatement(
        'CREATE TRIGGER fail_device_delete BEFORE DELETE ON devices '
        "BEGIN SELECT RAISE(ABORT, 'forced failure'); END",
      );

      await expectLater(
        devices.deleteDevice(device.id),
        throwsA(isA<AppException>()),
      );

      expect(await db.select(db.devices).get(), hasLength(1));
      expect(await db.select(db.maintenanceRecords).get(), hasLength(1));
      expect(await db.select(db.filterReplacements).get(), hasLength(2));
    });

    test('streams react: device count, overview and history', () async {
      final device = await addDevice('Watched');
      await addRecord(device.id, CalendarDate(2025, 1, 10), {
        FilterType.sediment,
      });

      final list = StreamRecorder(customers.watchCustomers());
      final overview = StreamRecorder(
        maintenance.watchDeviceOverview(device.id),
      );
      final history = StreamRecorder(maintenance.watchHistory(device.id));
      await list.waitFor((items) => items.single.deviceCount == 1);
      await overview.waitFor((o) => o != null);
      await history.waitFor((h) => h.length == 1);

      await devices.deleteDevice(device.id);

      await list.waitFor((items) => items.single.deviceCount == 0);
      await overview.waitFor((o) => o == null);
      await history.waitFor((h) => h.isEmpty);
      await list.cancel();
      await overview.cancel();
      await history.cancel();
    });
  });
}
