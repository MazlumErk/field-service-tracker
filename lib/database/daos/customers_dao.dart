import 'package:drift/drift.dart';
import 'package:field_service_tracker/database/app_database.dart';
import 'package:field_service_tracker/database/tables/customers_table.dart';
import 'package:field_service_tracker/database/tables/devices_table.dart';
import 'package:field_service_tracker/database/tables/filter_replacements_table.dart';
import 'package:field_service_tracker/database/tables/maintenance_records_table.dart';

part 'customers_dao.g.dart';

/// Customer row together with the number of its devices.
typedef CustomerWithDeviceCount = ({CustomerRow customer, int deviceCount});

/// Counts of rows that belong to a customer.
typedef CustomerRelatedCounts = ({int devices, int maintenanceRecords});

@DriftAccessor(
  tables: [Customers, Devices, MaintenanceRecords, FilterReplacements],
)
class CustomersDao extends DatabaseAccessor<AppDatabase>
    with _$CustomersDaoMixin {
  CustomersDao(super.attachedDatabase);

  /// Customers whose `search_key` contains every token (already normalized
  /// with `TurkishText.searchTokens`). Empty [tokens] returns all customers.
  Stream<List<CustomerWithDeviceCount>> watchWithDeviceCount(
    List<String> tokens,
  ) {
    final where = tokens.isEmpty
        ? ''
        : 'WHERE ${List.filled(tokens.length, r"c.search_key LIKE ? ESCAPE '\'").join(' AND ')}';
    return customSelect(
      'SELECT c.*, '
      '(SELECT COUNT(*) FROM devices d WHERE d.customer_id = c.id) '
      'AS device_count '
      'FROM customers c $where ORDER BY c.id',
      variables: [
        for (final t in tokens) Variable.withString('%${_escapeLike(t)}%'),
      ],
      readsFrom: {customers, devices},
    ).watch().map(
      (rows) => [
        for (final row in rows)
          (
            customer: customers.map(row.data),
            deviceCount: row.read<int>('device_count'),
          ),
      ],
    );
  }

  Stream<CustomerRow?> watchById(int id) =>
      (select(customers)..where((c) => c.id.equals(id))).watchSingleOrNull();

  Stream<int> watchCount() {
    final count = customers.id.count();
    return (selectOnly(
      customers,
    )..addColumns([count])).map((row) => row.read(count) ?? 0).watchSingle();
  }

  Future<CustomerRow?> findById(int id) =>
      (select(customers)..where((c) => c.id.equals(id))).getSingleOrNull();

  Future<bool> existsById(int id) async => await findById(id) != null;

  /// Whether a customer other than [excludingId] uses [customerNumber]
  /// (expects the normalized value).
  Future<bool> isNumberTaken(String customerNumber, {int? excludingId}) async {
    final query = select(customers)
      ..where((c) {
        final sameNumber = c.customerNumber.equals(customerNumber);
        return excludingId == null
            ? sameNumber
            : sameNumber & c.id.equals(excludingId).not();
      })
      ..limit(1);
    return await query.getSingleOrNull() != null;
  }

  Future<int> insertCustomer(CustomersCompanion entry) =>
      into(customers).insert(entry);

  /// Returns the number of updated rows (0 when [id] does not exist).
  Future<int> updateCustomer(int id, CustomersCompanion entry) =>
      (update(customers)..where((c) => c.id.equals(id))).write(entry);

  Future<CustomerRelatedCounts> relatedCounts(int customerId) async {
    final row = await customSelect(
      'SELECT '
      '(SELECT COUNT(*) FROM devices WHERE customer_id = ?1) AS devices, '
      '(SELECT COUNT(*) FROM maintenance_records r '
      ' JOIN devices d ON d.id = r.device_id WHERE d.customer_id = ?1) '
      'AS maintenance_records',
      variables: [Variable.withInt(customerId)],
      readsFrom: {devices, maintenanceRecords},
    ).getSingle();
    return (
      devices: row.read<int>('devices'),
      maintenanceRecords: row.read<int>('maintenance_records'),
    );
  }

  /// Explicit cascade: filters → records → devices → customer, atomically.
  /// Returns `false` (and changes nothing) when the customer does not exist.
  Future<bool> deleteWithRelatedRecords(int customerId) {
    return transaction(() async {
      if (!await existsById(customerId)) return false;

      final deviceIds = selectOnly(devices)
        ..addColumns([devices.id])
        ..where(devices.customerId.equals(customerId));
      final recordIds = selectOnly(maintenanceRecords)
        ..addColumns([maintenanceRecords.id])
        ..where(maintenanceRecords.deviceId.isInQuery(deviceIds));

      await (delete(
        filterReplacements,
      )..where((f) => f.maintenanceRecordId.isInQuery(recordIds))).go();
      await (delete(
        maintenanceRecords,
      )..where((r) => r.deviceId.isInQuery(deviceIds))).go();
      await (delete(
        devices,
      )..where((d) => d.customerId.equals(customerId))).go();
      await (delete(customers)..where((c) => c.id.equals(customerId))).go();
      return true;
    });
  }

  static String _escapeLike(String value) => value
      .replaceAll(r'\', r'\\')
      .replaceAll('%', r'\%')
      .replaceAll('_', r'\_');
}
