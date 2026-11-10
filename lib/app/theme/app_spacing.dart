import 'package:material_ui/material_ui.dart';

/// 4-pt spacing scale. Use these tokens instead of literal paddings.
abstract final class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;

  /// Standard horizontal padding of every screen.
  static const double screenHorizontal = lg;

  static const EdgeInsets screenPadding = EdgeInsets.symmetric(
    horizontal: screenHorizontal,
    vertical: lg,
  );
}

/// Corner radius tokens.
abstract final class AppRadius {
  static const double card = 12;
  static const double sheet = 16;

  static const BorderRadius cardRadius = BorderRadius.all(
    Radius.circular(card),
  );
}

/// Minimum interactive size (Material / WCAG touch target).
abstract final class AppSizes {
  static const double minTouchTarget = 48;
}
