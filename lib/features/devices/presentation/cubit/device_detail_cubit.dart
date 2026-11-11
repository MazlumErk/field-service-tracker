import 'dart:async';

import 'package:field_service_tracker/core/clock/app_clock.dart';
import 'package:field_service_tracker/core/errors/app_exception.dart';
import 'package:field_service_tracker/core/utils/calendar_date.dart';
import 'package:field_service_tracker/features/devices/domain/device_repository.dart';
import 'package:field_service_tracker/features/devices/presentation/cubit/device_detail_state.dart';
import 'package:field_service_tracker/features/maintenance/domain/device_maintenance_overview.dart';
import 'package:field_service_tracker/features/maintenance/domain/maintenance_record.dart';
import 'package:field_service_tracker/features/maintenance/domain/maintenance_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Device detail: device + owner + maintenance status, read-only history,
/// and the confirmed delete flow.
///
/// Combines the device overview and history streams; both subscriptions
/// are cancelled in [close].
class DeviceDetailCubit extends Cubit<DeviceDetailState> {
  DeviceDetailCubit({
    required this.deviceId,
    required DeviceRepository deviceRepository,
    required MaintenanceRepository maintenanceRepository,
    required AppClock clock,
    this._dayChanges,
  }) : _devices = deviceRepository,
       _maintenance = maintenanceRepository,
       super(DeviceDetailState(today: CalendarDate.today(clock)));

  final int deviceId;
  final DeviceRepository _devices;
  final MaintenanceRepository _maintenance;

  StreamSubscription<DeviceMaintenanceOverview?>? _overviewSubscription;
  StreamSubscription<List<MaintenanceRecord>>? _historySubscription;

  bool _overviewReceived = false;
  DeviceMaintenanceOverview? _latestOverview;
  List<MaintenanceRecord>? _latestHistory;

  /// Calendar-day changes (from `TodayProvider`); statuses are
  /// recomputed for the new day without touching the database.
  final Stream<CalendarDate>? _dayChanges;
  StreamSubscription<CalendarDate>? _daySubscription;

  void load() {
    _daySubscription ??= _dayChanges?.listen(
      (today) => emit(state.copyWith(today: today)),
    );
    unawaited(_overviewSubscription?.cancel());
    unawaited(_historySubscription?.cancel());
    _overviewReceived = false;
    _latestHistory = null;

    _overviewSubscription = _maintenance.watchDeviceOverview(deviceId).listen((
      overview,
    ) {
      _overviewReceived = true;
      _latestOverview = overview;
      _emitCombined();
    }, onError: _onStreamError);
    _historySubscription = _maintenance.watchHistory(deviceId).listen((
      history,
    ) {
      _latestHistory = history;
      _emitCombined();
    }, onError: _onStreamError);
  }

  void retry() {
    emit(state.copyWith(status: DeviceDetailStatus.loading));
    load();
  }

  void _emitCombined() {
    // After a successful delete the overview stream emits `null`; keep the
    // last content while the page navigates away.
    if (state.deletionStep == DeviceDeletionStep.deleted) return;
    if (!_overviewReceived) return;

    final overview = _latestOverview;
    if (overview == null) {
      emit(state.copyWith(status: DeviceDetailStatus.notFound));
      return;
    }
    final history = _latestHistory;
    if (history == null) return;
    emit(
      state.copyWith(
        status: DeviceDetailStatus.success,
        overview: overview,
        history: history,
      ),
    );
  }

  void _onStreamError(Object error, StackTrace stackTrace) {
    emit(
      state.copyWith(
        status: DeviceDetailStatus.failure,
        failure: toAppException(error, stackTrace),
      ),
    );
  }

  /// Step 1: count the history that would be deleted and ask the UI.
  Future<void> requestDeletion() async {
    if (state.deletionStep != DeviceDeletionStep.idle) return;
    emit(state.copyWith(deletionStep: DeviceDeletionStep.loadingImpact));
    try {
      final impact = await _devices.getDeletionImpact(deviceId);
      emit(
        state.copyWith(
          deletionStep: DeviceDeletionStep.confirming,
          deletionImpact: impact,
        ),
      );
    } catch (error, stackTrace) {
      emit(
        state.copyWith(
          deletionStep: DeviceDeletionStep.idle,
          deletionFailure: toAppException(error, stackTrace),
        ),
      );
    }
  }

  /// The user dismissed the dialog: nothing is deleted.
  void cancelDeletion() {
    if (state.deletionStep != DeviceDeletionStep.confirming) return;
    emit(state.copyWith(deletionStep: DeviceDeletionStep.idle));
  }

  /// Step 2: confirmed; runs the transactional delete.
  Future<void> confirmDeletion() async {
    if (state.deletionStep != DeviceDeletionStep.confirming) return;
    emit(state.copyWith(deletionStep: DeviceDeletionStep.deleting));
    try {
      await _devices.deleteDevice(deviceId);
      emit(state.copyWith(deletionStep: DeviceDeletionStep.deleted));
    } catch (error, stackTrace) {
      emit(
        state.copyWith(
          deletionStep: DeviceDeletionStep.idle,
          deletionFailure: toAppException(error, stackTrace),
        ),
      );
    }
  }

  @override
  Future<void> close() async {
    await _daySubscription?.cancel();
    await _overviewSubscription?.cancel();
    await _historySubscription?.cancel();
    return super.close();
  }
}
