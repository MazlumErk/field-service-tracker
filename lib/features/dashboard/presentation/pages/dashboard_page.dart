import 'dart:async';

import 'package:field_service_tracker/app/router/app_routes.dart';
import 'package:field_service_tracker/app/theme/app_spacing.dart';
import 'package:field_service_tracker/core/errors/app_exception_messages.dart';
import 'package:field_service_tracker/core/extensions/context_extensions.dart';
import 'package:field_service_tracker/core/extensions/date_format_extensions.dart';
import 'package:field_service_tracker/core/widgets/app_list_skeleton.dart';
import 'package:field_service_tracker/core/widgets/app_message_state.dart';
import 'package:field_service_tracker/core/widgets/app_metric_card.dart';
import 'package:field_service_tracker/core/widgets/app_scaffold.dart';
import 'package:field_service_tracker/core/widgets/app_section_header.dart';
import 'package:field_service_tracker/features/dashboard/presentation/cubit/dashboard_cubit.dart';
import 'package:field_service_tracker/features/dashboard/presentation/cubit/dashboard_state.dart';
import 'package:field_service_tracker/features/maintenance/presentation/widgets/maintenance_overview_tile.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

/// "Genel Bakış" tab: KPIs and the priority maintenance list.
class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AppScaffold(
      title: l10n.navDashboard,
      body: BlocBuilder<DashboardCubit, DashboardState>(
        builder: (context, state) => switch (state.status) {
          DashboardStatus.loading => const AppListSkeleton(itemCount: 4),
          DashboardStatus.failure => AppMessageState.error(
            title: l10n.errorLoadTitle,
            message: state.failure?.userMessage(l10n) ?? l10n.errorUnexpected,
            action: OutlinedButton.icon(
              onPressed: context.read<DashboardCubit>().retry,
              icon: const Icon(Icons.refresh),
              label: Text(l10n.commonRetry),
            ),
          ),
          DashboardStatus.success when state.isEmpty => AppMessageState.empty(
            icon: Icons.space_dashboard_outlined,
            title: l10n.dashboardEmptyTitle,
            message: l10n.dashboardEmptyMessage,
            action: FilledButton.icon(
              onPressed: () => unawaited(context.push(AppRoutes.customerNew)),
              icon: const Icon(Icons.person_add_alt_1_outlined),
              label: Text(l10n.customerAdd),
            ),
          ),
          DashboardStatus.success => _DashboardContent(state: state),
        },
      ),
    );
  }
}

class _DashboardContent extends StatelessWidget {
  const _DashboardContent({required this.state});

  final DashboardState state;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = context.textTheme;

    return ListView(
      padding: AppSpacing.screenPadding,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: AppSpacing.xs),
          child: Text(
            l10n.dashboardToday(context.formatDate(state.today)),
            style: textTheme.bodyMedium?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        _MetricGrid(state: state),
        const SizedBox(height: AppSpacing.xl),
        AppSectionHeader(
          l10n.dashboardPriorityTitle,
          trailing: TextButton(
            key: const ValueKey('dashboardSeeAll'),
            onPressed: () => context.go(AppRoutes.maintenance),
            child: Text(l10n.dashboardSeeAll),
          ),
        ),
        if (state.priority.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
              child: AppMessageState.empty(
                icon: Icons.task_alt,
                title: l10n.dashboardPriorityEmptyTitle,
                message: l10n.dashboardPriorityEmptyMessage,
              ),
            ),
          )
        else ...[
          for (final overview in state.priority) ...[
            MaintenanceOverviewTile(
              key: ValueKey(overview.device.id),
              overview: overview,
              today: state.today,
              onTap: () => unawaited(
                context.push(AppRoutes.deviceDetail(overview.device.id)),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
          if (state.priorityTotal > state.priority.length)
            Padding(
              padding: const EdgeInsets.only(left: AppSpacing.xs),
              child: Text(
                l10n.dashboardPriorityMore(
                  state.priorityTotal,
                  state.priority.length,
                ),
                style: textTheme.bodySmall,
              ),
            ),
        ],
      ],
    );
  }
}

/// 2×2 grid of KPI cards; falls back to one column when the screen is
/// narrow or the text is large, so nothing gets squeezed.
class _MetricGrid extends StatelessWidget {
  const _MetricGrid({required this.state});

  final DashboardState state;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final status = context.statusColors;

    final cards = [
      AppMetricCard(
        key: const ValueKey('kpiCustomers'),
        icon: Icons.people_outline,
        value: state.customerCount,
        label: l10n.dashboardKpiCustomers,
        foreground: colors.secondary,
        background: colors.secondaryContainer,
      ),
      AppMetricCard(
        key: const ValueKey('kpiDevices'),
        icon: Icons.water_drop_outlined,
        value: state.deviceCount,
        label: l10n.dashboardKpiDevices,
        foreground: colors.primary,
        background: colors.primaryContainer,
      ),
      AppMetricCard(
        key: const ValueKey('kpiOverdue'),
        icon: Icons.error_outline,
        value: state.statusCounts.overdue,
        label: l10n.dashboardKpiOverdue,
        foreground: status.overdue.foreground,
        background: status.overdue.background,
      ),
      AppMetricCard(
        key: const ValueKey('kpiUpcoming'),
        icon: Icons.schedule,
        value: state.statusCounts.upcoming,
        label: l10n.dashboardKpiUpcoming,
        hint: l10n.dashboardKpiUpcomingHint,
        foreground: status.upcoming.foreground,
        background: status.upcoming.background,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final textScale = MediaQuery.textScalerOf(context).scale(1);
        final twoColumns = constraints.maxWidth / textScale >= 300;
        if (!twoColumns) {
          return Column(
            children: [
              for (final card in cards) ...[
                SizedBox(width: double.infinity, child: card),
                const SizedBox(height: AppSpacing.sm),
              ],
            ],
          );
        }
        // Two rows of equal-height cards (a hint line must not make one
        // card taller than its neighbour).
        Widget row(Widget left, Widget right) => IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: left),
              const SizedBox(width: AppSpacing.sm),
              Expanded(child: right),
            ],
          ),
        );
        return Column(
          children: [
            row(cards[0], cards[1]),
            const SizedBox(height: AppSpacing.sm),
            row(cards[2], cards[3]),
          ],
        );
      },
    );
  }
}
