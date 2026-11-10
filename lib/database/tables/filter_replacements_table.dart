import 'package:drift/drift.dart';
import 'package:field_service_tracker/database/tables/maintenance_records_table.dart';
import 'package:field_service_tracker/features/maintenance/domain/filter_type.dart';

/// `filter_replacements` — one row per filter replaced in a visit.
///
/// Only replaced filters get a row. The UNIQUE key prevents the same filter
/// twice per record and doubles as the index on `maintenance_record_id`.
@DataClassName('FilterReplacementRow')
class FilterReplacements extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get maintenanceRecordId => integer().references(
    MaintenanceRecords,
    #id,
    onDelete: KeyAction.restrict,
    onUpdate: KeyAction.restrict,
  )();
  TextColumn get filterType => textEnum<FilterType>()();

  @override
  List<Set<Column>> get uniqueKeys => [
    {maintenanceRecordId, filterType},
  ];
}
