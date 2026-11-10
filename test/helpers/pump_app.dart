import 'package:field_service_tracker/app/app.dart';
import 'package:field_service_tracker/app/router/app_routes.dart';
import 'package:field_service_tracker/core/app_info.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fixed_clock.dart';

const testAppInfo = AppInfo(version: '0.1.0', buildNumber: '1');

extension PumpApp on WidgetTester {
  /// Pumps the full app (theme, localization, router) at [location].
  Future<void> pumpApp({String location = AppRoutes.dashboard}) async {
    await pumpWidget(
      FieldServiceTrackerApp(
        clock: FixedClock(DateTime(2026, 1, 15, 10)),
        appInfo: testAppInfo,
        initialLocation: location,
      ),
    );
    await pumpAndSettle();
  }
}
