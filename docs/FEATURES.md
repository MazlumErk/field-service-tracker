# Features & Acceptance Criteria

Legend: ✅ done · 🚧 in progress · ⏳ planned (phase)

| # | Feature | Status |
|---|---|---|
| 1 | App shell, theme, 4-tab navigation, Turkish UI | ✅ Phase 1 |
| 2 | Settings: about, version, licenses | ✅ Phase 1 |
| 3 | Local database, demo seed, demo reset | ⏳ Phase 2 |
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
| Price | ≥ 0, TL with up to 2 decimals | "Geçerli bir ücret girin" |
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
