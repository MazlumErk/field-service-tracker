import 'dart:async';

import 'package:field_service_tracker/app/router/app_routes.dart';
import 'package:field_service_tracker/app/theme/app_spacing.dart';
import 'package:field_service_tracker/core/errors/app_exception_messages.dart';
import 'package:field_service_tracker/core/extensions/context_extensions.dart';
import 'package:field_service_tracker/core/widgets/app_confirmation_dialog.dart';
import 'package:field_service_tracker/core/widgets/app_message_state.dart';
import 'package:field_service_tracker/core/widgets/app_scaffold.dart';
import 'package:field_service_tracker/core/widgets/app_section_header.dart';
import 'package:field_service_tracker/core/widgets/not_found_page.dart';
import 'package:field_service_tracker/features/devices/presentation/cubit/device_detail_cubit.dart';
import 'package:field_service_tracker/features/devices/presentation/cubit/device_detail_state.dart';
import 'package:field_service_tracker/features/devices/presentation/widgets/device_summary_card.dart';
import 'package:field_service_tracker/features/maintenance/presentation/widgets/maintenance_record_card.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

enum _MenuAction { delete }

/// Device detail: summary with maintenance status, owner, read-only
/// maintenance history, edit and delete actions.
class DeviceDetailPage extends StatelessWidget {
  const DeviceDetailPage({super.key});

  Future<void> _confirmDeletion(
    BuildContext context,
    DeviceDetailState state,
  ) async {
    final l10n = context.l10n;
    final cubit = context.read<DeviceDetailCubit>();
    final impact = state.deletionImpact;
    final model = state.overview?.device.model ?? '';
    final message = impact != null && impact.hasMaintenanceHistory
        ? l10n.deviceDeleteMessageWithHistory(
            model,
            impact.maintenanceRecordCount,
            impact.filterReplacementCount,
          )
        : l10n.deviceDeleteMessageSimple(model);

    final confirmed = await showAppConfirmationDialog(
      context: context,
      title: l10n.deviceDeleteTitle,
      message: message,
      confirmLabel: l10n.commonDelete,
      cancelLabel: l10n.commonCancel,
      isDestructive: true,
    );
    if (confirmed) {
      await cubit.confirmDeletion();
    } else {
      cubit.cancelDeletion();
    }
  }

  void _onStateChanged(BuildContext context, DeviceDetailState state) {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);

    switch (state.deletionStep) {
      case DeviceDeletionStep.confirming:
        unawaited(_confirmDeletion(context, state));
      case DeviceDeletionStep.deleted:
        messenger.showSnackBar(SnackBar(content: Text(l10n.deviceDeleted)));
        final customerId = state.overview?.customerId;
        context.go(
          customerId == null
              ? AppRoutes.customers
              : AppRoutes.customerDetail(customerId),
        );
      case DeviceDeletionStep.idle ||
          DeviceDeletionStep.loadingImpact ||
          DeviceDeletionStep.deleting:
        break;
    }

    final deletionFailure = state.deletionFailure;
    if (deletionFailure != null) {
      messenger.showSnackBar(
        SnackBar(content: Text(deletionFailure.userMessage(l10n))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return BlocConsumer<DeviceDetailCubit, DeviceDetailState>(
      listenWhen: (previous, current) =>
          previous.deletionStep != current.deletionStep ||
          current.deletionFailure != null,
      listener: _onStateChanged,
      builder: (context, state) {
        if (state.status == DeviceDetailStatus.notFound) {
          return const NotFoundPage();
        }

        final cubit = context.read<DeviceDetailCubit>();
        final hasContent = state.status == DeviceDetailStatus.success;
        return AppScaffold(
          title: l10n.deviceDetailTitle,
          actions: !hasContent
              ? null
              : [
                  IconButton(
                    tooltip: l10n.commonEdit,
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: state.isBusy
                        ? null
                        : () => unawaited(
                            context.push(AppRoutes.deviceEdit(cubit.deviceId)),
                          ),
                  ),
                  PopupMenuButton<_MenuAction>(
                    tooltip: l10n.commonMoreActions,
                    enabled: !state.isBusy,
                    onSelected: (_) => unawaited(cubit.requestDeletion()),
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: _MenuAction.delete,
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(
                            Icons.delete_outline,
                            color: context.colors.error,
                          ),
                          title: Text(l10n.deviceDelete),
                        ),
                      ),
                    ],
                  ),
                ],
          body: switch (state.status) {
            DeviceDetailStatus.loading => const Center(
              child: CircularProgressIndicator(),
            ),
            DeviceDetailStatus.failure => AppMessageState.error(
              title: l10n.errorLoadTitle,
              message: state.failure?.userMessage(l10n) ?? l10n.errorUnexpected,
              action: OutlinedButton.icon(
                onPressed: cubit.retry,
                icon: const Icon(Icons.refresh),
                label: Text(l10n.commonRetry),
              ),
            ),
            DeviceDetailStatus.success ||
            DeviceDetailStatus.notFound => _DetailContent(state: state),
          },
        );
      },
    );
  }
}

class _DetailContent extends StatelessWidget {
  const _DetailContent({required this.state});

  final DeviceDetailState state;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final overview = state.overview!;
    final history = state.history;

    return Stack(
      children: [
        ListView(
          padding: AppSpacing.screenPadding,
          children: [
            DeviceSummaryCard(
              state: state,
              // `go`, not `push`: jumps to the customer inside the
              // Müşteriler tab (stack: list → customer). Pushing would let
              // customer → device → customer → … grow without limit.
              onCustomerTap: () =>
                  context.go(AppRoutes.customerDetail(overview.customerId)),
            ),
            const SizedBox(height: AppSpacing.lg),
            FilledButton.tonalIcon(
              onPressed: state.isBusy
                  ? null
                  : () => unawaited(
                      context.push(
                        AppRoutes.maintenanceNew(overview.device.id),
                      ),
                    ),
              icon: const Icon(Icons.add_task),
              label: Text(l10n.maintenanceAdd),
            ),
            const SizedBox(height: AppSpacing.xl),
            AppSectionHeader('${l10n.maintenanceHistory} (${history.length})'),
            if (history.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                  child: AppMessageState.empty(
                    icon: Icons.history,
                    title: l10n.maintenanceHistoryEmptyTitle,
                    message: l10n.maintenanceHistoryEmptyMessage,
                  ),
                ),
              )
            else
              for (final record in history) ...[
                MaintenanceRecordCard(key: ValueKey(record.id), record: record),
                const SizedBox(height: AppSpacing.sm),
              ],
          ],
        ),
        if (state.isBusy)
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: LinearProgressIndicator(),
          ),
      ],
    );
  }
}
