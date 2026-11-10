import 'package:field_service_tracker/core/utils/calendar_date.dart';
import 'package:field_service_tracker/core/validation/validation_result.dart';
import 'package:field_service_tracker/features/devices/domain/device.dart';
import 'package:field_service_tracker/features/devices/domain/device_validator.dart';
import 'package:field_service_tracker/features/maintenance/domain/device_maintenance_overview.dart';
import 'package:field_service_tracker/features/maintenance/domain/filter_type.dart';
import 'package:field_service_tracker/features/maintenance/domain/maintenance_price.dart';
import 'package:field_service_tracker/features/maintenance/domain/maintenance_record.dart';
import 'package:field_service_tracker/features/maintenance/domain/maintenance_schedule.dart';
import 'package:field_service_tracker/features/maintenance/domain/maintenance_status.dart';
import 'package:field_service_tracker/features/maintenance/domain/maintenance_validator.dart';
import 'package:flutter_test/flutter_test.dart';

MaintenanceStatus _status(CalendarDate today, CalendarDate? next) =>
    MaintenanceStatusCalculator.statusFor(
      nextMaintenanceDate: next,
      today: today,
    );

void main() {
  final today = CalendarDate(2026, 1, 15);

  group('MaintenanceStatusCalculator boundaries', () {
    test('yesterday is overdue', () {
      expect(_status(today, today.addDays(-1)), MaintenanceStatus.overdue);
    });

    test('long past is overdue', () {
      expect(_status(today, today.addDays(-400)), MaintenanceStatus.overdue);
    });

    test('today is upcoming', () {
      expect(_status(today, today), MaintenanceStatus.upcoming);
    });

    test('day 30 is still upcoming', () {
      expect(_status(today, today.addDays(30)), MaintenanceStatus.upcoming);
    });

    test('day 31 is scheduled', () {
      expect(_status(today, today.addDays(31)), MaintenanceStatus.scheduled);
    });

    test('no record means noMaintenance', () {
      expect(_status(today, null), MaintenanceStatus.noMaintenance);
    });

    test('window across a year boundary', () {
      final dec20 = CalendarDate(2026, 12, 20);
      expect(
        _status(dec20, CalendarDate(2027, 1, 19)),
        MaintenanceStatus.upcoming,
      );
      expect(
        _status(dec20, CalendarDate(2027, 1, 20)),
        MaintenanceStatus.scheduled,
      );
    });

    test('window across a leap February', () {
      final feb1 = CalendarDate(2028, 2, 1);
      // 2028-02-01 → 2028-03-02 is 30 days because of 29 Feb.
      expect(
        _status(feb1, CalendarDate(2028, 3, 2)),
        MaintenanceStatus.upcoming,
      );
      expect(
        _status(feb1, CalendarDate(2028, 3, 3)),
        MaintenanceStatus.scheduled,
      );
    });

    test('DeviceMaintenanceOverview.statusOn delegates to the calculator', () {
      final overview = DeviceMaintenanceOverview(
        device: Device(
          id: 1,
          customerId: 1,
          model: 'M',
          installedAt: CalendarDate(2025, 1, 1),
          createdAt: DateTime.utc(2025),
        ),
        customerId: 1,
        customerNumber: 'FST-1',
        customerFirstName: 'Ali',
        customerLastName: 'Kaya',
        lastMaintenanceDate: CalendarDate(2025, 7, 14),
        nextMaintenanceDate: CalendarDate(2026, 1, 14),
      );
      expect(overview.statusOn(today), MaintenanceStatus.overdue);
      expect(overview.customerFullName, 'Ali Kaya');
      expect(overview.hasMaintenance, isTrue);
    });
  });

  group('MaintenanceSchedule.suggestNextDate', () {
    test('adds six calendar months, not 180 days', () {
      expect(
        MaintenanceSchedule.suggestNextDate(CalendarDate(2026, 1, 15)),
        CalendarDate(2026, 7, 15),
      );
      expect(
        CalendarDate(2026, 1, 15).daysUntil(CalendarDate(2026, 7, 15)),
        isNot(180),
      );
    });

    test('clamps month-end dates', () {
      expect(
        MaintenanceSchedule.suggestNextDate(CalendarDate(2025, 8, 31)),
        CalendarDate(2026, 2, 28),
      );
      expect(
        MaintenanceSchedule.suggestNextDate(CalendarDate(2027, 8, 31)),
        CalendarDate(2028, 2, 29),
      );
    });
  });

  group('MaintenancePrice.parseToKurus', () {
    final valid = <String, int>{
      '0': 0,
      '750': 75000,
      '1250,5': 125050,
      '1250,50': 125050,
      '1.250': 125000,
      '1.250,75': 125075,
      '₺ 1.250,75': 125075,
      '1250 TL': 125000,
      '1.000.000': 100000000,
    };
    valid.forEach((input, expected) {
      test('"$input" → $expected kuruş', () {
        expect(MaintenancePrice.parseToKurus(input), expected);
      });
    });

    for (final input in [
      '',
      'abc',
      '-50',
      '12,345',
      '1,2,3',
      '12.50',
      '1.25',
    ]) {
      test('"$input" is rejected', () {
        expect(MaintenancePrice.parseToKurus(input), isNull);
      });
    }

    test('range check', () {
      expect(MaintenancePrice.isValidKurus(0), isTrue);
      expect(MaintenancePrice.isValidKurus(MaintenancePrice.maxKurus), isTrue);
      expect(MaintenancePrice.isValidKurus(-1), isFalse);
      expect(
        MaintenancePrice.isValidKurus(MaintenancePrice.maxKurus + 1),
        isFalse,
      );
    });
  });

  group('MaintenanceValidator', () {
    MaintenanceRecordDraft draft({
      CalendarDate? date,
      CalendarDate? next,
      int price = 75000,
      Set<FilterType> filters = const {FilterType.sediment},
      String? notes,
    }) {
      final maintenanceDate = date ?? today;
      return MaintenanceRecordDraft(
        maintenanceDate: maintenanceDate,
        nextMaintenanceDate:
            next ?? MaintenanceSchedule.suggestNextDate(maintenanceDate),
        priceKurus: price,
        filters: filters,
        notes: notes,
      );
    }

    ValidationResult<MaintenanceField> validate(MaintenanceRecordDraft d) =>
        MaintenanceValidator.validate(d, today: today);

    test('accepts a valid record', () {
      expect(validate(draft()).isValid, isTrue);
    });

    test('next date equal to maintenance date is allowed', () {
      expect(validate(draft(next: today)).isValid, isTrue);
    });

    test('next date before maintenance date is rejected', () {
      expect(
        validate(draft(next: today.addDays(-1)))
            .errorFor(MaintenanceField.nextMaintenanceDate),
        ValidationError.beforeMaintenanceDate,
      );
    });

    test('maintenance date in the future is rejected', () {
      expect(
        validate(draft(date: today.addDays(1)))
            .errorFor(MaintenanceField.maintenanceDate),
        ValidationError.inFuture,
      );
    });

    test('price must be between 0 and the ceiling', () {
      expect(validate(draft(price: 0)).isValid, isTrue);
      expect(
        validate(draft(price: -1)).errorFor(MaintenanceField.price),
        ValidationError.negative,
      );
      expect(
        validate(draft(price: MaintenancePrice.maxKurus + 1))
            .errorFor(MaintenanceField.price),
        ValidationError.tooLarge,
      );
    });

    test('at least one filter is required', () {
      expect(
        validate(draft(filters: {})).errorFor(MaintenanceField.filters),
        ValidationError.empty,
      );
    });

    test('notes are limited to 500 characters', () {
      expect(
        validate(draft(notes: 'x' * 501)).errorFor(MaintenanceField.notes),
        ValidationError.tooLong,
      );
      expect(validate(draft(notes: '   ')).isValid, isTrue);
    });
  });

  group('DeviceValidator', () {
    test('requires a model and rejects future installation', () {
      final result = DeviceValidator.validate(
        DeviceDraft(model: '  ', installedAt: today.addDays(1)),
        today: today,
      );
      expect(result.errors, {
        DeviceField.model: ValidationError.required,
        DeviceField.installedAt: ValidationError.inFuture,
      });
    });

    test('serial number is optional with a length limit', () {
      expect(
        DeviceValidator.validate(
          DeviceDraft(model: 'AquaPure', installedAt: today, serialNumber: ' '),
          today: today,
        ).isValid,
        isTrue,
      );
      expect(
        DeviceValidator.validate(
          DeviceDraft(
            model: 'AquaPure',
            installedAt: today,
            serialNumber: 'S' * 51,
          ),
          today: today,
        ).errorFor(DeviceField.serialNumber),
        ValidationError.tooLong,
      );
    });
  });
}
