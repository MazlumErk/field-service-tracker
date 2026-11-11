import 'package:field_service_tracker/core/clock/app_clock.dart';
import 'package:field_service_tracker/core/errors/app_exception.dart';
import 'package:field_service_tracker/core/utils/calendar_date.dart';
import 'package:field_service_tracker/core/validation/validation_result.dart';
import 'package:field_service_tracker/features/maintenance/domain/filter_type.dart';
import 'package:field_service_tracker/features/maintenance/domain/maintenance_price.dart';
import 'package:field_service_tracker/features/maintenance/domain/maintenance_record.dart';
import 'package:field_service_tracker/features/maintenance/domain/maintenance_repository.dart';
import 'package:field_service_tracker/features/maintenance/domain/maintenance_schedule.dart';
import 'package:field_service_tracker/features/maintenance/domain/maintenance_validator.dart';
import 'package:field_service_tracker/features/maintenance/presentation/cubit/maintenance_form_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Logic of the "new maintenance record" form for one device.
///
/// Defaults: maintenance date = today, next date = today + 6 calendar months
/// (`MaintenanceSchedule`). Validation uses the domain rules (`MaintenanceValidator`); the
/// record and its filters are saved in one repository transaction.
class MaintenanceFormCubit extends Cubit<MaintenanceFormState> {
  MaintenanceFormCubit({
    required this.deviceId,
    required MaintenanceRepository repository,
    required AppClock clock,
    // ignore: prefer_initializing_formals — keeps the public parameter name.
  }) : _repository = repository,
       super(_initialState(CalendarDate.today(clock)));

  static MaintenanceFormState _initialState(CalendarDate today) =>
      MaintenanceFormState(
        status: MaintenanceFormStatus.loading,
        today: today,
        maintenanceDate: today,
        nextMaintenanceDate: MaintenanceSchedule.suggestNextDate(today),
      );

  final int deviceId;
  final MaintenanceRepository _repository;

  /// Loads the device header. An unknown device ends in `loadFailure`.
  Future<void> load() async {
    try {
      final device = await _repository.watchDeviceOverview(deviceId).first;
      if (device == null) {
        emit(
          state.copyWith(
            status: MaintenanceFormStatus.loadFailure,
            failure: NotFoundException('Device', deviceId),
          ),
        );
        return;
      }
      emit(
        state.copyWith(status: MaintenanceFormStatus.editing, device: device),
      );
    } catch (error, stackTrace) {
      emit(
        state.copyWith(
          status: MaintenanceFormStatus.loadFailure,
          failure: toAppException(error, stackTrace),
        ),
      );
    }
  }

  /// Changes the visit date. The next date follows the 6-month suggestion
  /// unless the user already chose it explicitly.
  void maintenanceDateChanged(CalendarDate date) {
    emit(
      state.copyWith(
        maintenanceDate: date,
        nextMaintenanceDate: state.nextDateCustomized
            ? null
            : MaintenanceSchedule.suggestNextDate(date),
        fieldErrors: _without(const [
          MaintenanceField.maintenanceDate,
          MaintenanceField.nextMaintenanceDate,
        ]),
      ),
    );
  }

  void nextMaintenanceDateChanged(CalendarDate date) {
    emit(
      state.copyWith(
        nextMaintenanceDate: date,
        nextDateCustomized: true,
        fieldErrors: _without(const [MaintenanceField.nextMaintenanceDate]),
      ),
    );
  }

  /// Returns the next date to the 6-month suggestion and lets it follow the
  /// maintenance date again.
  void resetNextDateSuggestion() {
    emit(
      state.copyWith(
        nextMaintenanceDate: MaintenanceSchedule.suggestNextDate(
          state.maintenanceDate,
        ),
        nextDateCustomized: false,
        fieldErrors: _without(const [MaintenanceField.nextMaintenanceDate]),
      ),
    );
  }

  /// Selects or deselects a filter. A `Set` makes duplicates impossible.
  void filterToggled(FilterType type) {
    final filters = Set.of(state.filters);
    if (!filters.remove(type)) filters.add(type);
    emit(
      state.copyWith(
        filters: filters,
        fieldErrors: _without(const [MaintenanceField.filters]),
      ),
    );
  }

  /// Clears the inline error of a text field when the user edits it.
  void fieldChanged(MaintenanceField field) {
    if (!state.fieldErrors.containsKey(field)) return;
    emit(state.copyWith(fieldErrors: _without([field])));
  }

  Future<void> submit({required String priceText, String? notes}) async {
    // Double-tap / repeated submit guard.
    if (state.status != MaintenanceFormStatus.editing) return;

    final errors = <MaintenanceField, ValidationError>{};
    final trimmedPrice = priceText.trim();
    final priceKurus = MaintenancePrice.parseToKurus(trimmedPrice);
    if (trimmedPrice.isEmpty) {
      errors[MaintenanceField.price] = ValidationError.required;
    } else if (priceKurus == null) {
      errors[MaintenanceField.price] = ValidationError.invalidFormat;
    }

    final draft = MaintenanceRecordDraft(
      maintenanceDate: state.maintenanceDate,
      nextMaintenanceDate: state.nextMaintenanceDate,
      // A placeholder that passes range checks; the price error above wins.
      priceKurus: priceKurus ?? 0,
      filters: state.filters,
      notes: notes,
    );
    final validation = MaintenanceValidator.validate(draft, today: state.today);
    errors.addAll({
      for (final entry in validation.errors.entries)
        if (!errors.containsKey(entry.key)) entry.key: entry.value,
    });
    if (errors.isNotEmpty) {
      emit(state.copyWith(fieldErrors: errors));
      return;
    }

    emit(
      state.copyWith(status: MaintenanceFormStatus.submitting, fieldErrors: {}),
    );
    try {
      final record = await _repository.createRecord(deviceId, draft);
      emit(
        state.copyWith(
          status: MaintenanceFormStatus.success,
          savedRecord: record,
        ),
      );
    } on ValidationException catch (error) {
      emit(
        state.copyWith(
          status: MaintenanceFormStatus.editing,
          fieldErrors: {
            for (final entry in error.errors.entries)
              if (entry.key is MaintenanceField)
                entry.key as MaintenanceField: entry.value,
          },
          failure: error,
        ),
      );
    } catch (error, stackTrace) {
      emit(
        state.copyWith(
          status: MaintenanceFormStatus.editing,
          failure: toAppException(error, stackTrace),
        ),
      );
    }
  }

  Map<MaintenanceField, ValidationError> _without(
    List<MaintenanceField> fields,
  ) => Map.of(state.fieldErrors)..removeWhere((key, _) => fields.contains(key));
}
