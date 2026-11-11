import 'dart:async';

import 'package:field_service_tracker/core/clock/day_tracker.dart';
import 'package:field_service_tracker/core/errors/app_exception.dart';
import 'package:field_service_tracker/core/utils/calendar_date.dart';
import 'package:field_service_tracker/features/dashboard/presentation/cubit/dashboard_cubit.dart';
import 'package:field_service_tracker/features/dashboard/presentation/cubit/dashboard_state.dart';
import 'package:field_service_tracker/features/maintenance/domain/device_maintenance_overview.dart';
import 'package:field_service_tracker/features/maintenance/domain/maintenance_status.dart';
import 'package:field_service_tracker/features/maintenance/presentation/cubit/maintenance_list_cubit.dart';
import 'package:field_service_tracker/features/maintenance/presentation/cubit/maintenance_list_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/mocks.dart';

/// [TodayProvider] whose day the test changes explicitly.
final class _FakeToday implements TodayProvider {
  _FakeToday(this.today);

  final _controller = StreamController<CalendarDate>.broadcast();

  @override
  CalendarDate today;

  @override
  Stream<CalendarDate> get changes => _controller.stream;

  void advanceTo(CalendarDate day) {
    today = day;
    _controller.add(day);
  }
}

/// DashboardCubit and MaintenanceListCubit on the same mocked overview
/// stream (sorting/counting rules themselves: maintenance_overview_rules
/// test).
void main() {
  final day = CalendarDate(2026, 1, 15);
  late MockCustomerRepository customers;
  late MockMaintenanceRepository maintenance;
  late StreamController<List<DeviceMaintenanceOverview>> overviews;
  late StreamController<int> customerCount;
  late _FakeToday today;

  DeviceMaintenanceOverview device(int id, int? nextInDays) => testOverview(
    deviceId: id,
    next: nextInDays == null ? null : day.addDays(nextInDays),
  );

  setUp(() {
    customers = MockCustomerRepository();
    maintenance = MockMaintenanceRepository();
    overviews = StreamController();
    customerCount = StreamController();
    today = _FakeToday(day);
    when(maintenance.watchOverview).thenAnswer((_) => overviews.stream);
    when(customers.watchCustomerCount).thenAnswer((_) => customerCount.stream);
  });

  // Not awaited: close() of a never-listened controller never completes.
  tearDown(() {
    unawaited(overviews.close());
    unawaited(customerCount.close());
  });

  Future<void> settle() => Future<void>.delayed(Duration.zero);

  group('DashboardCubit', () {
    DashboardCubit build() => DashboardCubit(
      customerRepository: customers,
      maintenanceRepository: maintenance,
      today: today,
      priorityLimit: 2,
    )..load();

    test('totals, status counts and a limited priority list', () async {
      final cubit = build();
      customerCount.add(3);
      overviews.add([
        device(1, 40),
        device(2, 5),
        device(3, -10),
        device(4, null),
        device(5, 0),
      ]);
      await settle();

      final state = cubit.state;
      expect(state.status, DashboardStatus.success);
      expect(state.customerCount, 3);
      expect(state.deviceCount, 5);
      expect(state.statusCounts.overdue, 1);
      expect(state.statusCounts.upcoming, 2);
      expect(state.priority.map((o) => o.device.id), [3, 5]);
      expect(state.priorityTotal, 3);
      await cubit.close();
    });

    test('waits for both sources and reports empty data', () async {
      final cubit = build();
      overviews.add(const []);
      await settle();
      expect(cubit.state.status, DashboardStatus.loading);

      customerCount.add(0);
      await settle();
      expect(cubit.state.isEmpty, isTrue);
      await cubit.close();
    });

    test('re-emits on new data (e.g. a new maintenance record)', () async {
      final cubit = build();
      customerCount.add(1);
      overviews.add([device(1, -3)]);
      await settle();
      expect(cubit.state.statusCounts.overdue, 1);

      overviews.add([device(1, 182)]); // latest record now scheduled
      await settle();
      expect(cubit.state.statusCounts.overdue, 0);
      expect(cubit.state.priority, isEmpty);
      await cubit.close();
    });

    test('a day change recomputes statuses without new data', () async {
      final cubit = build();
      customerCount.add(1);
      overviews.add([device(1, 0)]);
      await settle();
      expect(cubit.state.statusCounts.upcoming, 1);

      today.advanceTo(day.addDays(1));
      await settle();
      expect(cubit.state.today, day.addDays(1));
      expect(cubit.state.statusCounts.overdue, 1);
      expect(cubit.state.statusCounts.upcoming, 0);
      await cubit.close();
    });

    test('stream errors become failure', () async {
      final cubit = build();
      overviews.addError(const DatabaseException('x'));
      await settle();
      expect(cubit.state.status, DashboardStatus.failure);
      await cubit.close();
    });

    test('close cancels all three subscriptions', () async {
      final cubit = build();
      expect(overviews.hasListener, isTrue);
      expect(customerCount.hasListener, isTrue);
      await cubit.close();
      expect(overviews.hasListener, isFalse);
      expect(customerCount.hasListener, isFalse);
      // Day changes after close are ignored without errors.
      today.advanceTo(day.addDays(2));
      await settle();
    });
  });

  group('MaintenanceListCubit', () {
    MaintenanceListCubit build() =>
        MaintenanceListCubit(maintenanceRepository: maintenance, today: today)
          ..load();

    final data = [
      device(1, 40),
      device(2, 5),
      device(3, -10),
      device(4, null),
      device(5, -30),
    ];

    test('all devices once, in priority order, with counts', () async {
      final cubit = build();
      overviews.add(data);
      await settle();

      expect(cubit.state.items.map((o) => o.device.id), [5, 3, 2, 1, 4]);
      expect(cubit.state.counts.total, 5);
      expect(cubit.state.counts.overdue, 2);
      await cubit.close();
    });

    test('filters by status and back to all', () async {
      final cubit = build();
      overviews.add(data);
      await settle();

      cubit.filterSelected(MaintenanceStatus.overdue);
      expect(cubit.state.items.map((o) => o.device.id), [5, 3]);
      cubit.filterSelected(MaintenanceStatus.noMaintenance);
      expect(cubit.state.items.map((o) => o.device.id), [4]);
      cubit.filterSelected(null);
      expect(cubit.state.items, hasLength(5));
      expect(cubit.state.counts.overdue, 2, reason: 'counts ignore filter');
      await cubit.close();
    });

    test('empty filter vs. no devices', () async {
      final cubit = build();
      overviews.add([device(1, 40)]);
      await settle();
      cubit.filterSelected(MaintenanceStatus.overdue);
      expect(cubit.state.isFilterEmpty, isTrue);
      expect(cubit.state.hasNoDevices, isFalse);

      overviews.add(const []);
      await settle();
      expect(cubit.state.hasNoDevices, isTrue);
      await cubit.close();
    });

    test('a day change moves devices between filters', () async {
      final cubit = build();
      overviews.add([device(1, 0)]);
      await settle();
      cubit.filterSelected(MaintenanceStatus.overdue);
      expect(cubit.state.items, isEmpty);

      today.advanceTo(day.addDays(1));
      await settle();
      expect(cubit.state.items.single.device.id, 1);
      expect(cubit.state.filter, MaintenanceStatus.overdue);
      await cubit.close();
    });

    test('close cancels the overview subscription', () async {
      final cubit = build();
      expect(overviews.hasListener, isTrue);
      await cubit.close();
      expect(overviews.hasListener, isFalse);
      expect(MaintenanceListStatus.values, hasLength(3));
    });
  });
}
