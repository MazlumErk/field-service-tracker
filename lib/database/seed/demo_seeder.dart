import 'package:drift/drift.dart';
import 'package:field_service_tracker/core/clock/app_clock.dart';
import 'package:field_service_tracker/core/utils/calendar_date.dart';
import 'package:field_service_tracker/database/app_database.dart';
import 'package:field_service_tracker/features/customers/domain/customer_draft.dart';
import 'package:field_service_tracker/features/maintenance/domain/filter_type.dart';
import 'package:field_service_tracker/features/maintenance/domain/maintenance_schedule.dart';

/// Creates the fictional demo data set.
///
/// * **Deterministic:** no randomness; the same clock date always produces
///   identical rows (ids included).
/// * **Relative dates:** the *next* maintenance date of every device is an
///   offset from today, so a fresh install always shows overdue, due-today,
///   upcoming, scheduled and never-serviced devices.
/// * **Fictional only:** names are generic combinations, phone numbers use
///   the unassigned `0500 000 00 xx` pattern, streets are invented.
class DemoSeeder {
  const DemoSeeder(this._clock);

  final AppClock _clock;

  /// Pass as `AppDatabase.seeder`.
  Future<void> call(AppDatabase database) => seed(database);

  Future<void> seed(AppDatabase database) {
    final today = CalendarDate.today(_clock);
    final now = _clock.now().toUtc();
    final data = buildDemoData(today: today, now: now);

    return database.transaction(() async {
      await database.batch((batch) {
        batch
          ..insertAll(database.customers, data.customers)
          ..insertAll(database.devices, data.devices)
          ..insertAll(database.maintenanceRecords, data.records)
          ..insertAll(database.filterReplacements, data.filters);
      });
    });
  }
}

/// Rows of the demo data set. Exposed for tests.
typedef DemoData = ({
  List<CustomersCompanion> customers,
  List<DevicesCompanion> devices,
  List<MaintenanceRecordsCompanion> records,
  List<FilterReplacementsCompanion> filters,
});

/// Device plan: owner index and next-maintenance offset from today in days
/// (`null` = never serviced).
typedef _DevicePlan = ({int customer, int? nextInDays});

const List<String> _firstNames = [
  'Ahmet', 'Ayşe', 'Mehmet', 'Fatma', 'Mustafa', //
  'Emine', 'Ali', 'Zeynep', 'Hüseyin', 'Elif',
  'İbrahim', 'Hatice', 'Murat', 'Merve', 'Ömer',
  'Şeyma', 'Can', 'Gül', 'Emre', 'Özlem',
];

const List<String> _lastNames = [
  'Yılmaz', 'Kaya', 'Demir', 'Şahin', 'Çelik', //
  'Yıldız', 'Yıldırım', 'Öztürk', 'Aydın', 'Özdemir',
  'Arslan', 'Doğan', 'Kılıç', 'Aslan', 'Çetin',
  'Kara', 'Koç', 'Kurt', 'Özkan', 'Şimşek',
];

const List<String> _streets = [
  'Lale', 'Papatya', 'Menekşe', 'Gelincik', 'Zambak', //
  'Nergis', 'Sümbül', 'Karanfil', 'Orkide', 'Manolya',
];

const List<String> _districts = [
  'Kadıköy/İstanbul', 'Çankaya/Ankara', 'Bornova/İzmir', //
  'Nilüfer/Bursa', 'Muratpaşa/Antalya',
];

const List<String> _models = [
  'AquaPure RO-5', 'ClearFlow 7', 'HydroLine Mini', //
  'PureStream Pro', 'Crystal RO-6',
];

const List<String?> _notes = [
  'Rutin bakım yapıldı.',
  null,
  'Su basıncı kontrol edildi, normal.',
  'Tank temizliği yapıldı.',
  null,
];

/// 28 devices over 20 customers; customer #20 has none (empty state).
/// Offsets cover: overdue (-60, -20, -5, -1), due today (0), within 7 days
/// (2, 5, 7), within 30 days (12, 20, 30), scheduled (31 … 160) and never
/// serviced (`null`).
const List<_DevicePlan> _devicePlans = [
  (customer: 0, nextInDays: -20),
  (customer: 0, nextInDays: 120),
  (customer: 1, nextInDays: 0),
  (customer: 2, nextInDays: 5),
  (customer: 2, nextInDays: null),
  (customer: 3, nextInDays: -60),
  (customer: 4, nextInDays: 12),
  (customer: 4, nextInDays: 45),
  (customer: 4, nextInDays: 160),
  (customer: 5, nextInDays: 30),
  (customer: 6, nextInDays: 31),
  (customer: 7, nextInDays: null),
  (customer: 8, nextInDays: -1),
  (customer: 8, nextInDays: 2),
  (customer: 9, nextInDays: 75),
  (customer: 10, nextInDays: 7),
  (customer: 10, nextInDays: 20),
  (customer: 11, nextInDays: -5),
  (customer: 12, nextInDays: 0),
  (customer: 12, nextInDays: 160),
  (customer: 13, nextInDays: 45),
  (customer: 14, nextInDays: null),
  (customer: 15, nextInDays: 120),
  (customer: 15, nextInDays: -20),
  (customer: 16, nextInDays: 12),
  (customer: 17, nextInDays: 31),
  (customer: 17, nextInDays: 75),
  (customer: 18, nextInDays: 2),
];

/// Number of demo customers.
const int demoCustomerCount = 20;

/// Builds all demo rows for [today]. Pure function → easy to test.
DemoData buildDemoData({required CalendarDate today, required DateTime now}) {
  final customers = <CustomersCompanion>[];
  for (var i = 0; i < demoCustomerCount; i++) {
    final number = 'FST-${(i + 1).toString().padLeft(4, '0')}';
    final draft = CustomerDraft(
      customerNumber: number,
      firstName: _firstNames[i],
      lastName: _lastNames[i],
      // Every 4th customer has no phone, every 5th no address (optional data).
      phone: i % 4 == 3
          ? null
          : '0500 000 00 ${(i + 1).toString().padLeft(2, '0')}',
      address: i % 5 == 4
          ? null
          : 'Demo Mah. ${_streets[i % _streets.length]} Sk. '
                'No: ${i * 3 + 1}, ${_districts[i % _districts.length]}',
    );
    final createdAt = now.subtract(Duration(days: 400 - i * 7));
    customers.add(
      CustomersCompanion.insert(
        id: Value(i + 1),
        customerNumber: draft.customerNumber,
        firstName: draft.firstName,
        lastName: draft.lastName,
        phone: Value(draft.phone),
        address: Value(draft.address),
        searchKey: draft.searchKey,
        createdAt: createdAt,
        updatedAt: createdAt,
      ),
    );
  }

  final devices = <DevicesCompanion>[];
  final records = <MaintenanceRecordsCompanion>[];
  final filters = <FilterReplacementsCompanion>[];
  var recordId = 0;

  for (var d = 0; d < _devicePlans.length; d++) {
    final plan = _devicePlans[d];
    final deviceId = d + 1;

    // Visits are 6 months apart, ending with the one whose next date is
    // today + offset. 1–4 visits per device.
    final visits = <CalendarDate>[];
    final offset = plan.nextInDays;
    if (offset != null) {
      final visitCount = d % 4 + 1;
      var visit = today
          .addDays(offset)
          .addMonths(-MaintenanceSchedule.defaultIntervalMonths);
      for (var v = 0; v < visitCount; v++) {
        visits.insert(0, visit);
        visit = visit.addMonths(-MaintenanceSchedule.defaultIntervalMonths);
      }
    }

    final installedAt = visits.isEmpty
        ? today.addDays(-(d * 10 + 5))
        : visits.first.addDays(-14);

    devices.add(
      DevicesCompanion.insert(
        id: Value(deviceId),
        customerId: plan.customer + 1,
        model: _models[d % _models.length],
        serialNumber: Value(d % 3 == 2 ? null : 'DEMO-${1000 + deviceId}'),
        installedAt: installedAt,
        createdAt: installedAt.toUtcDateTime().add(const Duration(hours: 9)),
      ),
    );

    for (var v = 0; v < visits.length; v++) {
      recordId++;
      final date = visits[v];
      final isLast = v == visits.length - 1;
      final next = isLast ? today.addDays(offset!) : visits[v + 1];
      records.add(
        MaintenanceRecordsCompanion.insert(
          id: Value(recordId),
          deviceId: deviceId,
          maintenanceDate: date,
          nextMaintenanceDate: next,
          priceKurus: 45000 + (recordId % 5) * 15000,
          notes: Value(_notes[recordId % _notes.length]),
          createdAt: date.toUtcDateTime().add(const Duration(hours: 10)),
        ),
      );
      for (final type in _filtersForVisit(recordId)) {
        filters.add(
          FilterReplacementsCompanion.insert(
            maintenanceRecordId: recordId,
            filterType: type,
          ),
        );
      }
    }
  }

  return (
    customers: customers,
    devices: devices,
    records: records,
    filters: filters,
  );
}

/// Sediment is changed every visit; carbon filters often; membrane yearly.
List<FilterType> _filtersForVisit(int recordId) => switch (recordId % 3) {
  0 => FilterType.values,
  1 => const [FilterType.sediment, FilterType.cto, FilterType.gac],
  _ => const [FilterType.sediment, FilterType.post],
};
