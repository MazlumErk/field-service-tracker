import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:field_service_tracker/core/errors/app_exception.dart';
import 'package:field_service_tracker/core/utils/calendar_date.dart';
import 'package:field_service_tracker/features/customers/domain/customer.dart';
import 'package:field_service_tracker/features/customers/presentation/cubit/customer_detail_cubit.dart';
import 'package:field_service_tracker/features/customers/presentation/cubit/customer_detail_state.dart';
import 'package:field_service_tracker/features/maintenance/domain/device_maintenance_overview.dart';
import 'package:field_service_tracker/features/maintenance/domain/maintenance_status.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/fixed_clock.dart';
import '../../../../helpers/mocks.dart';

void main() {
  late MockCustomerRepository customers;
  late MockMaintenanceRepository maintenance;
  final clock = FixedClock(DateTime(2026, 1, 15, 10));
  final today = CalendarDate(2026, 1, 15);
  final customer = testCustomer(id: 5);
  final devices = [testOverview(customerId: 5, next: today.addDays(-3))];
  const impact = CustomerDeletionImpact(
    deviceCount: 1,
    maintenanceRecordCount: 4,
  );

  setUp(() {
    customers = MockCustomerRepository();
    maintenance = MockMaintenanceRepository();
  });

  CustomerDetailCubit build() => CustomerDetailCubit(
    customerId: 5,
    customerRepository: customers,
    maintenanceRepository: maintenance,
    clock: clock,
  );

  void stubStreams({
    Stream<Customer?>? customerStream,
    Stream<List<DeviceMaintenanceOverview>>? deviceStream,
  }) {
    when(() => customers.watchCustomer(5))
        .thenAnswer((_) => customerStream ?? Stream.value(customer));
    when(() => maintenance.watchCustomerOverview(5))
        .thenAnswer((_) => deviceStream ?? Stream.value(devices));
  }

  final loaded = CustomerDetailState(
    today: today,
    status: CustomerDetailStatus.success,
    customer: customer,
    devices: devices,
  );

  blocTest<CustomerDetailCubit, CustomerDetailState>(
    'combines the customer and device streams',
    setUp: stubStreams,
    build: build,
    act: (cubit) => cubit.load(),
    expect: () => [loaded],
    verify: (cubit) => expect(
      cubit.state.devices.single.statusOn(cubit.state.today),
      MaintenanceStatus.overdue,
    ),
  );

  blocTest<CustomerDetailCubit, CustomerDetailState>(
    'a missing customer is reported as notFound',
    setUp: () => stubStreams(customerStream: Stream.value(null)),
    build: build,
    act: (cubit) => cubit.load(),
    expect: () => [
      CustomerDetailState(today: today, status: CustomerDetailStatus.notFound),
    ],
  );

  blocTest<CustomerDetailCubit, CustomerDetailState>(
    'stream errors become a failure state',
    setUp: () => stubStreams(
      deviceStream: Stream.error(const DatabaseException('boom')),
    ),
    build: build,
    act: (cubit) => cubit.load(),
    verify: (cubit) {
      expect(cubit.state.status, CustomerDetailStatus.failure);
      expect(cubit.state.failure, isA<DatabaseException>());
    },
  );

  group('delete flow', () {
    blocTest<CustomerDetailCubit, CustomerDetailState>(
      'requestDeletion loads the impact and asks for confirmation',
      setUp: () =>
          when(() => customers.getDeletionImpact(5))
              .thenAnswer((_) async => impact),
      build: build,
      seed: () => loaded,
      act: (cubit) => cubit.requestDeletion(),
      expect: () => [
        loaded.copyWith(deletionStep: CustomerDeletionStep.loadingImpact),
        loaded.copyWith(
          deletionStep: CustomerDeletionStep.confirming,
          deletionImpact: impact,
        ),
      ],
    );

    blocTest<CustomerDetailCubit, CustomerDetailState>(
      'cancelling deletes nothing',
      build: build,
      seed: () => loaded.copyWith(
        deletionStep: CustomerDeletionStep.confirming,
        deletionImpact: impact,
      ),
      act: (cubit) => cubit.cancelDeletion(),
      expect: () => [loaded],
      verify: (_) => verifyNever(() => customers.deleteCustomer(any())),
    );

    blocTest<CustomerDetailCubit, CustomerDetailState>(
      'confirming deletes through the repository once',
      setUp: () =>
          when(() => customers.deleteCustomer(5)).thenAnswer((_) async {}),
      build: build,
      seed: () => loaded.copyWith(
        deletionStep: CustomerDeletionStep.confirming,
        deletionImpact: impact,
      ),
      act: (cubit) async {
        await cubit.confirmDeletion();
        await cubit.confirmDeletion(); // ignored: not confirming anymore
      },
      expect: () => [
        loaded.copyWith(deletionStep: CustomerDeletionStep.deleting),
        loaded.copyWith(deletionStep: CustomerDeletionStep.deleted),
      ],
      verify: (_) => verify(() => customers.deleteCustomer(5)).called(1),
    );

    blocTest<CustomerDetailCubit, CustomerDetailState>(
      'confirm without a pending confirmation does nothing',
      build: build,
      seed: () => loaded,
      act: (cubit) => cubit.confirmDeletion(),
      expect: () => <CustomerDetailState>[],
      verify: (_) => verifyNever(() => customers.deleteCustomer(any())),
    );

    blocTest<CustomerDetailCubit, CustomerDetailState>(
      'a failed delete returns to idle and reports the error',
      setUp: () =>
          when(() => customers.deleteCustomer(5))
              .thenThrow(const DatabaseException('locked')),
      build: build,
      seed: () => loaded.copyWith(
        deletionStep: CustomerDeletionStep.confirming,
        deletionImpact: impact,
      ),
      act: (cubit) => cubit.confirmDeletion(),
      expect: () => [
        loaded.copyWith(deletionStep: CustomerDeletionStep.deleting),
        isA<CustomerDetailState>()
            .having((s) => s.deletionStep, 'step', CustomerDeletionStep.idle)
            .having(
              (s) => s.deletionFailure,
              'failure',
              isA<DatabaseException>(),
            ),
      ],
    );

    blocTest<CustomerDetailCubit, CustomerDetailState>(
      'impact loading errors are reported and nothing is deleted',
      setUp: () =>
          when(() => customers.getDeletionImpact(5))
              .thenThrow(const NotFoundException('Customer', 5)),
      build: build,
      seed: () => loaded,
      act: (cubit) => cubit.requestDeletion(),
      verify: (cubit) {
        expect(cubit.state.deletionStep, CustomerDeletionStep.idle);
        expect(cubit.state.deletionFailure, isA<NotFoundException>());
        verifyNever(() => customers.deleteCustomer(any()));
      },
    );

    test('the impact survives stream updates while confirming', () async {
      final customerStream = StreamController<Customer?>();
      stubStreams(customerStream: customerStream.stream);
      when(() => customers.getDeletionImpact(5))
          .thenAnswer((_) async => impact);

      final cubit = build()..load();
      customerStream.add(customer);
      await Future<void>.delayed(Duration.zero);
      await cubit.requestDeletion();

      customerStream.add(testCustomer(id: 5, last: 'Güncel'));
      await Future<void>.delayed(Duration.zero);

      expect(cubit.state.customer!.lastName, 'Güncel');
      expect(cubit.state.deletionImpact, impact);
      await cubit.close();
      await customerStream.close();
    });

    test(
      'after deletion the null customer does not flip to notFound',
      () async {
        final customerStream = StreamController<Customer?>();
        stubStreams(customerStream: customerStream.stream);
        when(() => customers.getDeletionImpact(5))
            .thenAnswer((_) async => impact);
        when(() => customers.deleteCustomer(5)).thenAnswer((_) async {});

        final cubit = build()..load();
        customerStream.add(customer);
        await Future<void>.delayed(Duration.zero);
        await cubit.requestDeletion();
        await cubit.confirmDeletion();
        customerStream.add(null);
        await Future<void>.delayed(Duration.zero);

        expect(cubit.state.deletionStep, CustomerDeletionStep.deleted);
        expect(cubit.state.status, CustomerDetailStatus.success);
        await cubit.close();
        await customerStream.close();
      },
    );
  });

  test('close cancels both repository subscriptions', () async {
    final customerStream = StreamController<Customer?>();
    final deviceStream = StreamController<List<DeviceMaintenanceOverview>>();
    stubStreams(
      customerStream: customerStream.stream,
      deviceStream: deviceStream.stream,
    );

    final cubit = build()..load();
    expect(customerStream.hasListener, isTrue);
    expect(deviceStream.hasListener, isTrue);

    await cubit.close();

    expect(customerStream.hasListener, isFalse);
    expect(deviceStream.hasListener, isFalse);
    await customerStream.close();
    await deviceStream.close();
  });
}
