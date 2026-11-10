import 'package:field_service_tracker/core/utils/calendar_date.dart';
import 'package:field_service_tracker/features/customers/domain/customer.dart';
import 'package:field_service_tracker/features/customers/domain/customer_draft.dart';
import 'package:field_service_tracker/features/customers/domain/customer_repository.dart';
import 'package:field_service_tracker/features/devices/domain/device.dart';
import 'package:field_service_tracker/features/maintenance/domain/device_maintenance_overview.dart';
import 'package:field_service_tracker/features/maintenance/domain/maintenance_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockCustomerRepository extends Mock implements CustomerRepository {}

class MockMaintenanceRepository extends Mock implements MaintenanceRepository {}

/// Call once in `setUpAll` before using `any()` with these types.
void registerMockFallbacks() {
  registerFallbackValue(
    const CustomerDraft(customerNumber: 'X', firstName: 'X', lastName: 'X'),
  );
}

Customer testCustomer({
  int id = 1,
  String number = 'FST-0001',
  String first = 'Ayşe',
  String last = 'Yılmaz',
}) => Customer(
  id: id,
  customerNumber: number,
  firstName: first,
  lastName: last,
  createdAt: DateTime.utc(2025, 1, 1),
  updatedAt: DateTime.utc(2025, 1, 1),
);

CustomerListItem testListItem({int id = 1, int devices = 0}) =>
    CustomerListItem(
      customer: testCustomer(id: id),
      deviceCount: devices,
    );

DeviceMaintenanceOverview testOverview({
  int deviceId = 1,
  int customerId = 1,
  CalendarDate? next,
}) => DeviceMaintenanceOverview(
  device: Device(
    id: deviceId,
    customerId: customerId,
    model: 'AquaPure RO-5',
    installedAt: CalendarDate(2024, 1, 1),
    createdAt: DateTime.utc(2024),
  ),
  customerId: customerId,
  customerNumber: 'FST-0001',
  customerFirstName: 'Ayşe',
  customerLastName: 'Yılmaz',
  lastMaintenanceDate: next?.addMonths(-6),
  nextMaintenanceDate: next,
);
