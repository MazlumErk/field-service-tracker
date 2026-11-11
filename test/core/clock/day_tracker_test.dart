import 'dart:async';

import 'package:field_service_tracker/core/clock/app_clock.dart';
import 'package:field_service_tracker/core/clock/day_tracker.dart';
import 'package:field_service_tracker/core/utils/calendar_date.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// Clock whose time the test moves forward.
final class _MutableClock implements AppClock {
  _MutableClock(this.value);

  DateTime value;

  @override
  DateTime now() => value;
}

/// Records scheduled timers instead of running them.
final class _TimerSpy {
  final durations = <Duration>[];
  void Function()? lastCallback;

  Timer create(Duration duration, void Function() run) {
    durations.add(duration);
    lastCallback = run;
    return Timer(const Duration(days: 365), () {});
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _MutableClock clock;
  late _TimerSpy timers;
  late DayTracker tracker;
  late List<CalendarDate> emitted;
  late StreamSubscription<CalendarDate> subscription;

  setUp(() {
    clock = _MutableClock(DateTime(2026, 1, 15, 23, 30));
    timers = _TimerSpy();
    tracker = DayTracker(clock, timerFactory: timers.create)..start();
    emitted = [];
    subscription = tracker.changes.listen(emitted.add);
  });

  tearDown(() async {
    await subscription.cancel();
    await tracker.dispose();
  });

  test('arms one timer for just after the next local midnight', () {
    expect(tracker.today, CalendarDate(2026, 1, 15));
    expect(timers.durations.single, const Duration(minutes: 30, seconds: 1));
  });

  test('midnight timer emits the new day and re-arms', () async {
    clock.value = DateTime(2026, 1, 16, 0, 0, 1);
    timers.lastCallback!();
    await Future<void>.delayed(Duration.zero);

    expect(emitted, [CalendarDate(2026, 1, 16)]);
    expect(tracker.today, CalendarDate(2026, 1, 16));
    expect(timers.durations, hasLength(2));
    // 00:00:01 → next midnight (+1 s) is exactly one day later.
    expect(timers.durations.last, const Duration(days: 1));
  });

  test('resuming emits only when the day actually changed', () async {
    clock.value = DateTime(2026, 1, 15, 23, 50);
    tracker.didChangeAppLifecycleState(AppLifecycleState.resumed);
    await Future<void>.delayed(Duration.zero);
    expect(emitted, isEmpty);

    // App was in the background over two nights.
    clock.value = DateTime(2026, 1, 17, 8);
    tracker.didChangeAppLifecycleState(AppLifecycleState.resumed);
    await Future<void>.delayed(Duration.zero);
    expect(emitted, [CalendarDate(2026, 1, 17)]);

    // Pausing does nothing.
    clock.value = DateTime(2026, 1, 18, 8);
    tracker.didChangeAppLifecycleState(AppLifecycleState.paused);
    await Future<void>.delayed(Duration.zero);
    expect(emitted, hasLength(1));
  });

  test('day length is computed in local calendar days (DST safe)', () {
    // EU DST starts 29 March 2026; the day is 23 h long locally, but the
    // timer still targets the next calendar midnight.
    final spy = _TimerSpy();
    final dstTracker = DayTracker(
      _MutableClock(DateTime(2026, 3, 29, 12)),
      timerFactory: spy.create,
    )..start();
    final now = DateTime(2026, 3, 29, 12);
    expect(
      now.add(spy.durations.single),
      DateTime(2026, 3, 30).add(const Duration(seconds: 1)),
    );
    unawaited(dstTracker.dispose());
  });
}
