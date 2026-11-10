import 'package:field_service_tracker/app/router/app_routes.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../helpers/pump_app.dart';

/// Unsaved-changes guard on the customer and device forms (seeded data).
void main() {
  Finder appBarTitle(String text) =>
      find.descendant(of: find.byType(AppBar), matching: find.text(text));

  final dialogTitle = find.text('Kaydedilmemiş değişiklikler');

  Future<void> tapAppBarBack(WidgetTester tester) async {
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
  }

  Future<void> systemBack(WidgetTester tester) async {
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
  }

  final forms =
      <
        ({
          String name,
          String detailRoute,
          String detailTitle,
          String formTitle,
          String editTooltip,
          String fieldKey,
          String saveKey,
        })
      >[
        (
          name: 'customer form',
          detailRoute: AppRoutes.customerDetail(5),
          detailTitle: 'Müşteri Detayı',
          formTitle: 'Müşteriyi Düzenle',
          editTooltip: 'Düzenle',
          fieldKey: 'customerField-lastName',
          saveKey: 'customerFormSave',
        ),
        (
          name: 'device form',
          detailRoute: AppRoutes.deviceDetail(8),
          detailTitle: 'Cihaz Detayı',
          formTitle: 'Cihazı Düzenle',
          editTooltip: 'Düzenle',
          fieldKey: 'deviceField-model',
          saveKey: 'deviceFormSave',
        ),
      ];

  for (final form in forms) {
    group(form.name, () {
      Future<void> openEditForm(WidgetTester tester) async {
        await tester.pumpApp(location: form.detailRoute, seed: true);
        await tester.tap(find.byTooltip(form.editTooltip));
        await tester.pumpAndSettle();
        expect(appBarTitle(form.formTitle), findsOneWidget);
      }

      testAppWidgets('no changes: back leaves without a dialog', (
        tester,
      ) async {
        await openEditForm(tester);
        await tapAppBarBack(tester);
        expect(dialogTitle, findsNothing);
        expect(appBarTitle(form.detailTitle), findsOneWidget);
      });

      testAppWidgets('changes + app bar back: "Vazgeç" stays on the form', (
        tester,
      ) async {
        await openEditForm(tester);
        await tester.enterText(find.byKey(ValueKey(form.fieldKey)), 'Değişti');
        await tester.pump();
        await tapAppBarBack(tester);

        expect(dialogTitle, findsOneWidget);
        expect(find.text('Değişiklikleri At'), findsOneWidget);
        await tester.tap(find.text('Vazgeç'));
        await tester.pumpAndSettle();

        expect(dialogTitle, findsNothing);
        expect(appBarTitle(form.formTitle), findsOneWidget);
        expect(find.text('Değişti'), findsOneWidget); // input kept
      });

      testAppWidgets('changes + Android back: "Değişiklikleri At" leaves', (
        tester,
      ) async {
        await openEditForm(tester);
        await tester.enterText(find.byKey(ValueKey(form.fieldKey)), 'Değişti');
        await tester.pump();
        await systemBack(tester);

        expect(dialogTitle, findsOneWidget);
        await tester.tap(find.text('Değişiklikleri At'));
        await tester.pumpAndSettle();

        expect(appBarTitle(form.detailTitle), findsOneWidget);
        expect(find.text('Değişti'), findsNothing); // nothing saved
      });

      testAppWidgets('reverting the text counts as no change', (tester) async {
        await openEditForm(tester);
        final field = find.byKey(ValueKey(form.fieldKey));
        final original = tester.widget<TextField>(field).controller!.text;
        await tester.enterText(field, 'Değişti');
        await tester.pump();
        await tester.enterText(field, original);
        await tester.pump();
        await systemBack(tester);

        expect(dialogTitle, findsNothing);
        expect(appBarTitle(form.detailTitle), findsOneWidget);
      });

      testAppWidgets('after a successful save no dialog is shown', (
        tester,
      ) async {
        await openEditForm(tester);
        await tester.enterText(
          find.byKey(ValueKey(form.fieldKey)),
          'Kaydedildi',
        );
        await tester.pump();
        await tester.tap(find.byKey(ValueKey(form.saveKey)));
        await tester.pumpAndSettle();

        expect(dialogTitle, findsNothing);
        expect(appBarTitle(form.detailTitle), findsOneWidget);
        expect(find.textContaining('Kaydedildi'), findsWidgets);
      });
    });
  }

  testAppWidgets('new customer form also asks before discarding input', (
    tester,
  ) async {
    await tester.pumpApp(location: AppRoutes.customers, seed: true);
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('customerField-firstName')),
      'Yarım',
    );
    await tester.pump();
    await systemBack(tester);
    expect(dialogTitle, findsOneWidget);

    await tester.tap(find.text('Değişiklikleri At'));
    await tester.pumpAndSettle();
    expect(appBarTitle('Müşteriler'), findsOneWidget);
    expect(find.text('20 müşteri'), findsOneWidget);
  });

  testAppWidgets('new device form: changing only the date counts as a change', (
    tester,
  ) async {
    await tester.pumpApp(location: AppRoutes.customerDetail(20), seed: true);
    await tester.tap(find.byKey(const ValueKey('customerAddDevice')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('deviceField-installedAt')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('10'));
    await tester.tap(find.text('Tamam'));
    await tester.pumpAndSettle();

    await tapAppBarBack(tester);
    expect(dialogTitle, findsOneWidget);
    await tester.tap(find.text('Değişiklikleri At'));
    await tester.pumpAndSettle();
    expect(appBarTitle('Müşteri Detayı'), findsOneWidget);
    expect(find.text('Cihazlar (0)'), findsOneWidget);
  });
}
