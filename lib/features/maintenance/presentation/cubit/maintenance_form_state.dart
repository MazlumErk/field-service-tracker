import 'package:equatable/equatable.dart';
import 'package:field_service_tracker/core/errors/app_exception.dart';
import 'package:field_service_tracker/core/utils/calendar_date.dart';
import 'package:field_service_tracker/core/validation/validation_result.dart';
import 'package:field_service_tracker/features/maintenance/domain/device_maintenance_overview.dart';
import 'package:field_service_tracker/features/maintenance/domain/filter_type.dart';
import 'package:field_service_tracker/features/maintenance/domain/maintenance_record.dart';
import 'package:field_service_tracker/features/maintenance/domain/maintenance_validator.dart';

enum MaintenanceFormStatus {
  /// Loading the device header (model + customer).
  loading,

  /// The device does not exist (anymore) or could not be loaded.
  loadFailure,
  editing,
  submitting,
  success,
}

/// State of the "new maintenance record" form.
///
/// Dates and filter selection live here; price and notes are free text in
/// the page's controllers and are passed on submit.
final class MaintenanceFormState extends Equatable {
  const MaintenanceFormState({
    required this.status,
    required this.today,
    required this.maintenanceDate,
    required this.nextMaintenanceDate,
    this.nextDateCustomized = false,
    this.filters = const {},
    this.device,
    this.fieldErrors = const {},
    this.failure,
    this.savedRecord,
  });

  final MaintenanceFormStatus status;

  /// From `AppClock`; upper bound of the maintenance date.
  final CalendarDate today;
  final CalendarDate maintenanceDate;
  final CalendarDate nextMaintenanceDate;

  /// `true` once the user picked the next date. Until then it follows the
  /// 6-month suggestion whenever the maintenance date changes.
  final bool nextDateCustomized;
  final Set<FilterType> filters;

  /// Header data: device model and owner.
  final DeviceMaintenanceOverview? device;
  final Map<MaintenanceField, ValidationError> fieldErrors;

  /// Non-field error (load or save failure), shown once.
  final AppException? failure;
  final MaintenanceRecord? savedRecord;

  bool get isSubmitting => status == MaintenanceFormStatus.submitting;

  MaintenanceFormState copyWith({
    MaintenanceFormStatus? status,
    CalendarDate? maintenanceDate,
    CalendarDate? nextMaintenanceDate,
    bool? nextDateCustomized,
    Set<FilterType>? filters,
    DeviceMaintenanceOverview? device,
    Map<MaintenanceField, ValidationError>? fieldErrors,
    AppException? failure,
    MaintenanceRecord? savedRecord,
  }) {
    return MaintenanceFormState(
      status: status ?? this.status,
      today: today,
      maintenanceDate: maintenanceDate ?? this.maintenanceDate,
      nextMaintenanceDate: nextMaintenanceDate ?? this.nextMaintenanceDate,
      nextDateCustomized: nextDateCustomized ?? this.nextDateCustomized,
      filters: filters ?? this.filters,
      device: device ?? this.device,
      fieldErrors: fieldErrors ?? this.fieldErrors,
      failure: failure,
      savedRecord: savedRecord ?? this.savedRecord,
    );
  }

  @override
  List<Object?> get props => [
    status,
    today,
    maintenanceDate,
    nextMaintenanceDate,
    nextDateCustomized,
    filters,
    device,
    fieldErrors,
    failure,
    savedRecord,
  ];
}
