import 'dart:developer' as developer;

import 'package:field_service_tracker/app/app.dart';
import 'package:field_service_tracker/app/app_dependencies.dart';
import 'package:field_service_tracker/app/startup_error_app.dart';
import 'package:field_service_tracker/core/app_info.dart';
import 'package:field_service_tracker/core/clock/app_clock.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// App bootstrap: logging, licenses, database (seeded on first install),
/// then the app — or a friendly error screen if the database cannot open.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  _registerLogging();
  _registerFontLicense();

  const clock = SystemClock();
  final packageInfo = await PackageInfo.fromPlatform();

  final AppDependencies dependencies;
  try {
    dependencies = await AppDependencies.open(clock: clock);
  } catch (error, stackTrace) {
    developer.log(
      'Database could not be opened',
      name: 'field_service_tracker',
      error: error,
      stackTrace: stackTrace,
    );
    runApp(const StartupErrorApp());
    return;
  }

  runApp(
    FieldServiceTrackerApp(
      clock: clock,
      dependencies: dependencies,
      appInfo: AppInfo(
        version: packageInfo.version,
        buildNumber: packageInfo.buildNumber,
      ),
    ),
  );
}

/// Routes uncaught framework and platform errors to the developer log
/// instead of swallowing them.
void _registerLogging() {
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    developer.log(
      'Uncaught Flutter error',
      name: 'field_service_tracker',
      error: details.exception,
      stackTrace: details.stack,
    );
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    developer.log(
      'Uncaught platform error',
      name: 'field_service_tracker',
      error: error,
      stackTrace: stack,
    );
    return true;
  };
}

/// The Inter font is bundled under the SIL Open Font License; it must appear
/// on the licenses page next to the package licenses.
void _registerFontLicense() {
  LicenseRegistry.addLicense(() async* {
    final license = await rootBundle.loadString('assets/fonts/inter/OFL.txt');
    yield LicenseEntryWithLineBreaks(const ['Inter (font)'], license);
  });
}
