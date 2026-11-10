import 'package:field_service_tracker/app/theme/app_spacing.dart';
import 'package:field_service_tracker/core/extensions/context_extensions.dart';
import 'package:material_ui/material_ui.dart';

/// Static placeholder cards shaped like list rows, shown while a list loads.
/// Intentionally not animated (calm UI, no shimmer).
class AppListSkeleton extends StatelessWidget {
  const AppListSkeleton({this.itemCount = 6, super.key});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    final fill = context.colors.surfaceContainerHighest;
    Widget bar(double widthFactor, double height) => FractionallySizedBox(
      widthFactor: widthFactor,
      alignment: Alignment.centerLeft,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: fill,
          borderRadius: BorderRadius.circular(AppSpacing.xs),
        ),
      ),
    );

    return Semantics(
      label: MaterialLocalizations.of(context).refreshIndicatorSemanticLabel,
      child: ExcludeSemantics(
        child: ListView.separated(
          physics: const NeverScrollableScrollPhysics(),
          padding: AppSpacing.screenPadding,
          itemCount: itemCount,
          separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
          itemBuilder: (_, _) => Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                children: [
                  CircleAvatar(radius: 20, backgroundColor: fill),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        bar(0.6, 14),
                        const SizedBox(height: AppSpacing.sm),
                        bar(0.35, 12),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
