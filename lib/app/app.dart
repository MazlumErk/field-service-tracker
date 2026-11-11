import 'dart:async';

import 'package:field_service_tracker/app/app_dependencies.dart';
import 'package:field_service_tracker/app/router/app_router.dart';
import 'package:field_service_tracker/app/router/app_routes.dart';
import 'package:field_service_tracker/app/theme/app_theme.dart';
import 'package:field_service_tracker/core/app_info.dart';
import 'package:field_service_tracker/core/clock/app_clock.dart';
import 'package:field_service_tracker/core/clock/day_tracker.dart';
import 'package:field_service_tracker/features/customers/domain/customer_repository.dart';
import 'package:field_service_tracker/features/devices/domain/device_repository.dart';
import 'package:field_service_tracker/features/maintenance/domain/maintenance_repository.dart';
import 'package:field_service_tracker/features/settings/domain/demo_data_repository.dart';
import 'package:field_service_tracker/l10n/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

/// Root widget: owns the router and exposes app-wide dependencies.
///
/// Repositories are provided by their **interface** type; Cubits are created
/// per route with `BlocProvider`. The [DayTracker] reporting calendar-day
/// changes lives here as well.
class FieldServiceTrackerApp extends StatefulWidget {
  const FieldServiceTrackerApp({
    required this.clock,
    required this.appInfo,
    required this.dependencies,
    this.initialLocation = AppRoutes.dashboard,
    super.key,
  });

  final AppClock clock;
  final AppInfo appInfo;

  /// Owned by this widget: the database is closed when the app is disposed.
  final AppDependencies dependencies;

  /// Start route; overridable for widget tests.
  final String initialLocation;

  @override
  State<FieldServiceTrackerApp> createState() => _FieldServiceTrackerAppState();
}

class _FieldServiceTrackerAppState extends State<FieldServiceTrackerApp> {
  late final GoRouter _router = createAppRouter(
    initialLocation: widget.initialLocation,
  );

  /// Reports calendar-day changes (resume + midnight) to all screens.
  late final DayTracker _dayTracker = DayTracker(widget.clock)..start();

  @override
  void dispose() {
    _router.dispose();
    unawaited(_dayTracker.dispose());
    unawaited(widget.dependencies.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final deps = widget.dependencies;
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AppClock>.value(value: widget.clock),
        RepositoryProvider<AppInfo>.value(value: widget.appInfo),
        RepositoryProvider<TodayProvider>.value(value: _dayTracker),
        RepositoryProvider<CustomerRepository>.value(
          value: deps.customerRepository,
        ),
        RepositoryProvider<DeviceRepository>.value(
          value: deps.deviceRepository,
        ),
        RepositoryProvider<MaintenanceRepository>.value(
          value: deps.maintenanceRepository,
        ),
        RepositoryProvider<DemoDataRepository>.value(
          value: deps.demoDataRepository,
        ),
      ],
      child: MaterialApp.router(
        onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        themeMode: ThemeMode.light,
        locale: const Locale('tr'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          ...GlobalMaterialLocalizations.delegates,
        ],
        routerConfig: _router,
      ),
    );
  }
}
