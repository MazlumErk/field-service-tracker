import 'package:material_ui/material_ui.dart';

/// Raw brand palette of the "Calm Operations" design system.
///
/// Widgets must not use these constants directly; read colors from
/// `Theme.of(context).colorScheme` or the [StatusColors] extension instead.
/// This class only feeds [AppTheme].
abstract final class AppColors {
  static const Color primary = Color(0xFF0F766E);
  static const Color secondary = Color(0xFF234E70);
  static const Color background = Color(0xFFF7FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color warning = Color(0xFFD97706);
  static const Color error = Color(0xFFDC2626);

  /// Soft teal tint for selected states (navigation indicator, icon halos).
  /// The seed-generated container was too saturated for the calm palette.
  static const Color primaryContainer = Color(0xFFCCFBF1);
  static const Color onPrimaryContainer = Color(0xFF134E4A);

  /// Primary text. Slate 900 gives ~16:1 contrast on [background].
  static const Color onSurface = Color(0xFF0F172A);

  /// Secondary text. Slate 600 keeps WCAG AA (≥ 4.5:1) on [surface].
  static const Color onSurfaceVariant = Color(0xFF475569);

  /// Hairline borders for cards and inputs instead of shadows.
  static const Color outline = Color(0xFFCBD5E1);
  static const Color outlineVariant = Color(0xFFE2E8F0);
}
