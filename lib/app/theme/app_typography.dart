import 'package:material_ui/material_ui.dart';

/// Type scale of the design system, mapped onto Material 3 text roles.
///
/// | Design role     | Material role    |
/// |-----------------|------------------|
/// | Display/Metric  | `displaySmall`   |
/// | Page Title      | `headlineSmall`  |
/// | Section Title   | `titleMedium`    |
/// | Card Title      | `titleSmall`     |
/// | Body            | `bodyMedium`     |
/// | Secondary Text  | `bodyMedium` + `onSurfaceVariant` color |
/// | Caption         | `bodySmall`      |
/// | Button Label    | `labelLarge`     |
///
/// Sizes are logical pixels; Flutter applies the user's text scale on top,
/// so dynamic type is supported automatically.
abstract final class AppTypography {
  static const String fontFamily = 'Inter';

  static TextTheme textTheme({
    required Color primaryText,
    required Color secondaryText,
  }) {
    TextStyle style(
      double size,
      FontWeight weight,
      double height, {
      Color? color,
      double letterSpacing = 0,
    }) {
      return TextStyle(
        fontFamily: fontFamily,
        fontSize: size,
        fontWeight: weight,
        height: height,
        letterSpacing: letterSpacing,
        color: color ?? primaryText,
      );
    }

    return TextTheme(
      displayLarge: style(48, FontWeight.w600, 1.1, letterSpacing: -0.5),
      displayMedium: style(40, FontWeight.w600, 1.1, letterSpacing: -0.5),
      displaySmall: style(32, FontWeight.w600, 1.15, letterSpacing: -0.25),
      headlineLarge: style(28, FontWeight.w600, 1.2),
      headlineMedium: style(24, FontWeight.w600, 1.25),
      headlineSmall: style(22, FontWeight.w600, 1.3),
      titleLarge: style(20, FontWeight.w600, 1.3),
      titleMedium: style(16, FontWeight.w600, 1.4),
      titleSmall: style(15, FontWeight.w600, 1.4),
      bodyLarge: style(16, FontWeight.w400, 1.5),
      bodyMedium: style(14, FontWeight.w400, 1.5),
      bodySmall: style(12, FontWeight.w400, 1.4, color: secondaryText),
      labelLarge: style(14, FontWeight.w600, 1.3, letterSpacing: 0.1),
      labelMedium: style(12, FontWeight.w500, 1.3, letterSpacing: 0.2),
      labelSmall: style(11, FontWeight.w500, 1.3, letterSpacing: 0.3),
    );
  }
}
