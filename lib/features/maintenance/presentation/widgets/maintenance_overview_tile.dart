import 'package:field_service_tracker/app/theme/app_spacing.dart';
import 'package:field_service_tracker/core/extensions/context_extensions.dart';
import 'package:field_service_tracker/core/extensions/date_format_extensions.dart';
import 'package:field_service_tracker/core/utils/calendar_date.dart';
import 'package:field_service_tracker/features/maintenance/domain/device_maintenance_overview.dart';
import 'package:field_service_tracker/features/maintenance/presentation/maintenance_due_text.dart';
import 'package:field_service_tracker/features/maintenance/presentation/widgets/maintenance_status_badge.dart';
import 'package:material_ui/material_ui.dart';

/// Row of the dashboard priority list and the maintenance list: customer,
/// device model, next date, status badge and days overdue / left.
class MaintenanceOverviewTile extends StatelessWidget {
  const MaintenanceOverviewTile({
    required this.overview,
    required this.today,
    required this.onTap,
    super.key,
  });

  final DeviceMaintenanceOverview overview;
  final CalendarDate today;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = context.textTheme;
    final colors = context.colors;
    final status = overview.statusOn(today);
    final next = overview.nextMaintenanceDate;
    final dueText = maintenanceDueText(
      l10n,
      next == null ? null : today.daysUntil(next),
    );
    final nextText = next == null
        ? null
        : l10n.deviceNextMaintenance(context.formatDate(next));
    final statusColors = status.colors(context.statusColors);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Semantics(
          button: true,
          label: [
            overview.customerFullName,
            overview.device.model,
            status.label(l10n),
            dueText,
            ?nextText,
          ].join(', '),
          excludeSemantics: true,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        overview.customerFullName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.titleSmall,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        overview.device.model,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodyMedium?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.xs,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          MaintenanceStatusBadge(status),
                          Text(
                            dueText,
                            style: textTheme.labelMedium?.copyWith(
                              color: statusColors.foreground,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      if (nextText != null) ...[
                        const SizedBox(height: AppSpacing.xs),
                        Text(nextText, style: textTheme.bodySmall),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Icon(Icons.chevron_right, color: colors.onSurfaceVariant),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
