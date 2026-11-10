import 'package:field_service_tracker/core/validation/validation_result.dart';
import 'package:field_service_tracker/features/devices/domain/device_validator.dart';
import 'package:field_service_tracker/l10n/app_localizations.dart';

/// Turkish inline message for a device form field error.
String deviceFieldErrorText(
  AppLocalizations l10n,
  DeviceField field,
  ValidationError error,
) {
  return switch (error) {
    ValidationError.required => l10n.validationRequired,
    ValidationError.tooLong => l10n.validationTooLong(deviceMaxLengthOf(field)),
    ValidationError.inFuture => l10n.validationInstalledAtFuture,
    _ => l10n.errorValidation,
  };
}

int deviceMaxLengthOf(DeviceField field) => switch (field) {
  DeviceField.model => DeviceValidator.maxModelLength,
  DeviceField.serialNumber => DeviceValidator.maxSerialNumberLength,
  // Not a text field; never used for length limits.
  DeviceField.installedAt => 10,
};
