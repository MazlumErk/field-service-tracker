import 'package:field_service_tracker/app/theme/app_spacing.dart';
import 'package:field_service_tracker/app/theme/status_colors.dart';
import 'package:field_service_tracker/core/extensions/context_extensions.dart';
import 'package:field_service_tracker/features/maintenance/domain/maintenance_status.dart';
import 'package:field_service_tracker/l10n/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

/// Turkish label for a status (also used for semantics and filters).
extension MaintenanceStatusLabel on MaintenanceStatus {
  String label(AppLocalizations l10n) => switch (this) {
    MaintenanceStatus.overdue => l10n.statusOverdue,
    MaintenanceStatus.upcoming => l10n.statusUpcoming,
    MaintenanceStatus.scheduled => l10n.statusScheduled,
    MaintenanceStatus.noMaintenance => l10n.statusNoMaintenance,
  };

  IconData get icon => switch (this) {
    MaintenanceStatus.overdue => Icons.error_outline,
    MaintenanceStatus.upcoming => Icons.schedule,
    MaintenanceStatus.scheduled => Icons.check_circle_outline,
    MaintenanceStatus.noMaintenance => Icons.help_outline,
  };

  StatusColorPair colors(StatusColors palette) => switch (this) {
    MaintenanceStatus.overdue => palette.overdue,
    MaintenanceStatus.upcoming => palette.upcoming,
    MaintenanceStatus.scheduled => palette.scheduled,
    MaintenanceStatus.noMaintenance => palette.noRecord,
  };
}

/// Pill showing icon + text + color for a maintenance status, so the status
/// is never communicated by color alone.
class MaintenanceStatusBadge extends StatelessWidget {
  const MaintenanceStatusBadge(this.status, {super.key});

  final MaintenanceStatus status;

  @override
  Widget build(BuildContext context) {
    final pair = status.colors(context.statusColors);
    final label = status.label(context.l10n);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: pair.background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(status.icon, size: 16, color: pair.foreground),
            const SizedBox(width: AppSpacing.xs),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.textTheme.labelMedium?.copyWith(
                  color: pair.foreground,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
