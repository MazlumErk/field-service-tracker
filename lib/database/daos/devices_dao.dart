import 'package:drift/drift.dart';
import 'package:field_service_tracker/database/app_database.dart';
import 'package:field_service_tracker/database/tables/devices_table.dart';

part 'devices_dao.g.dart';

@DriftAccessor(tables: [Devices])
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
}
