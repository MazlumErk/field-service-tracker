import 'package:field_service_tracker/app/theme/app_spacing.dart';
import 'package:field_service_tracker/core/extensions/context_extensions.dart';
import 'package:field_service_tracker/core/extensions/date_format_extensions.dart';
import 'package:field_service_tracker/core/utils/calendar_date.dart';
import 'package:field_service_tracker/features/maintenance/domain/device_maintenance_overview.dart';
import 'package:field_service_tracker/features/maintenance/presentation/widgets/maintenance_status_badge.dart';
import 'package:material_ui/material_ui.dart';

/// Device card with model, serial number, next maintenance date and status.
/// Reused by customer detail now and by dashboard / maintenance list later.
class DeviceOverviewTile extends StatelessWidget {
  const DeviceOverviewTile({
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
    final device = overview.device;
    final status = overview.statusOn(today);
    final next = overview.nextMaintenanceDate;
    final nextText = next == null
        ? l10n.deviceNoMaintenanceYet
        : l10n.deviceNextMaintenance(context.formatDate(next));
    final serial = device.serialNumber;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Semantics(
          button: true,
          label: [
            device.model,
            if (serial != null) l10n.deviceSerial(serial),
            status.label(l10n),
            nextText,
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
                        device.model,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.titleSmall,
                      ),
                      if (serial != null) ...[
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          l10n.deviceSerial(serial),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.bodySmall,
                        ),
                      ],
                      const SizedBox(height: AppSpacing.sm),
                      Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.xs,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          MaintenanceStatusBadge(status),
                          Text(
                            nextText,
                            style: textTheme.bodySmall?.copyWith(
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
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
