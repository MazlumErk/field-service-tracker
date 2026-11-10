import 'package:field_service_tracker/app/theme/status_colors.dart';
import 'package:field_service_tracker/l10n/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

/// Short-hands for the most used inherited values.
extension BuildContextX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);

  ThemeData get theme => Theme.of(this);

  ColorScheme get colors => Theme.of(this).colorScheme;

  TextTheme get textTheme => Theme.of(this).textTheme;

  StatusColors get statusColors =>
      Theme.of(this).extension<StatusColors>() ?? StatusColors.light;
}
