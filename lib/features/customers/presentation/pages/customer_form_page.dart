import 'dart:async';

import 'package:field_service_tracker/app/router/app_routes.dart';
import 'package:field_service_tracker/app/theme/app_spacing.dart';
import 'package:field_service_tracker/core/errors/app_exception.dart';
import 'package:field_service_tracker/core/errors/app_exception_messages.dart';
import 'package:field_service_tracker/core/extensions/context_extensions.dart';
import 'package:field_service_tracker/core/widgets/app_message_state.dart';
import 'package:field_service_tracker/core/widgets/app_scaffold.dart';
import 'package:field_service_tracker/features/customers/domain/customer.dart';
import 'package:field_service_tracker/features/customers/domain/customer_draft.dart';
import 'package:field_service_tracker/features/customers/domain/customer_validator.dart';
import 'package:field_service_tracker/features/customers/presentation/cubit/customer_form_cubit.dart';
import 'package:field_service_tracker/features/customers/presentation/cubit/customer_form_state.dart';
import 'package:field_service_tracker/features/customers/presentation/customer_field_messages.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

/// Shared page for creating and editing a customer.
///
/// After a successful create the form is replaced by the new customer's
/// detail page; after an edit it pops back to the detail page (which updates
/// itself through its stream).
class CustomerFormPage extends StatefulWidget {
  const CustomerFormPage({super.key});

  @override
  State<CustomerFormPage> createState() => _CustomerFormPageState();
}

class _CustomerFormPageState extends State<CustomerFormPage> {
  final _controllers = {
    for (final field in CustomerField.values) field: TextEditingController(),
  };
  bool _prefilled = false;

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _prefill(Customer customer) {
    if (_prefilled) return;
    _prefilled = true;
    _controllers[CustomerField.firstName]!.text = customer.firstName;
    _controllers[CustomerField.lastName]!.text = customer.lastName;
    _controllers[CustomerField.customerNumber]!.text = customer.customerNumber;
    _controllers[CustomerField.phone]!.text = customer.phone ?? '';
    _controllers[CustomerField.address]!.text = customer.address ?? '';
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    String text(CustomerField field) => _controllers[field]!.text;
    unawaited(
      context.read<CustomerFormCubit>().submit(
        CustomerDraft(
          customerNumber: text(CustomerField.customerNumber),
          firstName: text(CustomerField.firstName),
          lastName: text(CustomerField.lastName),
          phone: text(CustomerField.phone),
          address: text(CustomerField.address),
        ),
      ),
    );
  }

  void _onStateChanged(BuildContext context, CustomerFormState state) {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);

    final initial = state.initialCustomer;
    if (initial != null) _prefill(initial);

    final failure = state.failure;
    if (failure != null &&
        state.status == CustomerFormStatus.editing &&
        failure is! ValidationException) {
      messenger.showSnackBar(
        SnackBar(content: Text(failure.userMessage(l10n))),
      );
    }

    final saved = state.savedCustomer;
    if (state.status == CustomerFormStatus.success && saved != null) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            state.isEditMode ? l10n.customerUpdated : l10n.customerSaved,
          ),
        ),
      );
      if (state.isEditMode) {
        context.pop();
      } else {
        context.pushReplacement(AppRoutes.customerDetail(saved.id));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isEdit = context.read<CustomerFormCubit>().customerId != null;

    return AppScaffold(
      title: isEdit ? l10n.customerEditTitle : l10n.customerNewTitle,
      body: BlocConsumer<CustomerFormCubit, CustomerFormState>(
        listener: _onStateChanged,
        builder: (context, state) {
          return switch (state.status) {
            CustomerFormStatus.loading => const Center(
              child: CircularProgressIndicator(),
            ),
            CustomerFormStatus.loadFailure => AppMessageState.error(
              title: l10n.errorLoadTitle,
              message: state.failure?.userMessage(l10n) ?? l10n.errorUnexpected,
              action: OutlinedButton.icon(
                onPressed: () =>
                    unawaited(context.read<CustomerFormCubit>().load()),
                icon: const Icon(Icons.refresh),
                label: Text(l10n.commonRetry),
              ),
            ),
            _ => _buildForm(context, state),
          };
        },
      ),
    );
  }

  Widget _buildForm(BuildContext context, CustomerFormState state) {
    final l10n = context.l10n;
    final cubit = context.read<CustomerFormCubit>();
    final enabled =
        !state.isSubmitting && state.status != CustomerFormStatus.success;

    Widget field(
      CustomerField field, {
      required String label,
      bool optional = false,
      String? helper,
      TextInputType? keyboardType,
      TextCapitalization capitalization = TextCapitalization.words,
      TextInputAction action = TextInputAction.next,
      int maxLines = 1,
      Iterable<String>? autofillHints,
    }) {
      final error = state.fieldErrors[field];
      return Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.lg),
        child: TextField(
          key: ValueKey('customerField-${field.name}'),
          controller: _controllers[field],
          enabled: enabled,
          keyboardType: keyboardType,
          textCapitalization: capitalization,
          textInputAction: action,
          maxLines: maxLines,
          minLines: 1,
          autofillHints: autofillHints,
          inputFormatters: [
            LengthLimitingTextInputFormatter(maxLengthOf(field)),
          ],
          onChanged: (_) => cubit.fieldChanged(field),
          onSubmitted: action == TextInputAction.done ? (_) => _submit() : null,
          decoration: InputDecoration(
            labelText: optional ? '$label (${l10n.commonOptional})' : label,
            helperText: helper,
            helperMaxLines: 2,
            errorText: error == null
                ? null
                : customerFieldErrorText(l10n, field, error),
            errorMaxLines: 3,
          ),
        ),
      );
    }

    return ListView(
      padding: AppSpacing.screenPadding,
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      children: [
        field(
          CustomerField.firstName,
          label: l10n.customerFieldFirstName,
          autofillHints: const [AutofillHints.givenName],
        ),
        field(
          CustomerField.lastName,
          label: l10n.customerFieldLastName,
          autofillHints: const [AutofillHints.familyName],
        ),
        field(
          CustomerField.customerNumber,
          label: l10n.customerFieldNumber,
          helper: l10n.customerFieldNumberHelper,
          capitalization: TextCapitalization.characters,
        ),
        field(
          CustomerField.phone,
          label: l10n.customerFieldPhone,
          optional: true,
          keyboardType: TextInputType.phone,
          capitalization: TextCapitalization.none,
          autofillHints: const [AutofillHints.telephoneNumber],
        ),
        field(
          CustomerField.address,
          label: l10n.customerFieldAddress,
          optional: true,
          keyboardType: TextInputType.streetAddress,
          capitalization: TextCapitalization.sentences,
          action: TextInputAction.done,
          maxLines: 3,
          autofillHints: const [AutofillHints.fullStreetAddress],
        ),
        const SizedBox(height: AppSpacing.sm),
        FilledButton.icon(
          key: const ValueKey('customerFormSave'),
          onPressed: enabled ? _submit : null,
          icon: state.isSubmitting
              ? const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.check),
          label: Text(l10n.commonSave),
        ),
      ],
    );
  }
}
