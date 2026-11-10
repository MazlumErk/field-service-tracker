/// Turkish-aware text helpers.
///
/// Dart's `toLowerCase` is locale-independent and maps `I` → `i` and leaves
/// `İ` as `i̇` (with a combining dot), which is wrong for Turkish. SQLite's
/// `LIKE` only folds ASCII. These helpers produce stable keys instead.
abstract final class TurkishText {
  /// Lowercases with Turkish rules: `I` → `ı`, `İ` → `i`.
  static String toLower(String input) {
    final buffer = StringBuffer();
    for (final rune in input.runes) {
      final char = String.fromCharCode(rune);
      buffer.write(switch (char) {
        'I' => 'ı',
        'İ' => 'i',
        _ => char.toLowerCase(),
      });
    }
    return buffer.toString();
  }

  /// Uppercases with Turkish rules: `i` → `İ`, `ı` → `I`.
  static String toUpper(String input) {
    final buffer = StringBuffer();
    for (final rune in input.runes) {
      final char = String.fromCharCode(rune);
      buffer.write(switch (char) {
        'i' => 'İ',
        'ı' => 'I',
        _ => char.toUpperCase(),
      });
    }
    return buffer.toString();
  }

  static const Map<String, String> _asciiFold = {
    'ç': 'c',
    'ğ': 'g',
    'ı': 'i',
    'ö': 'o',
    'ş': 's',
    'ü': 'u',
    'â': 'a',
    'î': 'i',
    'û': 'u',
  };

  static final RegExp _whitespace = RegExp(r'\s+');

  /// Search key: Turkish lowercase, diacritics folded to ASCII, whitespace
  /// collapsed. "ŞAHİN", "şahin" and "sahin" all become "sahin", so users can
  /// search with or without a Turkish keyboard.
  static String searchKey(String input) {
    final lower = toLower(input);
    final buffer = StringBuffer();
    for (final rune in lower.runes) {
      final char = String.fromCharCode(rune);
      // Drop a stray combining dot (U+0307) left by non-Turkish input.
      if (rune == 0x0307) continue;
      buffer.write(_asciiFold[char] ?? char);
    }
    return buffer.toString().trim().replaceAll(_whitespace, ' ');
  }

  /// Turkish alphabet (plus q, w, x) in collation order.
  static const String _alphabet = 'abcçdefgğhıijklmnoöpqrsştuüvwxyz';

  static int _rank(String char) {
    final index = _alphabet.indexOf(char);
    // Letters first; anything else (digits, punctuation) after, by code.
    return index >= 0 ? index : _alphabet.length + char.codeUnitAt(0);
  }

  /// Case-insensitive comparison in Turkish alphabetical order
  /// ("Çelik" sorts between "Can" and "Demir", not after "Z").
  static int compare(String a, String b) {
    final left = toLower(a).runes.toList();
    final right = toLower(b).runes.toList();
    final length = left.length < right.length ? left.length : right.length;
    for (var i = 0; i < length; i++) {
      final diff =
          _rank(String.fromCharCode(left[i])) -
          _rank(String.fromCharCode(right[i]));
      if (diff != 0) return diff;
    }
    return left.length - right.length;
  }

  /// Splits a free-text query into normalized search tokens.
  static List<String> searchTokens(String query) {
    final key = searchKey(query);
    if (key.isEmpty) return const [];
    return key.split(' ');
  }
}
