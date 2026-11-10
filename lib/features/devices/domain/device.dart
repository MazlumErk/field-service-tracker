import 'package:equatable/equatable.dart';
import 'package:field_service_tracker/core/utils/calendar_date.dart';

/// A water-treatment device installed at a customer.
final class Device extends Equatable {
  const Device({
    required this.id,
    required this.customerId,
    required this.model,
    required this.installedAt,
    required this.createdAt,
    this.serialNumber,
  });

  final int id;
  final int customerId;
  final String model;
  final String? serialNumber;
  final CalendarDate installedAt;
  final DateTime createdAt;

  @override
  List<Object?> get props => [
    id,
    customerId,
    model,
    serialNumber,
    installedAt,
    createdAt,
  ];
}

/// Raw user input for creating or updating a device.
final class DeviceDraft extends Equatable {
  const DeviceDraft({
    required this.model,
    required this.installedAt,
    this.serialNumber,
  });

  final String model;
  final String? serialNumber;
  final CalendarDate installedAt;

  /// Trimmed copy with blank serial number turned into `null`.
  DeviceDraft normalized() {
    final serial = serialNumber?.trim();
    return DeviceDraft(
      model: model.trim().replaceAll(RegExp(r'\s+'), ' '),
      serialNumber: serial == null || serial.isEmpty ? null : serial,
      installedAt: installedAt,
    );
  }

  @override
  List<Object?> get props => [model, serialNumber, installedAt];
}
