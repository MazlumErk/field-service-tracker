import 'package:material_ui/material_ui.dart';

/// Search input with a leading search icon and a clear button that appears
/// once text is entered. Owns no state; pass a [controller].
class AppSearchField extends StatelessWidget {
  const AppSearchField({
    required this.controller,
    required this.hintText,
    required this.clearTooltip,
    required this.onChanged,
    required this.onCleared,
    super.key,
  });

  final TextEditingController controller;
  final String hintText;
  final String clearTooltip;
  final ValueChanged<String> onChanged;
  final VoidCallback onCleared;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        return TextField(
          controller: controller,
          onChanged: onChanged,
          textInputAction: TextInputAction.search,
          autocorrect: false,
          decoration: InputDecoration(
            hintText: hintText,
            prefixIcon: const Icon(Icons.search),
            suffixIcon: value.text.isEmpty
                ? null
                : IconButton(
                    tooltip: clearTooltip,
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      controller.clear();
                      onCleared();
                    },
                  ),
          ),
        );
      },
    );
  }
}
