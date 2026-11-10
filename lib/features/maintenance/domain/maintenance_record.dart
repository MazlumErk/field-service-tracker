import 'package:equatable/equatable.dart';
import 'package:field_service_tracker/core/utils/calendar_date.dart';
import 'package:field_service_tracker/features/maintenance/domain/filter_type.dart';

/// A completed maintenance visit. Immutable once saved: a new visit creates
/// a new record instead of editing history.
final class MaintenanceRecord extends Equatable {
  const MaintenanceRecord({
    required this.id,
    required this.deviceId,
    required this.maintenanceDate,
    required this.nextMaintenanceDate,
    required this.priceKurus,
    required this.filters,
    required this.createdAt,
    this.notes,
  });

  final int id;
  final int deviceId;
  final CalendarDate maintenanceDate;
  final CalendarDate nextMaintenanceDate;
  final int priceKurus;

  /// Replaced filters in [FilterType] declaration order.
  final List<FilterType> filters;
  final String? notes;
  final DateTime createdAt;

  @override
  List<Object?> get props => [
    id,
    deviceId,
    maintenanceDate,
    nextMaintenanceDate,
    priceKurus,
    filters,
    notes,
    createdAt,
  ];
}

/// Raw user input for a new maintenance record.
final class MaintenanceRecordDraft extends Equatable {
  const MaintenanceRecordDraft({
    required this.maintenanceDate,
    required this.nextMaintenanceDate,
    required this.priceKurus,
    required this.filters,
    this.notes,
  });

  final CalendarDate maintenanceDate;
  final CalendarDate nextMaintenanceDate;
  final int priceKurus;
  final Set<FilterType> filters;
  final String? notes;

  /// Trimmed notes (blank → `null`).
  MaintenanceRecordDraft normalized() {
    final trimmed = notes?.trim();
    return MaintenanceRecordDraft(
      maintenanceDate: maintenanceDate,
      nextMaintenanceDate: nextMaintenanceDate,
      priceKurus: priceKurus,
      filters: filters,
      notes: trimmed == null || trimmed.isEmpty ? null : trimmed,
    );
  }

  @override
  List<Object?> get props => [
    maintenanceDate,
    nextMaintenanceDate,
    priceKurus,
    filters,
    notes,
  ];
}
