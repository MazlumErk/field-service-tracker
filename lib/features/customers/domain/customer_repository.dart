import 'package:field_service_tracker/features/customers/domain/customer.dart';
import 'package:field_service_tracker/features/customers/domain/customer_draft.dart';

/// Customer persistence. All methods throw `AppException` subtypes only.
abstract interface class CustomerRepository {
  /// Customers ordered by last name, first name; filtered by [query] which
  /// matches first name, last name and customer number (Turkish-insensitive,
  /// every word must match). Re-emits on any customer or device change.
  Stream<List<CustomerListItem>> watchCustomers({String query = ''});

  /// Emits `null` when the customer is deleted.
  Stream<Customer?> watchCustomer(int id);

  /// Total number of customers (dashboard).
  Stream<int> watchCustomerCount();

  /// Throws `NotFoundException`.
  Future<Customer> getCustomer(int id);

  /// Throws `ValidationException` or `DuplicateCustomerNumberException`.
  Future<Customer> createCustomer(CustomerDraft draft);

  /// Throws `NotFoundException`, `ValidationException` or
  /// `DuplicateCustomerNumberException`.
  Future<Customer> updateCustomer(int id, CustomerDraft draft);

  /// Whether [customerNumber] (normalized first) is used by a customer other
  /// than [excludingId].
  Future<bool> isCustomerNumberTaken(String customerNumber, {int? excludingId});

  /// Counts what [deleteCustomer] would remove. Throws `NotFoundException`.
  Future<CustomerDeletionImpact> getDeletionImpact(int id);

  /// Deletes the customer **and** its devices, maintenance records and filter
  /// replacements in one transaction. Call only after the user confirmed the
  /// [getDeletionImpact] counts. Throws `NotFoundException`.
  Future<void> deleteCustomer(int id);
}
