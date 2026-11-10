import 'package:field_service_tracker/app/theme/app_spacing.dart';
import 'package:field_service_tracker/core/extensions/context_extensions.dart';
import 'package:field_service_tracker/core/extensions/date_format_extensions.dart';
import 'package:field_service_tracker/features/devices/presentation/cubit/device_detail_state.dart';
import 'package:field_service_tracker/features/maintenance/domain/maintenance_status.dart';
import 'package:field_service_tracker/features/maintenance/presentation/widgets/maintenance_status_badge.dart';
import 'package:material_ui/material_ui.dart';

/// Header card of the device detail page: identity, owner and maintenance
/// state.
class DeviceSummaryCard extends StatelessWidget {
  const DeviceSummaryCard({
    required this.state,
    required this.onCustomerTap,
    super.key,
  });

  final DeviceDetailState state;
  final VoidCallback onCustomerTap;

  String _statusDetail(BuildContext context) {
    final l10n = context.l10n;
    final days = state.daysUntilNextMaintenance;
    if (days == null) return l10n.deviceNeverServiced;
    if (days < 0) return l10n.deviceOverdueDays(-days);
    if (days == 0) return l10n.deviceDueToday;
    return l10n.deviceDaysLeft(days);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = context.textTheme;
    final colors = context.colors;
    final overview = state.overview!;
    final device = overview.device;
    final status = state.maintenanceStatus ?? MaintenanceStatus.noMaintenance;
    final statusColors = status.colors(context.statusColors);
    final last = overview.lastMaintenanceDate;
    final next = overview.nextMaintenanceDate;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(device.model, style: textTheme.headlineSmall),
            const SizedBox(height: AppSpacing.xs),
            Text(
              device.serialNumber == null
                  ? l10n.deviceSerialMissing
                  : l10n.deviceSerial(device.serialNumber!),
              style: textTheme.bodySmall?.copyWith(
                fontStyle: device.serialNumber == null
                    ? FontStyle.italic
                    : null,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            // Status block: badge + plain-language detail.
            DecoratedBox(
              decoration: BoxDecoration(
                color: statusColors.background,
                borderRadius: AppRadius.cardRadius,
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Wrap(
                  spacing: AppSpacing.md,
                  runSpacing: AppSpacing.xs,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    MaintenanceStatusBadge(status),
                    Text(
                      _statusDetail(context),
                      style: textTheme.bodyMedium?.copyWith(
                        color: statusColors.foreground,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            _InfoRow(
              icon: Icons.event_available_outlined,
              label: l10n.deviceLastMaintenance,
              value: last == null
                  ? l10n.deviceNoRecordValue
                  : context.formatDate(last),
            ),
            _InfoRow(
              icon: Icons.update,
              label: l10n.deviceNextMaintenanceLabel,
              value: next == null
                  ? l10n.deviceNoRecordValue
                  : context.formatDate(next),
            ),
            _InfoRow(
              icon: Icons.build_outlined,
              label: l10n.deviceFieldInstalledAt,
              value: context.formatDate(device.installedAt),
            ),
            const Divider(),
            // Owner: tappable, opens the customer detail.
            InkWell(
              onTap: onCustomerTap,
              borderRadius: AppRadius.cardRadius,
              child: Semantics(
                button: true,
                label:
                    '${l10n.deviceCustomer}: ${overview.customerFullName}, '
                    '${overview.customerNumber}',
                excludeSemantics: true,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                  child: Row(
                    children: [
                      Icon(
                        Icons.person_outline,
                        size: 20,
                        color: colors.onSurfaceVariant,
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.deviceCustomer,
                              style: textTheme.bodySmall,
                            ),
                            Text(
                              overview.customerFullName,
                              style: textTheme.bodyMedium,
                            ),
                            Text(
                              '${l10n.deviceCustomerNumber}: '
                              '${overview.customerNumber}',
                              style: textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right, color: colors.onSurfaceVariant),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: context.colors.onSurfaceVariant),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              spacing: AppSpacing.sm,
              children: [
                Text(label, style: textTheme.bodySmall),
                Text(value, style: textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
