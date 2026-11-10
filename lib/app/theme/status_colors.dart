import 'package:material_ui/material_ui.dart';

/// Foreground / background pair for one maintenance status.
///
/// [foreground] is used for text and icons and always meets WCAG AA (≥ 4.5:1)
/// against [background].
@immutable
class StatusColorPair {
  const StatusColorPair({required this.foreground, required this.background});

  final Color foreground;
  final Color background;

  static StatusColorPair lerp(StatusColorPair a, StatusColorPair b, double t) {
    return StatusColorPair(
      foreground: Color.lerp(a.foreground, b.foreground, t)!,
      background: Color.lerp(a.background, b.background, t)!,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is StatusColorPair &&
      other.foreground == foreground &&
      other.background == background;

  @override
  int get hashCode => Object.hash(foreground, background);
}

/// Semantic colors for maintenance states, exposed as a [ThemeExtension] so
/// that widgets never hardcode red / amber / teal values.
@immutable
class StatusColors extends ThemeExtension<StatusColors> {
  const StatusColors({
    required this.overdue,
    required this.upcoming,
    required this.scheduled,
    required this.noRecord,
  });

  /// Light palette derived from the brand error, warning and primary colors.
  /// Foregrounds are darker shades than the raw brand colors to keep text
  /// readable on the tinted backgrounds.
  static const StatusColors light = StatusColors(
    overdue: StatusColorPair(
      foreground: Color(0xFFB91C1C),
      background: Color(0xFFFEF2F2),
    ),
    upcoming: StatusColorPair(
      foreground: Color(0xFF92400E),
      background: Color(0xFFFFFBEB),
    ),
    scheduled: StatusColorPair(
      foreground: Color(0xFF0F766E),
      background: Color(0xFFF0FDFA),
    ),
    noRecord: StatusColorPair(
      foreground: Color(0xFF475569),
      background: Color(0xFFF1F5F9),
    ),
  );

  final StatusColorPair overdue;
  final StatusColorPair upcoming;
  final StatusColorPair scheduled;
  final StatusColorPair noRecord;

  @override
  StatusColors copyWith({
    StatusColorPair? overdue,
    StatusColorPair? upcoming,
    StatusColorPair? scheduled,
    StatusColorPair? noRecord,
  }) {
    return StatusColors(
      overdue: overdue ?? this.overdue,
      upcoming: upcoming ?? this.upcoming,
      scheduled: scheduled ?? this.scheduled,
      noRecord: noRecord ?? this.noRecord,
    );
  }

  @override
  StatusColors lerp(StatusColors? other, double t) {
    if (other == null) return this;
    return StatusColors(
      overdue: StatusColorPair.lerp(overdue, other.overdue, t),
      upcoming: StatusColorPair.lerp(upcoming, other.upcoming, t),
      scheduled: StatusColorPair.lerp(scheduled, other.scheduled, t),
      noRecord: StatusColorPair.lerp(noRecord, other.noRecord, t),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is StatusColors &&
      other.overdue == overdue &&
      other.upcoming == upcoming &&
      other.scheduled == scheduled &&
      other.noRecord == noRecord;

  @override
  int get hashCode => Object.hash(overdue, upcoming, scheduled, noRecord);
}
