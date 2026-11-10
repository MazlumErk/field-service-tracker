import 'package:field_service_tracker/app/theme/app_spacing.dart';
import 'package:field_service_tracker/core/extensions/context_extensions.dart';
import 'package:field_service_tracker/core/extensions/date_format_extensions.dart';
import 'package:field_service_tracker/core/extensions/money_format_extensions.dart';
import 'package:field_service_tracker/features/maintenance/domain/filter_type.dart';
import 'package:field_service_tracker/features/maintenance/domain/maintenance_record.dart';
import 'package:field_service_tracker/l10n/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

/// Turkish display name of a filter type.
extension FilterTypeLabel on FilterType {
  String label(AppLocalizations l10n) => switch (this) {
    FilterType.sediment => l10n.filterSediment,
    FilterType.cto => l10n.filterCto,
    FilterType.gac => l10n.filterGac,
    FilterType.post => l10n.filterPost,
    FilterType.membrane => l10n.filterMembrane,
  };
}

/// Read-only card of one maintenance visit: date, price, next date,
/// replaced filters and notes.
class MaintenanceRecordCard extends StatelessWidget {
  const MaintenanceRecordCard({required this.record, super.key});

  final MaintenanceRecord record;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = context.textTheme;
    final colors = context.colors;
    final notes = record.notes;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: AppSpacing.md,
              runSpacing: AppSpacing.xs,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.event_available_outlined,
                      size: 18,
                      color: colors.primary,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Flexible(
                      child: Text(
                        context.formatDate(record.maintenanceDate),
                        style: textTheme.titleSmall,
                      ),
                    ),
                  ],
                ),
                Semantics(
                  label:
                      '${l10n.maintenanceRecordPrice}: '
                      '${context.formatKurus(record.priceKurus)}',
                  excludeSemantics: true,
                  child: Text(
                    context.formatKurus(record.priceKurus),
                    style: textTheme.titleSmall?.copyWith(
                      color: colors.secondary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              l10n.maintenanceRecordNext(
                context.formatDate(record.nextMaintenanceDate),
              ),
              style: textTheme.bodySmall,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(l10n.maintenanceRecordFilters, style: textTheme.labelMedium),
            const SizedBox(height: AppSpacing.xs),
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: [
                for (final filter in record.filters)
                  _FilterChip(label: filter.label(l10n)),
              ],
            ),
            if (notes != null) ...[
              const SizedBox(height: AppSpacing.md),
              Text(l10n.maintenanceRecordNotes, style: textTheme.labelMedium),
              const SizedBox(height: AppSpacing.xs),
              Text(notes, style: textTheme.bodyMedium),
            ],
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.secondaryContainer,
        borderRadius: BorderRadius.circular(AppSpacing.sm),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: 2,
        ),
        child: Text(
          label,
          style: context.textTheme.labelMedium?.copyWith(
            color: colors.onSecondaryContainer,
          ),
        ),
      ),
    );
  }
}
