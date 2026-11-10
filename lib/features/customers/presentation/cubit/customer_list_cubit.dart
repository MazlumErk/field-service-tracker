import 'dart:async';

import 'package:field_service_tracker/core/errors/app_exception.dart';
import 'package:field_service_tracker/features/customers/domain/customer.dart';
import 'package:field_service_tracker/features/customers/domain/customer_repository.dart';
import 'package:field_service_tracker/features/customers/presentation/cubit/customer_list_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Customer list with debounced live search.
///
/// Holds exactly one repository subscription at a time: changing the query
/// cancels the previous stream before subscribing to the new one. Everything
/// is cancelled in [close].
class CustomerListCubit extends Cubit<CustomerListState> {
  CustomerListCubit(
    this._repository, {
    this.debounce = const Duration(milliseconds: 250),
  }) : super(const CustomerListState());

  final CustomerRepository _repository;

  /// Delay between the last keystroke and the query (250 ms by default).
  final Duration debounce;

  StreamSubscription<List<CustomerListItem>>? _subscription;
  Timer? _debounceTimer;

  /// Starts listening with the current query (initial load).
  void load() => _subscribe(state.query);

  /// Called on every keystroke; the query runs after [debounce].
  void queryChanged(String query) {
    if (query == state.query) return;
    emit(state.copyWith(query: query, failure: state.failure));
    _debounceTimer?.cancel();
    _debounceTimer = Timer(debounce, () => _subscribe(query));
  }

  /// Clears the search immediately (no debounce).
  void clearQuery() {
    _debounceTimer?.cancel();
    emit(state.copyWith(query: ''));
    _subscribe('');
  }

  /// Re-subscribes after a failure.
  void retry() {
    emit(state.copyWith(status: CustomerListStatus.loading));
    _subscribe(state.query);
  }

  void _subscribe(String query) {
    unawaited(_subscription?.cancel());
    _subscription = _repository
        .watchCustomers(query: query)
        .listen(
          (customers) {
            // Ignore late results of an outdated query.
            if (query != state.query) return;
            emit(
              state.copyWith(
                status: CustomerListStatus.success,
                customers: customers,
                resultsQuery: query,
              ),
            );
          },
          onError: (Object error, StackTrace stackTrace) {
            emit(
              state.copyWith(
                status: CustomerListStatus.failure,
                failure: toAppException(error, stackTrace),
              ),
            );
          },
        );
  }

  @override
  Future<void> close() async {
    _debounceTimer?.cancel();
    await _subscription?.cancel();
    return super.close();
  }
}
