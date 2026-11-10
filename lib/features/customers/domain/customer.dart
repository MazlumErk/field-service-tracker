import 'package:equatable/equatable.dart';

/// A customer of the service business.
final class Customer extends Equatable {
  const Customer({
    required this.id,
    required this.customerNumber,
    required this.firstName,
    required this.lastName,
    required this.createdAt,
    required this.updatedAt,
    this.phone,
    this.address,
  });

  final int id;

  /// Normalized customer number (see `CustomerNumber.normalize`).
  final String customerNumber;
  final String firstName;
  final String lastName;
  final String? phone;
  final String? address;
  final DateTime createdAt;
  final DateTime updatedAt;

  String get fullName => '$firstName $lastName';

  @override
  List<Object?> get props => [
    id,
    customerNumber,
    firstName,
    lastName,
    phone,
    address,
    createdAt,
    updatedAt,
  ];
}

/// Row of the customer list: the customer plus how many devices it has.
final class CustomerListItem extends Equatable {
  const CustomerListItem({required this.customer, required this.deviceCount});

  final Customer customer;
  final int deviceCount;

  @override
  List<Object?> get props => [customer, deviceCount];
}

/// What deleting a customer would remove. Shown in the confirmation dialog
/// before the explicit cascade delete runs.
final class CustomerDeletionImpact extends Equatable {
  const CustomerDeletionImpact({
    required this.deviceCount,
    required this.maintenanceRecordCount,
  });

  final int deviceCount;
  final int maintenanceRecordCount;

  bool get hasRelatedRecords => deviceCount > 0 || maintenanceRecordCount > 0;

  @override
  List<Object?> get props => [deviceCount, maintenanceRecordCount];
}
