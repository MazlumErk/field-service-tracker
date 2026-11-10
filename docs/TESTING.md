# Testing

Rules: [AGENTS.md §6](../AGENTS.md#6-testing-rules).

## Commands

```bash
flutter pub get                       # also runs gen-l10n
dart run build_runner build           # Drift code (*.g.dart)
dart format .
flutter analyze
flutter test
flutter test --coverage
```

Schema snapshot / migration helpers (only after a schema change, see
`docs/DATABASE.md`):

```bash
dart run drift_dev make-migrations
dart run drift_dev schema generate drift_schemas/app_database/ test/database/generated_schema/
```

## Test layout

`test/` mirrors `lib/`. Shared helpers in `test/helpers/`:

| Helper | Purpose |
|---|---|
| `fixed_clock.dart` | `AppClock` frozen at a given instant |
| `test_database.dart` | Fresh in-memory `AppDatabase` (`NativeDatabase.memory()`), optional seeder |
| `stream_recorder.dart` | Records stream events to assert reactive updates without races |
| `pump_app.dart` | `pumpApp(location, seed)` pumps the whole app with an in-memory database (optionally the demo data on the fixed date 15 Jan 2026); `testAppWidgets` wraps `testWidgets` and drains Drift's stream-cleanup timers after the body |
| `mocks.dart` | mocktail repository mocks and test fixtures |

## Test pyramid

| Level | Tooling | Scope |
|---|---|---|
| Unit | `flutter_test` | Date rules, validation, normalization, price parsing |
| Database | in-memory Drift | Constraints, FK enforcement, schema snapshot |
| Repository | in-memory Drift | CRUD, search, transactions + rollback, streams, seed, reset |
| Cubit | `bloc_test`, `mocktail` | States, debounce, delete flow, double submit, subscription cleanup |
| Widget | `flutter_test` | Screens, navigation |

Rollback tests create a temporary SQLite trigger that `RAISE(ABORT)`s in the
middle of a transaction and assert that no partial data remains.

## Current suites (Phase 3)

| File | Covers |
|---|---|
| `test/core/utils/calendar_date_test.dart` | Validation, ISO format, day diff, DST, leap years, month-end clamping |
| `test/core/utils/turkish_text_test.dart` | Turkish case mapping, search folding, alphabetical order |
| `test/features/customers/domain/customer_rules_test.dart` | Number normalization, customer validation |
| `test/features/maintenance/domain/maintenance_rules_test.dart` | Status boundaries (−1, 0, 30, 31), 6-month suggestion, price parsing, maintenance & device validation |
| `test/database/app_database_test.dart` | `foreign_keys = ON`, UNIQUE / CHECK / FK / RESTRICT, schema v1 snapshot |
| `test/database/demo_data_test.dart` | Seed content & coverage, first-install-only seeding (file DB reopen), reset, reset rollback |
| `test/features/customers/data/drift_customer_repository_test.dart` | CRUD, uniqueness, Turkish search, cascade delete + rollback, streams |
| `test/features/maintenance/data/drift_maintenance_repository_test.dart` | Device CRUD, record + filters transaction + rollback, same-day ordering, overview, streams |
| `test/features/customers/presentation/cubit/*_cubit_test.dart` | List (load, empty, failure, 250 ms debounce, cancel on new query / close), detail (stream combination, not found, delete request / cancel / confirm / failure), form (create, validation, duplicate, storage error, double submit, edit load / update) |
| `test/features/customers/presentation/customer_flows_test.dart` | Seeded end-to-end flows: Turkish sort and search, debounce, no results, empty state, create → detail, inline errors, duplicate number, search → detail → edit → save, devices with status and dated next maintenance, delete cancel / confirm with database checks, back button, no refocus, 2× text on 320 × 568 |
| `test/app/**`, `test/features/settings/**` | Phase 1 app shell, routing, theme, settings |

## Manual Android verification (Phase 3)

Emulator `Medium_Phone_API_37.0`, fresh install with demo data:

1. Müşteriler → search "seyma" → Şeyma Kara → Düzenle → add phone → Kaydet
   → detail updates, snackbar shown.
2. Müşteriler → Yeni müşteri → "Deniz / Unal / fst 0099" → Kaydet → detail
   of `FST0099` → back → list shows 21 customers.
3. Mustafa Çelik → Müşteriyi sil → dialog "3 cihaz ve 8 bakım kaydı" →
   Vazgeç (database unchanged) → Sil → list (20 customers); pulled database:
   devices 28 → 25, records 63 → 55, filters 210 → 185, no FK violations.
4. App restarted: changes persisted.

Found and fixed during this check: dates without year, search field
regaining focus (keyboard) after returning from a detail page.
