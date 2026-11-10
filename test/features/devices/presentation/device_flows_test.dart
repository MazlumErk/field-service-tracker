import 'dart:async';

import 'package:field_service_tracker/app/router/app_routes.dart';
import 'package:field_service_tracker/core/utils/calendar_date.dart';
import 'package:field_service_tracker/database/app_database.dart';
import 'package:field_service_tracker/features/maintenance/presentation/widgets/device_overview_tile.dart';
import 'package:field_service_tracker/features/maintenance/presentation/widgets/maintenance_record_card.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../helpers/pump_app.dart';

/// End-to-end device flows on the seeded demo database (today: 15 Jan 2026).
///
/// Demo devices used below (see `DemoSeeder`):
/// * #3  customer #2   next maintenance today            → due today
/// * #5  customer #3   never serviced                   → no maintenance
/// * #6  customer #4   next −60 days, 2 visits          → overdue
/// * #7  customer #5   next +12 days, 3 visits          → upcoming
/// * #8  customer #5   "HydroLine Mini", next +45 days, 4 visits → scheduled
/// * customer #20 Özlem Şimşek has no devices
void main() {
  Finder appBarTitle(String text) =>
      find.descendant(of: find.byType(AppBar), matching: find.text(text));

  Finder save() => find.byKey(const ValueKey('deviceFormSave'));

  Future<int> deviceCount(AppDatabase db, {int? customerId}) async {
    final rows = await db.select(db.devices).get();
    return customerId == null
        ? rows.length
        : rows.where((d) => d.customerId == customerId).length;
  }

  void useTallView(WidgetTester tester) {
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
  }

  group('Add device', () {
    testAppWidgets('customer → add device → save → device detail', (
      tester,
    ) async {
      final db = await tester.pumpApp(
        location: AppRoutes.customerDetail(20),
        seed: true,
      );
      expect(find.text('Cihazlar (0)'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('customerAddDevice')));
      await tester.pumpAndSettle();
      expect(appBarTitle('Yeni Cihaz'), findsOneWidget);
      // Installation date defaults to today.
      expect(find.text('15 Oca 2026'), findsOneWidget);

      await tester.enterText(
        find.byKey(const ValueKey('deviceField-model')),
        'AquaPure X1',
      );
      await tester.tap(save());
      await tester.pumpAndSettle();

      expect(appBarTitle('Cihaz Detayı'), findsOneWidget);
      expect(find.text('AquaPure X1'), findsOneWidget);
      expect(find.text('Seri numarası belirtilmemiş'), findsOneWidget);
      expect(find.text('Bakım Kaydı Yok'), findsOneWidget);
      expect(find.text('Henüz bakım kaydı yok'), findsOneWidget);
      expect(find.text('Cihaz kaydedildi.'), findsOneWidget);
      expect(await deviceCount(db, customerId: 20), 1);

      // Back goes to the customer, whose device list updated itself.
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      expect(appBarTitle('Müşteri Detayı'), findsOneWidget);
      expect(find.text('Cihazlar (1)'), findsOneWidget);
      expect(find.byType(DeviceOverviewTile), findsOneWidget);
    });

    testAppWidgets('missing model shows an inline error and saves nothing', (
      tester,
    ) async {
      final db = await tester.pumpApp(
        location: AppRoutes.deviceNew(20),
        seed: true,
      );
      await tester.tap(save());
      await tester.pumpAndSettle();

      expect(
        find.descendant(
          of: find.byKey(const ValueKey('deviceField-model')),
          matching: find.text('Bu alan zorunludur.'),
        ),
        findsOneWidget,
      );
      expect(await deviceCount(db, customerId: 20), 0);
    });

    testAppWidgets('installation date is picked with the Turkish picker', (
      tester,
    ) async {
      await tester.pumpApp(location: AppRoutes.deviceNew(20), seed: true);

      await tester.tap(find.byKey(const ValueKey('deviceField-installedAt')));
      await tester.pumpAndSettle();
      expect(find.byType(DatePickerDialog), findsOneWidget);
      expect(find.text('Ocak 2026'), findsOneWidget);

      await tester.tap(find.text('10'));
      await tester.tap(find.text('Tamam'));
      await tester.pumpAndSettle();

      expect(find.byType(DatePickerDialog), findsNothing);
      expect(find.text('10 Oca 2026'), findsOneWidget);
    });

    testAppWidgets('rapid double tap on save creates a single device', (
      tester,
    ) async {
      final db = await tester.pumpApp(
        location: AppRoutes.deviceNew(20),
        seed: true,
      );
      await tester.enterText(
        find.byKey(const ValueKey('deviceField-model')),
        'Twice',
      );
      await tester.tap(save());
      await tester.tap(save(), warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(await deviceCount(db, customerId: 20), 1);
    });
  });

  group('Device detail', () {
    testAppWidgets('shows device, owner, dates and history newest first', (
      tester,
    ) async {
      useTallView(tester);
      await tester.pumpApp(location: AppRoutes.deviceDetail(8), seed: true);

      expect(find.text('HydroLine Mini'), findsOneWidget);
      expect(find.text('Seri no: DEMO-1008'), findsOneWidget);
      expect(find.text('Mustafa Çelik'), findsOneWidget);
      expect(find.text('Müşteri numarası: FST-0005'), findsOneWidget);
      expect(find.text('Planlandı'), findsOneWidget);
      expect(find.text('45 gün kaldı'), findsOneWidget);
      expect(find.text('Bakım geçmişi (4)'), findsOneWidget);

      final dates = tester
          .widgetList<MaintenanceRecordCard>(find.byType(MaintenanceRecordCard))
          .map((card) => card.record.maintenanceDate)
          .toList();
      expect(dates, [
        CalendarDate(2025, 9, 1),
        CalendarDate(2025, 3, 1),
        CalendarDate(2024, 9, 1),
        CalendarDate(2024, 3, 1),
      ]);
      // Price, filters and next date are rendered on the cards.
      expect(find.textContaining('₺'), findsNWidgets(4));
      expect(find.text('Sediment'), findsNWidgets(4));
      expect(find.text('Sonraki bakım: 1 Mar 2026'), findsOneWidget);
    });

    for (final (id, status, detail) in [
      (6, 'Gecikti', '60 gün gecikti'),
      (7, 'Yaklaşıyor', '12 gün kaldı'),
      (3, 'Yaklaşıyor', 'Bakım bugün'),
      (5, 'Bakım Kaydı Yok', 'Bu cihaz için henüz bakım yapılmadı'),
    ]) {
      testAppWidgets('device #$id shows "$status" / "$detail"', (tester) async {
        useTallView(tester);
        await tester.pumpApp(location: AppRoutes.deviceDetail(id), seed: true);
        expect(find.text(status), findsOneWidget);
        expect(find.text(detail), findsOneWidget);
      });
    }

    testAppWidgets('device without records shows the empty history state', (
      tester,
    ) async {
      useTallView(tester);
      await tester.pumpApp(location: AppRoutes.deviceDetail(5), seed: true);
      expect(find.text('Bakım geçmişi (0)'), findsOneWidget);
      expect(find.text('Henüz bakım kaydı yok'), findsOneWidget);
      expect(find.text('Son bakım'), findsOneWidget);
      expect(find.text('Kayıt yok'), findsNWidgets(2));
    });

    testAppWidgets('"Yeni bakım ekle" opens the maintenance route', (
      tester,
    ) async {
      await tester.pumpApp(location: AppRoutes.deviceDetail(8), seed: true);
      await tester.tap(find.text('Yeni bakım ekle'));
      await tester.pumpAndSettle();
      expect(appBarTitle('Yeni Bakım Kaydı'), findsOneWidget);
    });

    testAppWidgets('unknown device id shows not found', (tester) async {
      await tester.pumpApp(location: AppRoutes.deviceDetail(999), seed: true);
      expect(find.text('Sayfa bulunamadı'), findsWidgets);
    });

    testAppWidgets('customer → device → Android back returns to customer', (
      tester,
    ) async {
      await tester.pumpApp(location: AppRoutes.customerDetail(5), seed: true);
      await tester.tap(find.byType(DeviceOverviewTile).first);
      await tester.pumpAndSettle();
      expect(appBarTitle('Cihaz Detayı'), findsOneWidget);

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(appBarTitle('Müşteri Detayı'), findsOneWidget);
    });
  });

  group('Edit device', () {
    testAppWidgets('detail → edit → save updates the detail page', (
      tester,
    ) async {
      final db = await tester.pumpApp(
        location: AppRoutes.deviceDetail(8),
        seed: true,
      );
      await tester.tap(find.byTooltip('Düzenle'));
      await tester.pumpAndSettle();
      expect(appBarTitle('Cihazı Düzenle'), findsOneWidget);
      expect(find.text('HydroLine Mini'), findsOneWidget); // prefilled
      expect(find.text('DEMO-1008'), findsOneWidget);

      await tester.enterText(
        find.byKey(const ValueKey('deviceField-model')),
        'HydroLine Max',
      );
      await tester.tap(save());
      await tester.pumpAndSettle();

      expect(appBarTitle('Cihaz Detayı'), findsOneWidget);
      expect(find.text('HydroLine Max'), findsOneWidget);
      expect(find.text('Cihaz bilgileri güncellendi.'), findsOneWidget);
      final row = await (db.select(
        db.devices,
      )..where((d) => d.id.equals(8))).getSingle();
      expect(row.model, 'HydroLine Max');
      expect(row.customerId, 5, reason: 'owner must not change');
    });
  });

  group('Delete device', () {
    Future<void> openDeleteDialog(WidgetTester tester) async {
      await tester.tap(find.byTooltip('Diğer işlemler'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cihazı sil'));
      await tester.pumpAndSettle();
    }

    Future<({int records, int filters})> historyOf(
      AppDatabase db,
      int deviceId,
    ) async {
      final row = await db
          .customSelect(
            'SELECT (SELECT COUNT(*) FROM maintenance_records '
            ' WHERE device_id = $deviceId) AS r, '
            '(SELECT COUNT(*) FROM filter_replacements f JOIN '
            ' maintenance_records m ON m.id = f.maintenance_record_id '
            ' WHERE m.device_id = $deviceId) AS f',
          )
          .getSingle();
      return (records: row.read<int>('r'), filters: row.read<int>('f'));
    }

    testAppWidgets(
      'dialog states the permanent history loss; cancel keeps all',
      (tester) async {
        final db = await tester.pumpApp(
          location: AppRoutes.deviceDetail(8),
          seed: true,
        );
        final before = await historyOf(db, 8);
        expect(before.records, 4);

        await openDeleteDialog(tester);
        expect(find.text('Cihaz silinsin mi?'), findsOneWidget);
        expect(
          find.text(
            'HydroLine Mini cihazı ile birlikte 4 bakım kaydı ve '
            '${before.filters} filtre değişimi kalıcı olarak silinecek. '
            'Bakım geçmişi geri getirilemez.',
          ),
          findsOneWidget,
        );

        await tester.tap(find.text('Vazgeç'));
        await tester.pumpAndSettle();
        expect(appBarTitle('Cihaz Detayı'), findsOneWidget);
        expect(await deviceCount(db), 28);
        expect(await historyOf(db, 8), before);
      },
    );

    testAppWidgets('confirm deletes device + history and returns to customer', (
      tester,
    ) async {
      final db = await tester.pumpApp(
        location: AppRoutes.customers,
        seed: true,
      );
      await tester.tap(find.text('Mustafa Çelik'));
      await tester.pumpAndSettle();
      expect(find.text('Cihazlar (3)'), findsOneWidget);

      final router = GoRouter.of(tester.element(find.byType(AppBar).last));
      unawaited(router.push(AppRoutes.deviceDetail(8)));
      await tester.pumpAndSettle();

      await openDeleteDialog(tester);
      await tester.tap(find.widgetWithText(FilledButton, 'Sil'));
      await tester.pumpAndSettle();

      expect(appBarTitle('Müşteri Detayı'), findsOneWidget);
      expect(find.text('Cihaz silindi.'), findsOneWidget);
      expect(find.text('Cihazlar (2)'), findsOneWidget);
      expect(await deviceCount(db, customerId: 5), 2);
      expect(await historyOf(db, 8), (records: 0, filters: 0));

      // The customer list shows the new device count.
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      expect(appBarTitle('Müşteriler'), findsOneWidget);
      expect(
        find.descendant(
          of: find.ancestor(
            of: find.text('Mustafa Çelik'),
            matching: find.byType(Card),
          ),
          matching: find.text('2 cihaz'),
        ),
        findsOneWidget,
      );
    });
  });

  group('Small screens and large text', () {
    testAppWidgets('device detail and form do not overflow at 2x on 320x568', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.view.reset);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      await tester.pumpApp(location: AppRoutes.deviceDetail(8), seed: true);
      expect(tester.takeException(), isNull);
      await tester.drag(find.byType(ListView).last, const Offset(0, -2000));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      final router = GoRouter.of(tester.element(find.byType(AppBar).last));
      unawaited(router.push(AppRoutes.deviceEdit(8)));
      await tester.pumpAndSettle();
      await tester.dragUntilVisible(
        save(),
        find.byType(ListView).last,
        const Offset(0, -200),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });
}
