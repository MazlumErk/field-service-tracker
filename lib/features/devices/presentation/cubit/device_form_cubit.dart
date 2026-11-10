import 'package:field_service_tracker/core/clock/app_clock.dart';
import 'package:field_service_tracker/core/errors/app_exception.dart';
import 'package:field_service_tracker/core/utils/calendar_date.dart';
import 'package:field_service_tracker/features/devices/domain/device.dart';
import 'package:field_service_tracker/features/devices/domain/device_repository.dart';
import 'package:field_service_tracker/features/devices/domain/device_validator.dart';
import 'package:field_service_tracker/features/devices/presentation/cubit/device_form_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Shared create / edit logic of the device form.
///
/// In create mode the device is attached to [customerId]; in edit mode only
/// model, serial number and installation date are sent — the owning
/// customer cannot be changed.
class DeviceFormCubit extends Cubit<DeviceFormState> {
  /// Create mode for a device of [customerId]. Installation date defaults
  /// to today.
  DeviceFormCubit.create(
    this._repository, {
    required int this.customerId,
    required AppClock clock,
  }) : deviceId = null,
       super(_initialState(DeviceFormStatus.editing, clock));

  /// Edit mode for [deviceId]; call [load] next.
  DeviceFormCubit.edit(
    this._repository, {
    required int this.deviceId,
    required AppClock clock,
  }) : customerId = null,
       super(_initialState(DeviceFormStatus.loading, clock));

  static DeviceFormState _initialState(
    DeviceFormStatus status,
    AppClock clock,
  ) {
    final today = CalendarDate.today(clock);
    return DeviceFormState(status: status, today: today, installedAt: today);
  }

  final DeviceRepository _repository;
  final int? customerId;
  final int? deviceId;

  /// Edit mode: loads the device to prefill the form.
  Future<void> load() async {
    final id = deviceId;
    if (id == null) return;
    if (state.status != DeviceFormStatus.loading) {
      emit(state.copyWith(status: DeviceFormStatus.loading));
    }
    try {
      final device = await _repository.getDevice(id);
      emit(
        state.copyWith(
          status: DeviceFormStatus.editing,
          initialDevice: device,
          installedAt: device.installedAt,
        ),
      );
    } catch (error, stackTrace) {
      emit(
        state.copyWith(
          status: DeviceFormStatus.loadFailure,
          failure: toAppException(error, stackTrace),
        ),
      );
    }
  }

  void installedAtChanged(CalendarDate date) {
    emit(
      state.copyWith(
        installedAt: date,
        fieldErrors: Map.of(state.fieldErrors)..remove(DeviceField.installedAt),
      ),
    );
  }

  /// Clears the inline error of a text field as soon as the user edits it.
  void fieldChanged(DeviceField field) {
    if (!state.fieldErrors.containsKey(field)) return;
    emit(state.copyWith(fieldErrors: Map.of(state.fieldErrors)..remove(field)));
  }

  Future<void> submit({required String model, String? serialNumber}) async {
    // Double-tap / repeated submit guard.
    if (state.status != DeviceFormStatus.editing) return;

    final draft = DeviceDraft(
      model: model,
      serialNumber: serialNumber,
      installedAt: state.installedAt,
    );
    final validation = DeviceValidator.validate(draft, today: state.today);
    if (!validation.isValid) {
      emit(state.copyWith(fieldErrors: validation.errors));
      return;
    }

    emit(state.copyWith(status: DeviceFormStatus.submitting, fieldErrors: {}));
    try {
      final id = deviceId;
      final saved = id == null
          ? await _repository.createDevice(customerId!, draft)
          : await _repository.updateDevice(id, draft);
      emit(
        state.copyWith(status: DeviceFormStatus.success, savedDevice: saved),
      );
    } on ValidationException catch (error) {
      emit(
        state.copyWith(
          status: DeviceFormStatus.editing,
          fieldErrors: {
            for (final entry in error.errors.entries)
              if (entry.key is DeviceField)
                entry.key as DeviceField: entry.value,
          },
          failure: error,
        ),
      );
    } catch (error, stackTrace) {
      emit(
        state.copyWith(
          status: DeviceFormStatus.editing,
          failure: toAppException(error, stackTrace),
        ),
      );
    }
  }
}
