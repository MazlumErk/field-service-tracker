import 'dart:async';
import 'dart:developer' as developer;

import 'package:drift/isolate.dart' show DriftRemoteException;
import 'package:drift/native.dart';
import 'package:field_service_tracker/core/errors/app_exception.dart';

/// Extended SQLite result codes for constraint failures
/// (https://www.sqlite.org/rescode.html).
abstract final class _SqliteCodes {
  static const int constraintCheck = 275;
  static const int constraintForeignKey = 787;
  static const int constraintNotNull = 1299;
  static const int constraintPrimaryKey = 1555;

  /// Raised for `ON DELETE RESTRICT` (implemented by SQLite as an internal
  /// trigger) and by user `RAISE()` triggers; the message tells them apart.
  static const int constraintTrigger = 1811;
  static const int constraintUnique = 2067;
}

/// Translates any storage error into an [AppException] and logs the
/// technical details. [AppException]s pass through unchanged.
AppException mapDatabaseError(Object error, StackTrace stackTrace) {
  if (error is AppException) return error;

  // drift_flutter runs SQLite in a background isolate; errors arrive wrapped.
  final cause = error is DriftRemoteException ? error.remoteCause : error;

  final AppException mapped;
  if (cause is SqliteException) {
    mapped = switch (cause.extendedResultCode) {
      _SqliteCodes.constraintUnique ||
      _SqliteCodes.constraintPrimaryKey => ConstraintViolationException(
        cause.message,
        kind: ConstraintKind.unique,
        cause: cause,
        stackTrace: stackTrace,
      ),
      _SqliteCodes.constraintForeignKey || _SqliteCodes.constraintTrigger
          when cause.message.contains('FOREIGN KEY') =>
        ConstraintViolationException(
          cause.message,
          kind: ConstraintKind.foreignKey,
          cause: cause,
          stackTrace: stackTrace,
        ),
      _SqliteCodes.constraintCheck => ConstraintViolationException(
        cause.message,
        kind: ConstraintKind.check,
        cause: cause,
        stackTrace: stackTrace,
      ),
      _SqliteCodes.constraintNotNull => ConstraintViolationException(
        cause.message,
        kind: ConstraintKind.notNull,
        cause: cause,
        stackTrace: stackTrace,
      ),
      _ => DatabaseException(
        'SQLite error ${cause.extendedResultCode}: ${cause.message}',
        cause: cause,
        stackTrace: stackTrace,
      ),
    };
  } else {
    mapped = DatabaseException(
      'Unexpected storage error: $cause',
      cause: cause,
      stackTrace: stackTrace,
    );
  }

  developer.log(
    mapped.message,
    name: 'field_service_tracker.database',
    error: cause,
    stackTrace: stackTrace,
  );
  return mapped;
}

/// Runs [action] and converts failures with [mapDatabaseError].
Future<T> guardDatabase<T>(Future<T> Function() action) async {
  try {
    return await action();
  } catch (error, stackTrace) {
    throw mapDatabaseError(error, stackTrace);
  }
}

/// Converts errors emitted by a Drift watch stream with [mapDatabaseError].
Stream<T> guardDatabaseStream<T>(Stream<T> stream) => stream.transform(
  StreamTransformer<T, T>.fromHandlers(
    handleError: (error, stackTrace, sink) =>
        sink.addError(mapDatabaseError(error, stackTrace), stackTrace),
  ),
);
