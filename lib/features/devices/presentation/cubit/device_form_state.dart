import 'package:equatable/equatable.dart';
import 'package:field_service_tracker/core/errors/app_exception.dart';
import 'package:field_service_tracker/core/utils/calendar_date.dart';
import 'package:field_service_tracker/core/validation/validation_result.dart';
import 'package:field_service_tracker/features/devices/domain/device.dart';
import 'package:field_service_tracker/features/devices/domain/device_validator.dart';

enum DeviceFormStatus { loading, loadFailure, editing, submitting, success }

/// State of the shared create / edit device form.
///
/// Text fields live in the page's controllers; the installation date is
/// chosen with a date picker and therefore kept here.
final class DeviceFormState extends Equatable {
  const DeviceFormState({
    required this.status,
    required this.today,
    required this.installedAt,
    this.initialDevice,
    this.fieldErrors = const {},
    this.failure,
    this.savedDevice,
  });

  final DeviceFormStatus status;

  /// Upper bound for the date picker (from `AppClock`).
  final CalendarDate today;
  final CalendarDate installedAt;

  /// The device being edited (`null` in create mode).
  final Device? initialDevice;
  final Map<DeviceField, ValidationError> fieldErrors;

  /// Non-field error (load or save failure), shown once.
  final AppException? failure;
  final Device? savedDevice;

  bool get isEditMode => initialDevice != null;

  bool get isSubmitting => status == DeviceFormStatus.submitting;

  DeviceFormState copyWith({
    DeviceFormStatus? status,
    CalendarDate? installedAt,
    Device? initialDevice,
    Map<DeviceField, ValidationError>? fieldErrors,
    AppException? failure,
    Device? savedDevice,
  }) {
    return DeviceFormState(
      status: status ?? this.status,
      today: today,
      installedAt: installedAt ?? this.installedAt,
      initialDevice: initialDevice ?? this.initialDevice,
      fieldErrors: fieldErrors ?? this.fieldErrors,
      failure: failure,
      savedDevice: savedDevice ?? this.savedDevice,
    );
  }

  @override
  List<Object?> get props => [
    status,
    today,
    installedAt,
    initialDevice,
    fieldErrors,
    failure,
    savedDevice,
  ];
}
