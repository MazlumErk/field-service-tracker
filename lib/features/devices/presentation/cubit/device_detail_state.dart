import 'package:equatable/equatable.dart';
import 'package:field_service_tracker/core/errors/app_exception.dart';
import 'package:field_service_tracker/core/utils/calendar_date.dart';
import 'package:field_service_tracker/features/devices/domain/device.dart';
import 'package:field_service_tracker/features/maintenance/domain/device_maintenance_overview.dart';
import 'package:field_service_tracker/features/maintenance/domain/maintenance_record.dart';
import 'package:field_service_tracker/features/maintenance/domain/maintenance_status.dart';

enum DeviceDetailStatus { loading, success, notFound, failure }

/// Steps of the delete flow. The UI shows the confirmation dialog on
/// [confirming] and leaves the page on [deleted].
enum DeviceDeletionStep { idle, loadingImpact, confirming, deleting, deleted }

final class DeviceDetailState extends Equatable {
  const DeviceDetailState({
    required this.today,
    this.status = DeviceDetailStatus.loading,
    this.overview,
    this.history = const [],
    this.failure,
    this.deletionStep = DeviceDeletionStep.idle,
    this.deletionImpact,
    this.deletionFailure,
  });

  /// Reference day for the maintenance status (from `AppClock`).
  final CalendarDate today;
  final DeviceDetailStatus status;

  /// Device + owner + latest maintenance dates.
  final DeviceMaintenanceOverview? overview;

  /// Maintenance records, newest first (repository order).
  final List<MaintenanceRecord> history;
  final AppException? failure;

  final DeviceDeletionStep deletionStep;

  /// Set while [deletionStep] is [DeviceDeletionStep.confirming].
  final DeviceDeletionImpact? deletionImpact;

  /// Last delete error, shown once.
  final AppException? deletionFailure;

  /// Computed with `MaintenanceStatusCalculator` via the overview.
  MaintenanceStatus? get maintenanceStatus => overview?.statusOn(today);

  /// Signed days from today to the next maintenance (`null` without record).
  int? get daysUntilNextMaintenance {
    final next = overview?.nextMaintenanceDate;
    return next == null ? null : today.daysUntil(next);
  }

  bool get hasHistory => history.isNotEmpty;

  bool get isBusy =>
      deletionStep == DeviceDeletionStep.loadingImpact ||
      deletionStep == DeviceDeletionStep.deleting;

  DeviceDetailState copyWith({
    CalendarDate? today,
    DeviceDetailStatus? status,
    DeviceMaintenanceOverview? overview,
    List<MaintenanceRecord>? history,
    AppException? failure,
    DeviceDeletionStep? deletionStep,
    DeviceDeletionImpact? deletionImpact,
    AppException? deletionFailure,
  }) {
    final nextStep = deletionStep ?? this.deletionStep;
    return DeviceDetailState(
      today: today ?? this.today,
      status: status ?? this.status,
      overview: overview ?? this.overview,
      history: history ?? this.history,
      failure: failure,
      deletionStep: nextStep,
      // Survives stream updates while the dialog is open.
      deletionImpact: nextStep == DeviceDeletionStep.confirming
          ? deletionImpact ?? this.deletionImpact
          : null,
      deletionFailure: deletionFailure,
    );
  }

  @override
  List<Object?> get props => [
    today,
    status,
    overview,
    history,
    failure,
    deletionStep,
    deletionImpact,
    deletionFailure,
  ];
}
