import 'package:field_service_tracker/app/router/app_routes.dart';
import 'package:field_service_tracker/database/app_database.dart';
import 'package:field_service_tracker/features/customers/data/drift_customer_repository.dart';
import 'package:field_service_tracker/features/maintenance/presentation/widgets/maintenance_overview_tile.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../../helpers/pump_app.dart';

/// Seeded demo data on 15 Jan 2026: 20 customers, 28 devices,
/// 5 overdue, 10 upcoming, 10 scheduled, 3 without records.
/// The oldest overdue device is #6 (Fatma Şahin, −60 days).
void main() {
  Finder appBarTitle(String text) =>
      find.descendant(of: find.byType(AppBar), matching: find.text(text));

  int kpi(WidgetTester tester, String key) => int.parse(
    tester
        .widget<Text>(
          find.descendant(
            of: find.byKey(ValueKey(key)),
            matching: find.byWidgetPredicate(
              (w) => w is Text && int.tryParse(w.data ?? '') != null,
            ),
          ),
        )
        .data!,
  );

  Future<AppDatabase> pumpTall(WidgetTester tester, String location) {
    tester.view.physicalSize = const Size(800, 2600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    return tester.pumpApp(location: location, seed: true);
  }

  testAppWidgets('KPIs, priority list → device, see all → overdue filter', (
    tester,
  ) async {
    await pumpTall(tester, AppRoutes.dashboard);

    expect(kpi(tester, 'kpiCustomers'), 20);
    expect(kpi(tester, 'kpiDevices'), 28);
    expect(kpi(tester, 'kpiOverdue'), 5);
    expect(kpi(tester, 'kpiUpcoming'), 10);
    expect(find.text('15 öncelikli bakımdan 5 tanesi gösteriliyor'), findsOne);

    // First priority row = oldest overdue.
    final first = find.byType(MaintenanceOverviewTile).first;
    expect(
      find.descendant(of: first, matching: find.text('60 gün gecikti')),
      findsOneWidget,
    );
    await tester.tap(first);
    await tester.pumpAndSettle();
    expect(appBarTitle('Cihaz Detayı'), findsOneWidget);
    expect(find.text('Fatma Şahin'), findsOneWidget);
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('dashboardSeeAll')));
    await tester.pumpAndSettle();
    expect(appBarTitle('Bakımlar'), findsOneWidget);
    expect(find.text('Tümü (28)'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('maintenanceFilter-overdue')));
    await tester.pumpAndSettle();
    expect(find.byType(MaintenanceOverviewTile), findsNWidgets(5));
    expect(find.text('Yaklaşıyor'), findsNothing);

    // The chip row scrolls horizontally; bring the last chip into view.
    final noRecordChip = find.byKey(
      const ValueKey('maintenanceFilter-noMaintenance'),
    );
    await tester.ensureVisible(noRecordChip);
    await tester.pumpAndSettle();
    await tester.tap(noRecordChip);
    await tester.pumpAndSettle();
    expect(find.byType(MaintenanceOverviewTile), findsNWidgets(3));
  });

  testAppWidgets(
    'new maintenance and deleting a customer update the dashboard',
    (tester) async {
      final db = await pumpTall(tester, AppRoutes.dashboard);
      expect(kpi(tester, 'kpiOverdue'), 5);

      // Record a visit for the oldest overdue device (#6).
      await tester.tap(find.byType(MaintenanceOverviewTile).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Yeni bakım ekle'));
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(const ValueKey('maintenanceFilter-sediment')),
      );
      await tester.enterText(
        find.byKey(const ValueKey('maintenanceField-price')),
        '500',
      );
      await tester.tap(find.byKey(const ValueKey('maintenanceFormSave')));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();

      expect(appBarTitle('Genel Bakış'), findsOneWidget);
      expect(kpi(tester, 'kpiOverdue'), 4);
      expect(kpi(tester, 'kpiDevices'), 28);

      // Customer #5 owns devices due in 12, 45 and 160 days (1 upcoming).
      await tester.runAsync(
        () => DriftCustomerRepository(db, testClock).deleteCustomer(5),
      );
      await tester.pumpAndSettle();
      expect(kpi(tester, 'kpiCustomers'), 19);
      expect(kpi(tester, 'kpiDevices'), 25);
      expect(kpi(tester, 'kpiUpcoming'), 9);
    },
  );

  testAppWidgets('dashboard and list do not overflow at 2x on 320x568', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    await tester.pumpApp(seed: true);
    expect(tester.takeException(), isNull);
    await tester.drag(find.byType(ListView).first, const Offset(0, -3000));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    await tester.tap(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text('Bakımlar'),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
