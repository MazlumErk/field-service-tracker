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
import 'package:field_service_tracker/features/customers/domain/customer.dart';
import 'package:field_service_tracker/features/customers/presentation/cubit/customer_detail_cubit.dart';
import 'package:field_service_tracker/features/customers/presentation/cubit/customer_detail_state.dart';
import 'package:field_service_tracker/features/customers/presentation/widgets/customer_info_card.dart';
import 'package:field_service_tracker/features/maintenance/presentation/widgets/device_overview_tile.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

enum _MenuAction { delete }

/// Customer detail: contact data, devices with maintenance status, edit and
/// delete actions.
class CustomerDetailPage extends StatelessWidget {
  const CustomerDetailPage({super.key});

  Future<void> _confirmDeletion(
    BuildContext context,
    CustomerDetailState state,
  ) async {
    final l10n = context.l10n;
    final cubit = context.read<CustomerDetailCubit>();
    final impact = state.deletionImpact;
    final name = state.customer?.fullName ?? '';
    final message = impact != null && impact.hasRelatedRecords
        ? l10n.customerDeleteMessageWithRelated(
            name,
            impact.deviceCount,
            impact.maintenanceRecordCount,
          )
        : l10n.customerDeleteMessageSimple(name);

    final confirmed = await showAppConfirmationDialog(
      context: context,
      title: l10n.customerDeleteTitle,
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

  void _onStateChanged(BuildContext context, CustomerDetailState state) {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);

    switch (state.deletionStep) {
      case CustomerDeletionStep.confirming:
        unawaited(_confirmDeletion(context, state));
      case CustomerDeletionStep.deleted:
        messenger.showSnackBar(SnackBar(content: Text(l10n.customerDeleted)));
        context.go(AppRoutes.customers);
      case CustomerDeletionStep.idle ||
          CustomerDeletionStep.loadingImpact ||
          CustomerDeletionStep.deleting:
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

    return BlocConsumer<CustomerDetailCubit, CustomerDetailState>(
      listenWhen: (previous, current) =>
          previous.deletionStep != current.deletionStep ||
          current.deletionFailure != null,
      listener: _onStateChanged,
      builder: (context, state) {
        if (state.status == CustomerDetailStatus.notFound) {
          return const NotFoundPage();
        }

        final customer = state.customer;
        final cubit = context.read<CustomerDetailCubit>();
        return AppScaffold(
          title: l10n.customerDetailTitle,
          actions: customer == null
              ? null
              : [
                  IconButton(
                    tooltip: l10n.commonEdit,
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: state.isBusy
                        ? null
                        : () => unawaited(
                            context.push(AppRoutes.customerEdit(customer.id)),
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
                          title: Text(l10n.customerDelete),
                        ),
                      ),
                    ],
                  ),
                ],
          body: switch (state.status) {
            CustomerDetailStatus.loading => const Center(
              child: CircularProgressIndicator(),
            ),
            CustomerDetailStatus.failure => AppMessageState.error(
              title: l10n.errorLoadTitle,
              message: state.failure?.userMessage(l10n) ?? l10n.errorUnexpected,
              action: OutlinedButton.icon(
                onPressed: cubit.retry,
                icon: const Icon(Icons.refresh),
                label: Text(l10n.commonRetry),
              ),
            ),
            CustomerDetailStatus.success || CustomerDetailStatus.notFound =>
              _DetailContent(customer: customer!, state: state),
          },
        );
      },
    );
  }
}

class _DetailContent extends StatelessWidget {
  const _DetailContent({required this.customer, required this.state});

  final Customer customer;
  final CustomerDetailState state;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final devices = state.devices;

    return Stack(
      children: [
        ListView(
          padding: AppSpacing.screenPadding,
          children: [
            CustomerInfoCard(customer: customer),
            const SizedBox(height: AppSpacing.xl),
            AppSectionHeader(
              '${l10n.customerSectionDevices} (${devices.length})',
              trailing: TextButton.icon(
                key: const ValueKey('customerAddDevice'),
                onPressed: state.isBusy
                    ? null
                    : () => unawaited(
                        context.push(AppRoutes.deviceNew(customer.id)),
                      ),
                icon: const Icon(Icons.add),
                label: Text(l10n.deviceAdd),
              ),
            ),
            if (devices.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                  child: AppMessageState.empty(
                    icon: Icons.water_drop_outlined,
                    title: l10n.customerDevicesEmptyTitle,
                    message: l10n.customerDevicesEmptyMessage,
                  ),
                ),
              )
            else
              for (final overview in devices) ...[
                DeviceOverviewTile(
                  key: ValueKey(overview.device.id),
                  overview: overview,
                  today: state.today,
                  onTap: () => unawaited(
                    context.push(AppRoutes.deviceDetail(overview.device.id)),
                  ),
                ),
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
