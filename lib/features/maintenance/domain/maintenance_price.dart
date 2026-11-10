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

  /// Parses a Turkish-formatted TL amount into kuruş.
  ///
  /// Accepted: `750`, `1250,5`, `1.250`, `1.250,50`, `₺1.250,50`, `1250 TL`.
  /// Comma is the decimal separator; dots are only accepted as thousands
  /// separators in groups of three. Returns `null` for anything else,
  /// including negative values.
  static int? parseToKurus(String input) {
    var text = input.trim().replaceAll('₺', '').replaceAll(' ', '');
    if (text.toUpperCase().endsWith('TL')) {
      text = text.substring(0, text.length - 2);
    }
    if (text.isEmpty) return null;

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
