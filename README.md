# Field Service Tracker

**Offline-first field service and maintenance management application built
with Flutter, BLoC and SQLite.**

> 🚧 **Work in progress — Phase 3 of 9 (customer management).**
> The app shell, design system, SQLite database, business rules and the
> complete customer management module are in place and tested. Device,
> maintenance and dashboard screens are being built; see the
> [roadmap](#roadmap).
> Screenshots and a demo video will be added once real screens exist.

## Project Overview

Field Service Tracker helps water-purifier and similar field-service
businesses track customers, their devices and periodic maintenance — fully
offline, with all data stored on the device. The UI is in Turkish.

## Features

| Feature | Status |
|---|---|
| Material 3 app shell with 4-tab navigation | ✅ |
| "Calm Operations" design system (Inter, tokens, status colors) | ✅ |
| Settings: about, version, open-source licenses | ✅ |
| Local SQLite database (Drift) with integrity constraints | ✅ |
| Fictional demo data on first launch, transactional reset service | ✅ (reset button ⏳) |
| Maintenance status rules (overdue / upcoming / scheduled) | ✅ (logic, UI ⏳) |
| Customers: live Turkish-aware search, create, edit, safe delete with impact preview | ✅ |
| Customer detail with devices and maintenance status | ✅ |
| Devices and maintenance history | ⏳ |
| Maintenance records with filter replacements and pricing | ⏳ |
| Overdue / upcoming maintenance tracking and dashboard | ⏳ |

## Screenshots

_Coming with the feature phases — only real app screenshots will be used._

## Demo Video

_Planned for the portfolio release (Phase 9)._

## Architecture

Feature-first layered architecture:

```
UI → Cubit → Repository interface → Repository implementation → DAO → SQLite
```

Details: [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md).

## Tech Stack

| Area | Technology |
|---|---|
| Framework | Flutter 3.47 · Dart 3.13 |
| UI | Material 3 (`material_ui`) |
| State management | `flutter_bloc` (Cubit) + `equatable` |
| Navigation | `go_router` (`StatefulShellRoute`) |
| Database | Drift + SQLite (`drift_flutter`) |
| Localization | gen-l10n (Turkish) + `intl` |
| Testing | `flutter_test`, `bloc_test`, `mocktail` |

## Database Design

Four related tables — customers → devices → maintenance records → filter
replacements — with foreign keys (`RESTRICT`), unique and check constraints.
Details: [docs/DATABASE.md](docs/DATABASE.md).

## Project Structure

```
lib/
  app/        app widget, router, theme
  core/       clock, extensions, shared widgets
  l10n/       Turkish strings (ARB)
  database/   Drift database, tables, DAOs, seed
  features/   dashboard, customers, devices, maintenance, settings
docs/         architecture, database, design system, features, testing
```

## Getting Started

Requirements: Flutter 3.47+ (stable), Android SDK, an emulator or device.

```bash
flutter pub get
flutter run
```

## Testing

```bash
dart format .
flutter analyze
flutter test
```

More: [docs/TESTING.md](docs/TESTING.md).

## Design System

See [docs/DESIGN_SYSTEM.md](docs/DESIGN_SYSTEM.md).

## Roadmap

1. ✅ Project foundation — theme, routing, DI, docs
2. ✅ Database & domain — Drift schema, DAOs, repositories, rules, seed
3. ✅ Customers — list, search, form, detail, safe delete
4. ⏳ Devices
5. ⏳ Maintenance
6. ⏳ Dashboard
7. ⏳ UX refinement
8. ⏳ Quality assurance & CI
9. ⏳ Portfolio release — screenshots, demo video, APK

## Disclaimer

This is an independent portfolio project. It is not affiliated with any
company and contains no real customer data; all demo data is fictional.
The Inter typeface is licensed under the SIL Open Font License 1.1
(`assets/fonts/inter/OFL.txt`).
