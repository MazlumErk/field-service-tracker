# Release Guide (Android)

> Status: release **signing is configured but no release key exists yet.**
> Without `android/key.properties`, `flutter build apk --release` still
> works but signs with the Flutter **debug** key and prints a warning —
> such APKs are for local testing only and must not be shared as a
> release.

## How signing works

`android/app/build.gradle.kts` reads `android/key.properties`:

| Situation | Release build is signed with |
|---|---|
| `android/key.properties` present | your release keystore |
| file missing | debug key + Gradle warning `... signed with the DEBUG key ...` |

`android/key.properties`, `*.jks`, `*.keystore` and `.env*` are git-ignored.
A template without secrets is committed: `android/key.properties.example`.

Verified on 2026-11-11 with a throwaway keystore: the APK was signed with
that key (`apksigner verify --print-certs`), and without the file it was
signed with `CN=Android Debug`. The throwaway files were deleted.

## One-time setup (done by the owner)

1. **Create a keystore outside the repository** (keep it and the passwords
   in a password manager; losing it means you can never update the app with
   the same signature):

   ```bash
   keytool -genkeypair -v -storetype PKCS12 -keystore C:/keys/field-service-tracker-release.jks -keyalg RSA -keysize 4096 -validity 10000 -alias field-service-tracker
   ```

   `keytool` ships with Android Studio's JBR
   (`C:\Program Files\Android\Android Studio\jbr\bin\keytool.exe`).

2. **Create `android/key.properties`** from the example and fill in the
   path, alias and passwords. Do not commit it.

3. **Build and verify:**

   ```bash
   flutter build apk --release
   ```

   ```bash
   apksigner verify --print-certs build/app/outputs/flutter-apk/app-release.apk
   ```

   The certificate DN must be yours, not `CN=Android Debug`.

## Before publishing a build

- Decide the version in `pubspec.yaml` (`version: 0.1.0+1` today; e.g.
  `1.0.0+1` for the first public release). The build number must increase
  with every published APK.
- Application id `dev.mazlumerk.field_service_tracker` and display name
  "Field Service Tracker" are final; changing the id later would install as
  a different app and lose the local database.
- Publishing (GitHub Releases, Play Store) happens only with the owner's
  explicit approval. CI does not build or sign release artifacts and needs
  no secrets.
