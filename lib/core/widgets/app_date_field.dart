import 'package:field_service_tracker/app/theme/app_spacing.dart';
import 'package:field_service_tracker/core/extensions/context_extensions.dart';
import 'package:field_service_tracker/core/extensions/date_format_extensions.dart';
import 'package:field_service_tracker/core/utils/calendar_date.dart';
import 'package:material_ui/material_ui.dart';

/// Read-only form field showing a [CalendarDate] that opens the Material
/// date picker (Turkish through the app locale) when tapped.
///
/// Dates are converted with local `DateTime(y, m, d)` and back with
/// `CalendarDate.fromDateTime`, so no timezone shift can change the day.
class AppDateField extends StatelessWidget {
  const AppDateField({
    required this.label,
    required this.value,
    required this.firstDate,
    required this.lastDate,
    required this.onChanged,
    this.helperText,
    this.errorText,
    this.enabled = true,
    super.key,
  });

  final String label;
  final CalendarDate value;
  final CalendarDate firstDate;
  final CalendarDate lastDate;
  final ValueChanged<CalendarDate> onChanged;
  final String? helperText;
  final String? errorText;
  final bool enabled;

  static DateTime _toDateTime(CalendarDate d) =>
      DateTime(d.year, d.month, d.day);

  Future<void> _pick(BuildContext context) async {
    FocusManager.instance.primaryFocus?.unfocus();
    // The picker asserts initialDate within [firstDate, lastDate].
    var initial = value;
    if (initial.isBefore(firstDate)) initial = firstDate;
    if (initial.isAfter(lastDate)) initial = lastDate;

    final picked = await showDatePicker(
      context: context,
      initialDate: _toDateTime(initial),
      firstDate: _toDateTime(firstDate),
      lastDate: _toDateTime(lastDate),
      helpText: label,
    );
    // The dialog returns focus to the last text field when it closes, which
    // would reopen the keyboard; keep the form unfocused instead.
    FocusManager.instance.primaryFocus?.unfocus();
    if (picked != null) onChanged(CalendarDate.fromDateTime(picked));
  }

  @override
  Widget build(BuildContext context) {
    final formatted = context.formatDate(value);
    return Semantics(
      button: true,
      enabled: enabled,
      label: [label, formatted, ?helperText, ?errorText].join('. '),
      excludeSemantics: true,
      child: InkWell(
        onTap: enabled ? () => _pick(context) : null,
        borderRadius: AppRadius.cardRadius,
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            helperText: helperText,
            helperMaxLines: 2,
            errorText: errorText,
            errorMaxLines: 3,
            enabled: enabled,
            suffixIcon: const Icon(Icons.calendar_today_outlined),
          ),
          child: Text(formatted, style: context.textTheme.bodyLarge),
        ),
      ),
    );
  }
}
