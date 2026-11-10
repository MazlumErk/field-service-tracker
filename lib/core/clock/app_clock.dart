/// Source of the current time.
///
/// Every piece of code that needs "today" (maintenance status, seed dates,
/// default form values) must depend on this interface instead of calling
/// `DateTime.now()` directly, so that tests can freeze time.
abstract interface class AppClock {
  /// Current local date and time.
  DateTime now();
}

/// Production clock backed by the device time.
final class SystemClock implements AppClock {
  const SystemClock();

  @override
  DateTime now() => DateTime.now();
}
