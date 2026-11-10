import 'package:field_service_tracker/core/validation/validation_result.dart';
import 'package:field_service_tracker/features/customers/domain/customer_number.dart';
import 'package:field_service_tracker/features/customers/domain/customer_validator.dart';
import 'package:field_service_tracker/l10n/app_localizations.dart';

/// Turkish inline message for a customer form field error.
String customerFieldErrorText(
  AppLocalizations l10n,
  CustomerField field,
  ValidationError error,
) {
  return switch (error) {
    ValidationError.required => l10n.validationRequired,
    ValidationError.tooLong => l10n.validationTooLong(maxLengthOf(field)),
    ValidationError.alreadyInUse => l10n.validationAlreadyInUse,
    ValidationError.invalidFormat => switch (field) {
      CustomerField.phone => l10n.validationPhoneFormat,
      _ => l10n.validationCustomerNumberFormat,
    },
    // Not produced for customers; generic fallback keeps the switch total.
    _ => l10n.errorValidation,
  };
}

/// Maximum input length per field (mirrors the domain/schema limits).
int maxLengthOf(CustomerField field) => switch (field) {
  CustomerField.customerNumber => CustomerNumber.maxLength,
  CustomerField.firstName ||
  CustomerField.lastName => CustomerValidator.maxNameLength,
  CustomerField.phone => 20,
  CustomerField.address => CustomerValidator.maxAddressLength,
};
