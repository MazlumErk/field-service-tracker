/// Customer number normalization rule.
///
/// " fst - 0001 " and "FST-0001" are the same customer number. The
/// normalized value is what gets stored, compared and made unique.
abstract final class CustomerNumber {
  static const int maxLength = 20;

  /// Allowed characters after normalization: ASCII letters, digits and
  /// `- _ / .` separators, starting with a letter or digit.
  static final RegExp allowedPattern = RegExp(r'^[A-Z0-9][A-Z0-9\-_/.]*$');

  static final RegExp _whitespace = RegExp(r'\s+');

  /// Removes all whitespace and uppercases.
  ///
  /// Customer numbers are ASCII codes, so the locale-independent
  /// `toUpperCase` is intended here (`i` and `ı` both become `I`); Turkish
  /// letters such as `Ş` are then rejected by [allowedPattern].
  static String normalize(String input) =>
      input.replaceAll(_whitespace, '').toUpperCase();

  static bool isValidFormat(String normalized) =>
      allowedPattern.hasMatch(normalized);
}
