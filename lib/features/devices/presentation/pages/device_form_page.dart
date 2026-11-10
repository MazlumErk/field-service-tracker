import 'dart:async';

import 'package:field_service_tracker/app/router/app_routes.dart';
import 'package:field_service_tracker/app/theme/app_spacing.dart';
import 'package:field_service_tracker/core/errors/app_exception.dart';
import 'package:field_service_tracker/core/errors/app_exception_messages.dart';
import 'package:field_service_tracker/core/extensions/context_extensions.dart';
import 'package:field_service_tracker/core/utils/calendar_date.dart';
import 'package:field_service_tracker/core/widgets/app_date_field.dart';
import 'package:field_service_tracker/core/widgets/app_message_state.dart';
import 'package:field_service_tracker/core/widgets/app_scaffold.dart';
import 'package:field_service_tracker/core/widgets/unsaved_changes_guard.dart';
import 'package:field_service_tracker/features/devices/domain/device.dart';
import 'package:field_service_tracker/features/devices/domain/device_validator.dart';
import 'package:field_service_tracker/features/devices/presentation/cubit/device_form_cubit.dart';
import 'package:field_service_tracker/features/devices/presentation/cubit/device_form_state.dart';
import 'package:field_service_tracker/features/devices/presentation/device_field_messages.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

/// Shared page for adding a device to a customer and editing a device.
///
/// After a create the form is replaced by the new device's detail page;
/// after an edit it pops back to the detail page, which updates itself.
class DeviceFormPage extends StatefulWidget {
  const DeviceFormPage({super.key});

  @override
  State<DeviceFormPage> createState() => _DeviceFormPageState();
}

class _DeviceFormPageState extends State<DeviceFormPage> {
  final _modelController = TextEditingController();
  final _serialController = TextEditingController();
  final _hasChanges = ValueNotifier(false);

  // Baseline for unsaved-change detection (empty in create mode).
  String _initialModel = '';
  String _initialSerial = '';
  CalendarDate? _initialInstalledAt;
  bool _prefilled = false;

  @override
  void initState() {
    super.initState();
    final state = context.read<DeviceFormCubit>().state;
    _initialInstalledAt = state.installedAt;
    _modelController.addListener(_updateHasChanges);
    _serialController.addListener(_updateHasChanges);
  }

  @override
  void dispose() {
    _modelController.dispose();
    _serialController.dispose();
    _hasChanges.dispose();
    super.dispose();
  }

  void _updateHasChanges() {
    final state = context.read<DeviceFormCubit>().state;
    _hasChanges.value =
        state.status != DeviceFormStatus.success &&
        (_modelController.text != _initialModel ||
            _serialController.text != _initialSerial ||
            state.installedAt != _initialInstalledAt);
  }

  void _prefill(Device device) {
    if (_prefilled) return;
    _prefilled = true;
    _initialModel = device.model;
    _initialSerial = device.serialNumber ?? '';
    _initialInstalledAt = device.installedAt;
    _modelController.text = _initialModel;
    _serialController.text = _initialSerial;
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    unawaited(
      context.read<DeviceFormCubit>().submit(
        model: _modelController.text,
        serialNumber: _serialController.text,
      ),
    );
  }

  void _onStateChanged(BuildContext context, DeviceFormState state) {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);

    final initial = state.initialDevice;
    if (initial != null) _prefill(initial);
    _updateHasChanges();

    final failure = state.failure;
    if (failure != null &&
        state.status == DeviceFormStatus.editing &&
        failure is! ValidationException) {
      messenger.showSnackBar(
        SnackBar(content: Text(failure.userMessage(l10n))),
      );
    }

    final saved = state.savedDevice;
    if (state.status == DeviceFormStatus.success && saved != null) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            state.isEditMode ? l10n.deviceUpdated : l10n.deviceSaved,
          ),
        ),
      );
      if (state.isEditMode) {
        context.pop();
      } else {
        context.pushReplacement(AppRoutes.deviceDetail(saved.id));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isEdit = context.read<DeviceFormCubit>().deviceId != null;

    return UnsavedChangesGuard(
      hasChanges: _hasChanges,
      child: AppScaffold(
        title: isEdit ? l10n.deviceEditTitle : l10n.deviceNewTitle,
        body: BlocConsumer<DeviceFormCubit, DeviceFormState>(
          listener: _onStateChanged,
          builder: (context, state) => switch (state.status) {
            DeviceFormStatus.loading => const Center(
              child: CircularProgressIndicator(),
            ),
            DeviceFormStatus.loadFailure => AppMessageState.error(
              title: l10n.errorLoadTitle,
              message: state.failure?.userMessage(l10n) ?? l10n.errorUnexpected,
              action: OutlinedButton.icon(
                onPressed: () =>
                    unawaited(context.read<DeviceFormCubit>().load()),
                icon: const Icon(Icons.refresh),
                label: Text(l10n.commonRetry),
              ),
            ),
            _ => _buildForm(context, state),
          },
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context, DeviceFormState state) {
    final l10n = context.l10n;
    final cubit = context.read<DeviceFormCubit>();
    final enabled =
        !state.isSubmitting && state.status != DeviceFormStatus.success;

    String? errorFor(DeviceField field) {
      final error = state.fieldErrors[field];
      return error == null ? null : deviceFieldErrorText(l10n, field, error);
    }

    return ListView(
      padding: AppSpacing.screenPadding,
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      children: [
        TextField(
          key: const ValueKey('deviceField-model'),
          controller: _modelController,
          enabled: enabled,
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.next,
          inputFormatters: [
            LengthLimitingTextInputFormatter(
              deviceMaxLengthOf(DeviceField.model),
            ),
          ],
          onChanged: (_) => cubit.fieldChanged(DeviceField.model),
          decoration: InputDecoration(
            labelText: l10n.deviceFieldModel,
            helperText: l10n.deviceFieldModelHelper,
            errorText: errorFor(DeviceField.model),
            errorMaxLines: 2,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        TextField(
          key: const ValueKey('deviceField-serialNumber'),
          controller: _serialController,
          enabled: enabled,
          textCapitalization: TextCapitalization.characters,
          textInputAction: TextInputAction.done,
          inputFormatters: [
            LengthLimitingTextInputFormatter(
              deviceMaxLengthOf(DeviceField.serialNumber),
            ),
          ],
          onChanged: (_) => cubit.fieldChanged(DeviceField.serialNumber),
          decoration: InputDecoration(
            labelText: '${l10n.deviceFieldSerial} (${l10n.commonOptional})',
            errorText: errorFor(DeviceField.serialNumber),
            errorMaxLines: 2,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        AppDateField(
          key: const ValueKey('deviceField-installedAt'),
          label: l10n.deviceFieldInstalledAt,
          helperText: l10n.deviceFieldInstalledAtHint,
          value: state.installedAt,
          firstDate: CalendarDate(2000, 1, 1),
          lastDate: state.today,
          errorText: errorFor(DeviceField.installedAt),
          enabled: enabled,
          onChanged: cubit.installedAtChanged,
        ),
        const SizedBox(height: AppSpacing.xl),
        FilledButton.icon(
          key: const ValueKey('deviceFormSave'),
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
