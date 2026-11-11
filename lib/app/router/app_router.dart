import 'package:field_service_tracker/app/router/app_routes.dart';
import 'package:field_service_tracker/app/router/app_shell.dart';
import 'package:field_service_tracker/core/clock/app_clock.dart';
import 'package:field_service_tracker/core/clock/day_tracker.dart';
import 'package:field_service_tracker/core/widgets/not_found_page.dart';
import 'package:field_service_tracker/features/customers/domain/customer_repository.dart';
import 'package:field_service_tracker/features/customers/presentation/cubit/customer_detail_cubit.dart';
import 'package:field_service_tracker/features/customers/presentation/cubit/customer_form_cubit.dart';
import 'package:field_service_tracker/features/customers/presentation/cubit/customer_list_cubit.dart';
import 'package:field_service_tracker/features/customers/presentation/pages/customer_detail_page.dart';
import 'package:field_service_tracker/features/customers/presentation/pages/customer_form_page.dart';
import 'package:field_service_tracker/features/customers/presentation/pages/customer_list_page.dart';
import 'package:field_service_tracker/features/dashboard/presentation/cubit/dashboard_cubit.dart';
import 'package:field_service_tracker/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:field_service_tracker/features/devices/domain/device_repository.dart';
import 'package:field_service_tracker/features/devices/presentation/cubit/device_detail_cubit.dart';
import 'package:field_service_tracker/features/devices/presentation/cubit/device_form_cubit.dart';
import 'package:field_service_tracker/features/devices/presentation/pages/device_detail_page.dart';
import 'package:field_service_tracker/features/devices/presentation/pages/device_form_page.dart';
import 'package:field_service_tracker/features/maintenance/domain/maintenance_repository.dart';
import 'package:field_service_tracker/features/maintenance/presentation/cubit/maintenance_form_cubit.dart';
import 'package:field_service_tracker/features/maintenance/presentation/cubit/maintenance_list_cubit.dart';
import 'package:field_service_tracker/features/maintenance/presentation/pages/maintenance_form_page.dart';
import 'package:field_service_tracker/features/maintenance/presentation/pages/maintenance_list_page.dart';
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
                builder: (context, state) => BlocProvider(
                  create: (context) => DashboardCubit(
                    customerRepository: context.read<CustomerRepository>(),
                    maintenanceRepository: context
                        .read<MaintenanceRepository>(),
                    today: context.read<TodayProvider>(),
                  )..load(),
                  child: const DashboardPage(),
                ),
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
                          dayChanges: context.read<TodayProvider>().changes,
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
                          (id) => BlocProvider(
                            create: (context) => DeviceFormCubit.create(
                              context.read<DeviceRepository>(),
                              customerId: id,
                              clock: context.read<AppClock>(),
                            ),
                            child: const DeviceFormPage(),
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
                builder: (context, state) => BlocProvider(
                  create: (context) => MaintenanceListCubit(
                    maintenanceRepository: context
                        .read<MaintenanceRepository>(),
                    today: context.read<TodayProvider>(),
                  )..load(),
                  child: const MaintenanceListPage(),
                ),
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
          (id) => BlocProvider(
            create: (context) => DeviceDetailCubit(
              deviceId: id,
              deviceRepository: context.read<DeviceRepository>(),
              maintenanceRepository: context.read<MaintenanceRepository>(),
              clock: context.read<AppClock>(),
              dayChanges: context.read<TodayProvider>().changes,
            )..load(),
            child: const DeviceDetailPage(),
          ),
        ),
        routes: [
          GoRoute(
            path: 'edit',
            parentNavigatorKey: rootNavigatorKey,
            builder: (context, state) => _withId(
              state,
              'deviceId',
              (id) => BlocProvider(
                create: (context) => DeviceFormCubit.edit(
                  context.read<DeviceRepository>(),
                  deviceId: id,
                  clock: context.read<AppClock>(),
                )..load(),
                child: const DeviceFormPage(),
              ),
            ),
          ),
          GoRoute(
            path: 'maintenance/new',
            parentNavigatorKey: rootNavigatorKey,
            builder: (context, state) => _withId(
              state,
              'deviceId',
              (id) => BlocProvider(
                create: (context) => MaintenanceFormCubit(
                  deviceId: id,
                  repository: context.read<MaintenanceRepository>(),
                  clock: context.read<AppClock>(),
                )..load(),
                child: const MaintenanceFormPage(),
              ),
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
