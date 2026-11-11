import 'package:field_service_tracker/app/theme/app_spacing.dart';
import 'package:field_service_tracker/core/extensions/context_extensions.dart';
import 'package:material_ui/material_ui.dart';

/// KPI card: tinted icon, large number ("Display / Metric" role), label and
/// an optional hint. [foreground] / [background] carry the meaning (e.g.
/// status colors); the label always states it in words too.
class AppMetricCard extends StatelessWidget {
  const AppMetricCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.foreground,
    required this.background,
    this.hint,
    super.key,
  });

  final IconData icon;
  final int value;
  final String label;
  final String? hint;
  final Color foreground;
  final Color background;

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    return Semantics(
      container: true,
      label: [label, '$value', ?hint].join(', '),
      excludeSemantics: true,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: background,
                  borderRadius: BorderRadius.circular(AppSpacing.md),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  child: Icon(icon, size: 22, color: foreground),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                '$value',
                style: textTheme.displaySmall?.copyWith(color: foreground),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(label, style: textTheme.bodyMedium),
              if (hint != null) Text(hint!, style: textTheme.bodySmall),
            ],
          ),
        ),
      ),
    );
  }
}
