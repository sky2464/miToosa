# Analytics Setup (Firebase)

This document covers the manual setup required to activate analytics forwarding for the iPhone launch.

**Launch decision:** Firebase + Google Analytics are approved for release. The iOS Firebase app must use bundle ID `dev.atoosa.mitoosa`.

## Prerequisites

- Firebase project **`mitoosa-2121b`** exists (active alias: `default` in this repo)
- **Google Analytics is linked** to the Firebase project (Integrations → Google Analytics → Enable). DebugView and event upload do not work until this is done.
- After GA is linked, `ios/Runner/GoogleService-Info.plist` should include a `MEASUREMENT_ID` key and `IS_ANALYTICS_ENABLED` should be `true` when re-downloaded from Firebase.
- iOS app registered in Firebase with bundle ID `dev.atoosa.mitoosa`
- Firebase CLI authenticated: `firebase login` (required for `flutterfire configure`)
- Flutter SDK installed
- FlutterFire CLI available

## Steps

1. **Enable Google Analytics** in Firebase Console → Project settings → [Integrations](https://console.firebase.google.com/project/mitoosa-2121b/settings/integrations) → Google Analytics → **Enable** (create or link a GA4 property).
2. Re-download or regenerate iOS config after GA is linked:
   ```bash
   dart pub global activate flutterfire_cli
   export PATH="$PATH:$HOME/.pub-cache/bin"
   flutterfire configure --project=mitoosa-2121b --platforms=ios --ios-bundle-id=dev.atoosa.mitoosa --yes
   ```
3. **Verify** `ios/Runner/GoogleService-Info.plist` contains `MEASUREMENT_ID` (not only `GOOGLE_APP_ID`). If `IS_ANALYTICS_ENABLED` is still `false` and there is no `MEASUREMENT_ID`, GA is not linked yet — DebugView will stay empty.
4. Confirm `lib/firebase_options.dart` matches generated credentials.
5. Run the app with Firebase forwarding enabled:
   ```bash
   flutter run --dart-define=FIREBASE_ENABLED=true
   ```
6. Open Firebase Console → Analytics → DebugView and look for `mitoosa_debug_ping` (debug builds) or automatic events within ~60 seconds.
7. For release builds where analytics should be active, pass `--dart-define=FIREBASE_ENABLED=true`.
8. Complete App Store Connect App Privacy answers to declare the Firebase + Google Analytics behavior used in the submitted build.

## Notes

- The placeholder `lib/firebase_options.dart` intentionally throws when Firebase is enabled before configuration.
- Default behavior remains local-first analytics (`NoOpAnalyticsSink`) when `FIREBASE_ENABLED` is not set.
- Release analytics requires both generated Firebase config and `FIREBASE_ENABLED=true`.
- Do not enable leaderboard, auth sync, or server persistence from this setup; those remain separate product decisions.

## Troubleshooting

### `firebase projects:list` or `flutterfire configure` fails with 401

Expired Firebase CLI credentials. Re-authenticate, then re-run configure:

```bash
firebase login --reauth
export PATH="$PATH:$HOME/.pub-cache/bin"
flutterfire configure --project=mitoosa-2121b --platforms=ios --ios-bundle-id=dev.atoosa.mitoosa
```

### DebugView shows no events

**First check (most common):** Google Analytics is not linked to the project. Fetch the iOS config from Firebase (or open `ios/Runner/GoogleService-Info.plist`). If you do **not** see `MEASUREMENT_ID`, fix GA linking before anything else:

1. [Firebase Integrations](https://console.firebase.google.com/project/mitoosa-2121b/settings/integrations) → Google Analytics → **Enable**
2. Re-run `flutterfire configure` (see Steps above)
3. Confirm plist now has `MEASUREMENT_ID`

DebugView only receives **debug-mode** traffic. Production batches can take up to ~1 hour and never appear in DebugView.

1. **Rebuild** with Firebase forwarding (hot reload is not enough):
   ```bash
   flutter run -d "iPhone 17 Pro" --dart-define=FIREBASE_ENABLED=true
   ```
2. **Enable iOS Analytics debug mode** — required for DebugView:
   - **Simulator / `flutter run`:** the shared `Runner` scheme includes `-FIRDebugEnabled` for Debug builds (committed in `ios/Runner.xcodeproj/xcshareddata/xcschemes/Runner.xcscheme`).
   - **Physical device from Xcode:** Product → Scheme → Edit Scheme → Run → Arguments → add `-FIRDebugEnabled` if you use a custom scheme without that flag.
3. **Sign in** past the login screen so `MainAppShell` loads (custom telemetry session events fire there).
4. **Play at least one level** if you want `level_complete`-style events (when wired); automatic Firebase events (`first_open`, `screen_view`, automatic `session_start`) can appear as soon as the app runs with debug mode on.
5. In Firebase Console → **Analytics** → **DebugView**, select your device in the device dropdown (top left). Project: `mitoosa-2121b`, iOS app `dev.atoosa.mitoosa`.
6. Wait up to **60 seconds** after interacting with the app; refresh DebugView if needed.

**Note:** Custom `logEvent` names `session_start` / `session_end` overlap GA4 reserved names and may be dropped. Look for automatic session events or other custom events (e.g. `level_complete`) in DebugView. Verbose Xcode logging: add `-FIRAnalyticsVerboseLoggingEnabled` to the same scheme Arguments list.
