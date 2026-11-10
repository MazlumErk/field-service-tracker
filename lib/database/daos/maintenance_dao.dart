import 'package:drift/drift.dart';
import 'package:field_service_tracker/core/utils/calendar_date.dart';
import 'package:field_service_tracker/database/app_database.dart';
import 'package:field_service_tracker/database/converters/calendar_date_converter.dart';
import 'package:field_service_tracker/database/tables/customers_table.dart';
import 'package:field_service_tracker/database/tables/devices_table.dart';
import 'package:field_service_tracker/database/tables/filter_replacements_table.dart';
import 'package:field_service_tracker/database/tables/maintenance_records_table.dart';
import 'package:field_service_tracker/features/maintenance/domain/filter_type.dart';

part 'maintenance_dao.g.dart';

/// Device row joined with its customer and latest maintenance dates.
typedef DeviceOverviewRow = ({
  DeviceRow device,
  String customerNumber,
  String customerFirstName,
  String customerLastName,
  CalendarDate? lastMaintenanceDate,
  CalendarDate? nextMaintenanceDate,
});

/// Maintenance record row with its replaced filters.
typedef MaintenanceRecordWithFilters = ({
  MaintenanceRecordRow record,
  List<FilterType> filters,
});

@DriftAccessor(
  tables: [Customers, Devices, MaintenanceRecords, FilterReplacements],
)
class MaintenanceDao extends DatabaseAccessor<AppDatabase>
    with _$MaintenanceDaoMixin {
  MaintenanceDao(super.attachedDatabase);

  /// Deterministic "latest record" order: date, then creation time, then id.
  /// Columns are qualified because the sub-query is correlated with
  /// `devices`, which also has `id` and `created_at`.
  static String _latestFirst(String alias) =>
      '$alias.maintenance_date DESC, $alias.created_at DESC, $alias.id DESC';

  /// Overview rows, optionally restricted to one customer or one device.
  ///
  /// The latest record is picked by a correlated sub-query that uses the
  /// `(device_id, maintenance_date)` index.
  Stream<List<DeviceOverviewRow>> watchOverview({
    int? customerId,
    int? deviceId,
  }) {
    final conditions = <String>[
      if (customerId != null) 'd.customer_id = ?',
      if (deviceId != null) 'd.id = ?',
    ];
    final where = conditions.isEmpty ? '' : 'WHERE ${conditions.join(' AND ')}';

    return customSelect(
      'SELECT d.*, '
      'c.customer_number AS c_customer_number, '
      'c.first_name AS c_first_name, '
      'c.last_name AS c_last_name, '
      'lr.maintenance_date AS last_maintenance_date, '
      'lr.next_maintenance_date AS next_maintenance_date '
      'FROM devices d '
      'JOIN customers c ON c.id = d.customer_id '
      'LEFT JOIN maintenance_records lr ON lr.id = ('
      '  SELECT r.id FROM maintenance_records r WHERE r.device_id = d.id '
      '  ORDER BY ${_latestFirst('r')} LIMIT 1'
      ') '
      '$where ORDER BY d.id',
      variables: [
        if (customerId != null) Variable.withInt(customerId),
        if (deviceId != null) Variable.withInt(deviceId),
      ],
      readsFrom: {customers, devices, maintenanceRecords},
    ).watch().map((rows) => rows.map(_toOverviewRow).toList());
  }

  DeviceOverviewRow _toOverviewRow(QueryRow row) {
    const converter = CalendarDateConverter();
    final last = row.readNullable<String>('last_maintenance_date');
    final next = row.readNullable<String>('next_maintenance_date');
    return (
      device: devices.map(row.data),
      customerNumber: row.read<String>('c_customer_number'),
      customerFirstName: row.read<String>('c_first_name'),
      customerLastName: row.read<String>('c_last_name'),
      lastMaintenanceDate: last == null ? null : converter.fromSql(last),
      nextMaintenanceDate: next == null ? null : converter.fromSql(next),
    );
  }

  /// History of a device, newest first, with filters aggregated per record.
  Stream<List<MaintenanceRecordWithFilters>> watchHistory(int deviceId) {
    return customSelect(
      'SELECT r.*, '
      '(SELECT group_concat(f.filter_type) FROM filter_replacements f '
      ' WHERE f.maintenance_record_id = r.id) AS filter_types '
      'FROM maintenance_records r WHERE r.device_id = ? '
      'ORDER BY ${_latestFirst('r')}',
      variables: [Variable.withInt(deviceId)],
      readsFrom: {maintenanceRecords, filterReplacements},
    ).watch().map(
      (rows) => [
        for (final row in rows)
          (
            record: maintenanceRecords.map(row.data),
            filters: _parseFilters(row.readNullable<String>('filter_types')),
          ),
      ],
    );
  }

  static List<FilterType> _parseFilters(String? csv) {
    if (csv == null || csv.isEmpty) return const [];
    final names = csv.split(',').toSet();
    return [
      for (final type in FilterType.values)
        if (names.contains(type.name)) type,
    ];
  }

  /// Inserts the record and one filter row per type atomically.
  /// Returns the new record id.
  Future<int> insertRecordWithFilters(
    MaintenanceRecordsCompanion record,
    Iterable<FilterType> filters,
  ) {
    return transaction(() async {
      final recordId = await into(maintenanceRecords).insert(record);
      for (final type in filters) {
        await into(filterReplacements).insert(
          FilterReplacementsCompanion.insert(
            maintenanceRecordId: recordId,
            filterType: type,
          ),
        );
      }
      return recordId;
    });
  }

  Future<MaintenanceRecordRow?> findRecordById(int id) => (select(
    maintenanceRecords,
  )..where((r) => r.id.equals(id))).getSingleOrNull();
}
