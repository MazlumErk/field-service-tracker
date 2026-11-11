/// Parsing and limits for maintenance prices.
///
/// Prices are stored as integer kuruş (1 TL = 100 kuruş) to avoid floating
/// point errors.
abstract final class MaintenancePrice {
  /// 1,000,000.00 TL — a sanity ceiling against typos.
  static const int maxKurus = 100000000;

  static final RegExp _grouped = RegExp(r'^\d{1,3}(\.\d{3})+$');
  static final RegExp _digits = RegExp(r'^\d+$');
  static final RegExp _decimals = RegExp(r'^\d{1,2}$');

  /// A single dot followed by one or two digits ("1250.50", "1.5").
  static final RegExp _dotDecimal = RegExp(r'^\d+\.\d{1,2}$');

  /// Parses a TL amount into kuruş.
  ///
  /// Primary (Turkish) format: comma = decimal separator, dots = thousands
  /// separators in groups of three — `750`, `1250,5`, `1.250`, `1.250,50`,
  /// `₺1.250,50`, `1250 TL`.
  ///
  /// Also accepted, because phone keyboards often only offer a dot: a single
  /// dot followed by **one or two** digits is a decimal point (`1250.50`,
  /// `1.5`). This is unambiguous: a Turkish thousands group always has three
  /// digits, so `1.250` stays one thousand two hundred fifty.
  ///
  /// Returns `null` for anything else (e.g. `1.250.50`, `1250.505`,
  /// `12,345`, negative values) — ambiguous input is never guessed.
  static int? parseToKurus(String input) {
    var text = input.trim().replaceAll('₺', '').replaceAll(' ', '');
    if (text.toUpperCase().endsWith('TL')) {
      text = text.substring(0, text.length - 2);
    }
    if (text.isEmpty) return null;

    if (!text.contains(',') && _dotDecimal.hasMatch(text)) {
      text = text.replaceFirst('.', ',');
    }

    final parts = text.split(',');
    if (parts.length > 2) return null;

    final whole = parts[0];
    final String wholeDigits;
    if (_digits.hasMatch(whole)) {
      wholeDigits = whole;
    } else if (_grouped.hasMatch(whole)) {
      wholeDigits = whole.replaceAll('.', '');
    } else {
      return null;
    }

    var kurus = 0;
    if (parts.length == 2) {
      final fraction = parts[1];
      if (!_decimals.hasMatch(fraction)) return null;
      kurus = int.parse(fraction.padRight(2, '0'));
    }

    // Range limits are a validation concern ([isValidKurus]); this only
    // guards against integer overflow on absurd input.
    if (wholeDigits.length > 12) return null;
    return int.parse(wholeDigits) * 100 + kurus;
  }

  static bool isValidKurus(int kurus) => kurus >= 0 && kurus <= maxKurus;
}
