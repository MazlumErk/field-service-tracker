import 'dart:async';

import 'package:field_service_tracker/app/router/app_routes.dart';
import 'package:field_service_tracker/app/router/app_shell.dart';
import 'package:field_service_tracker/core/widgets/not_found_page.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../helpers/pump_app.dart';

Finder _tab(String label) =>
    find.descendant(of: find.byType(NavigationBar), matching: find.text(label));

Finder _appBarTitle(String title) =>
    find.descendant(of: find.byType(AppBar), matching: find.text(title));

GoRouter _router(WidgetTester tester) =>
    GoRouter.of(tester.element(find.byType(AppShell)));

void main() {
  group('Tab navigation', () {
    testWidgets('switches between all four tabs', (tester) async {
      await tester.pumpApp();

      for (final (index, label) in [
        (1, 'Müşteriler'),
        (2, 'Bakımlar'),
        (3, 'Ayarlar'),
        (0, 'Genel Bakış'),
      ]) {
        await tester.tap(_tab(label));
        await tester.pumpAndSettle();

        final bar = tester.widget<NavigationBar>(find.byType(NavigationBar));
        expect(bar.selectedIndex, index, reason: label);
        expect(_appBarTitle(label), findsOneWidget, reason: label);
      }
    });
  });

  group('Pushed routes', () {
    testWidgets('detail page covers the bottom bar and back returns to tab', (
      tester,
    ) async {
      await tester.pumpApp(location: AppRoutes.customers);

      unawaited(_router(tester).push(AppRoutes.customerDetail(7)));
      await tester.pumpAndSettle();

      expect(_appBarTitle('Müşteri Detayı'), findsOneWidget);
      expect(find.byType(NavigationBar), findsNothing);

      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();

      expect(_appBarTitle('Müşteriler'), findsOneWidget);
      expect(find.byType(NavigationBar), findsOneWidget);
    });

    testWidgets('Android system back pops a pushed page', (tester) async {
      await tester.pumpApp();

      unawaited(_router(tester).push(AppRoutes.deviceDetail(3)));
      await tester.pumpAndSettle();
      expect(_appBarTitle('Cihaz Detayı'), findsOneWidget);

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();

      expect(_appBarTitle('Genel Bakış'), findsOneWidget);
    });

    testWidgets('every planned route resolves to its page', (tester) async {
      final expected = <String, String>{
        AppRoutes.customerNew: 'Yeni Müşteri',
        AppRoutes.customerDetail(1): 'Müşteri Detayı',
        AppRoutes.customerEdit(1): 'Müşteriyi Düzenle',
        AppRoutes.deviceNew(1): 'Yeni Cihaz',
        AppRoutes.deviceDetail(1): 'Cihaz Detayı',
        AppRoutes.deviceEdit(1): 'Cihazı Düzenle',
        AppRoutes.maintenanceNew(1): 'Yeni Bakım Kaydı',
      };

      for (final MapEntry(key: location, value: title) in expected.entries) {
        await tester.pumpApp(location: location);
        expect(_appBarTitle(title), findsOneWidget, reason: location);
        // Rebuild from scratch for the next location.
        await tester.pumpWidget(const SizedBox());
      }
    });
  });

  group('Invalid locations', () {
    testWidgets('unknown path shows the not-found page', (tester) async {
      await tester.pumpApp(location: '/does-not-exist');

      expect(find.byType(NotFoundPage), findsOneWidget);
    });

    testWidgets('non-numeric id shows the not-found page', (tester) async {
      await tester.pumpApp(location: '/devices/abc');

      expect(find.byType(NotFoundPage), findsOneWidget);
    });

    testWidgets('not-found action navigates back to the dashboard', (
      tester,
    ) async {
      await tester.pumpApp(location: '/customers/0');
      expect(find.byType(NotFoundPage), findsOneWidget);

      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();

      expect(find.byType(NotFoundPage), findsNothing);
      expect(_appBarTitle('Genel Bakış'), findsOneWidget);
    });
  });
}
