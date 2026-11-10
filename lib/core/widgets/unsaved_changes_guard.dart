import 'dart:async';

import 'package:field_service_tracker/core/extensions/context_extensions.dart';
import 'package:field_service_tracker/core/widgets/app_confirmation_dialog.dart';
import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';

/// Asks for confirmation before leaving a form with unsaved changes.
///
/// Built on [PopScope], so the app bar back button (`Navigator.maybePop`)
/// and the Android system back button behave identically. When
/// [hasChanges] is `false` the route pops without a dialog.
///
/// Programmatic navigation after a successful save (`context.pop()`,
/// `pushReplacement`) is not intercepted: `Navigator.pop` ignores
/// [PopScope], and forms report `hasChanges == false` once saved.
class UnsavedChangesGuard extends StatelessWidget {
  const UnsavedChangesGuard({
    required this.hasChanges,
    required this.child,
    super.key,
  });

  final ValueListenable<bool> hasChanges;
  final Widget child;

  Future<void> _confirmLeave(BuildContext context) async {
    final l10n = context.l10n;
    final navigator = Navigator.of(context);
    final discard = await showAppConfirmationDialog(
      context: context,
      title: l10n.unsavedChangesTitle,
      message: l10n.unsavedChangesMessage,
      confirmLabel: l10n.unsavedChangesDiscard,
      cancelLabel: l10n.commonCancel,
      isDestructive: true,
    );
    if (discard) {
      if (navigator.mounted) navigator.pop();
    } else {
      // The dialog hands focus back to the last text field, which reopens
      // the keyboard; the next Android back press would then only close it.
      FocusManager.instance.primaryFocus?.unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: hasChanges,
      builder: (context, dirty, child) => PopScope<Object?>(
        canPop: !dirty,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) unawaited(_confirmLeave(context));
        },
        child: child!,
      ),
      child: child,
    );
  }
}
