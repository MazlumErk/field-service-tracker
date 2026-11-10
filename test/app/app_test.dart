import 'package:field_service_tracker/app/router/app_shell.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/pump_app.dart';

void main() {
  group('FieldServiceTrackerApp', () {
    testAppWidgets('starts on the dashboard tab', (tester) async {
      await tester.pumpApp();

      expect(find.byType(AppShell), findsOneWidget);
      final bar = tester.widget<NavigationBar>(find.byType(NavigationBar));
      expect(bar.selectedIndex, 0);
      expect(
        find.descendant(
          of: find.byType(AppBar),
          matching: find.text('Genel Bakış'),
        ),
        findsOneWidget,
      );
    });

    testAppWidgets('shows the four Turkish navigation destinations', (
      tester,
    ) async {
      await tester.pumpApp();

      final bar = find.byType(NavigationBar);
      for (final label in [
        'Genel Bakış',
        'Müşteriler',
        'Bakımlar',
        'Ayarlar',
      ]) {
        expect(
          find.descendant(of: bar, matching: find.text(label)),
          findsOneWidget,
          reason: label,
        );
      }
    });

    testAppWidgets('uses Turkish Material localizations', (tester) async {
      await tester.pumpApp();

      final context = tester.element(find.byType(AppShell));
      expect(Localizations.localeOf(context), const Locale('tr'));
      expect(MaterialLocalizations.of(context).okButtonLabel, 'Tamam');
    });
  });
}
