# AGENTS.md

## Commands

```bash
# IMPORTANT: Flutter está en C:\Users\TU-USUARIO\flutter\bin
# Agrégalo al PATH del usuario para usar flutter directamente:
#   [Environment]::SetEnvironmentVariable("PATH", "$env:PATH;C:\Users\sopes\flutter\bin", "User")
# O antepone cada comando con:
#   $env:Path += ";C:\Users\sopes\flutter\bin"; flutter <command>

# Analyze (lint + type-check)
flutter analyze

# Run all tests
flutter test

# Run a single test file
flutter test test/widget_test.dart

# Get dependencies
flutter pub get

# Run on connected device/emulator
flutter run

# Generate Riverpod providers
dart run build_runner build --delete-conflicting-outputs
```

## Architecture

- Standard Flutter app (stable channel), Dart SDK `^3.9.2`.
- Entrypoint: `lib/main.dart` — initializes Hive and Riverpod `ProviderScope`.
- State management: Riverpod with code generation (`riverpod_annotation`, `riverpod_generator`).
- Routing: `go_router` (defined in `lib/core/routing/app_router.dart`).
- Local storage: `hive_flutter` (adapters in `lib/core/data/hive_adapters.dart`).
- Animations: `flutter_animate` and `lottie`.
- Architecture: Feature-based folder structure (`lib/features/{auth,pet,routine,settings,stats,onboarding}`).

## Conventions

- Trailing commas on widget trees (e.g. `Scaffold`, `Column`) to enable Flutter's auto-formatter.
- No CI, no pre-commit hooks. Run `flutter analyze` before committing.
- The `pubspec.lock` is committed — it's an app, not a library package.
- Run `dart run build_runner build --delete-conflicting-outputs` after modifying `.g.dart` files.
