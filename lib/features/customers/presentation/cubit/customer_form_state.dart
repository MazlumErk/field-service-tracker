import 'package:equatable/equatable.dart';
import 'package:field_service_tracker/core/errors/app_exception.dart';
import 'package:field_service_tracker/core/validation/validation_result.dart';
import 'package:field_service_tracker/features/customers/domain/customer.dart';
import 'package:field_service_tracker/features/customers/domain/customer_validator.dart';

enum CustomerFormStatus {
  /// Edit mode: loading the existing customer.
  loading,

  /// Edit mode: the customer could not be loaded.
  loadFailure,

  /// Ready for input.
  editing,

  /// Save in progress; further submits are ignored.
  submitting,

  /// Saved; [CustomerFormState.savedCustomer] is set.
  success,
}

final class CustomerFormState extends Equatable {
  const CustomerFormState({
    required this.status,
    this.initialCustomer,
    this.fieldErrors = const {},
    this.failure,
    this.savedCustomer,
  });

  final CustomerFormStatus status;

  /// The customer being edited (`null` in create mode).
  final Customer? initialCustomer;

  /// Inline errors shown under the fields.
  final Map<CustomerField, ValidationError> fieldErrors;

  /// Non-field error (load failure or save failure), shown once.
  final AppException? failure;
  final Customer? savedCustomer;

  bool get isEditMode => initialCustomer != null;

  bool get isSubmitting => status == CustomerFormStatus.submitting;

  CustomerFormState copyWith({
    CustomerFormStatus? status,
    Customer? initialCustomer,
    Map<CustomerField, ValidationError>? fieldErrors,
    AppException? failure,
    Customer? savedCustomer,
  }) {
    return CustomerFormState(
      status: status ?? this.status,
      initialCustomer: initialCustomer ?? this.initialCustomer,
      fieldErrors: fieldErrors ?? this.fieldErrors,
      failure: failure,
      savedCustomer: savedCustomer ?? this.savedCustomer,
    );
  }

  @override
  List<Object?> get props => [
    status,
    initialCustomer,
    fieldErrors,
    failure,
    savedCustomer,
  ];
}
