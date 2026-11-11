import 'package:field_service_tracker/l10n/app_localizations.dart';

/// Plain-language distance to the next maintenance:
/// "12 gün gecikti", "Bakım bugün", "5 gün kaldı", or no-record text.
///
/// [days] is `today.daysUntil(nextMaintenanceDate)`; `null` = never serviced.
/// Shared by the device detail, dashboard and maintenance list.
String maintenanceDueText(AppLocalizations l10n, int? days) {
  if (days == null) return l10n.deviceNeverServiced;
  if (days < 0) return l10n.deviceOverdueDays(-days);
  if (days == 0) return l10n.deviceDueToday;
  return l10n.deviceDaysLeft(days);
}
