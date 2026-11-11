import 'dart:async';

import 'package:field_service_tracker/app/theme/app_spacing.dart';
import 'package:field_service_tracker/core/app_info.dart';
import 'package:field_service_tracker/core/errors/app_exception_messages.dart';
import 'package:field_service_tracker/core/extensions/context_extensions.dart';
import 'package:field_service_tracker/core/widgets/app_confirmation_dialog.dart';
import 'package:field_service_tracker/core/widgets/app_scaffold.dart';
import 'package:field_service_tracker/core/widgets/app_section_header.dart';
import 'package:field_service_tracker/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

/// Settings tab: app identity and version, demo data management, about and
/// licenses.
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  Future<void> _confirmReset(BuildContext context) async {
    final l10n = context.l10n;
    final cubit = context.read<SettingsCubit>();
    final confirmed = await showAppConfirmationDialog(
      context: context,
      title: l10n.settingsResetTitle,
      message: l10n.settingsResetMessage,
      confirmLabel: l10n.settingsResetConfirm,
      cancelLabel: l10n.commonCancel,
      isDestructive: true,
    );
    // Cancel: nothing is called, nothing changes.
    if (confirmed) await cubit.resetDemoData();
  }

  void _onStateChanged(BuildContext context, SettingsState state) {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    switch (state.resetStatus) {
      case DemoResetStatus.success:
        messenger.showSnackBar(SnackBar(content: Text(l10n.settingsResetDone)));
      case DemoResetStatus.failure:
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              state.failure?.userMessage(l10n) ?? l10n.errorUnexpected,
            ),
          ),
        );
      case DemoResetStatus.idle || DemoResetStatus.resetting:
        break;
    }
  }

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
      body: BlocConsumer<SettingsCubit, SettingsState>(
        listenWhen: (previous, current) =>
            previous.resetStatus != current.resetStatus,
        listener: _onStateChanged,
        builder: (context, state) => ListView(
          padding: AppSpacing.screenPadding,
          children: [
            _AppHeader(versionText: versionText),
            const SizedBox(height: AppSpacing.xl),
            AppSectionHeader(l10n.settingsSectionDemo),
            Card(
              clipBehavior: Clip.antiAlias,
              child: ListTile(
                key: const ValueKey('settingsResetDemo'),
                enabled: !state.isResetting,
                leading: Icon(Icons.restart_alt, color: context.colors.error),
                title: Text(l10n.settingsResetDemo),
                subtitle: Text(l10n.settingsResetDemoSubtitle),
                trailing: state.isResetting
                    ? const SizedBox.square(
                        dimension: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.chevron_right),
                onTap: state.isResetting
                    ? null
                    : () => unawaited(_confirmReset(context)),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            AppSectionHeader(l10n.settingsSectionApp),
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
      ),
    );
  }
}

/// App identity: icon, name, tagline and real version
/// (`package_info_plus`, loaded once at startup).
class _AppHeader extends StatelessWidget {
  const _AppHeader({required this.versionText});

  final String versionText;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final textTheme = context.textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: colors.primaryContainer,
                borderRadius: AppRadius.cardRadius,
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Icon(
                  Icons.water_drop_outlined,
                  size: 32,
                  color: colors.primary,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.appTitle, style: textTheme.titleMedium),
                  Text(l10n.settingsTagline, style: textTheme.bodySmall),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    '${l10n.settingsVersion} $versionText',
                    key: const ValueKey('settingsVersion'),
                    style: textTheme.labelMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
