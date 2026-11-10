import 'package:field_service_tracker/core/validation/validation_result.dart';

/// Base type of every error the data layer exposes to Cubits.
///
/// Repositories never leak `SqliteException` or Drift types; they translate
/// failures into one of these subtypes. The UI maps them to Turkish messages.
sealed class AppException implements Exception {
  const AppException(this.message, {this.cause, this.stackTrace});

  /// Technical description for logs (English, never shown to users).
  final String message;
  final Object? cause;
  final StackTrace? stackTrace;

  @override
  String toString() => '$runtimeType: $message';
}

/// The requested record does not exist (or was deleted meanwhile).
final class NotFoundException extends AppException {
  const NotFoundException(this.entity, this.id)
    : super('$entity #$id not found');

  final String entity;
  final int id;
}

/// Another customer already uses this (normalized) customer number.
final class DuplicateCustomerNumberException extends AppException {
  const DuplicateCustomerNumberException(this.customerNumber, {super.cause})
    : super('Customer number "$customerNumber" is already in use');

  final String customerNumber;
}

/// Input failed domain validation. [errors] maps a field enum to its error.
final class ValidationException extends AppException {
  ValidationException(this.errors)
    : super('Validation failed: ${errors.keys.map((f) => f.name).join(', ')}');

  final Map<Enum, ValidationError> errors;
}

/// A schema constraint (foreign key, CHECK, NOT NULL) rejected the write.
/// Normally prevented by validation; this is the safety net.
final class ConstraintViolationException extends AppException {
  const ConstraintViolationException(
    super.message, {
    required this.kind,
    super.cause,
    super.stackTrace,
  });

  final ConstraintKind kind;
}

enum ConstraintKind { foreignKey, check, notNull, unique }

/// Any other storage failure (I/O, corrupt file, unexpected SQLite error).
final class DatabaseException extends AppException {
  const DatabaseException(super.message, {super.cause, super.stackTrace});
}
