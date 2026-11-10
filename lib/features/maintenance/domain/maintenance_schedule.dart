import 'package:field_service_tracker/core/utils/calendar_date.dart';

/// Scheduling defaults for the next maintenance.
abstract final class MaintenanceSchedule {
  /// Default interval between two maintenance visits.
  static const int defaultIntervalMonths = 6;

  /// Suggested next maintenance date: [maintenanceDate] + 6 calendar months,
  /// clamped to the end of shorter months (31 Aug → 28/29 Feb).
  /// The user may override it with any date on or after [maintenanceDate].
  static CalendarDate suggestNextDate(CalendarDate maintenanceDate) =>
      maintenanceDate.addMonths(defaultIntervalMonths);
}
