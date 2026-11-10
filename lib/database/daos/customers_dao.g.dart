// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customers_dao.dart';

// ignore_for_file: type=lint
mixin _$CustomersDaoMixin on DatabaseAccessor<AppDatabase> {
  $CustomersTable get customers => attachedDatabase.customers;
  $DevicesTable get devices => attachedDatabase.devices;
  $MaintenanceRecordsTable get maintenanceRecords =>
      attachedDatabase.maintenanceRecords;
  $FilterReplacementsTable get filterReplacements =>
      attachedDatabase.filterReplacements;
  CustomersDaoManager get managers => CustomersDaoManager(this);
}

class CustomersDaoManager {
  final _$CustomersDaoMixin _db;
  CustomersDaoManager(this._db);
  $$CustomersTableTableManager get customers =>
      $$CustomersTableTableManager(_db.attachedDatabase, _db.customers);
  $$DevicesTableTableManager get devices =>
      $$DevicesTableTableManager(_db.attachedDatabase, _db.devices);
  $$MaintenanceRecordsTableTableManager get maintenanceRecords =>
      $$MaintenanceRecordsTableTableManager(
        _db.attachedDatabase,
        _db.maintenanceRecords,
      );
  $$FilterReplacementsTableTableManager get filterReplacements =>
      $$FilterReplacementsTableTableManager(
        _db.attachedDatabase,
        _db.filterReplacements,
      );
}
