import 'package:field_service_tracker/core/utils/calendar_date.dart';
import 'package:field_service_tracker/core/validation/validation_result.dart';
import 'package:field_service_tracker/features/maintenance/domain/maintenance_price.dart';
import 'package:field_service_tracker/features/maintenance/domain/maintenance_record.dart';

enum MaintenanceField {
  maintenanceDate,
  nextMaintenanceDate,
  price,
  filters,
  notes,
}

/// Validation rules for a new maintenance record.
abstract final class MaintenanceValidator {
  static const int maxNotesLength = 500;

  /// [today] comes from `AppClock`; a visit cannot be recorded in advance.
  static ValidationResult<MaintenanceField> validate(
    MaintenanceRecordDraft draft, {
    required CalendarDate today,
  }) {
    final input = draft.normalized();
    final errors = <MaintenanceField, ValidationError>{};

    if (input.maintenanceDate.isAfter(today)) {
      errors[MaintenanceField.maintenanceDate] = ValidationError.inFuture;
    }

    if (input.nextMaintenanceDate.isBefore(input.maintenanceDate)) {
      errors[MaintenanceField.nextMaintenanceDate] =
          ValidationError.beforeMaintenanceDate;
    }

    if (input.priceKurus < 0) {
      errors[MaintenanceField.price] = ValidationError.negative;
    } else if (!MaintenancePrice.isValidKurus(input.priceKurus)) {
      errors[MaintenanceField.price] = ValidationError.tooLarge;
    }

    if (input.filters.isEmpty) {
      errors[MaintenanceField.filters] = ValidationError.empty;
    }

    final notes = input.notes;
    if (notes != null && notes.length > maxNotesLength) {
      errors[MaintenanceField.notes] = ValidationError.tooLong;
    }

    return ValidationResult(errors);
  }
}
