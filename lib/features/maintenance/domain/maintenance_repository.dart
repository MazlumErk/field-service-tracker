import 'package:field_service_tracker/features/maintenance/domain/device_maintenance_overview.dart';
import 'package:field_service_tracker/features/maintenance/domain/maintenance_record.dart';

/// Maintenance persistence and the reactive device overviews.
/// All methods throw `AppException` subtypes only.
abstract interface class MaintenanceRepository {
  /// Every device with its latest maintenance dates. Re-emits whenever a
  /// customer, device or maintenance record changes (dashboard, list).
  Stream<List<DeviceMaintenanceOverview>> watchOverview();

  /// Overviews of one customer's devices (customer detail).
  Stream<List<DeviceMaintenanceOverview>> watchCustomerOverview(int customerId);

  /// Overview of one device; emits `null` when it no longer exists.
  Stream<DeviceMaintenanceOverview?> watchDeviceOverview(int deviceId);

  /// History of a device, newest first. Ties on the same maintenance date
  /// are ordered by creation time, then id (newest first).
  Stream<List<MaintenanceRecord>> watchHistory(int deviceId);

  /// Saves the record and its filter replacements in one transaction.
  /// Throws `NotFoundException` (unknown device) or `ValidationException`.
  Future<MaintenanceRecord> createRecord(
    int deviceId,
    MaintenanceRecordDraft draft,
  );
}
