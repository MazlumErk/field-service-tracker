/// Route paths of the app. Use the builder methods instead of string
/// interpolation at call sites so that paths stay in one place.
abstract final class AppRoutes {
  // Tab roots (bottom navigation).
  static const String dashboard = '/dashboard';
  static const String customers = '/customers';
  static const String maintenance = '/maintenance';
  static const String settings = '/settings';

  // Customers.
  static const String customerNew = '/customers/new';
  static String customerDetail(int customerId) => '/customers/$customerId';
  static String customerEdit(int customerId) => '/customers/$customerId/edit';
  static String deviceNew(int customerId) =>
      '/customers/$customerId/devices/new';

  // Devices.
  static String deviceDetail(int deviceId) => '/devices/$deviceId';
  static String deviceEdit(int deviceId) => '/devices/$deviceId/edit';
  static String maintenanceNew(int deviceId) =>
      '/devices/$deviceId/maintenance/new';
}
