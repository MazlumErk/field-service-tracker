// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'devices_dao.dart';

// ignore_for_file: type=lint
mixin _$DevicesDaoMixin on DatabaseAccessor<AppDatabase> {
  $CustomersTable get customers => attachedDatabase.customers;
  $DevicesTable get devices => attachedDatabase.devices;
  DevicesDaoManager get managers => DevicesDaoManager(this);
}

class DevicesDaoManager {
  final _$DevicesDaoMixin _db;
  DevicesDaoManager(this._db);
  $$CustomersTableTableManager get customers =>
      $$CustomersTableTableManager(_db.attachedDatabase, _db.customers);
  $$DevicesTableTableManager get devices =>
      $$DevicesTableTableManager(_db.attachedDatabase, _db.devices);
}
