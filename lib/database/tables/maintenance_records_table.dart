import 'package:drift/drift.dart';
import 'package:field_service_tracker/database/converters/calendar_date_converter.dart';
import 'package:field_service_tracker/database/tables/devices_table.dart';

/// `maintenance_records` — immutable history of maintenance visits.
///
/// The composite index serves both "history of a device" and "latest record
/// of a device" queries.
@DataClassName('MaintenanceRecordRow')
@TableIndex(
  name: 'idx_maintenance_records_device_date',
  columns: {#deviceId, #maintenanceDate},
)
class MaintenanceRecords extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get deviceId => integer().references(
    Devices,
    #id,
    onDelete: KeyAction.restrict,
    onUpdate: KeyAction.restrict,
  )();
  TextColumn get maintenanceDate => text().map(const CalendarDateConverter())();
  TextColumn get nextMaintenanceDate =>
      text().map(const CalendarDateConverter())();
  IntColumn get priceKurus => integer()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  List<String> get customConstraints => [
    'CHECK (price_kurus >= 0)',
    // ISO dates compare correctly as text.
    'CHECK (next_maintenance_date >= maintenance_date)',
  ];
}
