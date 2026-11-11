# Features & Acceptance Criteria

Legend: ✅ done · 🚧 in progress · ⏳ planned (phase)

| # | Feature | Status |
|---|---|---|
| 1 | App shell, theme, 4-tab navigation, Turkish UI | ✅ Phase 1 |
| 2 | Settings: identity, version, demo data reset, about, licenses | ✅ Phase 1 / 7 |
| 3 | Local database, domain rules, repositories, demo seed, demo reset service | ✅ Phase 2 (reset in Settings: Phase 7) |
| 4 | Customers: list, search, detail, create/edit/delete | ✅ Phase 3 |
| 5 | Devices: detail with history, create/edit, safe delete, customer relation | ✅ Phase 4 |
| 6 | Maintenance: form, filters, history, status | ✅ Phase 5 |
| 7 | Dashboard: statistics, priority list | ✅ Phase 6 |
| 8 | Maintenance overview with filters | ✅ Phase 6 |

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

All messages below are implemented (customers: Phase 3, devices: Phase 4,
maintenance: Phase 5).

| Field | Rule | Message (TR) |
|---|---|---|
| First / last name | required, trimmed, max 50 | "Bu alan zorunludur." / "En fazla 50 karakter girebilirsiniz." |
| Customer number | required, max 20, `A-Z 0-9 - _ / .`, unique after normalization | "Yalnızca harf (A–Z), rakam ve - _ / . kullanılabilir." / "Bu müşteri numarası başka bir müşteride kullanılıyor." |
| Address | optional, max 250 | "En fazla 250 karakter girebilirsiniz." |
| Device model | required | "Model zorunludur" |
| Phone | optional; digits, spaces, `+ ( ) -`, 10–15 digits | "Geçerli bir telefon numarası girin (10–15 rakam)." |
| Price | required; 0 … 1.000.000 TL; `1250`, `1250,50`, `1.250,50` (comma = decimals, dots only as thousands groups); stored as integer kuruş | "Bu alan zorunludur." / "Geçerli bir tutar girin (örn. 1.250,50)." / "Tutar en fazla ₺1.000.000,00 olabilir." |
| Maintenance date | defaults to today, not in the future | "Bakım tarihi ileri bir tarih olamaz." |
| Device installation date | not in the future | "Kurulum tarihi ileri bir tarih olamaz." |
| Next maintenance date | ≥ maintenance date; defaults to maintenance date + 6 calendar months | "Sonraki bakım tarihi bakım tarihinden önce olamaz." |
| Filters | at least one; each at most once | "En az bir filtre seçin." |
| Notes | optional, max 500; blank is stored as `NULL` | "En fazla 500 karakter girebilirsiniz." |

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

## Phase 5 — Maintenance & filter management

### Flow

Cihaz Detayı → "Yeni bakım ekle" → `/devices/:id/maintenance/new` →
Kaydet → back on the device detail, whose history, last / next dates and
status update through their streams.

### Form

| Field | Behaviour |
|---|---|
| Header | Device model, customer name and number |
| Bakım tarihi | Defaults to today (`AppClock`); Turkish date picker up to today |
| Sonraki bakım tarihi | Suggested as maintenance date + 6 calendar months (`MaintenanceSchedule`, month-end clamped: 31 Aug → 28/29 Feb, 31 Mar → 30 Sep). Follows the maintenance date until the user picks it; a manual choice is never overwritten ("6 ay sonrasını kullan" restores the suggestion). The picker starts at the maintenance date. |
| Değiştirilen filtreler | Checkbox rows: Sediment, CTO Karbon, GAC Karbon, Post Mineral, Membran (stored as `FilterType` names: `sediment`, `cto`, `gac`, `post`, `membrane`); at least one |
| Bakım ücreti | `MaintenancePrice.parseToKurus` → integer kuruş; shown with `formatKurus` |
| Notlar | Optional multi-line, max 500, blank → `NULL` |

Saving validates with `MaintenanceValidator`, shows a progress state,
ignores repeated submits and calls `MaintenanceRepository.createRecord`,
which inserts the record and its filter rows in **one transaction**
(rollback covered by Phase 2 tests). Records are immutable in v1: no edit or
delete. The unsaved-changes guard protects the form.

### Acceptance criteria

- [x] Form bound to the device with header, defaults and Turkish pickers.
- [x] 6-month suggestion re-applied on date change unless customised.
- [x] Multi-select filters (≥ 1, no duplicates), Turkish display names.
- [x] Turkish lira parsing into kuruş; invalid / too large amounts rejected inline.
- [x] Transactional save, progress state, double-submit guard, Turkish errors.
- [x] Device detail shows the new record first; last / next dates and status update.
- [x] Unsaved-changes dialog on both back paths; none after saving.
- [x] Verified on the Android emulator; screenshots in `docs/images/`.

## Phase 7 — Settings & demo data management

Ayarlar shows the app name, tagline and the real version
(`package_info_plus`, loaded at startup), a **Demo verileri** section and
the about / licenses section.

**Demo verilerini sıfırla:**

1. A destructive confirmation dialog states that *all* data — including
   customers, devices and maintenance records the user added — is deleted
   permanently and the initial demo data is recreated.
2. "Vazgeç" changes nothing (the reset is never called).
3. "Sıfırla" runs `DemoDataRepository.resetDemoData()` — delete all tables
   and re-seed relative to today in **one transaction**; on failure the
   transaction rolls back and the previous data stays.
4. While running, the row is disabled with a progress indicator and
   repeated calls are ignored (`SettingsCubit`).
5. A snackbar reports success ("Demo verileri yeniden oluşturuldu.") or a
   Turkish error.
6. Dashboard, customer list and maintenance overview update through their
   existing repository streams.

### Acceptance criteria

- [x] Settings with identity, real version, demo data management, about, licenses.
- [x] Confirmed reset; cancel keeps data; user data removed on reset.
- [x] Transactional reset with rollback; repeated taps ignored; success / error feedback.
- [x] Other tabs update automatically; data persists after restart.
- [x] Verified on the Android emulator; screenshots in `docs/images/`.

## Phase 6 — Dashboard & maintenance overview

### How the numbers are calculated

- **Müşteri / Cihaz:** `watchCustomerCount()` and the number of rows of
  `watchOverview()`.
- **Geciken / Yaklaşan bakım:** `watchOverview()` returns **one row per
  device** with its latest maintenance record (latest = maintenance date,
  then creation time, then id). Each device is therefore counted once,
  regardless of how many records it has. The status is computed for today
  with `MaintenanceStatusCalculator` (overdue < 0 days, upcoming 0–30 days,
  scheduled > 30 days, no record) — never stored.
- **Öncelikli Bakımlar:** overdue + upcoming devices in priority order, the
  first 5 shown, with "n öncelikli bakımdan 5 tanesi gösteriliyor" and
  "Tüm Bakımları Gör" → Bakımlar tab.

### Maintenance overview (Bakımlar)

Filter chips with counts: Tümü, Geciken, Yaklaşan, Planlanan, Bakım Kaydı
Yok (selected chip is filled and check-marked). Order (shared with the
dashboard, `MaintenanceOverviewRules.sortByPriority`):

1. Overdue — oldest next date first
2. Upcoming — nearest next date first
3. Scheduled — nearest next date first
4. No record — customer name (Turkish alphabet), then model
   (ties: device id)

Tapping a row opens the device detail.

### Day changes

`DayTracker` (`TodayProvider`) re-reads `AppClock` when the app resumes and
fires once just after each local midnight (single re-armed timer, no
polling). Dashboard, maintenance list, customer detail and device detail
recompute statuses for the new day without querying the database.

### Acceptance criteria

- [x] Four KPIs from real data; devices counted once.
- [x] Priority list (overdue oldest first, then upcoming nearest first), limited, device detail on tap, "Tüm Bakımları Gör".
- [x] Maintenance list with five filters, priority ordering, each device once.
- [x] Reactive updates after customer / device / maintenance changes and demo reset (shared streams).
- [x] Status refresh on day change (resume, midnight).
- [x] Loading, empty and error states; no overflow at 2× text on 320 × 568.
- [x] Verified on the Android emulator; screenshots in `docs/images/`.

