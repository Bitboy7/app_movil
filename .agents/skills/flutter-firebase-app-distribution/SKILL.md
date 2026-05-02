---
name: flutter-firebase-app-distribution
description: Build a debug APK and upload it to Firebase App Distribution to distribute updates to testers automatically. Run when the user says "sube la app", "actualiza la app", "distribuye la app", "deploy a testers", or similar.
metadata:
  model: models/gemini-3.1-pro-preview
  last_modified: Fri, 01 May 2026 23:21:00 CST
---
# Firebase App Distribution Skill

## Prerequisites (already configured in this project)
- Firebase project: `bibu-147d3`
- Firebase App ID (Android): `1:75108470606:android:1dec7ccc867d546ddf981f`
- Firebase CLI installed and authenticated
- `firebase_app_distribution` plugin integrated in the app (HomePage calls `updateIfNewReleaseAvailable()`)
- `missingDimensionStrategy("default", "production")` in `android/app/build.gradle.kts`

## Workflow: Build & Distribute

Follow these steps every time the user wants to distribute a new build to testers.

**Task Progress:**
- [ ] Step 1: Build debug APK
- [ ] Step 2: Verify APK exists
- [ ] Step 3: Upload to Firebase App Distribution via CLI
- [ ] Step 4: Confirm success and share links with the user

### Step 1: Build debug APK

Run from the project root (`C:\Users\sopes\OneDrive\Escritorio\app_movil`):

```powershell
$env:Path += ";C:\Users\sopes\flutter\bin"; flutter build apk --debug
```

If this fails with a Gradle variant ambiguity error, verify `android/app/build.gradle.kts` contains:
```kotlin
defaultConfig {
    // ... other config ...
    missingDimensionStrategy("default", "production")
}
```

### Step 2: Verify APK exists

Check that the APK file exists at:
```
C:\Users\sopes\OneDrive\Escritorio\app_movil\build\app\outputs\flutter-apk\app-debug.apk
```

If it does not exist, the build failed. Read the error output and fix the issue before proceeding.

### Step 3: Upload to Firebase App Distribution

Run the Firebase CLI command. Use the exact App ID and testers from the project configuration.

```powershell
$env:Path += ";C:\Users\sopes\AppData\Roaming\npm"
firebase appdistribution:distribute "C:\Users\sopes\OneDrive\Escritorio\app_movil\build\app\outputs\flutter-apk\app-debug.apk" `
  --app 1:75108470606:android:1dec7ccc867d546ddf981f `
  --release-notes "<DESCRIBE_CHANGES>" `
  --testers "<COMMA_SEPARATED_EMAILS>" `
  --project=bibu-147d3
```

Replace:
- `<DESCRIBE_CHANGES>` with a short summary of what changed in this version (e.g., "Fix: login con Google, Add: foto de perfil").
- `<COMMA_SEPARATED_EMAILS>` with the tester emails. If the user does not specify, default to: `noelia2925441@gmail.com`

### Step 4: Confirm success

After the CLI prints `distributed to testers/groups successfully`, report to the user:
- The version number uploaded
- The testers who were notified
- The Firebase console link for the release
- The direct download link (expires in 1 hour)

## Important Notes

- **Always use `--debug` builds** for Firebase App Distribution testing. Release builds require a signing keystore and take much longer.
- **Do NOT run `flutter clean`** before building unless the user explicitly asks for it or there are build cache issues.
- The app already has in-app update detection. Testers will see a native alert when a new build is available if they open the app.
- If a new tester email is provided, Firebase automatically sends an invitation email. The tester must accept it before they can download.
