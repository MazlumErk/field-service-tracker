import 'dart:async';

/// Records every event of a stream so tests can assert on reactive updates
/// without racing the initial emission.
final class StreamRecorder<T> {
  StreamRecorder(Stream<T> stream) {
    _subscription = stream.listen(values.add, onError: errors.add);
  }

  late final StreamSubscription<T> _subscription;
  final List<T> values = [];
  final List<Object> errors = [];

  T get last => values.last;

  /// Waits (yielding to the event loop) until [count] values arrived.
  Future<void> waitForValues(int count) async {
    for (var i = 0; i < 500 && values.length < count; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 2));
    }
    if (values.length < count) {
      throw TimeoutException('Expected $count values, got ${values.length}');
    }
  }

  /// Waits until a value satisfying [test] arrived and returns it.
  Future<T> waitFor(bool Function(T value) test) async {
    for (var i = 0; i < 500; i++) {
      for (final value in values) {
        if (test(value)) return value;
      }
      await Future<void>.delayed(const Duration(milliseconds: 2));
    }
    throw TimeoutException('No matching value in $values');
  }

  Future<void> cancel() => _subscription.cancel();
}
