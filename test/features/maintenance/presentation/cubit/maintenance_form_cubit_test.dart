import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:field_service_tracker/core/errors/app_exception.dart';
import 'package:field_service_tracker/core/utils/calendar_date.dart';
import 'package:field_service_tracker/core/validation/validation_result.dart';
import 'package:field_service_tracker/features/maintenance/domain/filter_type.dart';
import 'package:field_service_tracker/features/maintenance/domain/maintenance_record.dart';
import 'package:field_service_tracker/features/maintenance/domain/maintenance_validator.dart';
import 'package:field_service_tracker/features/maintenance/presentation/cubit/maintenance_form_cubit.dart';
import 'package:field_service_tracker/features/maintenance/presentation/cubit/maintenance_form_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/fixed_clock.dart';
import '../../../../helpers/mocks.dart';

/// Domain rules themselves (month clamping, price parsing, validator) are
/// covered in Phase 2 tests; these tests cover how the form applies them.
void main() {
  late MockMaintenanceRepository repository;

  setUpAll(() {
    registerMockFallbacks();
    registerFallbackValue(
      MaintenanceRecordDraft(
        maintenanceDate: CalendarDate(2026, 1, 1),
        nextMaintenanceDate: CalendarDate(2026, 1, 1),
        priceKurus: 0,
        filters: const {FilterType.sediment},
      ),
    );
  });
  setUp(() {
    repository = MockMaintenanceRepository();
    when(() => repository.watchDeviceOverview(3))
        .thenAnswer((_) => Stream.value(testOverview(deviceId: 3)));
  });

  MaintenanceFormCubit build([DateTime? now]) => MaintenanceFormCubit(
    deviceId: 3,
    repository: repository,
    clock: FixedClock(now ?? DateTime(2026, 1, 15, 10)),
  );

  /// Loaded and ready, with filters and dates as given.
  Future<MaintenanceFormCubit> ready({
    Set<FilterType> filters = const {FilterType.sediment},
  }) async {
    final cubit = build();
    await cubit.load();
    for (final f in filters) {
      cubit.filterToggled(f);
    }
    return cubit;
  }

  group('defaults and dates', () {
    test('today and today + 6 calendar months (month-end clamped)', () {
      final aug31 = build(DateTime(2025, 8, 31, 23, 30));
      expect(aug31.state.maintenanceDate, CalendarDate(2025, 8, 31));
      expect(aug31.state.nextMaintenanceDate, CalendarDate(2026, 2, 28));

      final mar31 = build(DateTime(2026, 3, 31, 0, 5));
      expect(mar31.state.nextMaintenanceDate, CalendarDate(2026, 9, 30));
      unawaited(aug31.close());
      unawaited(mar31.close());
    });

    test('changing the visit date re-suggests the next date', () async {
      final cubit = await ready();
      cubit.maintenanceDateChanged(CalendarDate(2025, 8, 31));
      expect(cubit.state.nextMaintenanceDate, CalendarDate(2026, 2, 28));
      await cubit.close();
    });

    test('a manually chosen next date is not overwritten', () async {
      final cubit = await ready();
      cubit
        ..nextMaintenanceDateChanged(CalendarDate(2026, 3, 1))
        ..maintenanceDateChanged(CalendarDate(2025, 12, 1));
      expect(cubit.state.nextMaintenanceDate, CalendarDate(2026, 3, 1));
      expect(cubit.state.nextDateCustomized, isTrue);

      cubit.resetNextDateSuggestion();
      expect(cubit.state.nextMaintenanceDate, CalendarDate(2026, 6, 1));
      expect(cubit.state.nextDateCustomized, isFalse);
      await cubit.close();
    });

    test('next date before the visit is rejected without saving', () async {
      final cubit = await ready();
      cubit
        ..nextMaintenanceDateChanged(CalendarDate(2026, 1, 10))
        ..maintenanceDateChanged(CalendarDate(2026, 1, 12));
      await cubit.submit(priceText: '750');

      expect(
        cubit.state.fieldErrors[MaintenanceField.nextMaintenanceDate],
        ValidationError.beforeMaintenanceDate,
      );
      verifyNever(() => repository.createRecord(any(), any()));
      await cubit.close();
    });
  });

  group('filters', () {
    test('toggle selects and deselects; a set prevents duplicates', () async {
      final cubit = await ready(filters: {});
      cubit
        ..filterToggled(FilterType.gac)
        ..filterToggled(FilterType.membrane)
        ..filterToggled(FilterType.gac);
      expect(cubit.state.filters, {FilterType.membrane});
      await cubit.close();
    });

    test('at least one filter is required', () async {
      final cubit = await ready(filters: {});
      await cubit.submit(priceText: '750');
      expect(
        cubit.state.fieldErrors[MaintenanceField.filters],
        ValidationError.empty,
      );
      verifyNever(() => repository.createRecord(any(), any()));
      await cubit.close();
    });
  });

  group('price', () {
    for (final (input, error) in [
      ('', ValidationError.required),
      ('12,345', ValidationError.invalidFormat),
      ('1.250.50', ValidationError.invalidFormat),
      ('1000000,01', ValidationError.tooLarge),
    ]) {
      test('"$input" → $error', () async {
        final cubit = await ready();
        await cubit.submit(priceText: input);
        expect(cubit.state.fieldErrors[MaintenanceField.price], error);
        verifyNever(() => repository.createRecord(any(), any()));
        await cubit.close();
      });
    }
  });

  group('submit', () {
    blocTest<MaintenanceFormCubit, MaintenanceFormState>(
      'saves kuruş, filters and trimmed notes for the device',
      setUp: () => when(() => repository.createRecord(3, any())).thenAnswer(
        (_) async =>
            testRecord(id: 9, deviceId: 3, date: CalendarDate(2026, 1, 15)),
      ),
      build: build,
      act: (cubit) async {
        await cubit.load();
        cubit
          ..filterToggled(FilterType.sediment)
          ..filterToggled(FilterType.membrane);
        await cubit.submit(priceText: '1.250,50', notes: '  Tank temizlendi ');
      },
      verify: (cubit) {
        final draft =
            verify(() => repository.createRecord(3, captureAny()))
                    .captured
                    .single
                as MaintenanceRecordDraft;
        expect(draft.priceKurus, 125050);
        expect(draft.filters, {FilterType.sediment, FilterType.membrane});
        expect(draft.maintenanceDate, CalendarDate(2026, 1, 15));
        expect(draft.nextMaintenanceDate, CalendarDate(2026, 7, 15));
        expect(draft.normalized().notes, 'Tank temizlendi');
        expect(cubit.state.status, MaintenanceFormStatus.success);
      },
    );

    test('repeated submits while saving create one record', () async {
      final completer = Completer<MaintenanceRecord>();
      when(() => repository.createRecord(3, any()))
          .thenAnswer((_) => completer.future);
      final cubit = await ready();

      final calls = [
        cubit.submit(priceText: '750'),
        cubit.submit(priceText: '750'),
        cubit.submit(priceText: '750'),
      ];
      expect(cubit.state.isSubmitting, isTrue);
      completer.complete(testRecord(date: CalendarDate(2026, 1, 15)));
      await Future.wait(calls);

      verify(() => repository.createRecord(3, any())).called(1);
      await cubit.close();
    });

    test('storage failure keeps the input and reports the error', () async {
      when(() => repository.createRecord(3, any()))
          .thenThrow(const DatabaseException('rolled back'));
      final cubit = await ready();
      await cubit.submit(priceText: '750');

      expect(cubit.state.status, MaintenanceFormStatus.editing);
      expect(cubit.state.failure, isA<DatabaseException>());
      expect(cubit.state.filters, {FilterType.sediment});
      await cubit.close();
    });

    test('an unknown device ends in loadFailure', () async {
      when(() => repository.watchDeviceOverview(3))
          .thenAnswer((_) => Stream.value(null));
      final cubit = build();
      await cubit.load();
      expect(cubit.state.status, MaintenanceFormStatus.loadFailure);
      expect(cubit.state.failure, isA<NotFoundException>());
      await cubit.submit(priceText: '750');
      verifyNever(() => repository.createRecord(any(), any()));
      await cubit.close();
    });
  });
}
