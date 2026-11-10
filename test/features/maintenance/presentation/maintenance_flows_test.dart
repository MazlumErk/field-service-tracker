import 'package:field_service_tracker/app/router/app_routes.dart';
import 'package:field_service_tracker/core/utils/calendar_date.dart';
import 'package:field_service_tracker/database/app_database.dart';
import 'package:field_service_tracker/features/maintenance/presentation/widgets/maintenance_record_card.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../../helpers/pump_app.dart';

/// Core maintenance flows on the seeded demo data (today: 15 Jan 2026).
/// Device #6 (Fatma Şahin, "AquaPure RO-5") is 60 days overdue, 2 visits.
void main() {
  Finder appBarTitle(String text) =>
      find.descendant(of: find.byType(AppBar), matching: find.text(text));

  Finder save() => find.byKey(const ValueKey('maintenanceFormSave'));

  Future<AppDatabase> openForm(WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final db = await tester.pumpApp(
      location: AppRoutes.deviceDetail(6),
      seed: true,
    );
    expect(find.text('Gecikti'), findsOneWidget);
    await tester.tap(find.text('Yeni bakım ekle'));
    await tester.pumpAndSettle();
    expect(appBarTitle('Yeni Bakım Kaydı'), findsOneWidget);
    return db;
  }

  testAppWidgets('device → new maintenance → save updates history and status', (
    tester,
  ) async {
    final db = await openForm(tester);

    // Header + defaults (today, today + 6 months).
    expect(find.text('AquaPure RO-5'), findsOneWidget);
    expect(find.text('Fatma Şahin · FST-0004'), findsOneWidget);
    expect(find.text('15 Oca 2026'), findsOneWidget);
    expect(find.text('15 Tem 2026'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('maintenanceFilter-sediment')));
    await tester.tap(find.byKey(const ValueKey('maintenanceFilter-membrane')));
    await tester.enterText(
      find.byKey(const ValueKey('maintenanceField-price')),
      '1.250,50',
    );
    await tester.enterText(
      find.byKey(const ValueKey('maintenanceField-notes')),
      'Membran değişti',
    );
    await tester.tap(save());
    await tester.pumpAndSettle();

    // Back on the device detail: new record on top, status recalculated.
    expect(appBarTitle('Cihaz Detayı'), findsOneWidget);
    expect(find.text('Bakım kaydedildi.'), findsOneWidget);
    expect(find.text('Bakım geçmişi (3)'), findsOneWidget);
    expect(find.text('Planlandı'), findsOneWidget);
    expect(find.text('181 gün kaldı'), findsOneWidget);

    final newest = tester
        .widgetList<MaintenanceRecordCard>(find.byType(MaintenanceRecordCard))
        .first
        .record;
    expect(newest.maintenanceDate, CalendarDate(2026, 1, 15));
    expect(newest.priceKurus, 125050);
    expect(find.text('₺1.250,50'), findsOneWidget);
    expect(find.text('Membran değişti'), findsOneWidget);
    expect(find.text('Membran'), findsWidgets);

    final rows = await (db.select(
      db.maintenanceRecords,
    )..where((r) => r.deviceId.equals(6))).get();
    expect(rows, hasLength(3));
  });

  testAppWidgets('invalid input shows Turkish errors and saves nothing', (
    tester,
  ) async {
    await openForm(tester);

    await tester.enterText(
      find.byKey(const ValueKey('maintenanceField-price')),
      '12,345',
    );
    await tester.tap(save());
    await tester.pumpAndSettle();

    expect(find.text('En az bir filtre seçin.'), findsOneWidget);
    expect(
      find.text('Geçerli bir tutar girin (örn. 1.250,50).'),
      findsOneWidget,
    );
    expect(appBarTitle('Yeni Bakım Kaydı'), findsOneWidget);
  });

  testAppWidgets('unsaved changes: selecting a filter then back asks first', (
    tester,
  ) async {
    await openForm(tester);

    // Untouched form leaves without a dialog.
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(appBarTitle('Cihaz Detayı'), findsOneWidget);

    await tester.tap(find.text('Yeni bakım ekle'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('maintenanceFilter-gac')));
    await tester.pump();

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.text('Kaydedilmemiş değişiklikler'), findsOneWidget);
    await tester.tap(find.text('Vazgeç'));
    await tester.pumpAndSettle();
    expect(appBarTitle('Yeni Bakım Kaydı'), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Değişiklikleri At'));
    await tester.pumpAndSettle();
    expect(appBarTitle('Cihaz Detayı'), findsOneWidget);
    expect(find.text('Bakım geçmişi (2)'), findsOneWidget);
  });

  testAppWidgets('form does not overflow at 2x text on 320x568', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    await tester.pumpApp(location: AppRoutes.maintenanceNew(6), seed: true);
    expect(tester.takeException(), isNull);
    await tester.drag(find.byType(ListView).last, const Offset(0, -3000));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
