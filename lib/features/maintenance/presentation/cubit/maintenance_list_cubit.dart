import 'dart:async';

import 'package:field_service_tracker/core/clock/day_tracker.dart';
import 'package:field_service_tracker/core/errors/app_exception.dart';
import 'package:field_service_tracker/core/utils/calendar_date.dart';
import 'package:field_service_tracker/features/maintenance/domain/device_maintenance_overview.dart';
import 'package:field_service_tracker/features/maintenance/domain/maintenance_overview_rules.dart';
import 'package:field_service_tracker/features/maintenance/domain/maintenance_repository.dart';
import 'package:field_service_tracker/features/maintenance/domain/maintenance_status.dart';
import 'package:field_service_tracker/features/maintenance/presentation/cubit/maintenance_list_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// "Bakımlar" tab: every device with its maintenance status, filterable.
///
/// Uses the same overview stream and [MaintenanceOverviewRules] as the
/// dashboard; filtering and day changes are applied in memory, so neither
/// triggers a new query.
class MaintenanceListCubit extends Cubit<MaintenanceListState> {
  MaintenanceListCubit({
    required MaintenanceRepository maintenanceRepository,
    required TodayProvider today,
  }) : _maintenance = maintenanceRepository,
       _today = today,
       super(MaintenanceListState(today: today.today));

  final MaintenanceRepository _maintenance;
  final TodayProvider _today;

  StreamSubscription<List<DeviceMaintenanceOverview>>? _overviewSubscription;
  StreamSubscription<CalendarDate>? _daySubscription;
  List<DeviceMaintenanceOverview>? _overviews;

  void load() {
    unawaited(_overviewSubscription?.cancel());
    _overviewSubscription = _maintenance.watchOverview().listen((overviews) {
      _overviews = overviews;
      _recompute(today: state.today, filter: state.filter);
    }, onError: _onError);
    _daySubscription ??= _today.changes.listen(
      (today) => _recompute(today: today, filter: state.filter),
    );
  }

  void retry() {
    emit(state.copyWith(status: MaintenanceListStatus.loading));
    load();
  }

  /// `null` selects "Tümü".
  void filterSelected(MaintenanceStatus? filter) {
    if (filter == state.filter) return;
    _recompute(today: state.today, filter: filter);
  }

  void _recompute({
    required CalendarDate today,
    required MaintenanceStatus? filter,
  }) {
    final overviews = _overviews;
    if (overviews == null) {
      emit(state.copyWith(today: today, filter: () => filter));
      return;
    }
    final sorted = MaintenanceOverviewRules.sortByPriority(overviews, today);
    emit(
      state.copyWith(
        today: today,
        status: MaintenanceListStatus.success,
        filter: () => filter,
        items: filter == null
            ? sorted
            : [
                for (final overview in sorted)
                  if (overview.statusOn(today) == filter) overview,
              ],
        counts: MaintenanceOverviewRules.count(overviews, today),
      ),
    );
  }

  void _onError(Object error, StackTrace stackTrace) {
    emit(
      state.copyWith(
        status: MaintenanceListStatus.failure,
        failure: toAppException(error, stackTrace),
      ),
    );
  }

  @override
  Future<void> close() async {
    await _overviewSubscription?.cancel();
    await _daySubscription?.cancel();
    return super.close();
  }
}
