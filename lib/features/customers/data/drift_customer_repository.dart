import 'package:drift/drift.dart';
import 'package:field_service_tracker/core/clock/app_clock.dart';
import 'package:field_service_tracker/core/errors/app_exception.dart';
import 'package:field_service_tracker/core/utils/turkish_text.dart';
import 'package:field_service_tracker/database/app_database.dart';
import 'package:field_service_tracker/database/daos/customers_dao.dart';
import 'package:field_service_tracker/database/database_error_mapper.dart';
import 'package:field_service_tracker/features/customers/domain/customer.dart';
import 'package:field_service_tracker/features/customers/domain/customer_draft.dart';
import 'package:field_service_tracker/features/customers/domain/customer_number.dart';
import 'package:field_service_tracker/features/customers/domain/customer_repository.dart';
import 'package:field_service_tracker/features/customers/domain/customer_validator.dart';

/// Drift implementation of [CustomerRepository].
final class DriftCustomerRepository implements CustomerRepository {
  DriftCustomerRepository(AppDatabase database, this._clock)
    : _dao = database.customersDao;

  final CustomersDao _dao;
  final AppClock _clock;

  static const String _entity = 'Customer';

  @override
  Stream<List<CustomerListItem>> watchCustomers({String query = ''}) {
    final tokens = TurkishText.searchTokens(query);
    return guardDatabaseStream(
      _dao.watchWithDeviceCount(tokens).map((rows) {
        final items = [
          for (final row in rows)
            CustomerListItem(
              customer: row.customer.toDomain(),
              deviceCount: row.deviceCount,
            ),
        ];
        // SQLite orders by byte value ("Ç" after "Z"); sort in Dart with
        // Turkish alphabet rules instead.
        items.sort((a, b) => _compareCustomers(a.customer, b.customer));
        return items;
      }),
    );
  }

  @override
  Stream<Customer?> watchCustomer(int id) =>
      guardDatabaseStream(_dao.watchById(id).map((row) => row?.toDomain()));

  @override
  Stream<int> watchCustomerCount() => guardDatabaseStream(_dao.watchCount());

  @override
  Future<Customer> getCustomer(int id) => guardDatabase(() async {
    final row = await _dao.findById(id);
    if (row == null) throw NotFoundException(_entity, id);
    return row.toDomain();
  });

  @override
  Future<Customer> createCustomer(CustomerDraft draft) =>
      guardDatabase(() async {
        final input = _validated(draft);
        if (await _dao.isNumberTaken(input.customerNumber)) {
          throw DuplicateCustomerNumberException(input.customerNumber);
        }
        final now = _clock.now().toUtc();
        final id = await _insertOrUpdate(
          input,
          () => _dao.insertCustomer(
            CustomersCompanion.insert(
              customerNumber: input.customerNumber,
              firstName: input.firstName,
              lastName: input.lastName,
              phone: Value(input.phone),
              address: Value(input.address),
              searchKey: input.searchKey,
              createdAt: now,
              updatedAt: now,
            ),
          ),
        );
        return (await _dao.findById(id))!.toDomain();
      });

  @override
  Future<Customer> updateCustomer(int id, CustomerDraft draft) =>
      guardDatabase(() async {
        if (!await _dao.existsById(id)) throw NotFoundException(_entity, id);
        final input = _validated(draft);
        if (await _dao.isNumberTaken(input.customerNumber, excludingId: id)) {
          throw DuplicateCustomerNumberException(input.customerNumber);
        }
        final updated = await _insertOrUpdate(
          input,
          () => _dao.updateCustomer(
            id,
            CustomersCompanion(
              customerNumber: Value(input.customerNumber),
              firstName: Value(input.firstName),
              lastName: Value(input.lastName),
              phone: Value(input.phone),
              address: Value(input.address),
              searchKey: Value(input.searchKey),
              updatedAt: Value(_clock.now().toUtc()),
            ),
          ),
        );
        if (updated == 0) throw NotFoundException(_entity, id);
        return (await _dao.findById(id))!.toDomain();
      });

  @override
  Future<bool> isCustomerNumberTaken(
    String customerNumber, {
    int? excludingId,
  }) => guardDatabase(
    () => _dao.isNumberTaken(
      CustomerNumber.normalize(customerNumber),
      excludingId: excludingId,
    ),
  );

  @override
  Future<CustomerDeletionImpact> getDeletionImpact(int id) =>
      guardDatabase(() async {
        if (!await _dao.existsById(id)) throw NotFoundException(_entity, id);
        final counts = await _dao.relatedCounts(id);
        return CustomerDeletionImpact(
          deviceCount: counts.devices,
          maintenanceRecordCount: counts.maintenanceRecords,
        );
      });

  @override
  Future<void> deleteCustomer(int id) => guardDatabase(() async {
    final deleted = await _dao.deleteWithRelatedRecords(id);
    if (!deleted) throw NotFoundException(_entity, id);
  });

  CustomerDraft _validated(CustomerDraft draft) {
    final result = CustomerValidator.validate(draft);
    if (!result.isValid) throw ValidationException(result.errors);
    return draft.normalized();
  }

  /// Runs a write and turns a race-condition UNIQUE violation on the
  /// customer number into [DuplicateCustomerNumberException].
  Future<int> _insertOrUpdate(
    CustomerDraft input,
    Future<int> Function() write,
  ) async {
    try {
      return await write();
    } catch (error, stackTrace) {
      final mapped = mapDatabaseError(error, stackTrace);
      if (mapped is ConstraintViolationException &&
          mapped.kind == ConstraintKind.unique &&
          mapped.message.contains('customer_number')) {
        throw DuplicateCustomerNumberException(
          input.customerNumber,
          cause: error,
        );
      }
      throw mapped;
    }
  }

  static int _compareCustomers(Customer a, Customer b) {
    final byLast = TurkishText.compare(a.lastName, b.lastName);
    if (byLast != 0) return byLast;
    final byFirst = TurkishText.compare(a.firstName, b.firstName);
    if (byFirst != 0) return byFirst;
    return a.id.compareTo(b.id);
  }
}

extension on CustomerRow {
  Customer toDomain() => Customer(
    id: id,
    customerNumber: customerNumber,
    firstName: firstName,
    lastName: lastName,
    phone: phone,
    address: address,
    createdAt: createdAt.toUtc(),
    updatedAt: updatedAt.toUtc(),
  );
}
