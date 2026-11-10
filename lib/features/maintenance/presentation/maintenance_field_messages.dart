import 'package:field_service_tracker/core/validation/validation_result.dart';
import 'package:field_service_tracker/features/maintenance/domain/maintenance_validator.dart';
import 'package:field_service_tracker/l10n/app_localizations.dart';

/// Turkish inline message for a maintenance form field error.
String maintenanceFieldErrorText(
  AppLocalizations l10n,
  MaintenanceField field,
  ValidationError error,
) {
  return switch ((field, error)) {
    (_, ValidationError.required) => l10n.validationRequired,
    (MaintenanceField.maintenanceDate, ValidationError.inFuture) =>
      l10n.validationMaintenanceDateFuture,
    (_, ValidationError.beforeMaintenanceDate) =>
      l10n.validationNextBeforeMaintenance,
    (MaintenanceField.filters, _) => l10n.validationFiltersEmpty,
    (MaintenanceField.price, ValidationError.negative) =>
      l10n.validationPriceNegative,
    (MaintenanceField.price, ValidationError.tooLarge) =>
      l10n.validationPriceTooLarge,
    (MaintenanceField.price, _) => l10n.validationPriceFormat,
    (MaintenanceField.notes, ValidationError.tooLong) => l10n.validationTooLong(
      MaintenanceValidator.maxNotesLength,
    ),
    _ => l10n.errorValidation,
  };
}
