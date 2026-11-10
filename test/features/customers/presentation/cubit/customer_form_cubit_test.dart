import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:field_service_tracker/core/errors/app_exception.dart';
import 'package:field_service_tracker/core/validation/validation_result.dart';
import 'package:field_service_tracker/features/customers/domain/customer.dart';
import 'package:field_service_tracker/features/customers/domain/customer_draft.dart';
import 'package:field_service_tracker/features/customers/domain/customer_validator.dart';
import 'package:field_service_tracker/features/customers/presentation/cubit/customer_form_cubit.dart';
import 'package:field_service_tracker/features/customers/presentation/cubit/customer_form_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';

void main() {
  late MockCustomerRepository repository;
  final saved = testCustomer(id: 21, number: 'FST-0021');
  const validDraft = CustomerDraft(
    customerNumber: 'fst-0021',
    firstName: 'Deniz',
    lastName: 'Ak',
  );
  const editing = CustomerFormState(status: CustomerFormStatus.editing);

  setUpAll(registerMockFallbacks);
  setUp(() => repository = MockCustomerRepository());

  group('create', () {
    blocTest<CustomerFormCubit, CustomerFormState>(
      'valid input is saved',
      setUp: () =>
          when(() => repository.createCustomer(validDraft))
              .thenAnswer((_) async => saved),
      build: () => CustomerFormCubit.create(repository),
      act: (cubit) => cubit.submit(validDraft),
      expect: () => [
        const CustomerFormState(status: CustomerFormStatus.submitting),
        CustomerFormState(
          status: CustomerFormStatus.success,
          savedCustomer: saved,
        ),
      ],
    );

    blocTest<CustomerFormCubit, CustomerFormState>(
      'invalid input shows field errors and never calls the repository',
      build: () => CustomerFormCubit.create(repository),
      act: (cubit) => cubit.submit(
        const CustomerDraft(
          customerNumber: 'ŞUBE 1',
          firstName: ' ',
          lastName: '',
          phone: '12',
        ),
      ),
      expect: () => [
        const CustomerFormState(
          status: CustomerFormStatus.editing,
          fieldErrors: {
            CustomerField.customerNumber: ValidationError.invalidFormat,
            CustomerField.firstName: ValidationError.required,
            CustomerField.lastName: ValidationError.required,
            CustomerField.phone: ValidationError.invalidFormat,
          },
        ),
      ],
      verify: (_) => verifyNever(() => repository.createCustomer(any())),
    );

    blocTest<CustomerFormCubit, CustomerFormState>(
      'a duplicate number is shown under the number field',
      setUp: () =>
          when(() => repository.createCustomer(any()))
              .thenThrow(const DuplicateCustomerNumberException('FST-0021')),
      build: () => CustomerFormCubit.create(repository),
      act: (cubit) => cubit.submit(validDraft),
      expect: () => [
        const CustomerFormState(status: CustomerFormStatus.submitting),
        const CustomerFormState(
          status: CustomerFormStatus.editing,
          fieldErrors: {
            CustomerField.customerNumber: ValidationError.alreadyInUse,
          },
        ),
      ],
    );

    blocTest<CustomerFormCubit, CustomerFormState>(
      'storage errors are reported without losing the input state',
      setUp: () =>
          when(() => repository.createCustomer(any()))
              .thenThrow(const DatabaseException('disk full')),
      build: () => CustomerFormCubit.create(repository),
      act: (cubit) => cubit.submit(validDraft),
      expect: () => [
        const CustomerFormState(status: CustomerFormStatus.submitting),
        isA<CustomerFormState>()
            .having((s) => s.status, 'status', CustomerFormStatus.editing)
            .having((s) => s.failure, 'failure', isA<DatabaseException>()),
      ],
    );

    test('a second submit while saving is ignored', () async {
      final completer = Completer<Customer>();
      when(() => repository.createCustomer(any()))
          .thenAnswer((_) => completer.future);
      final cubit = CustomerFormCubit.create(repository);

      final first = cubit.submit(validDraft);
      final second = cubit.submit(validDraft);
      final third = cubit.submit(validDraft);
      completer.complete(saved);
      await Future.wait([first, second, third]);

      verify(() => repository.createCustomer(any())).called(1);
      expect(cubit.state.status, CustomerFormStatus.success);

      await cubit.submit(validDraft); // also ignored after success
      verifyNever(() => repository.createCustomer(any()));
      await cubit.close();
    });

    blocTest<CustomerFormCubit, CustomerFormState>(
      'editing a field clears only its error',
      build: () => CustomerFormCubit.create(repository),
      seed: () => const CustomerFormState(
        status: CustomerFormStatus.editing,
        fieldErrors: {
          CustomerField.firstName: ValidationError.required,
          CustomerField.lastName: ValidationError.required,
        },
      ),
      act: (cubit) => cubit
        ..fieldChanged(CustomerField.firstName)
        ..fieldChanged(CustomerField.phone),
      expect: () => [
        const CustomerFormState(
          status: CustomerFormStatus.editing,
          fieldErrors: {CustomerField.lastName: ValidationError.required},
        ),
      ],
    );
  });

  group('edit', () {
    final existing = testCustomer(id: 3, number: 'FST-0003');

    blocTest<CustomerFormCubit, CustomerFormState>(
      'load prefills the existing customer',
      setUp: () =>
          when(() => repository.getCustomer(3))
              .thenAnswer((_) async => existing),
      build: () => CustomerFormCubit.edit(repository, customerId: 3),
      act: (cubit) => cubit.load(),
      expect: () => [
        CustomerFormState(
          status: CustomerFormStatus.editing,
          initialCustomer: existing,
        ),
      ],
    );

    blocTest<CustomerFormCubit, CustomerFormState>(
      'a missing customer becomes loadFailure',
      setUp: () =>
          when(() => repository.getCustomer(3))
              .thenThrow(const NotFoundException('Customer', 3)),
      build: () => CustomerFormCubit.edit(repository, customerId: 3),
      act: (cubit) => cubit.load(),
      verify: (cubit) {
        expect(cubit.state.status, CustomerFormStatus.loadFailure);
        expect(cubit.state.failure, isA<NotFoundException>());
      },
    );

    blocTest<CustomerFormCubit, CustomerFormState>(
      'submit updates instead of creating, keeping its own number',
      setUp: () =>
          when(() => repository.updateCustomer(3, any()))
              .thenAnswer((_) async => existing),
      build: () => CustomerFormCubit.edit(repository, customerId: 3),
      seed: () => CustomerFormState(
        status: CustomerFormStatus.editing,
        initialCustomer: existing,
      ),
      act: (cubit) => cubit.submit(
        const CustomerDraft(
          customerNumber: 'FST-0003',
          firstName: 'Ayşe',
          lastName: 'Kaya',
        ),
      ),
      verify: (cubit) {
        verify(() => repository.updateCustomer(3, any())).called(1);
        verifyNever(() => repository.createCustomer(any()));
        expect(cubit.state.status, CustomerFormStatus.success);
        expect(cubit.state.isEditMode, isTrue);
      },
    );

    test('submit before loading finished is ignored', () async {
      final cubit = CustomerFormCubit.edit(repository, customerId: 3);
      await cubit.submit(validDraft);
      verifyNever(() => repository.updateCustomer(any(), any()));
      expect(editing.status, isNot(cubit.state.status));
      await cubit.close();
    });
  });
}
