import 'package:field_service_tracker/app/theme/app_theme.dart';
import 'package:field_service_tracker/core/widgets/app_message_state.dart';
import 'package:field_service_tracker/l10n/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

/// Shown instead of the app when the database cannot be opened.
/// The technical error is logged by `main`; the user sees a calm message.
class StartupErrorApp extends StatelessWidget {
  const StartupErrorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      locale: const Locale('tr'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        ...GlobalMaterialLocalizations.delegates,
      ],
      home: Builder(
        builder: (context) {
          final l10n = AppLocalizations.of(context);
          return Scaffold(
            body: SafeArea(
              child: AppMessageState.error(
                title: l10n.startupErrorTitle,
                message: l10n.startupErrorMessage,
              ),
            ),
          );
        },
      ),
    );
  }
}
