/// Demo data management (Settings → "Demo Verilerini Sıfırla").
abstract interface class DemoDataRepository {
  /// Deletes **all** customers, devices and maintenance data and recreates
  /// the initial demo data set relative to today, in one transaction.
  /// On failure nothing changes. Throws `DatabaseException`.
  Future<void> resetDemoData();
}
