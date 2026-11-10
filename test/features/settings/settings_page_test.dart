import 'package:field_service_tracker/app/router/app_routes.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../helpers/pump_app.dart';

void main() {
  group('SettingsPage', () {
    testAppWidgets('shows app info and the injected version', (tester) async {
      await tester.pumpApp(location: AppRoutes.settings);

      expect(find.text('Uygulama hakkında'), findsOneWidget);
      expect(find.text('0.1.0 (derleme 1)'), findsOneWidget);
      expect(find.text('Açık kaynak lisansları'), findsOneWidget);
    });

    testAppWidgets('opens the licenses page', (tester) async {
      await tester.pumpApp(location: AppRoutes.settings);

      await tester.tap(find.text('Açık kaynak lisansları'));
      await tester.pumpAndSettle();

      expect(find.byType(LicensePage), findsOneWidget);
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

      await tester.pumpApp(location: AppRoutes.customerDetail(1));
      expect(tester.takeException(), isNull);
    });
  });
}
