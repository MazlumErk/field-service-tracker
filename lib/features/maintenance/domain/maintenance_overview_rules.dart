import 'package:equatable/equatable.dart';
import 'package:field_service_tracker/core/utils/calendar_date.dart';
import 'package:field_service_tracker/core/utils/turkish_text.dart';
import 'package:field_service_tracker/features/maintenance/domain/device_maintenance_overview.dart';
import 'package:field_service_tracker/features/maintenance/domain/maintenance_status.dart';

/// Device counts per maintenance status on a given day.
///
/// Built from `MaintenanceRepository.watchOverview()`, which has exactly one
/// row per device (its latest record), so every device is counted once no
/// matter how many maintenance records it has.
final class MaintenanceStatusCounts extends Equatable {
  const MaintenanceStatusCounts({
    this.overdue = 0,
    this.upcoming = 0,
    this.scheduled = 0,
    this.noMaintenance = 0,
  });

  final int overdue;
  final int upcoming;
  final int scheduled;
  final int noMaintenance;

  int get total => overdue + upcoming + scheduled + noMaintenance;

  int of(MaintenanceStatus status) => switch (status) {
    MaintenanceStatus.overdue => overdue,
    MaintenanceStatus.upcoming => upcoming,
    MaintenanceStatus.scheduled => scheduled,
    MaintenanceStatus.noMaintenance => noMaintenance,
  };

  @override
  List<Object?> get props => [overdue, upcoming, scheduled, noMaintenance];
}

/// Shared ordering and counting rules for the dashboard and the maintenance
/// list. Status always comes from `MaintenanceStatusCalculator` via
/// [DeviceMaintenanceOverview.statusOn] — never from stored values.
abstract final class MaintenanceOverviewRules {
  static MaintenanceStatusCounts count(
    Iterable<DeviceMaintenanceOverview> overviews,
    CalendarDate today,
  ) {
    var overdue = 0, upcoming = 0, scheduled = 0, none = 0;
    for (final overview in overviews) {
      switch (overview.statusOn(today)) {
        case MaintenanceStatus.overdue:
          overdue++;
        case MaintenanceStatus.upcoming:
          upcoming++;
        case MaintenanceStatus.scheduled:
          scheduled++;
        case MaintenanceStatus.noMaintenance:
          none++;
      }
    }
    return MaintenanceStatusCounts(
      overdue: overdue,
      upcoming: upcoming,
      scheduled: scheduled,
      noMaintenance: none,
    );
  }

  /// Priority order:
  /// 1. overdue — oldest next date first,
  /// 2. upcoming — nearest next date first,
  /// 3. scheduled — nearest next date first,
  /// 4. never serviced — customer name (Turkish order), then model.
  /// Ties end with the device id, so the order is deterministic.
  static List<DeviceMaintenanceOverview> sortByPriority(
    Iterable<DeviceMaintenanceOverview> overviews,
    CalendarDate today,
  ) {
    final ranked = [
      for (final overview in overviews) (overview, overview.statusOn(today)),
    ];
    ranked.sort((a, b) {
      final byStatus = a.$2.index.compareTo(b.$2.index);
      if (byStatus != 0) return byStatus;
      final nextA = a.$1.nextMaintenanceDate;
      final nextB = b.$1.nextMaintenanceDate;
      if (nextA != null && nextB != null) {
        final byDate = nextA.compareTo(nextB);
        if (byDate != 0) return byDate;
      }
      final byCustomer = TurkishText.compare(
        a.$1.customerFullName,
        b.$1.customerFullName,
      );
      if (byCustomer != 0) return byCustomer;
      final byModel = TurkishText.compare(a.$1.device.model, b.$1.device.model);
      if (byModel != 0) return byModel;
      return a.$1.device.id.compareTo(b.$1.device.id);
    });
    return [for (final entry in ranked) entry.$1];
  }

  /// Devices that need attention now: overdue and upcoming, in priority
  /// order.
  static List<DeviceMaintenanceOverview> priority(
    Iterable<DeviceMaintenanceOverview> overviews,
    CalendarDate today,
  ) => [
    for (final overview in sortByPriority(overviews, today))
      if (overview.statusOn(today)
          case MaintenanceStatus.overdue || MaintenanceStatus.upcoming)
        overview,
  ];
}
