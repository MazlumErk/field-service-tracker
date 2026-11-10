import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:field_service_tracker/core/errors/app_exception.dart';
import 'package:field_service_tracker/core/utils/calendar_date.dart';
import 'package:field_service_tracker/features/devices/domain/device.dart';
import 'package:field_service_tracker/features/devices/presentation/cubit/device_detail_cubit.dart';
import 'package:field_service_tracker/features/devices/presentation/cubit/device_detail_state.dart';
import 'package:field_service_tracker/features/maintenance/domain/device_maintenance_overview.dart';
import 'package:field_service_tracker/features/maintenance/domain/maintenance_record.dart';
import 'package:field_service_tracker/features/maintenance/domain/maintenance_status.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/fixed_clock.dart';
import '../../../../helpers/mocks.dart';

void main() {
  late MockDeviceRepository devices;
  late MockMaintenanceRepository maintenance;
  final clock = FixedClock(DateTime(2026, 1, 15, 10));
  final today = CalendarDate(2026, 1, 15);
  const impact = DeviceDeletionImpact(
    maintenanceRecordCount: 2,
    filterReplacementCount: 5,
  );

  setUp(() {
    devices = MockDeviceRepository();
    maintenance = MockMaintenanceRepository();
  });

  DeviceDetailCubit build() => DeviceDetailCubit(
    deviceId: 1,
    deviceRepository: devices,
    maintenanceRepository: maintenance,
    clock: clock,
  );

  void stub({
    Stream<DeviceMaintenanceOverview?>? overview,
    Stream<List<MaintenanceRecord>>? history,
  }) {
    when(() => maintenance.watchDeviceOverview(1)).thenAnswer(
      (_) => overview ?? Stream.value(testOverview(next: today.addDays(-4))),
    );
    when(() => maintenance.watchHistory(1))
        .thenAnswer((_) => history ?? Stream.value(const []));
  }

  group('maintenance status and days', () {
    for (final (offset, status) in [
      (-4, MaintenanceStatus.overdue),
      (0, MaintenanceStatus.upcoming),
      (30, MaintenanceStatus.upcoming),
      (31, MaintenanceStatus.scheduled),
    ]) {
      blocTest<DeviceDetailCubit, DeviceDetailState>(
        'next maintenance in $offset days → $status',
        setUp: () => stub(
          overview: Stream.value(testOverview(next: today.addDays(offset))),
        ),
        build: build,
        act: (cubit) => cubit.load(),
        verify: (cubit) {
          expect(cubit.state.status, DeviceDetailStatus.success);
          expect(cubit.state.maintenanceStatus, status);
          expect(cubit.state.daysUntilNextMaintenance, offset);
        },
      );
    }

    blocTest<DeviceDetailCubit, DeviceDetailState>(
      'a device without records is noMaintenance with empty history',
      setUp: () => stub(overview: Stream.value(testOverview())),
      build: build,
      act: (cubit) => cubit.load(),
      verify: (cubit) {
        expect(cubit.state.maintenanceStatus, MaintenanceStatus.noMaintenance);
        expect(cubit.state.daysUntilNextMaintenance, isNull);
        expect(cubit.state.hasHistory, isFalse);
      },
    );
  });

  blocTest<DeviceDetailCubit, DeviceDetailState>(
    'keeps the repository history order (newest first)',
    setUp: () => stub(
      history: Stream.value([
        testRecord(id: 3, date: CalendarDate(2025, 9, 1)),
        testRecord(id: 2, date: CalendarDate(2025, 3, 1)),
      ]),
    ),
    build: build,
    act: (cubit) => cubit.load(),
    verify: (cubit) => expect(cubit.state.history.map((r) => r.id), [3, 2]),
  );

  blocTest<DeviceDetailCubit, DeviceDetailState>(
    'a missing device is reported as notFound',
    setUp: () => stub(overview: Stream.value(null)),
    build: build,
    act: (cubit) => cubit.load(),
    verify: (cubit) => expect(cubit.state.status, DeviceDetailStatus.notFound),
  );

  blocTest<DeviceDetailCubit, DeviceDetailState>(
    'stream errors become a failure state',
    setUp: () => stub(history: Stream.error(const DatabaseException('x'))),
    build: build,
    act: (cubit) => cubit.load(),
    verify: (cubit) {
      expect(cubit.state.status, DeviceDetailStatus.failure);
      expect(cubit.state.failure, isA<DatabaseException>());
    },
  );

  group('delete flow', () {
    late DeviceDetailState loaded;

    setUp(() {
      loaded = DeviceDetailState(
        today: today,
        status: DeviceDetailStatus.success,
        overview: testOverview(customerId: 4),
      );
    });

    blocTest<DeviceDetailCubit, DeviceDetailState>(
      'requestDeletion asks for confirmation with the impact',
      setUp: () =>
          when(() => devices.getDeletionImpact(1))
              .thenAnswer((_) async => impact),
      build: build,
      seed: () => loaded,
      act: (cubit) => cubit.requestDeletion(),
      expect: () => [
        loaded.copyWith(deletionStep: DeviceDeletionStep.loadingImpact),
        loaded.copyWith(
          deletionStep: DeviceDeletionStep.confirming,
          deletionImpact: impact,
        ),
      ],
    );

    blocTest<DeviceDetailCubit, DeviceDetailState>(
      'cancel deletes nothing',
      build: build,
      seed: () => loaded.copyWith(
        deletionStep: DeviceDeletionStep.confirming,
        deletionImpact: impact,
      ),
      act: (cubit) => cubit.cancelDeletion(),
      expect: () => [loaded],
      verify: (_) => verifyNever(() => devices.deleteDevice(any())),
    );

    blocTest<DeviceDetailCubit, DeviceDetailState>(
      'confirm deletes once and ends in deleted',
      setUp: () => when(() => devices.deleteDevice(1)).thenAnswer((_) async {}),
      build: build,
      seed: () => loaded.copyWith(
        deletionStep: DeviceDeletionStep.confirming,
        deletionImpact: impact,
      ),
      act: (cubit) async {
        await cubit.confirmDeletion();
        await cubit.confirmDeletion();
      },
      expect: () => [
        loaded.copyWith(deletionStep: DeviceDeletionStep.deleting),
        loaded.copyWith(deletionStep: DeviceDeletionStep.deleted),
      ],
      verify: (cubit) {
        verify(() => devices.deleteDevice(1)).called(1);
        // The page navigates to this customer afterwards.
        expect(cubit.state.overview!.customerId, 4);
      },
    );

    blocTest<DeviceDetailCubit, DeviceDetailState>(
      'a failed delete (rolled back) returns to idle with an error',
      setUp: () =>
          when(() => devices.deleteDevice(1))
              .thenThrow(const DatabaseException('rolled back')),
      build: build,
      seed: () => loaded.copyWith(
        deletionStep: DeviceDeletionStep.confirming,
        deletionImpact: impact,
      ),
      act: (cubit) => cubit.confirmDeletion(),
      verify: (cubit) {
        expect(cubit.state.deletionStep, DeviceDeletionStep.idle);
        expect(cubit.state.deletionFailure, isA<DatabaseException>());
      },
    );

    test(
      'after deletion the null overview does not flip to notFound',
      () async {
        final overview = StreamController<DeviceMaintenanceOverview?>();
        stub(overview: overview.stream);
        when(() => devices.getDeletionImpact(1))
            .thenAnswer((_) async => impact);
        when(() => devices.deleteDevice(1)).thenAnswer((_) async {});

        final cubit = build()..load();
        overview.add(testOverview());
        await Future<void>.delayed(Duration.zero);
        await cubit.requestDeletion();
        await cubit.confirmDeletion();
        overview.add(null);
        await Future<void>.delayed(Duration.zero);

        expect(cubit.state.deletionStep, DeviceDeletionStep.deleted);
        expect(cubit.state.status, DeviceDetailStatus.success);
        await cubit.close();
        await overview.close();
      },
    );
  });

  test('close cancels both subscriptions', () async {
    final overview = StreamController<DeviceMaintenanceOverview?>();
    final history = StreamController<List<MaintenanceRecord>>();
    stub(overview: overview.stream, history: history.stream);

    final cubit = build()..load();
    expect(overview.hasListener, isTrue);
    expect(history.hasListener, isTrue);
    await cubit.close();
    expect(overview.hasListener, isFalse);
    expect(history.hasListener, isFalse);
    await overview.close();
    await history.close();
  });
}
