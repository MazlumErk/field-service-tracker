import 'dart:developer' as developer;

import 'package:field_service_tracker/app/app.dart';
import 'package:field_service_tracker/core/app_info.dart';
import 'package:field_service_tracker/core/clock/app_clock.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// App bootstrap. Database opening and seeding are added here in Phase 2.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  _registerLogging();
  _registerFontLicense();

  final packageInfo = await PackageInfo.fromPlatform();

  runApp(
    FieldServiceTrackerApp(
      clock: const SystemClock(),
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
