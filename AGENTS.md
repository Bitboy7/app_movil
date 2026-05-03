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
- Entrypoint: `lib/main.dart` — initializes Firebase, Hive, and Riverpod `ProviderScope`.
- App widget: `lib/app.dart` (class `AppMovil`) — `ConsumerWidget` with `MaterialApp.router`, dark mode support via `themeModeProvider`.
- State management: Riverpod with code generation (`riverpod_annotation`, `riverpod_generator`).
- Routing: `go_router` (defined in `lib/core/routing/app_router.dart`) — `ShellRoute` with bottom nav, custom page transitions (fade, slide).
- Auth: Firebase Auth + Google Sign-In (`firebase_auth`, `google_sign_in`).
- Local storage: `hive_flutter` (adapters in `lib/core/data/hive_adapters.dart`) + `shared_preferences`.
- Animations: `flutter_animate` and `lottie` (assets in `assets/lottie/`: `Hatch.json`, `checklist.json`, `progress.json`, `star.json`).
- Architecture: Feature-based folder structure (`lib/features/{auth,pet,routine,settings,stats,onboarding}`), each with `data/`, `domain/`, `presentation/` layers where applicable.
- Shared widgets: `lib/shared/widgets/` — `AppBottomNav`, `InteractivePet`, `DailyLoginGate`, `CelebrationOverlay`, `CoachMark`, `AnimatedCounter`, `AnimatedAppIcon`.
- Design tokens: `lib/core/theme/` — `AppColors`, `AppDesignTokens`, `AppDuration`, `AppEasing`, `AppRadius`, `AppTheme` (light + dark).
- Core services: `seasonal_theme.dart`, `sound_service.dart`, `widget_data_service.dart`.
- Core utils: `extensions.dart`.
- App title: "Bibu - Tu rutina con vida".
- Icons: `cupertino_icons`, `font_awesome_flutter`, `phosphor_flutter`.
- Fonts: `google_fonts`.
- Firebase App Distribution (`firebase_app_distribution`).

## Conventions

- Trailing commas on widget trees (e.g. `Scaffold`, `Column`) to enable Flutter's auto-formatter.
- No CI, no pre-commit hooks. Run `flutter analyze` before committing.
- The `pubspec.lock` is committed — it's an app, not a library package.
- Run `dart run build_runner build --delete-conflicting-outputs` after modifying `.g.dart` files.
- `firebase_options.dart` is generated — re-run `flutterfire configure` if Firebase project changes.
- Sensitive files (`.env`, `google-services.json`, `GoogleService-Info.plist`, `firebase_options.dart`, `.opencode/`) are in `.gitignore` — never commit them.
