import 'package:drift/drift.dart';
import 'package:field_service_tracker/core/utils/calendar_date.dart';

/// Stores [CalendarDate] as ISO `yyyy-MM-dd` text: timezone-free and
/// lexicographically sortable, so `ORDER BY` and `CHECK (a >= b)` work.
class CalendarDateConverter extends TypeConverter<CalendarDate, String> {
  const CalendarDateConverter();

  @override
  CalendarDate fromSql(String fromDb) => CalendarDate.parse(fromDb);

  @override
  String toSql(CalendarDate value) => value.toIsoString();
}
