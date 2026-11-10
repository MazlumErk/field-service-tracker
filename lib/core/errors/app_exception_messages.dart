import 'package:field_service_tracker/core/errors/app_exception.dart';
import 'package:field_service_tracker/l10n/app_localizations.dart';

/// Maps technical [AppException]s to short Turkish messages for the UI.
/// Raw exception text is never shown to users.
extension AppExceptionMessage on AppException {
  String userMessage(AppLocalizations l10n) => switch (this) {
    NotFoundException() => l10n.errorNotFound,
    DuplicateCustomerNumberException() => l10n.errorDuplicateCustomerNumber,
    ValidationException() => l10n.errorValidation,
    ConstraintViolationException() || DatabaseException() => l10n.errorDatabase,
    UnexpectedException() => l10n.errorUnexpected,
  };
}
