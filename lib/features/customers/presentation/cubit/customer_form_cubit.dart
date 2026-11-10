import 'package:field_service_tracker/core/errors/app_exception.dart';
import 'package:field_service_tracker/core/validation/validation_result.dart';
import 'package:field_service_tracker/features/customers/domain/customer_draft.dart';
import 'package:field_service_tracker/features/customers/domain/customer_repository.dart';
import 'package:field_service_tracker/features/customers/domain/customer_validator.dart';
import 'package:field_service_tracker/features/customers/presentation/cubit/customer_form_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Shared create / edit logic of the customer form.
///
/// Text lives in the page's controllers; the Cubit receives a
/// [CustomerDraft] on submit, validates it with the domain rules, saves it
/// and reports field errors (including a duplicate customer number).
class CustomerFormCubit extends Cubit<CustomerFormState> {
  /// Create mode.
  CustomerFormCubit.create(this._repository)
    : customerId = null,
      super(const CustomerFormState(status: CustomerFormStatus.editing));

  /// Edit mode for [customerId]; call [load] next.
  CustomerFormCubit.edit(this._repository, {required int this.customerId})
    : super(const CustomerFormState(status: CustomerFormStatus.loading));

  final CustomerRepository _repository;
  final int? customerId;

  /// Edit mode: loads the customer to prefill the form.
  Future<void> load() async {
    final id = customerId;
    if (id == null) return;
    if (state.status != CustomerFormStatus.loading) {
      emit(state.copyWith(status: CustomerFormStatus.loading));
    }
    try {
      final customer = await _repository.getCustomer(id);
      emit(
        state.copyWith(
          status: CustomerFormStatus.editing,
          initialCustomer: customer,
        ),
      );
    } catch (error, stackTrace) {
      emit(
        state.copyWith(
          status: CustomerFormStatus.loadFailure,
          failure: toAppException(error, stackTrace),
        ),
      );
    }
  }

  /// Clears the inline error of [field] as soon as the user edits it.
  void fieldChanged(CustomerField field) {
    if (!state.fieldErrors.containsKey(field)) return;
    emit(state.copyWith(fieldErrors: Map.of(state.fieldErrors)..remove(field)));
  }

  Future<void> submit(CustomerDraft draft) async {
    // Double-tap / repeated submit guard.
    if (state.status != CustomerFormStatus.editing) return;

    final validation = CustomerValidator.validate(draft);
    if (!validation.isValid) {
      emit(state.copyWith(fieldErrors: validation.errors));
      return;
    }

    emit(
      state.copyWith(status: CustomerFormStatus.submitting, fieldErrors: {}),
    );
    try {
      final id = customerId;
      final saved = id == null
          ? await _repository.createCustomer(draft)
          : await _repository.updateCustomer(id, draft);
      emit(
        state.copyWith(
          status: CustomerFormStatus.success,
          savedCustomer: saved,
        ),
      );
    } on DuplicateCustomerNumberException {
      emit(
        state.copyWith(
          status: CustomerFormStatus.editing,
          fieldErrors: {
            CustomerField.customerNumber: ValidationError.alreadyInUse,
          },
        ),
      );
    } on ValidationException catch (error) {
      emit(
        state.copyWith(
          status: CustomerFormStatus.editing,
          fieldErrors: {
            for (final entry in error.errors.entries)
              if (entry.key is CustomerField)
                entry.key as CustomerField: entry.value,
          },
          failure: error,
        ),
      );
    } catch (error, stackTrace) {
      emit(
        state.copyWith(
          status: CustomerFormStatus.editing,
          failure: toAppException(error, stackTrace),
        ),
      );
    }
  }
}
