import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:field_service_tracker/core/errors/app_exception.dart';
import 'package:field_service_tracker/core/utils/calendar_date.dart';
import 'package:field_service_tracker/core/validation/validation_result.dart';
import 'package:field_service_tracker/features/devices/domain/device.dart';
import 'package:field_service_tracker/features/devices/domain/device_validator.dart';
import 'package:field_service_tracker/features/devices/presentation/cubit/device_form_cubit.dart';
import 'package:field_service_tracker/features/devices/presentation/cubit/device_form_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/fixed_clock.dart';
import '../../../../helpers/mocks.dart';

void main() {
  late MockDeviceRepository repository;
  final clock = FixedClock(DateTime(2026, 1, 15, 10));
  final today = CalendarDate(2026, 1, 15);
  final saved = testDevice(id: 30, customerId: 7);

  setUpAll(registerMockFallbacks);
  setUp(() => repository = MockDeviceRepository());

  DeviceFormCubit create() =>
      DeviceFormCubit.create(repository, customerId: 7, clock: clock);

  group('create', () {
    test('installation date defaults to today', () {
      final cubit = create();
      expect(cubit.state.installedAt, today);
      expect(cubit.state.status, DeviceFormStatus.editing);
      unawaited(cubit.close());
    });

    blocTest<DeviceFormCubit, DeviceFormState>(
      'attaches the device to the given customer',
      setUp: () =>
          when(() => repository.createDevice(7, any()))
              .thenAnswer((_) async => saved),
      build: create,
      act: (cubit) => cubit.submit(model: 'AquaPure RO-5'),
      expect: () => [
        DeviceFormState(
          status: DeviceFormStatus.submitting,
          today: today,
          installedAt: today,
        ),
        DeviceFormState(
          status: DeviceFormStatus.success,
          today: today,
          installedAt: today,
          savedDevice: saved,
        ),
      ],
      verify: (_) {
        final draft =
            verify(() => repository.createDevice(7, captureAny()))
                    .captured
                    .single
                as DeviceDraft;
        expect(draft.model, 'AquaPure RO-5');
        expect(draft.installedAt, today);
      },
    );

    blocTest<DeviceFormCubit, DeviceFormState>(
      'serial number is optional',
      setUp: () =>
          when(() => repository.createDevice(7, any()))
              .thenAnswer((_) async => saved),
      build: create,
      act: (cubit) => cubit.submit(model: 'Crystal', serialNumber: '   '),
      verify: (cubit) {
        expect(cubit.state.status, DeviceFormStatus.success);
        verify(() => repository.createDevice(7, any())).called(1);
      },
    );

    blocTest<DeviceFormCubit, DeviceFormState>(
      'empty model and future date are rejected without saving',
      build: create,
      act: (cubit) => cubit
        ..installedAtChanged(today.addDays(3))
        ..submit(model: '  '),
      verify: (cubit) {
        expect(cubit.state.fieldErrors, {
          DeviceField.model: ValidationError.required,
          DeviceField.installedAt: ValidationError.inFuture,
        });
        verifyNever(() => repository.createDevice(any(), any()));
      },
    );

    blocTest<DeviceFormCubit, DeviceFormState>(
      'changing the date clears its error',
      build: create,
      seed: () => DeviceFormState(
        status: DeviceFormStatus.editing,
        today: today,
        installedAt: today.addDays(3),
        fieldErrors: const {DeviceField.installedAt: ValidationError.inFuture},
      ),
      act: (cubit) => cubit.installedAtChanged(CalendarDate(2025, 5, 1)),
      expect: () => [
        DeviceFormState(
          status: DeviceFormStatus.editing,
          today: today,
          installedAt: CalendarDate(2025, 5, 1),
        ),
      ],
    );

    blocTest<DeviceFormCubit, DeviceFormState>(
      'a deleted customer is reported as a NotFound failure',
      setUp: () =>
          when(() => repository.createDevice(7, any()))
              .thenThrow(const NotFoundException('Customer', 7)),
      build: create,
      act: (cubit) => cubit.submit(model: 'AquaPure'),
      verify: (cubit) {
        expect(cubit.state.status, DeviceFormStatus.editing);
        expect(cubit.state.failure, isA<NotFoundException>());
      },
    );

    test('repeated submits while saving create only one device', () async {
      final completer = Completer<Device>();
      when(() => repository.createDevice(7, any()))
          .thenAnswer((_) => completer.future);
      final cubit = create();

      final calls = [
        cubit.submit(model: 'AquaPure'),
        cubit.submit(model: 'AquaPure'),
        cubit.submit(model: 'AquaPure'),
      ];
      completer.complete(saved);
      await Future.wait(calls);

      verify(() => repository.createDevice(7, any())).called(1);
      expect(cubit.state.status, DeviceFormStatus.success);
      await cubit.close();
    });
  });

  group('edit', () {
    final existing = testDevice(id: 8, customerId: 5, serial: 'DEMO-1008');

    DeviceFormCubit edit() =>
        DeviceFormCubit.edit(repository, deviceId: 8, clock: clock);

    blocTest<DeviceFormCubit, DeviceFormState>(
      'load prefills the device including its installation date',
      setUp: () =>
          when(() => repository.getDevice(8)).thenAnswer((_) async => existing),
      build: edit,
      act: (cubit) => cubit.load(),
      expect: () => [
        DeviceFormState(
          status: DeviceFormStatus.editing,
          today: today,
          installedAt: existing.installedAt,
          initialDevice: existing,
        ),
      ],
    );

    blocTest<DeviceFormCubit, DeviceFormState>(
      'load failure is reported',
      setUp: () =>
          when(() => repository.getDevice(8))
              .thenThrow(const NotFoundException('Device', 8)),
      build: edit,
      act: (cubit) => cubit.load(),
      verify: (cubit) =>
          expect(cubit.state.status, DeviceFormStatus.loadFailure),
    );

    blocTest<DeviceFormCubit, DeviceFormState>(
      'submit updates (never creates) and keeps the owner',
      setUp: () =>
          when(() => repository.updateDevice(8, any()))
              .thenAnswer((_) async => existing),
      build: edit,
      seed: () => DeviceFormState(
        status: DeviceFormStatus.editing,
        today: today,
        installedAt: existing.installedAt,
        initialDevice: existing,
      ),
      act: (cubit) => cubit.submit(model: 'ClearFlow 7', serialNumber: 'X'),
      verify: (cubit) {
        verify(() => repository.updateDevice(8, any())).called(1);
        verifyNever(() => repository.createDevice(any(), any()));
        expect(cubit.state.status, DeviceFormStatus.success);
        expect(cubit.customerId, isNull);
      },
    );

    blocTest<DeviceFormCubit, DeviceFormState>(
      'storage errors keep the form editable',
      setUp: () =>
          when(() => repository.updateDevice(8, any()))
              .thenThrow(const DatabaseException('busy')),
      build: edit,
      seed: () => DeviceFormState(
        status: DeviceFormStatus.editing,
        today: today,
        installedAt: existing.installedAt,
        initialDevice: existing,
      ),
      act: (cubit) => cubit.submit(model: 'ClearFlow 7'),
      verify: (cubit) {
        expect(cubit.state.status, DeviceFormStatus.editing);
        expect(cubit.state.failure, isA<DatabaseException>());
      },
    );
  });
}
