import 'package:equatable/equatable.dart';
import 'package:field_service_tracker/core/errors/app_exception.dart';
import 'package:field_service_tracker/features/customers/domain/customer.dart';

enum CustomerListStatus { loading, success, failure }

/// Single immutable state class with a [status] enum (equatable 3 does not
/// compare runtime types, so subclasses with equal props would be `==`).
final class CustomerListState extends Equatable {
  const CustomerListState({
    this.status = CustomerListStatus.loading,
    this.customers = const [],
    this.query = '',
    this.resultsQuery = '',
    this.failure,
  });

  final CustomerListStatus status;

  /// Already filtered by [query] and sorted (Turkish alphabet) by the
  /// repository.
  final List<CustomerListItem> customers;

  /// The raw text in the search field (may still be debouncing).
  final String query;

  /// The query that produced [customers]. Differs from [query] while the
  /// debounce is pending, so counts and empty states never describe results
  /// of a query that has not run yet.
  final String resultsQuery;
  final AppException? failure;

  bool get isSearching => resultsQuery.trim().isNotEmpty;

  /// Database has no customers at all.
  bool get isEmpty =>
      status == CustomerListStatus.success && customers.isEmpty && !isSearching;

  /// A search returned nothing.
  bool get hasNoResults =>
      status == CustomerListStatus.success && customers.isEmpty && isSearching;

  CustomerListState copyWith({
    CustomerListStatus? status,
    List<CustomerListItem>? customers,
    String? query,
    String? resultsQuery,
    AppException? failure,
  }) {
    return CustomerListState(
      status: status ?? this.status,
      customers: customers ?? this.customers,
      query: query ?? this.query,
      resultsQuery: resultsQuery ?? this.resultsQuery,
      failure: failure,
    );
  }

  @override
  List<Object?> get props => [status, customers, query, resultsQuery, failure];
}
