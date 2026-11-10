# Features & Acceptance Criteria

Legend: ✅ done · 🚧 in progress · ⏳ planned (phase)

| # | Feature | Status |
|---|---|---|
| 1 | App shell, theme, 4-tab navigation, Turkish UI | ✅ Phase 1 |
| 2 | Settings: about, version, licenses | ✅ Phase 1 |
| 3 | Local database, domain rules, repositories, demo seed, demo reset service | ✅ Phase 2 (reset button: Phase 3+) |
| 4 | Customers: list, search, detail, create/edit/delete | ⏳ Phase 3 |
| 5 | Devices: detail, create/edit, customer relation | ⏳ Phase 4 |
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

| Field | Rule | Message (TR) |
|---|---|---|
| First / last name | required, trimmed | "Ad zorunludur" / "Soyad zorunludur" |
| Customer number | required, unique after normalization | "Bu müşteri numarası zaten kullanılıyor" |
| Device model | required | "Model zorunludur" |
| Phone | optional; digits, spaces, `+ ( ) -`, 10–15 digits | "Geçerli bir telefon numarası girin" |
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
