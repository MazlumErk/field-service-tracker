import 'package:field_service_tracker/app/theme/app_spacing.dart';
import 'package:field_service_tracker/core/extensions/context_extensions.dart';
import 'package:field_service_tracker/core/extensions/date_format_extensions.dart';
import 'package:field_service_tracker/features/customers/domain/customer.dart';
import 'package:field_service_tracker/features/customers/presentation/widgets/customer_list_tile.dart';
import 'package:material_ui/material_ui.dart';

/// Header card of the customer detail page: identity and contact data.
class CustomerInfoCard extends StatelessWidget {
  const CustomerInfoCard({required this.customer, super.key});

  final Customer customer;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = context.textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CustomerInitialsAvatar(customer: customer, radius: 28),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        customer.fullName,
                        style: textTheme.headlineSmall,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      _NumberChip(customer.customerNumber),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            const Divider(),
            const SizedBox(height: AppSpacing.sm),
            _InfoRow(
              icon: Icons.phone_outlined,
              label: l10n.customerFieldPhone,
              value: customer.phone,
            ),
            _InfoRow(
              icon: Icons.location_on_outlined,
              label: l10n.customerFieldAddress,
              value: customer.address,
            ),
            _InfoRow(
              icon: Icons.event_outlined,
              label: l10n.customerRegisteredAt,
              value: context.formatTimestampDate(customer.createdAt),
            ),
          ],
        ),
      ),
    );
  }
}

class _NumberChip extends StatelessWidget {
  const _NumberChip(this.number);

  final String number;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.secondaryContainer,
        borderRadius: BorderRadius.circular(AppSpacing.sm),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: 2,
        ),
        child: Text(
          number,
          style: context.textTheme.labelMedium?.copyWith(
            color: colors.onSecondaryContainer,
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String? value;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final textTheme = context.textTheme;
    final text = value ?? l10n.commonNotProvided;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: colors.onSurfaceVariant),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: textTheme.bodySmall),
                const SizedBox(height: 2),
                Text(
                  text,
                  style: textTheme.bodyMedium?.copyWith(
                    color: value == null
                        ? colors.onSurfaceVariant
                        : colors.onSurface,
                    fontStyle: value == null ? FontStyle.italic : null,
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
