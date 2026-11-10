import 'package:field_service_tracker/app/theme/app_spacing.dart';
import 'package:field_service_tracker/core/extensions/context_extensions.dart';
import 'package:material_ui/material_ui.dart';

/// Centered icon + title + message block used for empty and error states.
///
/// Scrollable so it never overflows on small screens or large text scales.
class AppMessageState extends StatelessWidget {
  const AppMessageState({
    required this.icon,
    required this.title,
    required this.message,
    this.action,
    this.isError = false,
    super.key,
  });

  /// Empty-content variant (neutral tone).
  const AppMessageState.empty({
    required IconData icon,
    required String title,
    required String message,
    Widget? action,
    Key? key,
  }) : this(
         icon: icon,
         title: title,
         message: message,
         action: action,
         key: key,
       );

  /// Error variant (error tone).
  const AppMessageState.error({
    required String title,
    required String message,
    Widget? action,
    Key? key,
  }) : this(
         icon: Icons.error_outline,
         title: title,
         message: message,
         action: action,
         isError: true,
         key: key,
       );

  final IconData icon;
  final String title;
  final String message;
  final Widget? action;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final iconColor = isError ? colors.error : colors.primary;
    final iconBackground = isError
        ? colors.errorContainer
        : colors.primaryContainer;

    return Center(
      child: SingleChildScrollView(
        padding: AppSpacing.screenPadding,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: iconBackground,
                  shape: BoxShape.circle,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Icon(icon, size: 32, color: iconColor),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                title,
                style: context.textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                message,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              if (action != null) ...[
                const SizedBox(height: AppSpacing.xl),
                action!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
