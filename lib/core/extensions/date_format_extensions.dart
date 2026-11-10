import 'package:field_service_tracker/core/utils/calendar_date.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

/// Single place for user-visible date formatting.
///
/// Uses `DateFormat.yMMMd` of the active locale ("19 Oca 2026" in Turkish).
/// Material's `formatMediumDate` was not used because its Turkish pattern
/// omits the year, which is essential for maintenance dates. Date symbols
/// are loaded by the Material localization delegate at startup.
extension DateFormatContext on BuildContext {
  String formatDate(CalendarDate date) =>
      DateFormat.yMMMd(Localizations.localeOf(this).toLanguageTag())
          .format(DateTime(date.year, date.month, date.day));

  /// Formats the local calendar day of a UTC/local timestamp.
  String formatTimestampDate(DateTime timestamp) =>
      formatDate(CalendarDate.fromDateTime(timestamp.toLocal()));
}
