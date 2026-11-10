import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:field_service_tracker/core/errors/app_exception.dart';
import 'package:field_service_tracker/features/customers/domain/customer.dart';
import 'package:field_service_tracker/features/customers/presentation/cubit/customer_list_cubit.dart';
import 'package:field_service_tracker/features/customers/presentation/cubit/customer_list_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';

void main() {
  late MockCustomerRepository repository;
  final items = [testListItem(id: 1, devices: 2), testListItem(id: 2)];

  setUp(() => repository = MockCustomerRepository());

  void stubWatch(Stream<List<CustomerListItem>> stream, {String? query}) {
    when(() => repository.watchCustomers(query: query ?? any(named: 'query')))
        .thenAnswer((_) => stream);
  }

  test('debounce defaults to 250 ms', () {
    expect(
      CustomerListCubit(repository).debounce,
      const Duration(milliseconds: 250),
    );
  });

  blocTest<CustomerListCubit, CustomerListState>(
    'load emits the customers from the repository',
    setUp: () => stubWatch(Stream.value(items)),
    build: () => CustomerListCubit(repository),
    act: (cubit) => cubit.load(),
    expect: () => [
      CustomerListState(status: CustomerListStatus.success, customers: items),
    ],
  );

  blocTest<CustomerListCubit, CustomerListState>(
    'an empty database is reported as isEmpty',
    setUp: () => stubWatch(Stream.value(const [])),
    build: () => CustomerListCubit(repository),
    act: (cubit) => cubit.load(),
    verify: (cubit) {
      expect(cubit.state.isEmpty, isTrue);
      expect(cubit.state.hasNoResults, isFalse);
    },
  );

  blocTest<CustomerListCubit, CustomerListState>(
    'repository errors become a failure state',
    setUp: () =>
        stubWatch(Stream.error(const DatabaseException('disk I/O error'))),
    build: () => CustomerListCubit(repository),
    act: (cubit) => cubit.load(),
    expect: () => [
      isA<CustomerListState>()
          .having((s) => s.status, 'status', CustomerListStatus.failure)
          .having((s) => s.failure, 'failure', isA<DatabaseException>()),
    ],
  );

  blocTest<CustomerListCubit, CustomerListState>(
    'unexpected errors are wrapped in UnexpectedException',
    setUp: () => stubWatch(Stream.error(StateError('bug'))),
    build: () => CustomerListCubit(repository),
    act: (cubit) => cubit.load(),
    verify: (cubit) => expect(cubit.state.failure, isA<UnexpectedException>()),
  );

  blocTest<CustomerListCubit, CustomerListState>(
    'typing quickly only queries the last text after the debounce',
    setUp: () {
      stubWatch(Stream.value(items), query: '');
      stubWatch(Stream.value(const []), query: 'şey');
      stubWatch(Stream.value([items.first]), query: 'şeyma');
    },
    build: () => CustomerListCubit(repository),
    act: (cubit) async {
      cubit.load();
      await Future<void>.delayed(Duration.zero);
      cubit
        ..queryChanged('şey')
        ..queryChanged('şeyma');
    },
    wait: const Duration(milliseconds: 300),
    verify: (cubit) {
      verify(() => repository.watchCustomers(query: '')).called(1);
      verifyNever(() => repository.watchCustomers(query: 'şey'));
      verify(() => repository.watchCustomers(query: 'şeyma')).called(1);
      expect(cubit.state.query, 'şeyma');
      expect(cubit.state.customers, [items.first]);
    },
  );

  blocTest<CustomerListCubit, CustomerListState>(
    'a search without matches is reported as hasNoResults',
    setUp: () {
      stubWatch(Stream.value(items), query: '');
      stubWatch(Stream.value(const []), query: 'zzz');
    },
    build: () => CustomerListCubit(
      repository,
      debounce: const Duration(milliseconds: 10),
    ),
    act: (cubit) async {
      cubit.load();
      await Future<void>.delayed(Duration.zero);
      cubit.queryChanged('zzz');
    },
    wait: const Duration(milliseconds: 50),
    verify: (cubit) {
      expect(cubit.state.hasNoResults, isTrue);
      expect(cubit.state.isEmpty, isFalse);
    },
  );

  blocTest<CustomerListCubit, CustomerListState>(
    'clearQuery resubscribes immediately with an empty query',
    setUp: () => stubWatch(Stream.value(items)),
    build: () => CustomerListCubit(repository),
    seed: () => const CustomerListState(
      status: CustomerListStatus.success,
      query: 'abc',
      resultsQuery: 'abc',
    ),
    act: (cubit) => cubit.clearQuery(),
    verify: (cubit) {
      verify(() => repository.watchCustomers(query: '')).called(1);
      expect(cubit.state.query, '');
      expect(cubit.state.customers, items);
    },
  );

  blocTest<CustomerListCubit, CustomerListState>(
    'retry after a failure loads again',
    setUp: () => stubWatch(Stream.value(items)),
    build: () => CustomerListCubit(repository),
    seed: () => const CustomerListState(
      status: CustomerListStatus.failure,
      failure: DatabaseException('x'),
    ),
    act: (cubit) => cubit.retry(),
    expect: () => [
      const CustomerListState(),
      CustomerListState(status: CustomerListStatus.success, customers: items),
    ],
  );

  group('subscription lifecycle', () {
    test('a new query cancels the previous stream', () async {
      var firstCancelled = false;
      final first = StreamController<List<CustomerListItem>>(
        onCancel: () => firstCancelled = true,
      );
      final second = StreamController<List<CustomerListItem>>();
      stubWatch(first.stream, query: '');
      stubWatch(second.stream, query: 'a');

      final cubit = CustomerListCubit(repository, debounce: Duration.zero)
        ..load();
      cubit.queryChanged('a');
      await Future<void>.delayed(const Duration(milliseconds: 5));

      expect(firstCancelled, isTrue);
      expect(second.hasListener, isTrue);
      await cubit.close();
      expect(second.hasListener, isFalse);
      await first.close();
      await second.close();
    });

    test('close cancels the stream and a pending debounce', () async {
      final controller = StreamController<List<CustomerListItem>>();
      stubWatch(controller.stream, query: '');

      final cubit = CustomerListCubit(repository)..load();
      expect(controller.hasListener, isTrue);
      cubit.queryChanged('late');
      await cubit.close();

      expect(controller.hasListener, isFalse);
      await Future<void>.delayed(const Duration(milliseconds: 300));
      verifyNever(() => repository.watchCustomers(query: 'late'));
      await controller.close();
    });
  });
}
