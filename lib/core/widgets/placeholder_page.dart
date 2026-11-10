import 'package:field_service_tracker/core/extensions/context_extensions.dart';
import 'package:field_service_tracker/core/widgets/app_message_state.dart';
import 'package:field_service_tracker/core/widgets/app_scaffold.dart';
import 'package:material_ui/material_ui.dart';

/// Temporary page used by routes whose feature is not implemented yet.
///
/// Removed feature by feature in later phases; it exists so navigation can be
/// wired and tested from Phase 1 on.
class PlaceholderPage extends StatelessWidget {
  const PlaceholderPage({required this.title, super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: title,
      body: AppMessageState.empty(
        icon: Icons.construction_outlined,
        title: context.l10n.placeholderTitle,
        message: context.l10n.placeholderMessage,
      ),
    );
  }
}
