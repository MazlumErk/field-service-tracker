import 'dart:async';

import 'package:field_service_tracker/core/clock/app_clock.dart';
import 'package:field_service_tracker/core/utils/calendar_date.dart';
import 'package:flutter/widgets.dart';

/// Source of "today" that also reports when the calendar day changes.
///
/// Maintenance statuses depend on today's date, so screens must recompute
/// them not only when data changes but also when the day rolls over.
abstract interface class TodayProvider {
  CalendarDate get today;

  /// Emits the new date whenever the calendar day changes.
  Stream<CalendarDate> get changes;
}

/// Creates a one-shot timer; injectable for tests.
typedef TimerFactory = Timer Function(Duration duration, void Function() run);

/// Production [TodayProvider] based on [AppClock].
///
/// Detects day changes in two simple ways, without polling:
/// * when the app returns to the foreground (`AppLifecycleState.resumed`),
/// * with a single timer that fires just after the next local midnight and
///   re-arms itself.
///
/// Midnight is computed with `DateTime(y, m, d + 1)` in local time, so DST
/// transitions cannot shift the day.
class DayTracker with WidgetsBindingObserver implements TodayProvider {
  DayTracker(this._clock, {TimerFactory? timerFactory})
    : _timerFactory = timerFactory ?? Timer.new,
      _today = CalendarDate.today(_clock);

  final AppClock _clock;
  final TimerFactory _timerFactory;
  final _controller = StreamController<CalendarDate>.broadcast();
  CalendarDate _today;
  Timer? _midnightTimer;
  bool _started = false;

  /// Small delay after midnight so the clock is safely on the new day.
  static const Duration _afterMidnight = Duration(seconds: 1);

  @override
  CalendarDate get today => _today;

  @override
  Stream<CalendarDate> get changes => _controller.stream;

  /// Starts listening to lifecycle changes and arms the midnight timer.
  void start() {
    if (_started) return;
    _started = true;
    WidgetsBinding.instance.addObserver(this);
    _scheduleMidnight();
  }

  /// Re-reads the clock and emits if the calendar day changed.
  void refresh() {
    final now = CalendarDate.today(_clock);
    if (now == _today) return;
    _today = now;
    if (!_controller.isClosed) _controller.add(now);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) return;
    refresh();
    // Timers may have been delayed while the app was suspended.
    _scheduleMidnight();
  }

  void _scheduleMidnight() {
    _midnightTimer?.cancel();
    final now = _clock.now();
    final nextMidnight = DateTime(now.year, now.month, now.day + 1);
    _midnightTimer = _timerFactory(
      nextMidnight.difference(now) + _afterMidnight,
      () {
        refresh();
        _scheduleMidnight();
      },
    );
  }

  Future<void> dispose() async {
    _midnightTimer?.cancel();
    if (_started) WidgetsBinding.instance.removeObserver(this);
    await _controller.close();
  }
}
