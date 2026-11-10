import 'dart:async';

import 'package:field_service_tracker/app/router/app_routes.dart';
import 'package:field_service_tracker/database/app_database.dart';
import 'package:field_service_tracker/features/customers/presentation/widgets/customer_list_tile.dart';
import 'package:field_service_tracker/features/maintenance/presentation/widgets/device_overview_tile.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../helpers/pump_app.dart';

/// End-to-end flows on the seeded demo database (20 customers).
///
/// Demo customers used below (see `DemoSeeder`):
/// * #5  Mustafa Çelik  FST-0005 — 3 devices (upcoming, scheduled ×2)
/// * #16 Şeyma Kara     FST-0016
/// * #20 Özlem Şimşek   FST-0020 — no devices
void main() {
  Finder appBarTitle(String text) =>
      find.descendant(of: find.byType(AppBar), matching: find.text(text));

  Finder field(String name) => find.byKey(ValueKey('customerField-$name'));

  Finder errorText(String fieldName, String message) =>
      find.descendant(of: field(fieldName), matching: find.text(message));

  Future<void> search(WidgetTester tester, String text) async {
    await tester.enterText(find.byType(TextField), text);
    await tester.pump(const Duration(milliseconds: 300)); // debounce
    await tester.pumpAndSettle();
  }

  Future<int> customerCount(AppDatabase db) async =>
      (await db.select(db.customers).get()).length;

  group('Customer list', () {
    testAppWidgets('lists demo customers in Turkish alphabetical order', (
      tester,
    ) async {
      await tester.pumpApp(location: AppRoutes.customers, seed: true);

      expect(find.text('20 müşteri'), findsOneWidget);
      final names = tester
          .widgetList<CustomerListTile>(find.byType(CustomerListTile))
          .map((tile) => tile.item.customer.lastName)
          .take(5)
          .toList();
      expect(names, ['Arslan', 'Aslan', 'Aydın', 'Çelik', 'Çetin']);
      expect(find.text('İbrahim Arslan'), findsOneWidget);
    });

    testAppWidgets('search ignores case and Turkish characters', (
      tester,
    ) async {
      await tester.pumpApp(location: AppRoutes.customers, seed: true);

      for (final query in ['şeyma', 'SEYMA', 'kara fst', 'fst-0016']) {
        await search(tester, query);
        expect(find.text('Şeyma Kara'), findsOneWidget, reason: query);
        expect(find.text('1 sonuç'), findsOneWidget, reason: query);
      }
    });

    testAppWidgets('search waits for the debounce before filtering', (
      tester,
    ) async {
      await tester.pumpApp(location: AppRoutes.customers, seed: true);

      await tester.enterText(find.byType(TextField), 'şeyma');
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('20 müşteri'), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 200));
      await tester.pumpAndSettle();
      expect(find.text('1 sonuç'), findsOneWidget);
    });

    testAppWidgets('no results state offers to clear the search', (
      tester,
    ) async {
      await tester.pumpApp(location: AppRoutes.customers, seed: true);

      await search(tester, 'zzzz');
      expect(find.text('Sonuç bulunamadı'), findsOneWidget);
      expect(find.byType(CustomerListTile), findsNothing);

      await tester.tap(find.widgetWithText(OutlinedButton, 'Aramayı temizle'));
      await tester.pumpAndSettle();
      expect(find.text('20 müşteri'), findsOneWidget);
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        isEmpty,
      );
    });

    testAppWidgets('empty database shows the empty state with an action', (
      tester,
    ) async {
      await tester.pumpApp(location: AppRoutes.customers);

      expect(find.text('Henüz müşteri yok'), findsOneWidget);
      await tester.tap(find.widgetWithText(FilledButton, 'Yeni müşteri'));
      await tester.pumpAndSettle();
      expect(appBarTitle('Yeni Müşteri'), findsOneWidget);
    });
  });

  group('Customer form', () {
    testAppWidgets(
      'create → detail → back shows the new customer in the list',
      (tester) async {
        final db = await tester.pumpApp(
          location: AppRoutes.customers,
          seed: true,
        );

        await tester.tap(find.byType(FloatingActionButton));
        await tester.pumpAndSettle();
        expect(appBarTitle('Yeni Müşteri'), findsOneWidget);

        await tester.enterText(field('firstName'), 'Deniz');
        await tester.enterText(field('lastName'), 'Ünal');
        await tester.enterText(field('customerNumber'), ' fst 0099 ');
        await tester.enterText(field('phone'), '0500 000 00 99');
        await tester.tap(find.byKey(const ValueKey('customerFormSave')));
        await tester.pumpAndSettle();

        // Replaced by the detail page of the new customer.
        expect(appBarTitle('Müşteri Detayı'), findsOneWidget);
        expect(find.text('Deniz Ünal'), findsOneWidget);
        expect(find.text('FST0099'), findsOneWidget);
        expect(find.text('Müşteri kaydedildi.'), findsOneWidget);
        expect(await customerCount(db), 21);

        await tester.tap(find.byType(BackButton));
        await tester.pumpAndSettle();
        expect(appBarTitle('Müşteriler'), findsOneWidget);
        expect(find.text('21 müşteri'), findsOneWidget);
      },
    );

    testAppWidgets('empty required fields show inline errors', (tester) async {
      final db = await tester.pumpApp(
        location: AppRoutes.customerNew,
        seed: true,
      );

      await tester.tap(find.byKey(const ValueKey('customerFormSave')));
      await tester.pumpAndSettle();

      for (final name in ['firstName', 'lastName', 'customerNumber']) {
        expect(errorText(name, 'Bu alan zorunludur.'), findsOneWidget);
      }
      expect(appBarTitle('Yeni Müşteri'), findsOneWidget);
      expect(await customerCount(db), 20);

      // Typing into a field clears its error.
      await tester.enterText(field('firstName'), 'A');
      await tester.pump();
      expect(errorText('firstName', 'Bu alan zorunludur.'), findsNothing);
    });

    testAppWidgets('invalid phone and number formats are explained', (
      tester,
    ) async {
      await tester.pumpApp(location: AppRoutes.customerNew, seed: true);

      await tester.enterText(field('firstName'), 'Ali');
      await tester.enterText(field('lastName'), 'Veli');
      await tester.enterText(field('customerNumber'), 'ŞUBE-1');
      await tester.enterText(field('phone'), '123');
      await tester.tap(find.byKey(const ValueKey('customerFormSave')));
      await tester.pumpAndSettle();

      expect(
        errorText(
          'customerNumber',
          'Yalnızca harf (A–Z), rakam ve - _ / . kullanılabilir.',
        ),
        findsOneWidget,
      );
      expect(
        errorText('phone', 'Geçerli bir telefon numarası girin (10–15 rakam).'),
        findsOneWidget,
      );
    });

    testAppWidgets('a duplicate customer number is shown under the field', (
      tester,
    ) async {
      final db = await tester.pumpApp(
        location: AppRoutes.customerNew,
        seed: true,
      );

      await tester.enterText(field('firstName'), 'Yeni');
      await tester.enterText(field('lastName'), 'Kişi');
      await tester.enterText(field('customerNumber'), 'fst-0001');
      await tester.tap(find.byKey(const ValueKey('customerFormSave')));
      await tester.pumpAndSettle();

      expect(
        errorText(
          'customerNumber',
          'Bu müşteri numarası başka bir müşteride kullanılıyor.',
        ),
        findsOneWidget,
      );
      expect(appBarTitle('Yeni Müşteri'), findsOneWidget);
      expect(await customerCount(db), 20);
    });

    testAppWidgets('list → search → detail → edit → save updates everything', (
      tester,
    ) async {
      await tester.pumpApp(location: AppRoutes.customers, seed: true);

      await search(tester, 'şeyma');
      await tester.tap(find.text('Şeyma Kara'));
      await tester.pumpAndSettle();
      expect(appBarTitle('Müşteri Detayı'), findsOneWidget);

      await tester.tap(find.byTooltip('Düzenle'));
      await tester.pumpAndSettle();
      expect(appBarTitle('Müşteriyi Düzenle'), findsOneWidget);
      // Prefilled with the existing values.
      expect(find.text('FST-0016'), findsOneWidget);

      // Keeping its own number must not count as a duplicate.
      await tester.enterText(field('lastName'), 'Karaca');
      await tester.tap(find.byKey(const ValueKey('customerFormSave')));
      await tester.pumpAndSettle();

      expect(appBarTitle('Müşteri Detayı'), findsOneWidget);
      expect(find.text('Şeyma Karaca'), findsOneWidget);
      expect(find.text('Değişiklikler kaydedildi.'), findsOneWidget);

      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      // The list still filters by "şeyma" and shows the new name.
      expect(find.text('Şeyma Karaca'), findsOneWidget);
    });
  });

  group('Customer detail', () {
    testAppWidgets('shows contact data and devices with their status', (
      tester,
    ) async {
      // Tall viewport so that all three device cards are built.
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpApp(location: AppRoutes.customerDetail(5), seed: true);

      expect(find.text('Mustafa Çelik'), findsOneWidget);
      expect(find.text('FST-0005'), findsOneWidget);
      expect(find.text('Cihazlar (3)'), findsOneWidget);
      expect(find.byType(DeviceOverviewTile), findsNWidgets(3));
      expect(find.text('Yaklaşıyor'), findsOneWidget);
      expect(find.text('Planlandı'), findsNWidgets(2));
      // Dates include the year (seed: next maintenance today + 12 days).
      expect(find.text('Sonraki bakım: 27 Oca 2026'), findsOneWidget);
    });

    testAppWidgets('customer without devices shows an empty device state', (
      tester,
    ) async {
      await tester.pumpApp(location: AppRoutes.customerDetail(20), seed: true);

      expect(find.text('Cihazlar (0)'), findsOneWidget);
      expect(find.text('Kayıtlı cihaz yok'), findsOneWidget);
    });

    testAppWidgets('tapping a device opens the device route', (tester) async {
      await tester.pumpApp(location: AppRoutes.customerDetail(5), seed: true);

      await tester.tap(find.byType(DeviceOverviewTile).first);
      await tester.pumpAndSettle();
      expect(appBarTitle('Cihaz Detayı'), findsOneWidget);
    });

    testAppWidgets('unknown customer id shows not found', (tester) async {
      await tester.pumpApp(location: AppRoutes.customerDetail(999), seed: true);
      expect(find.text('Sayfa bulunamadı'), findsWidgets);
    });

    testAppWidgets('returning from detail does not refocus the search', (
      tester,
    ) async {
      await tester.pumpApp(location: AppRoutes.customers, seed: true);
      await search(tester, 'çelik');
      expect(tester.testTextInput.isVisible, isTrue);

      await tester.tap(find.text('Mustafa Çelik'));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();

      expect(appBarTitle('Müşteriler'), findsOneWidget);
      expect(tester.testTextInput.isVisible, isFalse);
    });

    testAppWidgets('Android back from detail returns to the list', (
      tester,
    ) async {
      await tester.pumpApp(location: AppRoutes.customers, seed: true);
      await tester.tap(find.text('Mustafa Çelik'));
      await tester.pumpAndSettle();
      expect(appBarTitle('Müşteri Detayı'), findsOneWidget);

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(appBarTitle('Müşteriler'), findsOneWidget);
      expect(find.byType(NavigationBar), findsOneWidget);
    });
  });

  group('Customer delete', () {
    Future<void> openDeleteDialog(WidgetTester tester) async {
      await tester.tap(find.byTooltip('Diğer işlemler'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Müşteriyi sil'));
      await tester.pumpAndSettle();
    }

    testAppWidgets('the dialog shows the impact and cancel keeps all data', (
      tester,
    ) async {
      final db = await tester.pumpApp(
        location: AppRoutes.customerDetail(5),
        seed: true,
      );
      final recordsBefore =
          (await db.select(db.maintenanceRecords).get()).length;

      await openDeleteDialog(tester);
      expect(find.text('Müşteri silinsin mi?'), findsOneWidget);
      expect(find.textContaining('3 cihaz ve 8 bakım kaydı'), findsOneWidget);

      await tester.tap(find.text('Vazgeç'));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsNothing);
      expect(appBarTitle('Müşteri Detayı'), findsOneWidget);
      expect(await customerCount(db), 20);
      expect((await db.select(db.devices).get()).length, 28);
      expect(
        (await db.select(db.maintenanceRecords).get()).length,
        recordsBefore,
      );
    });

    testAppWidgets('confirm deletes related records and returns to the list', (
      tester,
    ) async {
      final db = await tester.pumpApp(
        location: AppRoutes.customers,
        seed: true,
      );
      await tester.tap(find.text('Mustafa Çelik'));
      await tester.pumpAndSettle();

      await openDeleteDialog(tester);
      await tester.tap(find.widgetWithText(FilledButton, 'Sil'));
      await tester.pumpAndSettle();

      expect(appBarTitle('Müşteriler'), findsOneWidget);
      expect(find.text('Müşteri silindi.'), findsOneWidget);
      expect(find.text('19 müşteri'), findsOneWidget);
      expect(find.text('Mustafa Çelik'), findsNothing);

      expect(await customerCount(db), 19);
      final devices = await db.select(db.devices).get();
      expect(devices.where((d) => d.customerId == 5), isEmpty);
      expect(devices, hasLength(25));
      final orphanFilters = await db
          .customSelect(
            'SELECT COUNT(*) AS n FROM filter_replacements f '
            'LEFT JOIN maintenance_records r ON r.id = f.maintenance_record_id '
            'WHERE r.id IS NULL',
          )
          .getSingle();
      expect(orphanFilters.read<int>('n'), 0);
    });

    testAppWidgets('customer without related records gets the short message', (
      tester,
    ) async {
      await tester.pumpApp(location: AppRoutes.customerDetail(20), seed: true);
      await openDeleteDialog(tester);
      expect(
        find.text(
          'Özlem Şimşek kalıcı olarak silinecek. Bu işlem geri alınamaz.',
        ),
        findsOneWidget,
      );
      await tester.tap(find.text('Vazgeç'));
      await tester.pumpAndSettle();
    });
  });

  group('Small screens and large text', () {
    testAppWidgets('list, detail and form do not overflow at 2x on 320x568', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.view.reset);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      await tester.pumpApp(location: AppRoutes.customers, seed: true);
      expect(tester.takeException(), isNull);

      final router = GoRouter.of(tester.element(find.byType(NavigationBar)));
      unawaited(router.push(AppRoutes.customerDetail(5)));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      unawaited(router.push(AppRoutes.customerEdit(5)));
      await tester.pumpAndSettle();
      final save = find.byKey(const ValueKey('customerFormSave'));
      // The form list builds lazily; scroll until the button exists.
      await tester.dragUntilVisible(
        save,
        find.byType(ListView).last,
        const Offset(0, -200),
      );
      await tester.pumpAndSettle();
      await tester.tap(save);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });
}
