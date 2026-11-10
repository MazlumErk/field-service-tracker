import 'package:field_service_tracker/app/theme/app_spacing.dart';
import 'package:field_service_tracker/core/app_info.dart';
import 'package:field_service_tracker/core/extensions/context_extensions.dart';
import 'package:field_service_tracker/core/widgets/app_scaffold.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

/// Settings tab: app information and licenses.
///
/// "Reset demo data" is added in Phase 2 together with the database.
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final appInfo = context.read<AppInfo>();
    final versionText = l10n.settingsVersionValue(
      appInfo.version,
      appInfo.buildNumber,
    );

    return AppScaffold(
      title: l10n.navSettings,
      body: ListView(
        padding: AppSpacing.screenPadding,
        children: [
          _SectionHeader(l10n.settingsSectionApp),
          Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: Text(l10n.settingsAbout),
                  subtitle: Text(l10n.settingsAboutDescription),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.tag),
                  title: Text(l10n.settingsVersion),
                  subtitle: Text(versionText),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.description_outlined),
                  title: Text(l10n.settingsLicenses),
                  subtitle: Text(l10n.settingsLicensesSubtitle),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => showLicensePage(
                    context: context,
                    applicationName: l10n.appTitle,
                    applicationVersion: versionText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: AppSpacing.xs,
        bottom: AppSpacing.sm,
      ),
      child: Text(
        text,
        style: context.textTheme.titleMedium?.copyWith(
          color: context.colors.onSurfaceVariant,
        ),
      ),
    );
  }
}
