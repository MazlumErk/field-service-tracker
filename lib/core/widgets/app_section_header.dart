import 'package:field_service_tracker/app/theme/app_spacing.dart';
import 'package:field_service_tracker/core/extensions/context_extensions.dart';
import 'package:material_ui/material_ui.dart';

/// Section title above a group of cards ("Section Title" text role).
class AppSectionHeader extends StatelessWidget {
  const AppSectionHeader(this.text, {this.trailing, super.key});

  final String text;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: AppSpacing.xs,
        top: AppSpacing.sm,
        bottom: AppSpacing.sm,
      ),
      child: Row(
        children: [
          Expanded(
            child: Semantics(
              header: true,
              child: Text(
                text,
                style: context.textTheme.titleMedium?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}
