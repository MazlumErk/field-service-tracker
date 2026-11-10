import 'package:field_service_tracker/features/devices/domain/device.dart';

/// Device persistence. All methods throw `AppException` subtypes only.
///
/// Lists of devices together with their maintenance state are served by
/// `MaintenanceRepository` (overview streams), because they need the latest
/// maintenance record.
abstract interface class DeviceRepository {
  /// Emits `null` when the device is deleted.
  Stream<Device?> watchDevice(int id);

  /// Throws `NotFoundException`.
  Future<Device> getDevice(int id);

  /// Throws `NotFoundException` (unknown customer) or `ValidationException`.
  Future<Device> createDevice(int customerId, DeviceDraft draft);

  /// Updates model, serial number and installation date. The owning
  /// customer can never be changed through this method.
  /// Throws `NotFoundException` or `ValidationException`.
  Future<Device> updateDevice(int id, DeviceDraft draft);

  /// Counts what [deleteDevice] would remove. Throws `NotFoundException`.
  Future<DeviceDeletionImpact> getDeletionImpact(int id);

  /// Deletes the device **and** its maintenance records and filter
  /// replacements in one transaction. Call only after the user confirmed the
  /// [getDeletionImpact] counts. Throws `NotFoundException`.
  Future<void> deleteDevice(int id);
}
