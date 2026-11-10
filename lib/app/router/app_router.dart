import 'package:field_service_tracker/app/router/app_routes.dart';
import 'package:field_service_tracker/app/router/app_shell.dart';
import 'package:field_service_tracker/core/clock/app_clock.dart';
import 'package:field_service_tracker/core/extensions/context_extensions.dart';
import 'package:field_service_tracker/core/widgets/not_found_page.dart';
import 'package:field_service_tracker/core/widgets/placeholder_page.dart';
import 'package:field_service_tracker/features/customers/domain/customer_repository.dart';
import 'package:field_service_tracker/features/customers/presentation/cubit/customer_detail_cubit.dart';
import 'package:field_service_tracker/features/customers/presentation/cubit/customer_form_cubit.dart';
import 'package:field_service_tracker/features/customers/presentation/cubit/customer_list_cubit.dart';
import 'package:field_service_tracker/features/customers/presentation/pages/customer_detail_page.dart';
import 'package:field_service_tracker/features/customers/presentation/pages/customer_form_page.dart';
import 'package:field_service_tracker/features/customers/presentation/pages/customer_list_page.dart';
import 'package:field_service_tracker/features/maintenance/domain/maintenance_repository.dart';
import 'package:field_service_tracker/features/settings/presentation/pages/settings_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

/// Creates the app router.
///
/// Layout:
/// * The four tabs live in a [StatefulShellRoute] and keep their own stacks.
/// * Detail and form pages are pushed on the root navigator
///   (`parentNavigatorKey: rootNavigatorKey`) so they cover the bottom bar
///   and the Android back button simply pops them.
///
/// Placeholder pages are replaced feature by feature in later phases.
GoRouter createAppRouter({String initialLocation = AppRoutes.dashboard}) {
  final rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: initialLocation,
    errorBuilder: (context, state) => const NotFoundPage(),
    routes: [
      GoRoute(path: '/', redirect: (_, _) => AppRoutes.dashboard),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.dashboard,
                builder: (context, state) =>
                    PlaceholderPage(title: context.l10n.navDashboard),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.customers,
                builder: (context, state) => BlocProvider(
                  create: (context) =>
                      CustomerListCubit(context.read<CustomerRepository>())
                        ..load(),
                  child: const CustomerListPage(),
                ),
                routes: [
                  // `new` must be declared before `:customerId`.
                  GoRoute(
                    path: 'new',
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (context, state) => BlocProvider(
                      create: (context) => CustomerFormCubit.create(
                        context.read<CustomerRepository>(),
                      ),
                      child: const CustomerFormPage(),
                    ),
                  ),
                  GoRoute(
                    path: ':customerId',
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (context, state) => _withId(
                      state,
                      'customerId',
                      (id) => BlocProvider(
                        create: (context) => CustomerDetailCubit(
                          customerId: id,
                          customerRepository: context
                              .read<CustomerRepository>(),
                          maintenanceRepository: context
                              .read<MaintenanceRepository>(),
                          clock: context.read<AppClock>(),
                        )..load(),
                        child: const CustomerDetailPage(),
                      ),
                    ),
                    routes: [
                      GoRoute(
                        path: 'edit',
                        parentNavigatorKey: rootNavigatorKey,
                        builder: (context, state) => _withId(
                          state,
                          'customerId',
                          (id) => BlocProvider(
                            create: (context) => CustomerFormCubit.edit(
                              context.read<CustomerRepository>(),
                              customerId: id,
                            )..load(),
                            child: const CustomerFormPage(),
                          ),
                        ),
                      ),
                      GoRoute(
                        path: 'devices/new',
                        parentNavigatorKey: rootNavigatorKey,
                        builder: (context, state) => _withId(
                          state,
                          'customerId',
                          (_) => PlaceholderPage(
                            title: context.l10n.deviceNewTitle,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.maintenance,
                builder: (context, state) =>
                    PlaceholderPage(title: context.l10n.navMaintenance),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.settings,
                builder: (context, state) => const SettingsPage(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/devices/:deviceId',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => _withId(
          state,
          'deviceId',
          (_) => PlaceholderPage(title: context.l10n.deviceDetailTitle),
        ),
        routes: [
          GoRoute(
            path: 'edit',
            parentNavigatorKey: rootNavigatorKey,
            builder: (context, state) => _withId(
              state,
              'deviceId',
              (_) => PlaceholderPage(title: context.l10n.deviceEditTitle),
            ),
          ),
          GoRoute(
            path: 'maintenance/new',
            parentNavigatorKey: rootNavigatorKey,
            builder: (context, state) => _withId(
              state,
              'deviceId',
              (_) => PlaceholderPage(title: context.l10n.maintenanceNewTitle),
            ),
          ),
        ],
      ),
    ],
  );
}

/// Parses a positive integer path parameter; malformed ids show
/// [NotFoundPage] instead of crashing.
Widget _withId(
  GoRouterState state,
  String name,
  Widget Function(int id) builder,
) {
  final id = int.tryParse(state.pathParameters[name] ?? '');
  if (id == null || id <= 0) return const NotFoundPage();
  return builder(id);
}
