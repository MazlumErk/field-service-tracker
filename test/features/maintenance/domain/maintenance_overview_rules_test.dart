import 'package:field_service_tracker/core/utils/calendar_date.dart';
import 'package:field_service_tracker/features/devices/domain/device.dart';
import 'package:field_service_tracker/features/maintenance/domain/device_maintenance_overview.dart';
import 'package:field_service_tracker/features/maintenance/domain/maintenance_overview_rules.dart';
import 'package:flutter_test/flutter_test.dart';

final _today = CalendarDate(2026, 1, 15);

DeviceMaintenanceOverview _device(
  int id,
  int? nextInDays, {
  String first = 'Ali',
  String last = 'Kaya',
  String model = 'AquaPure',
}) => DeviceMaintenanceOverview(
  device: Device(
    id: id,
    customerId: id,
    model: model,
    installedAt: CalendarDate(2024, 1, 1),
    createdAt: DateTime.utc(2024),
  ),
  customerId: id,
  customerNumber: 'FST-$id',
  customerFirstName: first,
  customerLastName: last,
  lastMaintenanceDate: nextInDays == null
      ? null
      : _today.addDays(nextInDays).addMonths(-6),
  nextMaintenanceDate: nextInDays == null ? null : _today.addDays(nextInDays),
);

void main() {
  test('counts each device once with the 0 / 30 / 31 day boundaries', () {
    final overviews = [
      _device(1, -1), // overdue
      _device(2, 0), // upcoming (today)
      _device(3, 30), // upcoming (last day)
      _device(4, 31), // scheduled
      _device(5, null), // no record
    ];
    expect(
      MaintenanceOverviewRules.count(overviews, _today),
      const MaintenanceStatusCounts(
        overdue: 1,
        upcoming: 2,
        scheduled: 1,
        noMaintenance: 1,
      ),
    );
    // The next day the "today" device becomes overdue and the day-31
    // device enters the 30-day window.
    final tomorrow = MaintenanceOverviewRules.count(
      overviews,
      _today.addDays(1),
    );
    expect(tomorrow.overdue, 2);
    expect(tomorrow.upcoming, 2);
    expect(tomorrow.scheduled, 0);
  });

  test(
    'priority order: overdue oldest first, then upcoming, scheduled, none',
    () {
      final sorted = MaintenanceOverviewRules.sortByPriority([
        _device(1, 45),
        _device(2, null, first: 'Zeynep', last: 'Yıldız'),
        _device(3, 3),
        _device(4, -2),
        _device(5, null, first: 'Can', last: 'Çelik'),
        _device(6, -40),
        _device(7, 0),
        _device(8, 31),
      ], _today);

      expect(sorted.map((o) => o.device.id), [6, 4, 7, 3, 8, 1, 5, 2]);
    },
  );

  test('priority keeps only overdue and upcoming devices', () {
    final priority = MaintenanceOverviewRules.priority([
      _device(1, 45),
      _device(2, 10),
      _device(3, -5),
      _device(4, null),
    ], _today);
    expect(priority.map((o) => o.device.id), [3, 2]);
  });
}
