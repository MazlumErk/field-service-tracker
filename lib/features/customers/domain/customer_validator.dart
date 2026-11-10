import 'package:field_service_tracker/core/validation/validation_result.dart';
import 'package:field_service_tracker/features/customers/domain/customer_draft.dart';
import 'package:field_service_tracker/features/customers/domain/customer_number.dart';

enum CustomerField { customerNumber, firstName, lastName, phone, address }

/// Validation rules for customer input. Pure and synchronous; uniqueness of
/// the customer number is checked by the repository (needs the database).
abstract final class CustomerValidator {
  static const int maxNameLength = 50;
  static const int maxAddressLength = 250;
  static const int minPhoneDigits = 10;
  static const int maxPhoneDigits = 15;

  static final RegExp _phoneCharacters = RegExp(r'^[0-9 +()\-]+$');
  static final RegExp _nonDigit = RegExp(r'\D');

  static ValidationResult<CustomerField> validate(CustomerDraft draft) {
    final input = draft.normalized();
    final errors = <CustomerField, ValidationError>{};

    if (input.customerNumber.isEmpty) {
      errors[CustomerField.customerNumber] = ValidationError.required;
    } else if (input.customerNumber.length > CustomerNumber.maxLength) {
      errors[CustomerField.customerNumber] = ValidationError.tooLong;
    } else if (!CustomerNumber.isValidFormat(input.customerNumber)) {
      errors[CustomerField.customerNumber] = ValidationError.invalidFormat;
    }

    _validateName(input.firstName, CustomerField.firstName, errors);
    _validateName(input.lastName, CustomerField.lastName, errors);

    final phone = input.phone;
    if (phone != null) {
      final digitCount = phone.replaceAll(_nonDigit, '').length;
      if (!_phoneCharacters.hasMatch(phone) ||
          digitCount < minPhoneDigits ||
          digitCount > maxPhoneDigits) {
        errors[CustomerField.phone] = ValidationError.invalidFormat;
      }
    }

    final address = input.address;
    if (address != null && address.length > maxAddressLength) {
      errors[CustomerField.address] = ValidationError.tooLong;
    }

    return ValidationResult(errors);
  }

  static void _validateName(
    String value,
    CustomerField field,
    Map<CustomerField, ValidationError> errors,
  ) {
    if (value.isEmpty) {
      errors[field] = ValidationError.required;
    } else if (value.length > maxNameLength) {
      errors[field] = ValidationError.tooLong;
    }
  }
}
