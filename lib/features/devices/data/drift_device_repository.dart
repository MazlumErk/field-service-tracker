import 'package:drift/drift.dart';
import 'package:field_service_tracker/core/clock/app_clock.dart';
import 'package:field_service_tracker/core/errors/app_exception.dart';
import 'package:field_service_tracker/core/utils/calendar_date.dart';
import 'package:field_service_tracker/database/app_database.dart';
import 'package:field_service_tracker/database/database_error_mapper.dart';
import 'package:field_service_tracker/features/devices/domain/device.dart';
import 'package:field_service_tracker/features/devices/domain/device_repository.dart';
import 'package:field_service_tracker/features/devices/domain/device_validator.dart';

/// Drift implementation of [DeviceRepository].
final class DriftDeviceRepository implements DeviceRepository {
  DriftDeviceRepository(this._database, this._clock);

  final AppDatabase _database;
  final AppClock _clock;

  static const String _entity = 'Device';

  @override
  Stream<Device?> watchDevice(int id) => guardDatabaseStream(
    _database.devicesDao.watchById(id).map((row) => row?.toDomain()),
  );

  @override
  Future<Device> getDevice(int id) => guardDatabase(() async {
    final row = await _database.devicesDao.findById(id);
    if (row == null) throw NotFoundException(_entity, id);
    return row.toDomain();
  });

  @override
  Future<Device> createDevice(int customerId, DeviceDraft draft) =>
      guardDatabase(() async {
        final input = _validated(draft);
        if (!await _database.customersDao.existsById(customerId)) {
          throw NotFoundException('Customer', customerId);
        }
        final id = await _database.devicesDao.insertDevice(
          DevicesCompanion.insert(
            customerId: customerId,
            model: input.model,
            serialNumber: Value(input.serialNumber),
            installedAt: input.installedAt,
            createdAt: _clock.now().toUtc(),
          ),
        );
        return (await _database.devicesDao.findById(id))!.toDomain();
      });

  @override
  Future<Device> updateDevice(int id, DeviceDraft draft) =>
      guardDatabase(() async {
        final input = _validated(draft);
        final updated = await _database.devicesDao.updateDevice(
          id,
          DevicesCompanion(
            model: Value(input.model),
            serialNumber: Value(input.serialNumber),
            installedAt: Value(input.installedAt),
          ),
        );
        if (updated == 0) throw NotFoundException(_entity, id);
        return (await _database.devicesDao.findById(id))!.toDomain();
      });

  @override
  Future<DeviceDeletionImpact> getDeletionImpact(int id) =>
      guardDatabase(() async {
        if (await _database.devicesDao.findById(id) == null) {
          throw NotFoundException(_entity, id);
        }
        final counts = await _database.devicesDao.relatedCounts(id);
        return DeviceDeletionImpact(
          maintenanceRecordCount: counts.maintenanceRecords,
          filterReplacementCount: counts.filterReplacements,
        );
      });

  @override
  Future<void> deleteDevice(int id) => guardDatabase(() async {
    final deleted = await _database.devicesDao.deleteWithRelatedRecords(id);
    if (!deleted) throw NotFoundException(_entity, id);
  });

  DeviceDraft _validated(DeviceDraft draft) {
    final result = DeviceValidator.validate(
      draft,
      today: CalendarDate.today(_clock),
    );
    if (!result.isValid) throw ValidationException(result.errors);
    return draft.normalized();
  }
}

extension DeviceRowMapper on DeviceRow {
  Device toDomain() => Device(
    id: id,
    customerId: customerId,
    model: model,
    serialNumber: serialNumber,
    installedAt: installedAt,
    createdAt: createdAt.toUtc(),
  );
}
