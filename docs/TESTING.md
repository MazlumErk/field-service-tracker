# Testing

Rules: [AGENTS.md §6](../AGENTS.md#6-testing-rules).

## Strategy (from Phase 4)

- While developing, run only the tests of the changed module; when shared
  code (core widgets, repository interfaces, domain rules) changes, also run
  the tests of the modules that use it.
- New tests focus on business rules, data integrity, deletions, important
  Cubit behaviour and the core user flows of a finished feature — no tests
  for trivial widgets, no count or coverage targets.
- At the end of a phase: `dart format`, `flutter analyze` and the full
  `flutter test` once; a phase is not done while tests fail.

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

## Current suites (Phase 4)

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
| `test/features/devices/data/drift_device_repository_test.dart` | Owner never changes on update, deletion impact, transactional delete, rollback, stream reactions |
| `test/features/devices/presentation/cubit/*_cubit_test.dart` | Form (customer binding, optional serial, validation, date, double submit, edit), detail (status per offset, history order, not found, delete flow, cleanup) |
| `test/features/devices/presentation/device_flows_test.dart` | Seeded flows: add → detail → customer list update, Turkish date picker, history order and content, all statuses, edit, delete cancel / confirm with database checks, back button, 2× text |
| `test/core/widgets/unsaved_changes_test.dart` | Guard on customer and device forms: no-change exit, cancel, discard via Android back, revert = no change, no dialog after save, create forms |
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

## Manual Android verification (Phase 4)

Emulator `Medium_Phone_API_37.0`, fresh install with demo data. Screenshots:
`docs/images/`.

1. Özlem Şimşek → Cihaz ekle → "AquaPure X1", serial, date via the Turkish
   picker → Kaydet → device detail ("Bakım Kaydı Yok", empty history) → back
   → "Cihazlar (1)".
2. Mustafa Çelik → HydroLine Mini → Düzenle → model "HydroLine Mini Plus"
   → Kaydet → detail updated, owner unchanged.
3. HydroLine Mini → history: 4 records newest first with price, filters,
   notes; "Planlandı · 45 gün kaldı".
4. Delete dialog "4 bakım kaydı ve 13 filtre değişimi" → Vazgeç (database
   unchanged) → Sil → customer detail "Cihazlar (2)", list "2 cihaz"; pulled
   database: devices 29 → 28, records 63 → 59, filters 210 → 197, no FK
   violations.
5. Edit form changed → back → "Kaydedilmemiş değişiklikler" → Vazgeç stays
   → Android back → Değişiklikleri At → detail unchanged.

Found and fixed: after closing the date picker or the unsaved-changes dialog
focus returned to the last text field and reopened the keyboard (the next
Android back press then only closed the keyboard).
