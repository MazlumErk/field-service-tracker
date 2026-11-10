# Features & Acceptance Criteria

Legend: ✅ done · 🚧 in progress · ⏳ planned (phase)

| # | Feature | Status |
|---|---|---|
| 1 | App shell, theme, 4-tab navigation, Turkish UI | ✅ Phase 1 |
| 2 | Settings: about, version, licenses | ✅ Phase 1 |
| 3 | Local database, domain rules, repositories, demo seed, demo reset service | ✅ Phase 2 (reset button: Phase 3+) |
| 4 | Customers: list, search, detail, create/edit/delete | ✅ Phase 3 |
| 5 | Devices: detail with history, create/edit, safe delete, customer relation | ✅ Phase 4 |
| 6 | Maintenance: form, filters, history, status | ⏳ Phase 5 |
| 7 | Dashboard: statistics, priority list | ⏳ Phase 6 |
| 8 | Maintenance overview with filters | ⏳ Phase 5–6 |

## Maintenance status rules

`days = nextMaintenanceDate − today` (calendar days only):

| Condition | Status |
|---|---|
| `days < 0` | Gecikti (overdue) |
| `0 ≤ days ≤ 30` | Yaklaşıyor (upcoming, includes today) |
| `days > 30` | Planlandı (scheduled) |
| no record | Bakım Kaydı Yok |

Default next date = maintenance date + 6 calendar months; when the target
month is shorter, the day is clamped to the month's last day
(Aug 31 → Feb 28/29). The user can pick any date ≥ maintenance date.

## Validation

Customer messages are implemented (Phase 3); device and maintenance
messages are drafts for Phases 4–5.

| Field | Rule | Message (TR) |
|---|---|---|
| First / last name | required, trimmed, max 50 | "Bu alan zorunludur." / "En fazla 50 karakter girebilirsiniz." |
| Customer number | required, max 20, `A-Z 0-9 - _ / .`, unique after normalization | "Yalnızca harf (A–Z), rakam ve - _ / . kullanılabilir." / "Bu müşteri numarası başka bir müşteride kullanılıyor." |
| Address | optional, max 250 | "En fazla 250 karakter girebilirsiniz." |
| Device model | required | "Model zorunludur" |
| Phone | optional; digits, spaces, `+ ( ) -`, 10–15 digits | "Geçerli bir telefon numarası girin (10–15 rakam)." |
| Price | 0 … 1.000.000 TL, Turkish format (`1.250,50`), stored as kuruş | "Geçerli bir ücret girin" |
| Maintenance date | not in the future | "Bakım tarihi ileri bir tarih olamaz" |
| Device installation date | not in the future | "Kurulum tarihi ileri bir tarih olamaz" |
| Next maintenance date | ≥ maintenance date | "Sonraki bakım tarihi bakım tarihinden önce olamaz" |
| Filters | at least one | "En az bir filtre seçin" |

## Phase 1 acceptance criteria

- [x] Project `field_service_tracker`, application id `dev.mazlumerk.field_service_tracker`.
- [x] Dependencies added and resolved; `pubspec.lock` committed.
- [x] Central theme: ColorScheme, StatusColors extension, Inter, tokens.
- [x] GoRouter: 4-tab shell, all planned routes with placeholders, not-found handling.
- [x] Turkish localization (gen-l10n + Material localizations).
- [x] `AppClock` and dependency wiring via `RepositoryProvider`.
- [x] Widget tests for shell navigation, routing, settings, theme.
- [x] Format, analyze and tests pass.

## Phase 2 acceptance criteria

- [x] Drift tables with FK (`RESTRICT`), UNIQUE, CHECK and indexes; `foreign_keys = ON` verified.
- [x] Immutable domain models independent of Drift.
- [x] Business rules in separate, tested classes (normalization, validation, search, dates, status, price).
- [x] Repository interfaces + Drift implementations returning domain models; reactive streams.
- [x] Explicit transactional cascade delete for customers.
- [x] Deterministic demo seed on first creation only; transactional reset service.
- [x] Schema v1 snapshot and migration test infrastructure.
- [x] In-memory database tests incl. rollback and stream reactivity.

## Phase 3 — Customer management

### Screens and flows

| Screen | Behaviour |
|---|---|
| Müşteriler (`/customers`) | Live list (name, number, device count) sorted in Turkish alphabetical order; search by first name, last name or number, case- and diacritic-insensitive, 250 ms debounce; states: loading skeleton, empty database, no results (with "clear search"), error (with retry); FAB "Yeni müşteri" |
| Yeni Müşteri (`/customers/new`) | Shared form; on success replaced by the new customer's detail page |
| Müşteri Detayı (`/customers/:id`) | Contact data, devices with maintenance status badge and next date (with year); edit action; overflow menu → delete; unknown id → not-found page |
| Müşteriyi Düzenle (`/customers/:id/edit`) | Same form prefilled; on success pops back to the detail page, which updates through its stream |

### Acceptance criteria

- [x] List, search (Turkish characters, case-insensitive, 250 ms debounce), Turkish sort.
- [x] Loading, empty, no-results and error states.
- [x] Shared create / edit form with inline Turkish errors; customer number normalized; duplicate number shown under the field; own number allowed when editing.
- [x] Save button disabled with progress while saving; repeated submits ignored.
- [x] Detail with devices and maintenance status; device tap opens `/devices/:id` (Phase 4 screen).
- [x] Delete: impact (devices / records) shown in a confirmation dialog; cancel changes nothing; confirm runs the transactional delete and returns to the list.
- [x] Lists update reactively after create, edit and delete.
- [x] No overflow at 2× text on a 320 × 568 screen.
- [x] Verified on the Android emulator (see `docs/TESTING.md`).

Adding devices from the customer detail page was delivered in Phase 4.

## Phase 4 — Device management

### Screens and flows

| Screen | Behaviour |
|---|---|
| Müşteri Detayı | "Cihaz ekle" action next to the device section header |
| Yeni Cihaz (`/customers/:id/devices/new`) | Model (required), serial number (optional), installation date (Turkish date picker, defaults to today, no future dates); on success replaced by the new device's detail page |
| Cihaz Detayı (`/devices/:id`) | Model, serial number, installation date, owner (tappable) and customer number, last / next maintenance, status badge + "n gün gecikti / n gün kaldı / Bakım bugün", read-only history newest first (date, next date, filters, price, notes), empty state without records, "Yeni bakım ekle" → `/devices/:id/maintenance/new` (form in Phase 5) |
| Cihazı Düzenle (`/devices/:id/edit`) | Same form prefilled; the owning customer cannot change; on success pops back, detail updates through its stream |
| Delete (detail menu) | Dialog states how many maintenance records and filter replacements are permanently deleted; cancel changes nothing; confirm deletes filters → records → device in one transaction and returns to the customer |
| All forms | Unsaved-changes dialog ("Vazgeç" / "Değişiklikleri At") on app bar back and Android back; no dialog without changes or after saving |

### Acceptance criteria

- [x] Device created for the right customer; validation of model, serial length and installation date.
- [x] Save disabled while saving; repeated submits ignored.
- [x] Customer detail and customer list device counts update reactively after create / delete.
- [x] Device detail with status from `MaintenanceStatusCalculator`, history newest first, empty state.
- [x] Edit keeps the owner; detail updates after saving.
- [x] Delete with impact preview, transactional cascade, rollback on failure, `RESTRICT` foreign keys kept.
- [x] Unsaved-changes guard on customer and device forms (both back paths).
- [x] No overflow at 2× text on a 320 × 568 screen.
- [x] Verified on the Android emulator; real screenshots in `docs/images/`.

