import 'package:drift/drift.dart';
import 'package:field_service_tracker/database/app_database.dart';
import 'package:field_service_tracker/database/tables/devices_table.dart';
import 'package:field_service_tracker/database/tables/filter_replacements_table.dart';
import 'package:field_service_tracker/database/tables/maintenance_records_table.dart';

part 'devices_dao.g.dart';

/// Counts of rows that belong to a device.
typedef DeviceRelatedCounts = ({
  int maintenanceRecords,
  int filterReplacements,
});

@DriftAccessor(tables: [Devices, MaintenanceRecords, FilterReplacements])
class DevicesDao extends DatabaseAccessor<AppDatabase> with _$DevicesDaoMixin {
  DevicesDao(super.attachedDatabase);

  Stream<DeviceRow?> watchById(int id) =>
      (select(devices)..where((d) => d.id.equals(id))).watchSingleOrNull();

  Future<DeviceRow?> findById(int id) =>
      (select(devices)..where((d) => d.id.equals(id))).getSingleOrNull();

  Future<int> insertDevice(DevicesCompanion entry) =>
      into(devices).insert(entry);

  /// Returns the number of updated rows (0 when [id] does not exist).
  Future<int> updateDevice(int id, DevicesCompanion entry) =>
      (update(devices)..where((d) => d.id.equals(id))).write(entry);

  Future<DeviceRelatedCounts> relatedCounts(int deviceId) async {
    final row = await customSelect(
      'SELECT '
      '(SELECT COUNT(*) FROM maintenance_records WHERE device_id = ?1) '
      'AS maintenance_records, '
      '(SELECT COUNT(*) FROM filter_replacements f '
      ' JOIN maintenance_records r ON r.id = f.maintenance_record_id '
      ' WHERE r.device_id = ?1) AS filter_replacements',
      variables: [Variable.withInt(deviceId)],
      readsFrom: {maintenanceRecords, filterReplacements},
    ).getSingle();
    return (
      maintenanceRecords: row.read<int>('maintenance_records'),
      filterReplacements: row.read<int>('filter_replacements'),
    );
  }

  /// Explicit cascade: filters → records → device, atomically. Foreign keys
  /// stay `RESTRICT`; children are removed first on purpose.
  /// Returns `false` (and changes nothing) when the device does not exist.
  Future<bool> deleteWithRelatedRecords(int deviceId) {
    return transaction(() async {
      if (await findById(deviceId) == null) return false;

      final recordIds = selectOnly(maintenanceRecords)
        ..addColumns([maintenanceRecords.id])
        ..where(maintenanceRecords.deviceId.equals(deviceId));

      await (delete(
        filterReplacements,
      )..where((f) => f.maintenanceRecordId.isInQuery(recordIds))).go();
      await (delete(
        maintenanceRecords,
      )..where((r) => r.deviceId.equals(deviceId))).go();
      await (delete(devices)..where((d) => d.id.equals(deviceId))).go();
      return true;
    });
  }
}
