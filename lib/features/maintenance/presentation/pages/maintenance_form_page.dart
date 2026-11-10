import 'dart:async';

import 'package:field_service_tracker/app/theme/app_spacing.dart';
import 'package:field_service_tracker/core/errors/app_exception.dart';
import 'package:field_service_tracker/core/errors/app_exception_messages.dart';
import 'package:field_service_tracker/core/extensions/context_extensions.dart';
import 'package:field_service_tracker/core/utils/calendar_date.dart';
import 'package:field_service_tracker/core/widgets/app_date_field.dart';
import 'package:field_service_tracker/core/widgets/app_message_state.dart';
import 'package:field_service_tracker/core/widgets/app_scaffold.dart';
import 'package:field_service_tracker/core/widgets/app_section_header.dart';
import 'package:field_service_tracker/core/widgets/unsaved_changes_guard.dart';
import 'package:field_service_tracker/features/maintenance/domain/filter_type.dart';
import 'package:field_service_tracker/features/maintenance/domain/maintenance_validator.dart';
import 'package:field_service_tracker/features/maintenance/presentation/cubit/maintenance_form_cubit.dart';
import 'package:field_service_tracker/features/maintenance/presentation/cubit/maintenance_form_state.dart';
import 'package:field_service_tracker/features/maintenance/presentation/maintenance_field_messages.dart';
import 'package:field_service_tracker/features/maintenance/presentation/widgets/maintenance_record_card.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

/// "Yeni Bakım Kaydı" for one device: dates, replaced filters, price, notes.
///
/// On success it pops back to the device detail page, whose history and
/// status update through their streams.
class MaintenanceFormPage extends StatefulWidget {
  const MaintenanceFormPage({super.key});

  @override
  State<MaintenanceFormPage> createState() => _MaintenanceFormPageState();
}

class _MaintenanceFormPageState extends State<MaintenanceFormPage> {
  final _priceController = TextEditingController();
  final _notesController = TextEditingController();
  final _hasChanges = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    _priceController.addListener(_updateHasChanges);
    _notesController.addListener(_updateHasChanges);
  }

  @override
  void dispose() {
    _priceController.dispose();
    _notesController.dispose();
    _hasChanges.dispose();
    super.dispose();
  }

  /// Anything differing from the untouched defaults counts as a change.
  void _updateHasChanges() {
    final state = context.read<MaintenanceFormCubit>().state;
    _hasChanges.value =
        state.status != MaintenanceFormStatus.success &&
        (state.maintenanceDate != state.today ||
            state.nextDateCustomized ||
            state.filters.isNotEmpty ||
            _priceController.text.isNotEmpty ||
            _notesController.text.isNotEmpty);
  }

  void _submit() {
    FocusManager.instance.primaryFocus?.unfocus();
    unawaited(
      context.read<MaintenanceFormCubit>().submit(
        priceText: _priceController.text,
        notes: _notesController.text,
      ),
    );
  }

  void _onStateChanged(BuildContext context, MaintenanceFormState state) {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    _updateHasChanges();

    final failure = state.failure;
    if (failure != null &&
        state.status == MaintenanceFormStatus.editing &&
        failure is! ValidationException) {
      messenger.showSnackBar(
        SnackBar(content: Text(failure.userMessage(l10n))),
      );
    }

    if (state.status == MaintenanceFormStatus.success) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.maintenanceSaved)));
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return UnsavedChangesGuard(
      hasChanges: _hasChanges,
      child: AppScaffold(
        title: l10n.maintenanceNewTitle,
        body: BlocConsumer<MaintenanceFormCubit, MaintenanceFormState>(
          listener: _onStateChanged,
          builder: (context, state) => switch (state.status) {
            MaintenanceFormStatus.loading => const Center(
              child: CircularProgressIndicator(),
            ),
            MaintenanceFormStatus.loadFailure => AppMessageState.error(
              title: l10n.errorLoadTitle,
              message: state.failure?.userMessage(l10n) ?? l10n.errorUnexpected,
            ),
            _ => _buildForm(context, state),
          },
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context, MaintenanceFormState state) {
    final l10n = context.l10n;
    final cubit = context.read<MaintenanceFormCubit>();
    final enabled =
        !state.isSubmitting && state.status != MaintenanceFormStatus.success;

    String? errorFor(MaintenanceField field) {
      final error = state.fieldErrors[field];
      return error == null
          ? null
          : maintenanceFieldErrorText(l10n, field, error);
    }

    return ListView(
      padding: AppSpacing.screenPadding,
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      children: [
        _DeviceHeader(state: state),
        const SizedBox(height: AppSpacing.xl),
        AppDateField(
          key: const ValueKey('maintenanceField-date'),
          label: l10n.maintenanceFieldDate,
          value: state.maintenanceDate,
          firstDate: CalendarDate(2000, 1, 1),
          lastDate: state.today,
          errorText: errorFor(MaintenanceField.maintenanceDate),
          enabled: enabled,
          onChanged: cubit.maintenanceDateChanged,
        ),
        const SizedBox(height: AppSpacing.lg),
        AppDateField(
          key: const ValueKey('maintenanceField-nextDate'),
          label: l10n.maintenanceFieldNextDate,
          value: state.nextMaintenanceDate,
          // The picker cannot produce a next date before the visit.
          firstDate: state.maintenanceDate,
          lastDate: state.today.addMonths(120),
          helperText: state.nextDateCustomized
              ? l10n.maintenanceFieldNextDateCustom
              : l10n.maintenanceFieldNextDateSuggested,
          errorText: errorFor(MaintenanceField.nextMaintenanceDate),
          enabled: enabled,
          onChanged: cubit.nextMaintenanceDateChanged,
        ),
        if (state.nextDateCustomized)
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              key: const ValueKey('maintenanceUseSuggestion'),
              onPressed: enabled ? cubit.resetNextDateSuggestion : null,
              icon: const Icon(Icons.restart_alt),
              label: Text(l10n.maintenanceUseSuggestion),
            ),
          ),
        const SizedBox(height: AppSpacing.lg),
        AppSectionHeader(l10n.maintenanceFieldFilters),
        _FilterSelection(
          selected: state.filters,
          errorText: errorFor(MaintenanceField.filters),
          enabled: enabled,
          onToggled: cubit.filterToggled,
        ),
        const SizedBox(height: AppSpacing.xl),
        TextField(
          key: const ValueKey('maintenanceField-price'),
          controller: _priceController,
          enabled: enabled,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          textInputAction: TextInputAction.next,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp('[0-9.,]')),
            LengthLimitingTextInputFormatter(16),
          ],
          onChanged: (_) => cubit.fieldChanged(MaintenanceField.price),
          decoration: InputDecoration(
            labelText: l10n.maintenanceFieldPrice,
            prefixText: '₺ ',
            helperText: l10n.maintenanceFieldPriceHelper,
            helperMaxLines: 2,
            errorText: errorFor(MaintenanceField.price),
            errorMaxLines: 2,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        TextField(
          key: const ValueKey('maintenanceField-notes'),
          controller: _notesController,
          enabled: enabled,
          minLines: 3,
          maxLines: 6,
          maxLength: MaintenanceValidator.maxNotesLength,
          keyboardType: TextInputType.multiline,
          textCapitalization: TextCapitalization.sentences,
          onChanged: (_) => cubit.fieldChanged(MaintenanceField.notes),
          decoration: InputDecoration(
            labelText: '${l10n.maintenanceFieldNotes} (${l10n.commonOptional})',
            alignLabelWithHint: true,
            errorText: errorFor(MaintenanceField.notes),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        FilledButton.icon(
          key: const ValueKey('maintenanceFormSave'),
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

/// Which device (and customer) this record belongs to.
class _DeviceHeader extends StatelessWidget {
  const _DeviceHeader({required this.state});

  final MaintenanceFormState state;

  @override
  Widget build(BuildContext context) {
    final device = state.device;
    if (device == null) return const SizedBox.shrink();
    final textTheme = context.textTheme;
    final colors = context.colors;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            Icon(Icons.water_drop_outlined, color: colors.primary),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.maintenanceDeviceHeader,
                    style: textTheme.bodySmall,
                  ),
                  Text(device.device.model, style: textTheme.titleMedium),
                  Text(
                    '${device.customerFullName} · ${device.customerNumber}',
                    style: textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Multi-select of replaced filters as large checkbox rows.
class _FilterSelection extends StatelessWidget {
  const _FilterSelection({
    required this.selected,
    required this.onToggled,
    required this.enabled,
    this.errorText,
  });

  final Set<FilterType> selected;
  final ValueChanged<FilterType> onToggled;
  final bool enabled;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final hasError = errorText != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.cardRadius,
            side: BorderSide(
              color: hasError ? colors.error : colors.outlineVariant,
            ),
          ),
          child: Column(
            children: [
              for (final type in FilterType.values)
                CheckboxListTile(
                  key: ValueKey('maintenanceFilter-${type.name}'),
                  value: selected.contains(type),
                  onChanged: enabled ? (_) => onToggled(type) : null,
                  title: Text(type.label(l10n)),
                  controlAffinity: ListTileControlAffinity.leading,
                ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(
            left: AppSpacing.lg,
            top: AppSpacing.xs,
          ),
          child: Text(
            errorText ?? l10n.maintenanceFieldFiltersHelper,
            style: context.textTheme.bodySmall?.copyWith(
              color: hasError ? colors.error : null,
            ),
          ),
        ),
      ],
    );
  }
}
