# Testing

Rules: [AGENTS.md §6](../AGENTS.md#6-testing-rules).

## Commands

```bash
flutter pub get                                   # also runs gen-l10n
dart run build_runner build --delete-conflicting-outputs   # Drift code (Phase 2+)
dart format .
flutter analyze
flutter test
flutter test --coverage
```

## Test layout

`test/` mirrors `lib/`. Shared helpers live in `test/helpers/`:

- `pump_app.dart` — pumps `FieldServiceTrackerApp` with a fixed clock and
  fake `AppInfo`.
- `fixed_clock.dart` — `AppClock` returning a constant date.

## Test pyramid

| Level | Tooling | Scope |
|---|---|---|
| Unit | `flutter_test` | Date rules, validation, normalization, mapping |
| Cubit | `bloc_test`, `mocktail` | Loading / loaded / empty / error, submit flows |
| Database | in-memory Drift (`NativeDatabase.memory()`) | CRUD, FK, transactions, seed, reset |
| Widget | `flutter_test` | Screens, forms, navigation |

## Current suites (Phase 1)

| File | Covers |
|---|---|
| `test/app/app_test.dart` | App starts on dashboard, Turkish tab labels |
| `test/app/router/app_router_test.dart` | Tab switching, pushed routes hide the bar, back navigation, invalid ids |
| `test/app/theme/app_theme_test.dart` | Brand colors, StatusColors extension, Inter font |
| `test/features/settings/settings_page_test.dart` | Version text, licenses entry |
