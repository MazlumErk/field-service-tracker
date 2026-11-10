import 'package:field_service_tracker/core/utils/calendar_date.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fixed_clock.dart';

void main() {
  group('CalendarDate construction', () {
    test('rejects impossible dates', () {
      expect(() => CalendarDate(2025, 2, 29), throwsArgumentError);
      expect(() => CalendarDate(2026, 4, 31), throwsArgumentError);
      expect(() => CalendarDate(2026, 13, 1), throwsArgumentError);
    });

    test('accepts 29 February in leap years', () {
      expect(CalendarDate(2024, 2, 29).day, 29);
      expect(CalendarDate(2000, 2, 29).day, 29);
      expect(() => CalendarDate(1900, 2, 29), throwsArgumentError);
    });

    test('fromDateTime drops the time of day', () {
      final lateNight = CalendarDate.fromDateTime(
        DateTime(2026, 3, 29, 23, 59, 59),
      );
      final midnight = CalendarDate.fromDateTime(DateTime(2026, 3, 29));
      expect(lateNight, midnight);
    });

    test('today() uses the injected clock', () {
      final clock = FixedClock(DateTime(2026, 1, 15, 23, 59));
      expect(CalendarDate.today(clock), CalendarDate(2026, 1, 15));
    });
  });

  group('ISO format', () {
    test('round-trips through yyyy-MM-dd', () {
      final date = CalendarDate(2026, 3, 7);
      expect(date.toIsoString(), '2026-03-07');
      expect(CalendarDate.parse('2026-03-07'), date);
    });

    test('rejects malformed text', () {
      expect(() => CalendarDate.parse('2026-3-7'), throwsFormatException);
      expect(() => CalendarDate.parse('07.03.2026'), throwsFormatException);
      expect(() => CalendarDate.parse('2026-02-30'), throwsArgumentError);
    });

    test('ISO strings sort in date order', () {
      final dates = [
        CalendarDate(2026, 10, 1),
        CalendarDate(2025, 12, 31),
        CalendarDate(2026, 2, 1),
      ];
      final byText = [...dates]
        ..sort((a, b) => a.toIsoString().compareTo(b.toIsoString()));
      final byDate = [...dates]..sort();
      expect(byText, byDate);
    });
  });

  group('daysUntil / addDays', () {
    test('counts calendar days across months and years', () {
      expect(CalendarDate(2025, 12, 31).daysUntil(CalendarDate(2026, 1, 1)), 1);
      expect(
        CalendarDate(2026, 1, 15).daysUntil(CalendarDate(2026, 1, 14)),
        -1,
      );
      expect(CalendarDate(2026, 1, 1).daysUntil(CalendarDate(2027, 1, 1)), 365);
      expect(CalendarDate(2028, 1, 1).daysUntil(CalendarDate(2029, 1, 1)), 366);
    });

    test('is not affected by daylight-saving transitions', () {
      // EU DST starts on 29 March 2026; still exactly 2 calendar days.
      expect(CalendarDate(2026, 3, 28).daysUntil(CalendarDate(2026, 3, 30)), 2);
    });

    test('addDays handles leap day', () {
      final feb28 = CalendarDate(2024, 2, 28);
      expect(feb28.addDays(1), CalendarDate(2024, 2, 29));
      expect(feb28.addDays(2), CalendarDate(2024, 3, 1));
      expect(CalendarDate(2025, 2, 28).addDays(1), CalendarDate(2025, 3, 1));
      expect(CalendarDate(2026, 1, 1).addDays(-1), CalendarDate(2025, 12, 31));
    });
  });

  group('addMonths (end-of-month clamping)', () {
    final cases = <(CalendarDate, int, CalendarDate)>[
      (CalendarDate(2026, 1, 15), 6, CalendarDate(2026, 7, 15)),
      (CalendarDate(2026, 10, 15), 6, CalendarDate(2027, 4, 15)),
      (CalendarDate(2025, 8, 31), 6, CalendarDate(2026, 2, 28)),
      (CalendarDate(2023, 8, 31), 6, CalendarDate(2024, 2, 29)),
      (CalendarDate(2026, 3, 31), 6, CalendarDate(2026, 9, 30)),
      (CalendarDate(2024, 2, 29), 12, CalendarDate(2025, 2, 28)),
      (CalendarDate(2024, 2, 29), 48, CalendarDate(2028, 2, 29)),
      (CalendarDate(2026, 3, 31), -1, CalendarDate(2026, 2, 28)),
      (CalendarDate(2026, 1, 31), -2, CalendarDate(2025, 11, 30)),
      (CalendarDate(2026, 7, 15), -6, CalendarDate(2026, 1, 15)),
    ];

    for (final (start, months, expected) in cases) {
      test('${start.toIsoString()} ${months >= 0 ? '+' : ''}$months months '
          '= ${expected.toIsoString()}', () {
        expect(start.addMonths(months), expected);
      });
    }
  });

  group('comparison', () {
    test('isBefore / isAfter / equality', () {
      final a = CalendarDate(2026, 1, 15);
      final b = CalendarDate(2026, 1, 16);
      expect(a.isBefore(b), isTrue);
      expect(b.isAfter(a), isTrue);
      expect(a.isAfter(a), isFalse);
      expect(a, CalendarDate(2026, 1, 15));
      expect(a.compareTo(CalendarDate(2026, 1, 15)), 0);
    });
  });
}
