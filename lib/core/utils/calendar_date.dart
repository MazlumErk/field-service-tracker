import 'package:equatable/equatable.dart';
import 'package:field_service_tracker/core/clock/app_clock.dart';

/// A date without time or timezone (year, month, day).
///
/// Maintenance dates are calendar facts ("serviced on 3 March"), so they are
/// modelled without a time component. All arithmetic goes through UTC epoch
/// days, which makes it immune to DST and timezone shifts.
final class CalendarDate extends Equatable implements Comparable<CalendarDate> {
  /// Creates a validated date. Throws [ArgumentError] for impossible dates
  /// such as 30 February.
  factory CalendarDate(int year, int month, int day) {
    final utc = DateTime.utc(year, month, day);
    if (utc.year != year || utc.month != month || utc.day != day) {
      throw ArgumentError('Invalid calendar date: $year-$month-$day');
    }
    return CalendarDate._(year, month, day);
  }

  const CalendarDate._(this.year, this.month, this.day);

  /// Takes the *local* year/month/day of [dateTime] and drops the time.
  factory CalendarDate.fromDateTime(DateTime dateTime) =>
      CalendarDate._(dateTime.year, dateTime.month, dateTime.day);

  /// Today's date according to [clock].
  factory CalendarDate.today(AppClock clock) =>
      CalendarDate.fromDateTime(clock.now());

  /// Parses the storage format `yyyy-MM-dd` strictly.
  factory CalendarDate.parse(String value) {
    final match = _isoPattern.firstMatch(value);
    if (match == null) {
      throw FormatException('Expected yyyy-MM-dd', value);
    }
    return CalendarDate(
      int.parse(match.group(1)!),
      int.parse(match.group(2)!),
      int.parse(match.group(3)!),
    );
  }

  static final RegExp _isoPattern = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$');
  static const int _millisecondsPerDay = 24 * 60 * 60 * 1000;

  final int year;
  final int month;
  final int day;

  static int daysInMonth(int year, int month) =>
      DateTime.utc(year, month + 1, 0).day;

  int get _epochDay =>
      DateTime.utc(year, month, day).millisecondsSinceEpoch ~/
      _millisecondsPerDay;

  /// Signed number of days from this date to [other]
  /// (`today.daysUntil(tomorrow) == 1`).
  int daysUntil(CalendarDate other) => other._epochDay - _epochDay;

  CalendarDate addDays(int days) =>
      CalendarDate.fromDateTime(DateTime.utc(year, month, day + days));

  /// Adds calendar months. If the target month is shorter, the day is
  /// clamped to its last day: 31 Aug + 6 months = 28 Feb (29 in leap years).
  CalendarDate addMonths(int months) {
    final monthIndex = year * 12 + (month - 1) + months;
    final targetYear = monthIndex ~/ 12;
    final targetMonth = monthIndex % 12 + 1;
    final lastDay = daysInMonth(targetYear, targetMonth);
    return CalendarDate._(
      targetYear,
      targetMonth,
      day > lastDay ? lastDay : day,
    );
  }

  bool isBefore(CalendarDate other) => compareTo(other) < 0;

  bool isAfter(CalendarDate other) => compareTo(other) > 0;

  /// Midnight UTC of this date; used for persistence of timestamps only.
  DateTime toUtcDateTime() => DateTime.utc(year, month, day);

  /// Storage / sort format `yyyy-MM-dd` (lexicographic order == date order).
  String toIsoString() =>
      '${year.toString().padLeft(4, '0')}-'
      '${month.toString().padLeft(2, '0')}-'
      '${day.toString().padLeft(2, '0')}';

  @override
  int compareTo(CalendarDate other) {
    if (year != other.year) return year.compareTo(other.year);
    if (month != other.month) return month.compareTo(other.month);
    return day.compareTo(other.day);
  }

  @override
  List<Object?> get props => [year, month, day];

  @override
  String toString() => 'CalendarDate(${toIsoString()})';
}
