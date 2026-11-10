import 'package:field_service_tracker/app/router/app_routes.dart';
import 'package:field_service_tracker/core/extensions/context_extensions.dart';
import 'package:field_service_tracker/core/widgets/app_message_state.dart';
import 'package:field_service_tracker/core/widgets/app_scaffold.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

/// Shown for unknown routes and malformed ids (e.g. `/customers/abc`).
class NotFoundPage extends StatelessWidget {
  const NotFoundPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AppScaffold(
      title: l10n.notFoundTitle,
      body: AppMessageState.error(
        title: l10n.notFoundTitle,
        message: l10n.notFoundMessage,
        action: FilledButton.icon(
          onPressed: () => context.go(AppRoutes.dashboard),
          icon: const Icon(Icons.space_dashboard_outlined),
          label: Text(l10n.backToDashboard),
        ),
      ),
    );
  }
}
