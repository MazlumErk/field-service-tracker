/// Filters that can be replaced during a maintenance visit.
///
/// Persisted by [name] (text), so values may be reordered safely but must
/// never be renamed without a migration.
enum FilterType { sediment, cto, gac, post, membrane }
