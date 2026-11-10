import 'package:drift/drift.dart';
import 'package:field_service_tracker/database/converters/calendar_date_converter.dart';
import 'package:field_service_tracker/database/tables/customers_table.dart';

/// `devices` — each device belongs to exactly one customer.
///
/// `ON DELETE RESTRICT`: a customer with devices cannot be deleted by
/// accident; the repository deletes children explicitly in a transaction.
@DataClassName('DeviceRow')
@TableIndex(name: 'idx_devices_customer_id', columns: {#customerId})
class Devices extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get customerId => integer().references(
    Customers,
    #id,
    onDelete: KeyAction.restrict,
    onUpdate: KeyAction.restrict,
  )();
  TextColumn get model => text().withLength(min: 1, max: 80)();
  TextColumn get serialNumber => text().nullable()();
  TextColumn get installedAt => text().map(const CalendarDateConverter())();
  DateTimeColumn get createdAt => dateTime()();

  @override
  List<String> get customConstraints => ['CHECK (length(trim(model)) > 0)'];
}
