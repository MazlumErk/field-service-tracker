import 'package:equatable/equatable.dart';
import 'package:field_service_tracker/core/errors/app_exception.dart';
import 'package:field_service_tracker/core/utils/calendar_date.dart';
import 'package:field_service_tracker/features/maintenance/domain/device_maintenance_overview.dart';
import 'package:field_service_tracker/features/maintenance/domain/maintenance_overview_rules.dart';
import 'package:field_service_tracker/features/maintenance/domain/maintenance_status.dart';

enum MaintenanceListStatus { loading, success, failure }

final class MaintenanceListState extends Equatable {
  const MaintenanceListState({
    required this.today,
    this.status = MaintenanceListStatus.loading,
    this.filter,
    this.items = const [],
    this.counts = const MaintenanceStatusCounts(),
    this.failure,
  });

  final CalendarDate today;
  final MaintenanceListStatus status;

  /// Selected status filter; `null` means "Tümü".
  final MaintenanceStatus? filter;

  /// Devices matching [filter], in priority order, each exactly once.
  final List<DeviceMaintenanceOverview> items;

  /// Counts for every filter chip (independent of [filter]).
  final MaintenanceStatusCounts counts;
  final AppException? failure;

  /// There are no devices at all.
  bool get hasNoDevices =>
      status == MaintenanceListStatus.success && counts.total == 0;

  /// Devices exist, but none matches the selected filter.
  bool get isFilterEmpty =>
      status == MaintenanceListStatus.success && items.isEmpty && !hasNoDevices;

  MaintenanceListState copyWith({
    CalendarDate? today,
    MaintenanceListStatus? status,
    MaintenanceStatus? Function()? filter,
    List<DeviceMaintenanceOverview>? items,
    MaintenanceStatusCounts? counts,
    AppException? failure,
  }) {
    return MaintenanceListState(
      today: today ?? this.today,
      status: status ?? this.status,
      // A function so that `null` ("all") can be set explicitly.
      filter: filter == null ? this.filter : filter(),
      items: items ?? this.items,
      counts: counts ?? this.counts,
      failure: failure,
    );
  }

  @override
  List<Object?> get props => [today, status, filter, items, counts, failure];
}
