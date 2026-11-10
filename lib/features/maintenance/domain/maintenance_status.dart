import 'package:field_service_tracker/core/utils/calendar_date.dart';

/// Maintenance state of a device on a given day.
enum MaintenanceStatus {
  /// Next maintenance date is before today.
  overdue,

  /// Next maintenance date is today or within the next 30 days.
  upcoming,

  /// Next maintenance date is more than 30 days away.
  scheduled,

  /// The device has no maintenance record yet.
  noMaintenance,
}

/// Single source of the status rules. Compares calendar days only, so the
/// time of day and timezone never change the result.
abstract final class MaintenanceStatusCalculator {
  /// Inclusive window (in days from today) for [MaintenanceStatus.upcoming].
  static const int upcomingWindowDays = 30;

  static MaintenanceStatus statusFor({
    required CalendarDate? nextMaintenanceDate,
    required CalendarDate today,
  }) {
    if (nextMaintenanceDate == null) return MaintenanceStatus.noMaintenance;
    final days = today.daysUntil(nextMaintenanceDate);
    if (days < 0) return MaintenanceStatus.overdue;
    if (days <= upcomingWindowDays) return MaintenanceStatus.upcoming;
    return MaintenanceStatus.scheduled;
  }
}
