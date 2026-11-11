import 'package:equatable/equatable.dart';
import 'package:field_service_tracker/core/errors/app_exception.dart';
import 'package:field_service_tracker/core/utils/calendar_date.dart';
import 'package:field_service_tracker/features/maintenance/domain/device_maintenance_overview.dart';
import 'package:field_service_tracker/features/maintenance/domain/maintenance_overview_rules.dart';

enum DashboardStatus { loading, success, failure }

final class DashboardState extends Equatable {
  const DashboardState({
    required this.today,
    this.status = DashboardStatus.loading,
    this.customerCount = 0,
    this.deviceCount = 0,
    this.statusCounts = const MaintenanceStatusCounts(),
    this.priority = const [],
    this.priorityTotal = 0,
    this.failure,
  });

  final CalendarDate today;
  final DashboardStatus status;
  final int customerCount;
  final int deviceCount;

  /// Each device counted once, by the status of its latest record.
  final MaintenanceStatusCounts statusCounts;

  /// First overdue / upcoming devices in priority order (limited).
  final List<DeviceMaintenanceOverview> priority;

  /// All overdue + upcoming devices (may exceed [priority]).
  final int priorityTotal;
  final AppException? failure;

  /// No customers and no devices yet.
  bool get isEmpty =>
      status == DashboardStatus.success &&
      customerCount == 0 &&
      deviceCount == 0;

  DashboardState copyWith({
    CalendarDate? today,
    DashboardStatus? status,
    int? customerCount,
    int? deviceCount,
    MaintenanceStatusCounts? statusCounts,
    List<DeviceMaintenanceOverview>? priority,
    int? priorityTotal,
    AppException? failure,
  }) {
    return DashboardState(
      today: today ?? this.today,
      status: status ?? this.status,
      customerCount: customerCount ?? this.customerCount,
      deviceCount: deviceCount ?? this.deviceCount,
      statusCounts: statusCounts ?? this.statusCounts,
      priority: priority ?? this.priority,
      priorityTotal: priorityTotal ?? this.priorityTotal,
      failure: failure,
    );
  }

  @override
  List<Object?> get props => [
    today,
    status,
    customerCount,
    deviceCount,
    statusCounts,
    priority,
    priorityTotal,
    failure,
  ];
}
