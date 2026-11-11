import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:field_service_tracker/app/router/app_routes.dart';
import 'package:field_service_tracker/core/errors/app_exception.dart';
import 'package:field_service_tracker/database/app_database.dart';
import 'package:field_service_tracker/features/customers/data/drift_customer_repository.dart';
import 'package:field_service_tracker/features/customers/domain/customer_draft.dart';
import 'package:field_service_tracker/features/settings/domain/demo_data_repository.dart';
import 'package:field_service_tracker/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/pump_app.dart';

class _MockDemoDataRepository extends Mock implements DemoDataRepository {}

void main() {
  Finder navTab(String label) => find.descendant(
    of: find.byType(NavigationBar),
    matching: find.text(label),
  );

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

  Future<int> customerCount(AppDatabase db) async =>
      (await db.select(db.customers).get()).length;

  Future<void> addUserCustomer(WidgetTester tester, AppDatabase db) =>
      tester.runAsync(
        () => DriftCustomerRepository(db, testClock).createCustomer(
          const CustomerDraft(
            customerNumber: 'USER-1',
            firstName: 'Yeni',
            lastName: 'Kullanıcı',
          ),
        ),
      );

  Future<AppDatabase> pumpSettings(WidgetTester tester) {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    return tester.pumpApp(location: AppRoutes.settings, seed: true);
  }

  group('SettingsPage', () {
    testAppWidgets('shows identity, real version and licenses', (tester) async {
      await pumpSettings(tester);

      expect(find.text('Field Service Tracker'), findsOneWidget);
      expect(find.text('Sürüm 0.1.0 (derleme 1)'), findsOneWidget);
      expect(find.text('Demo verilerini sıfırla'), findsOneWidget);

      await tester.tap(find.text('Açık kaynak lisansları'));
      await tester.pumpAndSettle();
      expect(find.byType(LicensePage), findsOneWidget);
    });

    testAppWidgets('cancelling the reset keeps user data', (tester) async {
      final db = await pumpSettings(tester);
      await addUserCustomer(tester, db);

      await tester.tap(find.byKey(const ValueKey('settingsResetDemo')));
      await tester.pumpAndSettle();
      expect(find.text('Demo verileri sıfırlansın mı?'), findsOneWidget);
      expect(
        find.textContaining('Sonradan eklediğiniz müşteriler'),
        findsOneWidget,
      );

      await tester.tap(find.text('Vazgeç'));
      await tester.pumpAndSettle();
      expect(await customerCount(db), 21);
    });

    testAppWidgets('confirmed reset restores demo data and updates the tabs', (
      tester,
    ) async {
      final db = await pumpSettings(tester);
      await addUserCustomer(tester, db);
      // Visit the dashboard first so its Cubit is alive and must react.
      await tester.tap(navTab('Genel Bakış'));
      await tester.pumpAndSettle();
      expect(kpi(tester, 'kpiCustomers'), 21);
      await tester.tap(navTab('Ayarlar'));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('settingsResetDemo')));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Sıfırla'));
      await tester.pumpAndSettle();

      expect(find.text('Demo verileri yeniden oluşturuldu.'), findsOneWidget);
      expect(await customerCount(db), 20);

      await tester.tap(navTab('Genel Bakış'));
      await tester.pumpAndSettle();
      expect(kpi(tester, 'kpiCustomers'), 20);
      expect(kpi(tester, 'kpiDevices'), 28);

      await tester.tap(navTab('Müşteriler'));
      await tester.pumpAndSettle();
      expect(find.text('20 müşteri'), findsOneWidget);
      expect(find.text('Yeni Kullanıcı'), findsNothing);
    });
  });

  group('SettingsCubit', () {
    late _MockDemoDataRepository repository;
    setUp(() => repository = _MockDemoDataRepository());

    blocTest<SettingsCubit, SettingsState>(
      'success goes through resetting',
      setUp: () =>
          when(() => repository.resetDemoData()).thenAnswer((_) async {}),
      build: () => SettingsCubit(repository),
      act: (cubit) => cubit.resetDemoData(),
      expect: () => const [
        SettingsState(resetStatus: DemoResetStatus.resetting),
        SettingsState(resetStatus: DemoResetStatus.success),
      ],
    );

    blocTest<SettingsCubit, SettingsState>(
      'a failed (rolled back) reset reports the error',
      setUp: () =>
          when(() => repository.resetDemoData())
              .thenThrow(const DatabaseException('disk full')),
      build: () => SettingsCubit(repository),
      act: (cubit) => cubit.resetDemoData(),
      expect: () => [
        const SettingsState(resetStatus: DemoResetStatus.resetting),
        isA<SettingsState>()
            .having((s) => s.resetStatus, 'status', DemoResetStatus.failure)
            .having((s) => s.failure, 'failure', isA<DatabaseException>()),
      ],
    );

    test('repeated taps while resetting run the reset once', () async {
      final completer = Completer<void>();
      when(() => repository.resetDemoData())
          .thenAnswer((_) => completer.future);
      final cubit = SettingsCubit(repository);

      final calls = [cubit.resetDemoData(), cubit.resetDemoData()];
      completer.complete();
      await Future.wait(calls);

      verify(() => repository.resetDemoData()).called(1);
      expect(cubit.state.resetStatus, DemoResetStatus.success);
      await cubit.close();
    });
  });

  group('Small screen and large text', () {
    testAppWidgets('settings and shell render without overflow at 2x text on a '
        '320x568 screen', (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.view.reset);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      await tester.pumpApp(location: AppRoutes.settings);
      expect(tester.takeException(), isNull);
      await tester.drag(find.byType(ListView).last, const Offset(0, -2000));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      await tester.pumpApp(location: AppRoutes.customerDetail(1));
      expect(tester.takeException(), isNull);
    });
  });
}
