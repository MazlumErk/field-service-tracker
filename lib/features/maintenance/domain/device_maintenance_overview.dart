import 'package:equatable/equatable.dart';
import 'package:field_service_tracker/core/utils/calendar_date.dart';
import 'package:field_service_tracker/features/devices/domain/device.dart';
import 'package:field_service_tracker/features/maintenance/domain/maintenance_status.dart';

/// A device with its owner and the dates of its latest maintenance record.
///
/// Feeds the dashboard, the maintenance list and customer detail. The status
/// is *not* stored: it depends on "today", so it is computed on demand with
/// [statusOn] using the injected clock.
final class DeviceMaintenanceOverview extends Equatable {
  const DeviceMaintenanceOverview({
    required this.device,
    required this.customerId,
    required this.customerNumber,
    required this.customerFirstName,
    required this.customerLastName,
    this.lastMaintenanceDate,
    this.nextMaintenanceDate,
  });

  final Device device;
  final int customerId;
  final String customerNumber;
  final String customerFirstName;
  final String customerLastName;

  /// `null` when the device has no maintenance record.
  final CalendarDate? lastMaintenanceDate;
  final CalendarDate? nextMaintenanceDate;

  String get customerFullName => '$customerFirstName $customerLastName';

  bool get hasMaintenance => lastMaintenanceDate != null;

  MaintenanceStatus statusOn(CalendarDate today) =>
      MaintenanceStatusCalculator.statusFor(
        nextMaintenanceDate: nextMaintenanceDate,
        today: today,
      );

  @override
  List<Object?> get props => [
    device,
    customerId,
    customerNumber,
    customerFirstName,
    customerLastName,
    lastMaintenanceDate,
    nextMaintenanceDate,
  ];
}
