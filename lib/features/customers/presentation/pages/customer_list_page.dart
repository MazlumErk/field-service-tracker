import 'dart:async';

import 'package:field_service_tracker/app/router/app_routes.dart';
import 'package:field_service_tracker/app/theme/app_spacing.dart';
import 'package:field_service_tracker/core/errors/app_exception_messages.dart';
import 'package:field_service_tracker/core/extensions/context_extensions.dart';
import 'package:field_service_tracker/core/widgets/app_list_skeleton.dart';
import 'package:field_service_tracker/core/widgets/app_message_state.dart';
import 'package:field_service_tracker/core/widgets/app_scaffold.dart';
import 'package:field_service_tracker/core/widgets/app_search_field.dart';
import 'package:field_service_tracker/features/customers/presentation/cubit/customer_list_cubit.dart';
import 'package:field_service_tracker/features/customers/presentation/cubit/customer_list_state.dart';
import 'package:field_service_tracker/features/customers/presentation/widgets/customer_list_tile.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

/// "Müşteriler" tab: searchable customer list.
class CustomerListPage extends StatefulWidget {
  const CustomerListPage({super.key});

  @override
  State<CustomerListPage> createState() => _CustomerListPageState();
}

class _CustomerListPageState extends State<CustomerListPage> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _clearSearch() {
    _searchController.clear();
    context.read<CustomerListCubit>().clearQuery();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cubit = context.read<CustomerListCubit>();

    return AppScaffold(
      title: l10n.navCustomers,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openRoute(context, AppRoutes.customerNew),
        icon: const Icon(Icons.person_add_alt_1_outlined),
        label: Text(l10n.customerAdd),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenHorizontal,
              AppSpacing.sm,
              AppSpacing.screenHorizontal,
              AppSpacing.sm,
            ),
            child: AppSearchField(
              controller: _searchController,
              hintText: l10n.customerSearchHint,
              clearTooltip: l10n.customerSearchClear,
              onChanged: cubit.queryChanged,
              onCleared: cubit.clearQuery,
            ),
          ),
          Expanded(
            child: BlocBuilder<CustomerListCubit, CustomerListState>(
              builder: _buildBody,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, CustomerListState state) {
    final l10n = context.l10n;
    final cubit = context.read<CustomerListCubit>();

    switch (state.status) {
      case CustomerListStatus.loading:
        return const AppListSkeleton();
      case CustomerListStatus.failure:
        return AppMessageState.error(
          title: l10n.errorLoadTitle,
          message: (state.failure?.userMessage(l10n)) ?? l10n.errorUnexpected,
          action: OutlinedButton.icon(
            onPressed: cubit.retry,
            icon: const Icon(Icons.refresh),
            label: Text(l10n.commonRetry),
          ),
        );
      case CustomerListStatus.success when state.isEmpty:
        return AppMessageState.empty(
          icon: Icons.people_outline,
          title: l10n.customerListEmptyTitle,
          message: l10n.customerListEmptyMessage,
          action: FilledButton.icon(
            onPressed: () => _openRoute(context, AppRoutes.customerNew),
            icon: const Icon(Icons.person_add_alt_1_outlined),
            label: Text(l10n.customerAdd),
          ),
        );
      case CustomerListStatus.success when state.hasNoResults:
        return AppMessageState.empty(
          icon: Icons.search_off,
          title: l10n.customerNoResultsTitle,
          message: l10n.customerNoResultsMessage(state.resultsQuery.trim()),
          action: OutlinedButton(
            onPressed: _clearSearch,
            child: Text(l10n.customerSearchClear),
          ),
        );
      case CustomerListStatus.success:
        return _CustomerList(state: state);
    }
  }
}

class _CustomerList extends StatelessWidget {
  const _CustomerList({required this.state});

  final CustomerListState state;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final customers = state.customers;
    final countText = state.isSearching
        ? l10n.customerResultCount(customers.length)
        : l10n.customerCount(customers.length);

    return ListView.separated(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      // Bottom padding keeps the last card clear of the FAB.
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenHorizontal,
        0,
        AppSpacing.screenHorizontal,
        96,
      ),
      itemCount: customers.length + 1,
      separatorBuilder: (_, index) =>
          SizedBox(height: index == 0 ? AppSpacing.xs : AppSpacing.sm),
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(left: AppSpacing.xs),
            child: Semantics(
              liveRegion: true,
              child: Text(countText, style: context.textTheme.bodySmall),
            ),
          );
        }
        final item = customers[index - 1];
        return CustomerListTile(
          key: ValueKey(item.customer.id),
          item: item,
          onTap: () =>
              _openRoute(context, AppRoutes.customerDetail(item.customer.id)),
        );
      },
    );
  }
}

/// Opens [location] above the list. The search field is unfocused first so
/// that returning to the list does not reopen the keyboard (which would also
/// hide the confirmation snackbar).
void _openRoute(BuildContext context, String location) {
  FocusManager.instance.primaryFocus?.unfocus();
  unawaited(context.push(location));
}
