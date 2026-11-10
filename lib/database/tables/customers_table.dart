import 'package:drift/drift.dart';

/// `customers` — one row per customer.
///
/// `customer_number` is stored normalized and is UNIQUE.
/// `search_key` holds the Turkish-folded "first last number" text used by the
/// list search (SQLite `LIKE` folds ASCII only).
@DataClassName('CustomerRow')
@TableIndex(name: 'idx_customers_search_key', columns: {#searchKey})
class Customers extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get customerNumber => text().withLength(min: 1, max: 20)();
  TextColumn get firstName => text().withLength(min: 1, max: 50)();
  TextColumn get lastName => text().withLength(min: 1, max: 50)();
  TextColumn get phone => text().nullable()();
  TextColumn get address => text().nullable()();
  TextColumn get searchKey => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  List<Set<Column>> get uniqueKeys => [
    {customerNumber},
  ];

  @override
  List<String> get customConstraints => [
    'CHECK (length(trim(first_name)) > 0)',
    'CHECK (length(trim(last_name)) > 0)',
  ];
}
