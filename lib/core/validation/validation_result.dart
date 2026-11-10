import 'package:equatable/equatable.dart';

/// Reasons a single field can be invalid. The UI maps each value to a
/// Turkish message; domain code never produces user-facing text.
enum ValidationError {
  required,
  tooLong,
  invalidFormat,
  negative,
  tooLarge,
  inFuture,
  beforeMaintenanceDate,
  empty,

  /// The value must be unique but is already used (e.g. customer number).
  /// Detected by the repository, not by the synchronous validators.
  alreadyInUse,
}

/// Outcome of validating a draft whose fields are described by enum [F].
final class ValidationResult<F extends Enum> extends Equatable {
  const ValidationResult(this.errors);

  const ValidationResult.valid() : errors = const {};

  final Map<F, ValidationError> errors;

  bool get isValid => errors.isEmpty;

  ValidationError? errorFor(F field) => errors[field];

  @override
  List<Object?> get props => [errors];
}
