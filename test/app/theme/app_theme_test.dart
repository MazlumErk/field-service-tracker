import 'package:field_service_tracker/app/theme/app_theme.dart';
import 'package:field_service_tracker/app/theme/status_colors.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  group('AppTheme.light', () {
    final theme = AppTheme.light();

    test('applies the brand palette', () {
      expect(theme.useMaterial3, isTrue);
      expect(theme.colorScheme.primary, const Color(0xFF0F766E));
      expect(theme.colorScheme.secondary, const Color(0xFF234E70));
      expect(theme.colorScheme.error, const Color(0xFFDC2626));
      expect(theme.colorScheme.surface, const Color(0xFFFFFFFF));
      expect(theme.scaffoldBackgroundColor, const Color(0xFFF7FAFC));
    });

    test('uses Inter for every text role', () {
      final styles = [
        theme.textTheme.displaySmall,
        theme.textTheme.headlineSmall,
        theme.textTheme.titleMedium,
        theme.textTheme.titleSmall,
        theme.textTheme.bodyMedium,
        theme.textTheme.bodySmall,
        theme.textTheme.labelLarge,
      ];
      for (final style in styles) {
        expect(style?.fontFamily, 'Inter');
      }
    });

    test('registers StatusColors extension', () {
      expect(theme.extension<StatusColors>(), StatusColors.light);
    });

    test('cards are flat with a 12 px radius', () {
      expect(theme.cardTheme.elevation, 0);
      final shape = theme.cardTheme.shape! as RoundedRectangleBorder;
      expect(shape.borderRadius, BorderRadius.circular(12));
    });
  });

  group('StatusColors', () {
    test('status foregrounds meet WCAG AA contrast on their backgrounds', () {
      const colors = StatusColors.light;
      for (final pair in [
        colors.overdue,
        colors.upcoming,
        colors.scheduled,
        colors.noRecord,
      ]) {
        expect(
          _contrastRatio(pair.foreground, pair.background),
          greaterThanOrEqualTo(4.5),
        );
      }
    });

    test('lerp at the ends returns the inputs', () {
      final other = StatusColors.light.copyWith(
        overdue: const StatusColorPair(
          foreground: Color(0xFF000000),
          background: Color(0xFFFFFFFF),
        ),
      );
      expect(StatusColors.light.lerp(other, 0), StatusColors.light);
      expect(StatusColors.light.lerp(other, 1).overdue, other.overdue);
      expect(StatusColors.light.lerp(null, 0.5), StatusColors.light);
    });
  });
}

double _contrastRatio(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  final lighter = la > lb ? la : lb;
  final darker = la > lb ? lb : la;
  return (lighter + 0.05) / (darker + 0.05);
}
