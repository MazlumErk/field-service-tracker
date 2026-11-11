import 'dart:async';

import 'package:field_service_tracker/core/clock/day_tracker.dart';
import 'package:field_service_tracker/core/errors/app_exception.dart';
import 'package:field_service_tracker/core/utils/calendar_date.dart';
import 'package:field_service_tracker/features/customers/domain/customer_repository.dart';
import 'package:field_service_tracker/features/dashboard/presentation/cubit/dashboard_state.dart';
import 'package:field_service_tracker/features/maintenance/domain/device_maintenance_overview.dart';
import 'package:field_service_tracker/features/maintenance/domain/maintenance_overview_rules.dart';
import 'package:field_service_tracker/features/maintenance/domain/maintenance_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Dashboard: customer / device totals, overdue / upcoming counts and the
/// priority list.
///
/// Sources: `watchCustomerCount()` and `watchOverview()` (one row per device
/// with its latest record) plus [TodayProvider.changes]. Database changes
/// and day changes both trigger a recomputation with the shared
/// [MaintenanceOverviewRules].
class DashboardCubit extends Cubit<DashboardState> {
  DashboardCubit({
    required CustomerRepository customerRepository,
    required MaintenanceRepository maintenanceRepository,
    required TodayProvider today,
    this.priorityLimit = 5,
  }) : _customers = customerRepository,
       _maintenance = maintenanceRepository,
       _today = today,
       super(DashboardState(today: today.today));

  final CustomerRepository _customers;
  final MaintenanceRepository _maintenance;
  final TodayProvider _today;

  /// Maximum number of priority rows shown on the dashboard.
  final int priorityLimit;

  StreamSubscription<int>? _countSubscription;
  StreamSubscription<List<DeviceMaintenanceOverview>>? _overviewSubscription;
  StreamSubscription<CalendarDate>? _daySubscription;

  int? _customerCount;
  List<DeviceMaintenanceOverview>? _overviews;

  void load() {
    unawaited(_countSubscription?.cancel());
    unawaited(_overviewSubscription?.cancel());
    _customerCount = null;
    _overviews = null;

    _countSubscription = _customers.watchCustomerCount().listen((count) {
      _customerCount = count;
      _recompute(state.today);
    }, onError: _onError);
    _overviewSubscription = _maintenance.watchOverview().listen((overviews) {
      _overviews = overviews;
      _recompute(state.today);
    }, onError: _onError);
    _daySubscription ??= _today.changes.listen(_recompute);
  }

  void retry() {
    emit(state.copyWith(status: DashboardStatus.loading));
    load();
  }

  void _recompute(CalendarDate today) {
    final count = _customerCount;
    final overviews = _overviews;
    if (count == null || overviews == null) {
      if (today != state.today) emit(state.copyWith(today: today));
      return;
    }
    final priority = MaintenanceOverviewRules.priority(overviews, today);
    emit(
      state.copyWith(
        today: today,
        status: DashboardStatus.success,
        customerCount: count,
        deviceCount: overviews.length,
        statusCounts: MaintenanceOverviewRules.count(overviews, today),
        priority: priority.take(priorityLimit).toList(),
        priorityTotal: priority.length,
      ),
    );
  }

  void _onError(Object error, StackTrace stackTrace) {
    emit(
      state.copyWith(
        status: DashboardStatus.failure,
        failure: toAppException(error, stackTrace),
      ),
    );
  }

  @override
  Future<void> close() async {
    await _countSubscription?.cancel();
    await _overviewSubscription?.cancel();
    await _daySubscription?.cancel();
    return super.close();
  }
}
