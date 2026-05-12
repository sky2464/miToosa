# Spec: S1-02 — Analytics Backend Integration

**Story ID:** S1-02
**Epic:** EP-01 — Launch Readiness & Validation
**Status:** Approved
**Date:** 2026-05-04
**Author:** AgToosa

## ✅ Spec Approved

Approved: 2026-05-11 10:00

## Build Scope

Files in scope: `pubspec.yaml`, `lib/core/analytics/firebase_analytics_sink.dart`, `lib/firebase_options.dart`, `lib/data/telemetry_provider.dart`, `lib/main.dart`, `docs/ANALYTICS-SETUP.md`, `docs/AgToosa_TestPlan-S1-02.md`, `docs/Master-Plan.md`
Directories in scope: `lib/core/analytics`, `lib/data`, `lib`, `docs`
Out of scope: Firebase Console project creation, `flutterfire configure` execution, real credential commit, DebugView validation requiring live Firebase project

---

## Context

The analytics architecture is already wired for a real backend:

- `lib/core/analytics/analytics_sink.dart` — `AnalyticsSink` abstract class + `NoOpAnalyticsSink`
- `lib/data/telemetry_provider.dart` — `analyticsSinkProvider` with a TODO comment: _"Replace with a
  real AnalyticsSink once a backend is selected"_
- `lib/data/forwarding_telemetry_repository.dart` — wraps `HiveTelemetryRepository` and forwards
  every event to the active sink
- 12 events fully defined in `docs/analytics-events-v1.3.md` and already wired at their emit
  locations

Firebase Analytics is the chosen backend (confirmed in `docs/backend-research.md` and
`docs/LAUNCH.md`). No `firebase_*` packages are in `pubspec.yaml` yet. Firebase project creation is
a **manual prerequisite** (see S1-01 for project setup).

This spec covers all code that can be written now, plus step-by-step instructions for wiring the
credentials once the Firebase project exists.

---

## Scope

### In scope — code (do now)

1. Add `firebase_core` and `firebase_analytics` to `pubspec.yaml`
   _(versions must be verified against pub.dev before implementing — see note below)_
2. Implement `FirebaseAnalyticsSink` in `lib/core/analytics/firebase_analytics_sink.dart`
3. Add `lib/firebase_options.dart` as a placeholder with a compile-error guard and TODO instructions
4. Update `lib/data/telemetry_provider.dart` — wire `FirebaseAnalyticsSink` behind a
   `kFirebaseEnabled` dart-define flag (default `false`, so default build is unchanged)
5. Update `lib/main.dart` — call `Firebase.initializeApp()` conditionally on `kFirebaseEnabled`
6. Create `docs/ANALYTICS-SETUP.md` — step-by-step FlutterFire CLI + Firebase project wiring guide

### Out of scope (requires Firebase project — manual)

- Creating the Firebase project
- Running `flutterfire configure` to generate real `firebase_options.dart`
- Verifying events in Firebase Analytics DebugView

---

## Version Verification Note

Before implementing, verify current stable versions on pub.dev:
- `firebase_core` — check [pub.dev/packages/firebase_core](https://pub.dev/packages/firebase_core)
- `firebase_analytics` — check [pub.dev/packages/firebase_analytics](https://pub.dev/packages/firebase_analytics)

Use the latest stable minor compatible with Dart SDK `>=3.11.0`.

---

## Architecture Blueprint

### Files changed

| File | Change |
|------|--------|
| `pubspec.yaml` | Add `firebase_core`, `firebase_analytics` |
| `lib/core/analytics/firebase_analytics_sink.dart` | New — FirebaseAnalyticsSink |
| `lib/firebase_options.dart` | New — placeholder with compile-error guard |
| `lib/data/telemetry_provider.dart` | Wire FirebaseAnalyticsSink via kFirebaseEnabled flag |
| `lib/main.dart` | Add conditional `Firebase.initializeApp()` |
| `docs/ANALYTICS-SETUP.md` | New — manual FlutterFire setup guide |

### FirebaseAnalyticsSink

```dart
// lib/core/analytics/firebase_analytics_sink.dart
import 'package:firebase_analytics/firebase_analytics.dart';
import '../../data/telemetry_event.dart';
import 'analytics_sink.dart';

class FirebaseAnalyticsSink implements AnalyticsSink {
  final FirebaseAnalytics _analytics;
  const FirebaseAnalyticsSink(this._analytics);

  @override
  Future<void> track(TelemetryEvent event) async {
    await _analytics.logEvent(
      name: event.name,
      parameters: event.properties,
    );
  }
}
```

### kFirebaseEnabled Flag + Provider Update

```dart
// lib/data/telemetry_provider.dart
const kFirebaseEnabled =
    bool.fromEnvironment('FIREBASE_ENABLED', defaultValue: false);

final analyticsSinkProvider = Provider<AnalyticsSink>((ref) {
  if (kFirebaseEnabled) {
    return FirebaseAnalyticsSink(FirebaseAnalytics.instance);
  }
  return const NoOpAnalyticsSink();
});
```

Activate for local testing: `flutter run --dart-define=FIREBASE_ENABLED=true`

### firebase_options.dart Placeholder

```dart
// lib/firebase_options.dart
// TODO: Run `flutterfire configure --project=<your-project-id>` to replace
// this file with real credentials. Until then, do NOT set FIREBASE_ENABLED=true.
// ignore_for_file: lines_longer_than_80_chars

// This file intentionally fails to compile when FIREBASE_ENABLED=true and
// real credentials have not been added.
// Replace entire file with output from: flutterfire configure
throw UnsupportedError(
  'firebase_options.dart: Replace this file by running: '
  'flutterfire configure --project=<your-firebase-project-id>',
);
```

### main.dart Conditional Init

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kFirebaseEnabled) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
  runApp(const ProviderScope(child: MyApp()));
}
```

---

## STRIDE Threat Model

| Threat | Category | Mitigation |
|--------|----------|------------|
| Firebase web API key in `firebase_options.dart` exposed | Information Disclosure | Firebase web API keys are designed to be public; restrict by authorized domain in Firebase Console |
| Events contain PII | Information Disclosure | Player ID is anonymous UUID; event properties per `analytics-events-v1.3.md` contain no PII |
| `firebase_options.dart` with real keys committed to public repo | Information Disclosure | Placeholder guard prevents accidental use; real values added only after Firebase project created |
| Analytics SDK adds GDPR/COPPA obligations | Repudiation | Firebase Analytics uses anonymous identifiers; miToosa uses no sign-in, no PII collection |
| `kFirebaseEnabled=true` on default build | Tampering | Default is `false`; requires explicit `--dart-define` to enable |

---

## Acceptance Criteria

| ID | Scenario | Given | When | Then | Priority |
|----|----------|-------|------|------|----------|
| AC-001 | Default build unchanged | `FIREBASE_ENABLED` not set (default `false`) | `flutter run` / `flutter build web` | `NoOpAnalyticsSink` active; all events silently dropped; no crash | Must |
| AC-002 | Packages compile | `firebase_core` + `firebase_analytics` in pubspec | `flutter pub get && dart analyze` | Zero errors; `FirebaseAnalyticsSink` importable | Must |
| AC-003 | All 12 events route correctly | `ForwardingTelemetryRepository` active | Any `TelemetryEvent` is tracked | Event reaches active sink's `track()` method | Must |
| AC-004 | firebase_options placeholder guard | `lib/firebase_options.dart` is placeholder | `FIREBASE_ENABLED=true` + no real credentials | Build fails with clear error message pointing to `flutterfire configure` | Must |
| AC-005 | Firebase init on enable | Real `firebase_options.dart` + `FIREBASE_ENABLED=true` | App starts | `Firebase.initializeApp()` completes without error | Must (gated on Firebase project) |
| AC-006 | Event in DebugView | Firebase project live + `FIREBASE_ENABLED=true` | `session_start` event fired | Event visible in Firebase Analytics DebugView within 60 seconds | Must (gated on Firebase project) |
| AC-007 | Test suite unaffected | All code changes applied | `flutter test` | 637+ tests pass, zero failures | Must |

---

## Manual Firebase + FlutterFire Setup (step-by-step)

_See `docs/ANALYTICS-SETUP.md` generated by this spec. Full steps:_

1. Complete S1-01 Firebase project setup (Firebase project must exist first)
2. Enable Google Analytics in the Firebase project (Firebase Console → project settings)
3. Install FlutterFire CLI: `dart pub global activate flutterfire_cli`
4. In repo root: `flutterfire configure --project=<your-project-id>`
   - Selects platforms (iOS, Android, Web, macOS)
   - Overwrites `lib/firebase_options.dart` with real credentials
5. Enable DebugView for local testing (Android): `adb shell setprop debug.firebase.analytics.app com.mitoosa.app`
6. Run with Firebase enabled: `flutter run --dart-define=FIREBASE_ENABLED=true`
7. Open Firebase Console → Analytics → DebugView → confirm `session_start` appears within 60s
8. Set `kFirebaseEnabled` default to `true` in code once credentials are confirmed working

---

## Definition of Done

- [x] `pubspec.yaml` has `firebase_core` and `firebase_analytics` (versions verified on pub.dev)
- [x] `FirebaseAnalyticsSink` implemented in `lib/core/analytics/firebase_analytics_sink.dart`
- [x] `analyticsSinkProvider` wired with `kFirebaseEnabled` compile-time flag
- [x] `lib/firebase_options.dart` placeholder exists with compile-error guard
- [x] `lib/main.dart` includes conditional `Firebase.initializeApp()`
- [x] `docs/ANALYTICS-SETUP.md` written with all manual steps
- [x] Default build (`FIREBASE_ENABLED=false`): `dart analyze` passes, `flutter test` 637+ pass
- [x] Default build behaviour identical to pre-change (NoOpAnalyticsSink active)

---

## 3. Tasks

### 3.1 Task Tree

- [x] **1. Dependency and bootstrap wiring**
  - [x] 1.1 Verify latest stable `firebase_core` and `firebase_analytics` versions and add to `pubspec.yaml` — _Requirements: AC-002_
  - [x] 1.2 Add guarded `Firebase.initializeApp()` path in `lib/main.dart` using `FIREBASE_ENABLED` flag — _Requirements: AC-001, AC-005_
- [x] **2. Analytics sink integration**
  - [x] 2.1 Implement `FirebaseAnalyticsSink` adapter in `lib/core/analytics/firebase_analytics_sink.dart` — _Requirements: AC-002, AC-003_
  - [x] 2.2 Wire `analyticsSinkProvider` to switch between `NoOpAnalyticsSink` and Firebase sink by flag in `lib/data/telemetry_provider.dart` — _Requirements: AC-001, AC-003_
- [x] **3. Safety guards and docs**
  - [x] 3.1 Add placeholder `lib/firebase_options.dart` compile guard for enabled-without-config scenario — _Requirements: AC-004_
  - [x] 3.2 Create `docs/ANALYTICS-SETUP.md` with FlutterFire and DebugView manual setup flow — _Requirements: AC-006_
- [x] **4. Verification**
  - [x] 4.1 Run `flutter pub get`, `dart analyze`, and `flutter test` with `FIREBASE_ENABLED=false` baseline — _Requirements: AC-001, AC-007_

### 3.2 Wave Plan

**Wave 1 (parallel):** 1.1, 2.1, 3.2
**Wave 2 (sequential after Wave 1):** 1.2, 2.2, 3.1
**Wave 3 (sequential after Wave 2):** 4.1

### 3.3 Test Plan Link

Test plan skeleton: `docs/AgToosa_TestPlan-S1-02.md`
