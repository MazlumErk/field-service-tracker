import 'dart:async';

import 'package:field_service_tracker/app/router/app_routes.dart';
import 'package:field_service_tracker/app/theme/app_spacing.dart';
import 'package:field_service_tracker/core/errors/app_exception_messages.dart';
import 'package:field_service_tracker/core/extensions/context_extensions.dart';
import 'package:field_service_tracker/core/widgets/app_list_skeleton.dart';
import 'package:field_service_tracker/core/widgets/app_message_state.dart';
import 'package:field_service_tracker/core/widgets/app_scaffold.dart';
import 'package:field_service_tracker/features/maintenance/domain/maintenance_status.dart';
import 'package:field_service_tracker/features/maintenance/presentation/cubit/maintenance_list_cubit.dart';
import 'package:field_service_tracker/features/maintenance/presentation/cubit/maintenance_list_state.dart';
import 'package:field_service_tracker/features/maintenance/presentation/widgets/maintenance_overview_tile.dart';
import 'package:field_service_tracker/features/maintenance/presentation/widgets/maintenance_status_badge.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

/// "Bakımlar" tab: all devices by maintenance priority with status filters.
class MaintenanceListPage extends StatelessWidget {
  const MaintenanceListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AppScaffold(
      title: l10n.navMaintenance,
      body: BlocBuilder<MaintenanceListCubit, MaintenanceListState>(
        builder: (context, state) => switch (state.status) {
          MaintenanceListStatus.loading => const AppListSkeleton(),
          MaintenanceListStatus.failure => AppMessageState.error(
            title: l10n.errorLoadTitle,
            message: state.failure?.userMessage(l10n) ?? l10n.errorUnexpected,
            action: OutlinedButton.icon(
              onPressed: context.read<MaintenanceListCubit>().retry,
              icon: const Icon(Icons.refresh),
              label: Text(l10n.commonRetry),
            ),
          ),
          MaintenanceListStatus.success when state.hasNoDevices =>
            AppMessageState.empty(
              icon: Icons.water_drop_outlined,
              title: l10n.maintenanceListNoDevicesTitle,
              message: l10n.maintenanceListNoDevicesMessage,
            ),
          MaintenanceListStatus.success => Column(
            children: [
              _FilterBar(state: state),
              Expanded(child: _MaintenanceList(state: state)),
            ],
          ),
        },
      ),
    );
  }
}

/// Horizontally scrollable status chips with counts; the selected one is
/// filled and check-marked (not only colored).
class _FilterBar extends StatelessWidget {
  const _FilterBar({required this.state});

  final MaintenanceListState state;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cubit = context.read<MaintenanceListCubit>();
    final options = <(MaintenanceStatus?, String, int)>[
      (null, l10n.maintenanceFilterAll, state.counts.total),
      (
        MaintenanceStatus.overdue,
        l10n.maintenanceFilterOverdue,
        state.counts.overdue,
      ),
      (
        MaintenanceStatus.upcoming,
        l10n.maintenanceFilterUpcoming,
        state.counts.upcoming,
      ),
      (
        MaintenanceStatus.scheduled,
        l10n.maintenanceFilterScheduled,
        state.counts.scheduled,
      ),
      (
        MaintenanceStatus.noMaintenance,
        l10n.maintenanceFilterNoRecord,
        state.counts.noMaintenance,
      ),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenHorizontal,
        AppSpacing.sm,
        AppSpacing.screenHorizontal,
        AppSpacing.sm,
      ),
      child: Row(
        children: [
          for (final (status, label, count) in options) ...[
            FilterChip(
              key: ValueKey('maintenanceFilter-${status?.name ?? 'all'}'),
              avatar: status == null || state.filter == status
                  ? null
                  : Icon(status.icon, size: 18),
              label: Text(l10n.maintenanceFilterWithCount(label, count)),
              selected: state.filter == status,
              onSelected: (_) => cubit.filterSelected(status),
            ),
            const SizedBox(width: AppSpacing.sm),
          ],
        ],
      ),
    );
  }
}

class _MaintenanceList extends StatelessWidget {
  const _MaintenanceList({required this.state});

  final MaintenanceListState state;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    if (state.isFilterEmpty) {
      return AppMessageState.empty(
        icon: Icons.filter_alt_off_outlined,
        title: l10n.maintenanceListFilterEmptyTitle,
        message: l10n.maintenanceListFilterEmptyMessage,
      );
    }
    final items = state.items;
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenHorizontal,
        0,
        AppSpacing.screenHorizontal,
        AppSpacing.lg,
      ),
      itemCount: items.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (context, index) {
        final overview = items[index];
        return MaintenanceOverviewTile(
          key: ValueKey(overview.device.id),
          overview: overview,
          today: state.today,
          onTap: () => unawaited(
            context.push(AppRoutes.deviceDetail(overview.device.id)),
          ),
        );
      },
    );
  }
}
