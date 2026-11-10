import 'package:field_service_tracker/app/router/app_router.dart';
import 'package:field_service_tracker/app/router/app_routes.dart';
import 'package:field_service_tracker/app/theme/app_theme.dart';
import 'package:field_service_tracker/core/app_info.dart';
import 'package:field_service_tracker/core/clock/app_clock.dart';
import 'package:field_service_tracker/l10n/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

/// Root widget: owns the router and exposes app-wide dependencies.
///
/// Dependency graph (grows in later phases):
/// `RepositoryProvider<AppClock>`, `RepositoryProvider<AppInfo>`
/// → repositories (Phase 2) → page-scoped Cubits via `BlocProvider`.
class FieldServiceTrackerApp extends StatefulWidget {
  const FieldServiceTrackerApp({
    required this.clock,
    required this.appInfo,
    this.initialLocation = AppRoutes.dashboard,
    super.key,
  });

  final AppClock clock;
  final AppInfo appInfo;

  /// Start route; overridable for widget tests.
  final String initialLocation;

  @override
  State<FieldServiceTrackerApp> createState() => _FieldServiceTrackerAppState();
}

class _FieldServiceTrackerAppState extends State<FieldServiceTrackerApp> {
  late final GoRouter _router = createAppRouter(
    initialLocation: widget.initialLocation,
  );

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AppClock>.value(value: widget.clock),
        RepositoryProvider<AppInfo>.value(value: widget.appInfo),
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
