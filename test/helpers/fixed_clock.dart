import 'package:field_service_tracker/core/clock/app_clock.dart';

/// [AppClock] frozen at [value] for deterministic tests.
final class FixedClock implements AppClock {
  FixedClock(this.value);

  final DateTime value;

  @override
  DateTime now() => value;
}
