import 'package:drift/drift.dart';
import 'package:field_service_tracker/core/clock/app_clock.dart';
import 'package:field_service_tracker/core/errors/app_exception.dart';
import 'package:field_service_tracker/core/utils/calendar_date.dart';
import 'package:field_service_tracker/database/app_database.dart';
import 'package:field_service_tracker/database/daos/maintenance_dao.dart';
import 'package:field_service_tracker/database/database_error_mapper.dart';
import 'package:field_service_tracker/features/devices/data/drift_device_repository.dart';
import 'package:field_service_tracker/features/maintenance/domain/device_maintenance_overview.dart';
import 'package:field_service_tracker/features/maintenance/domain/filter_type.dart';
import 'package:field_service_tracker/features/maintenance/domain/maintenance_record.dart';
import 'package:field_service_tracker/features/maintenance/domain/maintenance_repository.dart';
import 'package:field_service_tracker/features/maintenance/domain/maintenance_validator.dart';

/// Drift implementation of [MaintenanceRepository].
final class DriftMaintenanceRepository implements MaintenanceRepository {
  DriftMaintenanceRepository(this._database, this._clock);

  final AppDatabase _database;
  final AppClock _clock;

  MaintenanceDao get _dao => _database.maintenanceDao;

  @override
  Stream<List<DeviceMaintenanceOverview>> watchOverview() =>
      _overviews(_dao.watchOverview());

  @override
  Stream<List<DeviceMaintenanceOverview>> watchCustomerOverview(
    int customerId,
  ) => _overviews(_dao.watchOverview(customerId: customerId));

  @override
  Stream<DeviceMaintenanceOverview?> watchDeviceOverview(int deviceId) =>
      _overviews(_dao.watchOverview(deviceId: deviceId))
          .map((items) => items.isEmpty ? null : items.single);

  @override
  Stream<List<MaintenanceRecord>> watchHistory(int deviceId) =>
      guardDatabaseStream(
        _dao
            .watchHistory(deviceId)
            .map(
              (rows) => [
                for (final row in rows) row.record.toDomain(row.filters),
              ],
            ),
      );

  @override
  Future<MaintenanceRecord> createRecord(
    int deviceId,
    MaintenanceRecordDraft draft,
  ) => guardDatabase(() async {
    final result = MaintenanceValidator.validate(
      draft,
      today: CalendarDate.today(_clock),
    );
    if (!result.isValid) throw ValidationException(result.errors);
    final input = draft.normalized();

    if (await _database.devicesDao.findById(deviceId) == null) {
      throw NotFoundException('Device', deviceId);
    }

    final filters = [
      for (final type in FilterType.values)
        if (input.filters.contains(type)) type,
    ];
    final id = await _dao.insertRecordWithFilters(
      MaintenanceRecordsCompanion.insert(
        deviceId: deviceId,
        maintenanceDate: input.maintenanceDate,
        nextMaintenanceDate: input.nextMaintenanceDate,
        priceKurus: input.priceKurus,
        notes: Value(input.notes),
        createdAt: _clock.now().toUtc(),
      ),
      filters,
    );
    return (await _dao.findRecordById(id))!.toDomain(filters);
  });

  Stream<List<DeviceMaintenanceOverview>> _overviews(
    Stream<List<DeviceOverviewRow>> rows,
  ) => guardDatabaseStream(
    rows.map(
      (items) => [
        for (final row in items)
          DeviceMaintenanceOverview(
            device: row.device.toDomain(),
            customerId: row.device.customerId,
            customerNumber: row.customerNumber,
            customerFirstName: row.customerFirstName,
            customerLastName: row.customerLastName,
            lastMaintenanceDate: row.lastMaintenanceDate,
            nextMaintenanceDate: row.nextMaintenanceDate,
          ),
      ],
    ),
  );
}

extension on MaintenanceRecordRow {
  MaintenanceRecord toDomain(List<FilterType> filters) => MaintenanceRecord(
    id: id,
    deviceId: deviceId,
    maintenanceDate: maintenanceDate,
    nextMaintenanceDate: nextMaintenanceDate,
    priceKurus: priceKurus,
    filters: List.unmodifiable(filters),
    notes: notes,
    createdAt: createdAt.toUtc(),
  );
}
