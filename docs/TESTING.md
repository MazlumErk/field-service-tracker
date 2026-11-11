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

## Current suites (Phase 7)

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
| `test/features/maintenance/presentation/cubit/maintenance_form_cubit_test.dart` | Defaults incl. month-end clamping, suggestion follow / no overwrite / reset, filters ≥ 1 and no duplicates, price errors, saved kuruş / filters / notes, double submit, storage failure, unknown device |
| `test/features/maintenance/presentation/maintenance_flows_test.dart` | Seeded flow: device → form → save → history first and status updated; Turkish validation errors; unsaved-changes guard; 2× text |
| `test/core/clock/day_tracker_test.dart` | Midnight timer duration and re-arming, resume only emits on a real day change, DST-safe midnight |
| `test/features/maintenance/domain/maintenance_overview_rules_test.dart` | Each device counted once, 0 / 30 / 31 boundaries and next-day shift, priority order, priority subset |
| `test/features/dashboard/presentation/overview_cubits_test.dart` | Dashboard KPIs, priority limit, waiting for both sources, data and day-change recomputation, errors, cleanup; maintenance list order, filters, empty states, day change, cleanup |
| `test/features/dashboard/presentation/dashboard_flows_test.dart` | Seeded: KPIs, priority row → device, see all → overdue / no-record filters, new maintenance and customer delete update the dashboard, 2× text |
| `test/core/widgets/unsaved_changes_test.dart` | Guard on customer and device forms: no-change exit, cancel, discard via Android back, revert = no change, no dialog after save, create forms |
| `test/features/settings/settings_page_test.dart` | Identity / version / licenses, reset cancel keeps data, confirmed reset restores demo data and updates dashboard and customer list, `SettingsCubit` success / failure / single run, 2× text |
| `test/app/**` | Phase 1 app shell, routing, theme |

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

## Manual Android verification (Phase 5)

Fresh install, emulator date 10 Nov 2026. Screenshots: `maintenance_form.png`,
`maintenance_validation_errors.png`, `maintenance_filter_selection.png`,
`maintenance_history_updated.png` in `docs/images/`.

1. Fatma Şahin → AquaPure RO-5 ("Gecikti") → Yeni bakım ekle: header, dates
   10 Kas 2026 / 10 May 2027 → Sediment, CTO Karbon, Membran, ₺ 1.250,50,
   note → Kaydet.
2. Device detail: "Planlandı · 181 gün kaldı", last / next dates updated, the
   new record first in the history. Pulled database: `price_kurus = 125050`,
   filter rows `cto, membrane, sediment`, no FK violations.
3. Untouched form → back without dialog; filter selected → app bar back →
   dialog → Vazgeç stays → Android back → dialog → Değişiklikleri At →
   history unchanged.
4. No filter + price "12,345" → "En az bir filtre seçin." and
   "Geçerli bir tutar girin (örn. 1.250,50)."

## Manual Android verification (Phase 6)

Fresh install (emulator date 11 Nov 2026). Screenshots: `dashboard.png`,
`maintenance_overview.png`, `maintenance_overdue_filter.png`.

1. Dashboard: 20 / 28 / 5 overdue / 10 upcoming; first priority row
   Fatma Şahin "60 gün gecikti" → device detail.
2. Bakımlar → "Geciken (5)" → oldest first → device detail.
3. Device → Yeni bakım → Kaydet → "Planlandı · 181 gün kaldı"; Bakımlar
   "Geciken (4)"; dashboard overdue 5 → 4, priority list updated.
4. Filters: Yaklaşan (10, "Bakım bugün" first), Planlanan (11, 31 days
   first), Bakım Kaydı Yok (3), Tümü (28 = 4 + 10 + 11 + 3).

Narrow screen / 2× text is covered by widget tests (system font size of the
emulator was not changed).

## Manual Android verification (Phase 7)

Fresh install. Screenshots: `settings.png`, `settings_reset_dialog.png`,
`settings_reset_success.png`.

1. Ayarlar → Demo verilerini sıfırla → Vazgeç: database unchanged
   (20 customers, 28 devices, 63 records).
2. Müşteriler → Yeni müşteri "Deneme Musteri / USR-1" → 21 customers on the
   list and dashboard.
3. Ayarlar → Sıfırla → snackbar; database 20 / 28 / 63, no user customer,
   no FK violations; dashboard 20 / 28 / 5 overdue, list "20 müşteri".
4. Force-stop and restart: data persisted (20 / 28 / 63).

Rollback of a failing reset is covered by `demo_data_test.dart` (Phase 2).

Transaction rollback of record + filters is covered by
`drift_maintenance_repository_test.dart` (Phase 2) and was not duplicated.
