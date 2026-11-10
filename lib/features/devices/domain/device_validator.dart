import 'package:field_service_tracker/core/utils/calendar_date.dart';
import 'package:field_service_tracker/core/validation/validation_result.dart';
import 'package:field_service_tracker/features/devices/domain/device.dart';

enum DeviceField { model, serialNumber, installedAt }

/// Validation rules for device input.
abstract final class DeviceValidator {
  static const int maxModelLength = 80;
  static const int maxSerialNumberLength = 50;

  /// [today] comes from `AppClock`; installation cannot be in the future.
  static ValidationResult<DeviceField> validate(
    DeviceDraft draft, {
    required CalendarDate today,
  }) {
    final input = draft.normalized();
    final errors = <DeviceField, ValidationError>{};

    if (input.model.isEmpty) {
      errors[DeviceField.model] = ValidationError.required;
    } else if (input.model.length > maxModelLength) {
      errors[DeviceField.model] = ValidationError.tooLong;
    }

    final serial = input.serialNumber;
    if (serial != null && serial.length > maxSerialNumberLength) {
      errors[DeviceField.serialNumber] = ValidationError.tooLong;
    }

    if (input.installedAt.isAfter(today)) {
      errors[DeviceField.installedAt] = ValidationError.inFuture;
    }

    return ValidationResult(errors);
  }
}
