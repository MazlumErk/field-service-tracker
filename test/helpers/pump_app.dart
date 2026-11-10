import 'package:field_service_tracker/app/app.dart';
import 'package:field_service_tracker/app/app_dependencies.dart';
import 'package:field_service_tracker/app/router/app_routes.dart';
import 'package:field_service_tracker/core/app_info.dart';
import 'package:field_service_tracker/database/app_database.dart';
import 'package:field_service_tracker/database/seed/demo_seeder.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fixed_clock.dart';
import 'test_database.dart';

const testAppInfo = AppInfo(version: '0.1.0', buildNumber: '1');

/// "Today" in every widget test: 15 January 2026, 10:00.
final testClock = FixedClock(DateTime(2026, 1, 15, 10));

/// [testWidgets] for tests that pump the full app.
///
/// Drift cancels stream queries with a zero-duration timer. After the body,
/// the widget tree is removed (closing Cubits, streams and the database) and
/// the event queue is flushed so no timer is left pending.
void testAppWidgets(
  String description,
  Future<void> Function(WidgetTester tester) body,
) {
  testWidgets(description, (tester) async {
    await body(tester);
    await tester.pumpWidget(const SizedBox());
    // Cubit.close → stream cancel → drift Timer.run; DB close follows
    // asynchronously. Advance fake time a few frames to drain all of it.
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 1));
    }
  });
}

extension PumpApp on WidgetTester {
  /// Pumps the full app (theme, localization, router, repositories backed by
  /// an in-memory database) at [location].
  ///
  /// With [seed] the database contains the 20 demo customers, exactly like a
  /// first install on [testClock]'s date. Returns the database for
  /// assertions.
  Future<AppDatabase> pumpApp({
    String location = AppRoutes.dashboard,
    bool seed = false,
  }) async {
    final database = createTestDatabase(
      seeder: seed ? DemoSeeder(testClock).call : null,
    );
    await pumpWidget(
      FieldServiceTrackerApp(
        clock: testClock,
        appInfo: testAppInfo,
        dependencies: AppDependencies(database: database, clock: testClock),
        initialLocation: location,
      ),
    );
    await pumpAndSettle();
    return database;
  }
}
