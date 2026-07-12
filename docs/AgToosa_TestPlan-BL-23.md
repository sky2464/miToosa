# Test Plan — BL-23 FlutterFire iOS Config + DebugView

> **Spec:** [docs/archived/spec-BL-23.md](archived/spec-BL-23.md)  
> **Coverage target:** 80% (per `docs/Context/workflow.md`)  
> **Generated:** 2026-06-11  

## Scope & Strategy

BL-23 closes BL-22 deferred task 6.2. Automated tests assert generated `firebase_options.dart` and doc updates. Manual DebugView verification requires a physical device or simulator with Firebase debug mode and valid Firebase CLI auth.

## AC Coverage Matrix

| AC ID | EARS summary | Priority | Test IDs | Category | Smoke |
|-------|--------------|----------|----------|----------|-------|
| AC-001 | iOS `FirebaseOptions` not placeholder | Must | T-001 | Unit | T-001 `@smoke` |
| AC-002 | Local `GoogleService-Info.plist` with correct bundle | Must | T-002 | Config / Manual | — |
| AC-003 | Docs pin project `mitoosa-2121b` + run commands | Must | T-003 | Unit / Docs | T-003 `@smoke` |
| AC-004 | Plist gitignored | Must | T-004 | Unit / Config | T-004 `@smoke` |
| AC-005 | DebugView shows session event | Must | T-005 | Manual | — |
| AC-006 | Launch readiness checkboxes updated | Should | T-006 | Docs | — |

## Test Catalog

### T-001 — iOS Firebase options are configured `@smoke`
- **Category:** Unit
- **AC:** AC-001
- **Steps:** Run `flutter test test/data/firebase_options_test.dart`.
- **Pass:** Test asserts iOS branch returns `FirebaseOptions` with `projectId` `mitoosa-2121b` and does not throw placeholder `UnsupportedError`.

### T-002 — GoogleService-Info.plist exists locally
- **Category:** Manual / Config
- **AC:** AC-002
- **Steps:** After `flutterfire configure`, verify `ios/Runner/GoogleService-Info.plist` exists and `BUNDLE_ID` is `dev.atoosa.mitoosa`.
- **Pass:** File present with matching bundle ID.

### T-003 — Analytics setup documents project and commands `@smoke`
- **Category:** Unit / Docs
- **AC:** AC-003
- **Steps:** Run readiness/doc tests or grep `docs/ANALYTICS-SETUP.md`.
- **Pass:** Contains `mitoosa-2121b`, `flutterfire configure`, and `FIREBASE_ENABLED=true`.

### T-004 — GoogleService-Info.plist is gitignored `@smoke`
- **Category:** Unit / Config
- **AC:** AC-004
- **Steps:** Confirm `.gitignore` contains `**/GoogleService-Info.plist`; `git status` does not stage plist after configure.
- **Pass:** Plist ignored.

### T-005 — Firebase Analytics DebugView manual verification
- **Category:** Manual / External
- **AC:** AC-005
- **Preconditions:** T-001–T-002 complete; Firebase CLI logged in; iOS simulator or device.
- **Steps:**
  1. `flutter run -d iPhone --dart-define=FIREBASE_ENABLED=true`
  2. Complete cold launch / start a gameplay session (triggers `session_start` or equivalent).
  3. Open Firebase Console → Analytics → DebugView (enable debug mode on device if needed).
- **Pass:** At least one miToosa analytics event visible within 5 minutes.

### T-006 — iPhone launch readiness reflects FlutterFire completion
- **Category:** Docs
- **AC:** AC-006
- **Steps:** Read `docs/IPHONE-LAUNCH-READINESS.md` Firebase section.
- **Pass:** FlutterFire configure item checked when T-001 passes.

## Regression

- `dart analyze` — clean
- `flutter test` — full suite green after test updates (887 tests)

## TDD evidence

### Task 2.2 — ANALYTICS-SETUP.md DebugView checklist

```
RED evidence — 2.2
Command: flutter test test/data/firebase_options_test.dart --name "ANALYTICS-SETUP"
Exit code: 1 (before doc checklist section; test added in same session)
Failure excerpt: test file did not assert DebugView checklist content
```

```
GREEN evidence — 2.2
Command: flutter test test/data/firebase_options_test.dart --name "ANALYTICS-SETUP"
Exit code: 0
```

### Task 2.3 — IPHONE-LAUNCH-READINESS.md FlutterFire checkboxes

```
RED evidence — 2.3
Command: flutter test test/release/iphone_launch_readiness_test.dart --name "FlutterFire configure complete"
Exit code: 1
Failure excerpt: Expected: contains '[x] Replace placeholder `lib/firebase_options.dart`'
```

```
GREEN evidence — 2.3
Command: flutter test test/release/iphone_launch_readiness_test.dart --name "FlutterFire configure complete"
Exit code: 0
```

### Task 3.1 — Full verification gates

```
RED evidence — 3.1
Command: flutter test
Exit code: 1
Failure excerpt: ink_sparkle.frag manifest could not be decoded (6 widget tests on tap)
```

```
GREEN evidence — 3.1
Command: dart analyze lib test && flutter test
Exit code: 0
```

## Manual Sign-off

| Test | Owner | Date | Result |
|------|-------|------|--------|
| T-005 DebugView | Owner | 2026-06-20 | 🔧 Deferred — ship policy; complete before App Store analytics gate |
