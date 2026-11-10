// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'maintenance_dao.dart';

// ignore_for_file: type=lint
mixin _$MaintenanceDaoMixin on DatabaseAccessor<AppDatabase> {
  $CustomersTable get customers => attachedDatabase.customers;
  $DevicesTable get devices => attachedDatabase.devices;
  $MaintenanceRecordsTable get maintenanceRecords =>
      attachedDatabase.maintenanceRecords;
  $FilterReplacementsTable get filterReplacements =>
      attachedDatabase.filterReplacements;
  MaintenanceDaoManager get managers => MaintenanceDaoManager(this);
}

class MaintenanceDaoManager {
  final _$MaintenanceDaoMixin _db;
  MaintenanceDaoManager(this._db);
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
