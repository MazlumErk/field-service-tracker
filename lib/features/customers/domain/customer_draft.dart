import 'package:equatable/equatable.dart';
import 'package:field_service_tracker/core/utils/turkish_text.dart';
import 'package:field_service_tracker/features/customers/domain/customer_number.dart';

/// Raw user input for creating or updating a customer.
final class CustomerDraft extends Equatable {
  const CustomerDraft({
    required this.customerNumber,
    required this.firstName,
    required this.lastName,
    this.phone,
    this.address,
  });

  final String customerNumber;
  final String firstName;
  final String lastName;
  final String? phone;
  final String? address;

  /// Trimmed copy with a normalized customer number and blank optionals
  /// turned into `null`. This is what gets persisted.
  CustomerDraft normalized() => CustomerDraft(
    customerNumber: CustomerNumber.normalize(customerNumber),
    firstName: _collapse(firstName),
    lastName: _collapse(lastName),
    phone: _blankToNull(phone),
    address: _blankToNull(address),
  );

  /// Search key stored in the database (`customers.search_key`).
  String get searchKey => TurkishText.searchKey(
    '$firstName $lastName ${CustomerNumber.normalize(customerNumber)}',
  );

  static final RegExp _whitespace = RegExp(r'\s+');

  static String _collapse(String value) =>
      value.trim().replaceAll(_whitespace, ' ');

  static String? _blankToNull(String? value) {
    final trimmed = value?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }

  @override
  List<Object?> get props => [
    customerNumber,
    firstName,
    lastName,
    phone,
    address,
  ];
}
