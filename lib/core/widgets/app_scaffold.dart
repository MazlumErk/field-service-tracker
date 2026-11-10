import 'package:material_ui/material_ui.dart';

/// Standard page frame: top bar with a page title plus a body that respects
/// safe areas. Keeps every screen visually consistent.
class AppScaffold extends StatelessWidget {
  const AppScaffold({
    required this.title,
    required this.body,
    this.actions,
    this.floatingActionButton,
    super.key,
  });

  final String title;
  final Widget body;
  final List<Widget>? actions;
  final Widget? floatingActionButton;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
        actions: actions,
      ),
      body: SafeArea(top: false, child: body),
      floatingActionButton: floatingActionButton,
    );
  }
}
