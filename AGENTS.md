# AGENTS.md — Engineering Standards

Single source of truth for the technical rules of **Field Service Tracker**.
Every contributor (human or AI) follows this file. Other docs link here instead
of repeating rules.

## 1. Product scope

- Offline-first Android app for customers, devices and periodic maintenance of
  water-purifier / field-service businesses.
- UI language: **Turkish**. Code, comments, commit messages, docs: **English**.
- No Firebase, REST backend, authentication, push notifications, analytics or
  paid services unless the project owner explicitly asks.
- All bundled data is fictional. Never add real names, phone numbers,
  addresses, secrets or real database files.

## 2. Architecture

Feature-first, layered. Dependency direction (never reversed, no cycles):

```
UI (pages/widgets) → Cubit/Bloc → Repository interface (domain)
  → Repository implementation (data) → DAO (database) → SQLite
```

| Layer | Lives in | Responsibility | Must not |
|---|---|---|---|
| Presentation | `features/*/presentation/{pages,widgets}` | Render state, forward user intent, navigate | Touch Drift, DAOs, SQL, `DateTime.now()` |
| State | `features/*/presentation/cubit` | Call repositories, build immutable UI state, map errors | Import Flutter widgets other than via `flutter_bloc` |
| Domain | `features/*/domain` | Models, repository interfaces, validation, date rules | Depend on Flutter, Drift or generated classes |
| Data | `features/*/data`, `lib/database` | Drift tables, DAOs, repository impls, migrations, seed | Leak Drift row classes outside the data layer |

- **Cubit by default.** Use `Bloc` only when there is real event handling
  (e.g. event transformers). One Cubit per screen/use, not per widget.
- No separate ViewModel next to a Cubit.
- No use-case class for plain CRUD. A domain service is allowed only for logic
  that is complex, reused, or coordinates several repositories.
- Dependency injection: `RepositoryProvider` for app-wide services and
  repositories (in `lib/app/app.dart`), `BlocProvider` scoped to the route.
- Time: always inject `AppClock` (`lib/core/clock`). Never call
  `DateTime.now()` in domain, state or UI code.

## 3. Folder layout

```
lib/
  main.dart            bootstrap (logging, licenses, DB open, runApp)
  app/                 app.dart, router/, theme/
  core/                clock/, errors/, extensions/, utils/, widgets/
  l10n/                app_tr.arb (+ generated app_localizations*.dart)
  database/            app_database.dart, tables/, daos/, converters/, seed/
  features/<feature>/  domain/, data/, presentation/{cubit,pages,widgets}
test/                  mirrors lib/; shared helpers in test/helpers/
docs/                  ARCHITECTURE, DATABASE, DESIGN_SYSTEM, FEATURES, TESTING
```

## 4. Package policy

- Allowed stack: `material_ui`, `flutter_bloc`, `equatable`, `go_router`,
  `drift` + `drift_flutter`, `intl`, `package_info_plus`; dev: `flutter_test`,
  `bloc_test`, `mocktail`, `build_runner`, `drift_dev`, `flutter_lints`.
- **Never** add Riverpod, Provider (as a state solution), GetX or a second
  state-management system.
- A new dependency needs a written reason (what it replaces, why own code is
  worse). Verify the version on pub.dev and its SDK constraints first.
- `pubspec.lock` is committed.
- **Material import:** use `package:material_ui/material_ui.dart`, not
  `package:flutter/material.dart`. Since Flutter 3.44 Material lives in the
  `material_ui` package and `go_router` 18 depends on it; mixing both imports
  creates two incompatible `ThemeData` types.
- Fonts are bundled assets (Inter, OFL). No runtime font downloads (offline).

## 5. Code standards

- `dart format` (default style) and `flutter analyze` with zero issues.
  Lint rules live in `analysis_options.yaml`; do not silence them inline
  without a comment explaining why.
- Package imports only (`package:field_service_tracker/...`).
- Immutable state classes extending `Equatable`.
  **equatable ≥ 3.0 does not compare `runtimeType`**: two different state
  subclasses with equal `props` are `==`. Prefer a single state class with a
  `status` enum, or make every subclass's `props` distinguishable.
- User-facing strings only via `context.l10n` (ARB). No hardcoded Turkish text
  in widgets.
- Colors, spacing, radius and text styles only via theme / tokens
  (`lib/app/theme`). No literal hex colors or magic paddings in widgets.
- Keep widget files small; extract private widgets or `core/widgets` components
  when a build method grows beyond one screen of code.
- Errors are never swallowed: log technical details with `dart:developer`
  `log`, show the user a friendly Turkish message, never a raw exception.
- Money is stored as integer **kuruş**. Calendar dates are `CalendarDate`
  values (no time, no timezone); timestamps are UTC `DateTime`.
- Turkish text: use `TurkishText` for lowercasing, search keys and sorting —
  never plain `toLowerCase()` / `compareTo` on names.
- Dispose controllers, cancel stream subscriptions, close Cubits / DB.

## 6. Testing rules

- Every business rule gets unit tests (dates, validation, normalization).
- Every Cubit gets `bloc_test` coverage for success, empty and failure paths.
- Repositories / DAOs are tested against an in-memory Drift database.
- Widget tests cover loading, empty, error, form validation and navigation.
- Freeze time with a fake `AppClock` in tests.
- Never report tests as passing without running them.
- While developing, run the tests of the changed module (plus dependent
  modules when shared code changes). At the end of a phase run
  `dart format .`, `flutter analyze` and the full `flutter test` once; a
  phase with failing tests is not complete. Write few, meaningful tests
  (rules, data integrity, deletions, key Cubit behaviour, core flows) — no
  count or coverage targets. Details: `docs/TESTING.md`.

## 7. Database rules

- SQLite via Drift; `PRAGMA foreign_keys = ON` on every connection.
- Uniqueness and integrity are enforced in the schema (UNIQUE, CHECK, FK),
  not only in the UI.
- Multi-table writes run in a transaction.
- Foreign keys use `ON DELETE RESTRICT`; related rows are deleted explicitly,
  in a transaction, and only after the user confirmed what will be removed.
- Every schema change bumps `schemaVersion`, adds a migration step and a
  migration test. No unplanned schema edits.
- Demo seed runs only when the database is created and is deterministic.
- Repositories wrap every DAO call with `guardDatabase` /
  `guardDatabaseStream` so no `SqliteException` reaches a Cubit.
- Generated files (`*.g.dart`, `lib/l10n/app_localizations*.dart`) are
  committed; regenerate with the commands in `docs/TESTING.md`.

## 8. Security & repository hygiene

- Never commit secrets, keystores, `key.properties`, `.env`, local databases,
  build output or machine-specific files (see `.gitignore`).
- The GitHub repository is **private**. Never change its visibility.
- Commit locally with meaningful messages; push only with the owner's
  explicit approval.
