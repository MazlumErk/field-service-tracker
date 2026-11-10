import 'package:field_service_tracker/app/theme/app_spacing.dart';
import 'package:field_service_tracker/core/extensions/context_extensions.dart';
import 'package:field_service_tracker/core/utils/turkish_text.dart';
import 'package:field_service_tracker/features/customers/domain/customer.dart';
import 'package:material_ui/material_ui.dart';

/// One row of the customer list: initials, name, number and device count.
class CustomerListTile extends StatelessWidget {
  const CustomerListTile({required this.item, required this.onTap, super.key});

  final CustomerListItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final customer = item.customer;
    final l10n = context.l10n;
    final colors = context.colors;
    final textTheme = context.textTheme;
    final deviceLabel = l10n.customerDeviceCount(item.deviceCount);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Semantics(
          button: true,
          label:
              '${customer.fullName}, ${customer.customerNumber}, $deviceLabel',
          excludeSemantics: true,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            child: Row(
              children: [
                CustomerInitialsAvatar(customer: customer),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        customer.fullName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.titleSmall,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      // Wraps to a second line on narrow screens or large
                      // text instead of overflowing.
                      Wrap(
                        spacing: AppSpacing.md,
                        runSpacing: AppSpacing.xs,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            customer.customerNumber,
                            style: textTheme.bodySmall,
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.water_drop_outlined,
                                size: 14,
                                color: colors.onSurfaceVariant,
                              ),
                              const SizedBox(width: 2),
                              Flexible(
                                child: Text(
                                  deviceLabel,
                                  style: textTheme.bodySmall,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Icon(Icons.chevron_right, color: colors.onSurfaceVariant),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Circle with the customer's initials (Turkish uppercase).
class CustomerInitialsAvatar extends StatelessWidget {
  const CustomerInitialsAvatar({
    required this.customer,
    this.radius = 20,
    super.key,
  });

  final Customer customer;
  final double radius;

  @override
  Widget build(BuildContext context) {
    String first(String value) =>
        value.isEmpty ? '' : TurkishText.toUpper(value.characters.first);
    final colors = context.colors;
    return CircleAvatar(
      radius: radius,
      backgroundColor: colors.primaryContainer,
      child: Text(
        '${first(customer.firstName)}${first(customer.lastName)}',
        style: context.textTheme.labelLarge?.copyWith(
          color: colors.onPrimaryContainer,
          fontSize: radius * 0.7,
        ),
        textScaler: TextScaler.noScaling,
      ),
    );
  }
}
