# Design System — "Calm Operations"

Modern, calm, trustworthy. Material 3 based, flat surfaces, color carries
meaning. All tokens live in `lib/app/theme/`; widgets never hardcode them.

## Colors (`app_colors.dart`, `ColorScheme`)

| Token | Hex | Use |
|---|---|---|
| primary | `#0F766E` | Primary actions, selected states, "scheduled" tone |
| secondary | `#234E70` | Secondary emphasis |
| background | `#F7FAFC` | Scaffold / app bar background |
| surface | `#FFFFFF` | Cards, inputs, navigation bar |
| warning | `#D97706` | Upcoming maintenance accents |
| error | `#DC2626` | Errors, overdue accents |
| onSurface | `#0F172A` | Primary text |
| onSurfaceVariant | `#475569` | Secondary text (AA on white) |
| outline / outlineVariant | `#CBD5E1` / `#E2E8F0` | Input / card borders |

### Status colors (`StatusColors` ThemeExtension)

| Status | Foreground | Background | Icon + label (always shown) |
|---|---|---|---|
| Gecikti (overdue) | `#B91C1C` | `#FEF2F2` | error icon + "Gecikti" |
| Yaklaşıyor (upcoming) | `#92400E` | `#FFFBEB` | schedule icon + "Yaklaşıyor" |
| Planlandı (scheduled) | `#0F766E` | `#F0FDFA` | check icon + "Planlandı" |
| Bakım Kaydı Yok | `#475569` | `#F1F5F9` | help icon + "Bakım Kaydı Yok" |

Foregrounds are darker than the raw brand colors so text keeps ≥ 4.5:1
contrast on the tinted background. Status is never communicated by color only.

## Typography (`app_typography.dart`) — Inter, bundled

| Role | Material role | Size / weight |
|---|---|---|
| Display / Metric | `displaySmall` | 32 / 600 |
| Page Title | `headlineSmall` | 22 / 600 |
| Section Title | `titleMedium` | 16 / 600 |
| Card Title | `titleSmall` | 15 / 600 |
| Body | `bodyMedium` | 14 / 400 |
| Secondary Text | `bodyMedium` + `onSurfaceVariant` | 14 / 400 |
| Caption | `bodySmall` | 12 / 400 |
| Button Label | `labelLarge` | 14 / 600 |

Text scales with the system font size; layouts must not overflow at 1.3×–2×.

## Spacing & shape (`app_spacing.dart`)

- Spacing scale: `4 · 8 · 12 · 16 · 24 · 32` (`AppSpacing.xs … xxl`).
- Screen horizontal padding: 16.
- Radius: 12 for cards, inputs and buttons; 16 for sheets and FAB.
- No elevation shadows; cards use a 1 px `outlineVariant` border.
- Minimum touch target: 48 × 48.

## Components

| Component | Status | Notes |
|---|---|---|
| `AppScaffold` | ✅ Phase 1 | Title bar + safe-area body |
| `AppMessageState` | ✅ Phase 1 | `.empty` / `.error` variants (replaces separate Empty/Error widgets — same layout) |
| `NotFoundPage` | ✅ Phase 1 | Routing fallback for unknown paths and ids (the Phase 1 placeholder page was removed in Phase 6) |
| Buttons, text fields, top bar | ✅ via theme | Styled through `ThemeData`; no wrapper widget unless behavior is added |
| `AppSearchField` | ✅ Phase 3 | Search icon, clear button when text is entered |
| `AppListSkeleton` | ✅ Phase 3 | Static (non-animated) placeholder cards while lists load |
| `showAppConfirmationDialog` | ✅ Phase 3 | Returns `true` only for the confirm button; destructive variant uses the `error` color |
| `AppSectionHeader` | ✅ Phase 3 | Section title with header semantics |
| `MaintenanceStatusBadge` | ✅ Phase 3 | Icon + label + status colors (never color only) |
| `DeviceOverviewTile` | ✅ Phase 3 | Model, serial number, status badge, next date |
| `CustomerListTile`, `CustomerInfoCard`, `CustomerInitialsAvatar` | ✅ Phase 3 | Customer feature widgets; secondary info wraps instead of overflowing |
| `UnsavedChangesGuard` | ✅ Phase 4 | `PopScope` + destructive confirmation ("Değişiklikleri At"); unfocuses after "Vazgeç" so one back press is enough |
| `DeviceSummaryCard` | ✅ Phase 4 | Status block (badge + plain-language days), dates, tappable owner |
| `MaintenanceRecordCard` | ✅ Phase 4 | Date, price, next date, filter chips, notes |
| `AppDateField` | ✅ Phase 5 | Read-only field + Turkish date picker; clamps the initial date into range; unfocuses afterwards (no keyboard pop-up). Used by device and maintenance forms |
| Filter selection | ✅ Phase 5 | Card with one `CheckboxListTile` per filter (48 dp rows); error outline + message when none is selected |
| `AppMetricCard` | ✅ Phase 6 | KPI: tinted icon, metric number (status / brand color), label, optional hint. 2 × 2 grid with equal row heights; one column when narrow or text is large |
| `MaintenanceOverviewTile` | ✅ Phase 6 | Customer, model, status badge, "n gün gecikti / kaldı", next date — dashboard priority list and maintenance list |
| Status filter chips | ✅ Phase 6 | Horizontally scrollable `FilterChip`s with counts; selected = filled + check mark, others show the status icon |

## Dates

User-visible dates use `context.formatDate(CalendarDate)` →
`DateFormat.yMMMd` of the active locale ("19 Oca 2026"). Material's
`formatMediumDate` is not used: its Turkish pattern omits the year.

## Money

`context.formatKurus(int)` → `NumberFormat.currency` of the active locale
with the `₺` symbol ("₺1.250,50"). Amounts are stored as integer kuruş.

## Motion

Android page transition: `FadeForwardsPageTransitionsBuilder`. Animations are
short and functional (state changes, list updates, save feedback).

## Responsive rules

- Content max width 420 for centered message states.
- Long names / models: `maxLines` + ellipsis.
- Forms scroll inside `SafeArea`; keyboard must never cause overflow.

## Portfolio assets

`docs/images/banner.png` (1280 × 640) uses the same tokens — background
`#F7FAFC`, primary `#0F766E`, secondary `#234E70`, Inter — around three real
screenshots. Gallery screenshots in `docs/images/screens/` are real
emulator captures scaled to 540 × 1200.
