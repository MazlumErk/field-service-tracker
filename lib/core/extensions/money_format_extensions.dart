import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

/// Formats integer kuruş amounts as Turkish lira for display
/// (e.g. 125050 → "₺1.250,50").
extension MoneyFormatContext on BuildContext {
  String formatKurus(int kurus) => NumberFormat.currency(
    locale: Localizations.localeOf(this).toLanguageTag(),
    symbol: '₺',
    decimalDigits: 2,
  ).format(kurus / 100);
}
