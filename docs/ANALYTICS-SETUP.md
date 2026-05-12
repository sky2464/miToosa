# Analytics Setup (Firebase)

This document covers the manual setup required to activate S1-02 analytics forwarding.

## Prerequisites

- Firebase project exists (S1-01 setup complete)
- Flutter SDK installed
- FlutterFire CLI available

## Steps

1. Enable Google Analytics in your Firebase project.
2. Install FlutterFire CLI:
   ```bash
   dart pub global activate flutterfire_cli
   ```
3. From repository root, generate Firebase options:
   ```bash
   flutterfire configure --project=<your-firebase-project-id>
   ```
4. Confirm `lib/firebase_options.dart` is replaced by generated credentials.
5. Run the app with Firebase forwarding enabled:
   ```bash
   flutter run --dart-define=FIREBASE_ENABLED=true
   ```
6. Trigger at least one telemetry event (for example `session_start`).
7. Open Firebase Console -> Analytics -> DebugView and verify event arrival.
8. After verification, keep `FIREBASE_ENABLED` default disabled in normal builds unless rollout is approved.

## Notes

- The placeholder `lib/firebase_options.dart` intentionally throws when Firebase is enabled before configuration.
- Default behavior remains local-first analytics (`NoOpAnalyticsSink`) when `FIREBASE_ENABLED` is not set.
