# Spec: BL-23 — FlutterFire iOS Config + Verify DebugView

> **Story ID:** BL-23  
> **Epic:** EP-01 Launch Readiness & Validation  
> **Status:** 🏁 Shipped  
> **Estimate:** S  
> **Spec created:** 2026-06-11  
> **Shipped:** 2026-06-20  

## Goal Contract

| Field | Value |
|-------|-------|
| Outcome | iOS Firebase options are generated for project `mitoosa-2121b` / bundle `dev.atoosa.mitoosa`; release analytics path is verifiable in Firebase DebugView |
| User | Launch operator / project owner |
| Success | `lib/firebase_options.dart` contains real iOS options (not placeholder); local `ios/Runner/GoogleService-Info.plist` exists; app runs with `FIREBASE_ENABLED=true` and session events appear in DebugView |
| Proof | `flutter test` green including updated `firebase_options_test.dart`; manual DebugView screenshot or checklist sign-off in test plan T-005 |
| Non-goals | Android/Web/macOS Firebase apps; leaderboard/auth; changing `docs/PRODUCT-WEDGE.md`; App Store submission |

## 1. Requirements

### 1.1 User Stories

**As a** launch operator, **I want** FlutterFire to generate iOS Firebase configuration for `dev.atoosa.mitoosa` **so that** release builds can forward telemetry to Firebase Analytics.

**As a** launch operator, **I want** a DebugView verification checklist **so that** I can confirm analytics events arrive before App Store submission.

### 1.2 Acceptance Criteria (EARS)

| ID | EARS | Priority |
|----|------|----------|
| AC-001 | WHEN `DefaultFirebaseOptions.currentPlatform` is read on iOS THE SYSTEM SHALL return valid `FirebaseOptions` for project `mitoosa-2121b` (not the placeholder `UnsupportedError`). | Must |
| AC-002 | WHEN the iOS Runner target is built locally THE SYSTEM SHALL have `ios/Runner/GoogleService-Info.plist` present on disk with bundle ID `dev.atoosa.mitoosa`. | Must |
| AC-003 | WHEN analytics docs are inspected THE SYSTEM SHALL document project ID `mitoosa-2121b`, `flutterfire configure` command, and `FIREBASE_ENABLED=true` run instructions. | Must |
| AC-004 | WHEN `GoogleService-Info.plist` is generated THE SYSTEM SHALL keep it gitignored and SHALL NOT commit API keys to the public repo without owner approval. | Must |
| AC-005 | WHEN the operator runs the app with `--dart-define=FIREBASE_ENABLED=true` and triggers a session THE SYSTEM SHALL allow verification of at least one analytics event in Firebase Analytics DebugView. | Must |
| AC-006 | WHEN BL-22 manual task 6.2 is complete THE SYSTEM SHALL mark Firebase iOS app + FlutterFire configure as done in launch readiness docs. | Should |

### 1.3 Out of Scope

- Creating the Firebase project (exists: `mitoosa-2121b`).
- Enabling Google Analytics admin settings beyond documenting steps.
- Android `google-services.json` or multi-platform FlutterFire.
- Automated E2E against live Firebase (manual DebugView only).
- App Store Connect or TestFlight upload.

## 2. Design

### 2.1 Architecture Blueprint

| File / artifact | Change |
|-----------------|--------|
| `lib/firebase_options.dart` | Replace placeholder with FlutterFire-generated iOS options |
| `ios/Runner/GoogleService-Info.plist` | Generated locally; remains in `.gitignore` |
| `firebase.json` | May gain `flutter` section from FlutterFire CLI |
| `docs/ANALYTICS-SETUP.md` | Pin project ID `mitoosa-2121b`; DebugView steps |
| `docs/IPHONE-LAUNCH-READINESS.md` | Check off FlutterFire items when complete |
| `test/data/firebase_options_test.dart` | Assert iOS options exist and reference project/bundle |
| `test/release/iphone_launch_readiness_test.dart` | Optional: assert docs mention configured project |

### 2.2 Data Flow

1. Operator ensures Firebase iOS app registered (`dev.atoosa.mitoosa`) in console.
2. `flutterfire configure --project=mitoosa-2121b --platforms=ios` writes `firebase_options.dart` + plist.
3. `flutter run -d iPhone --dart-define=FIREBASE_ENABLED=true` initializes Firebase + `FirebaseAnalyticsSink`.
4. Session telemetry fires → Firebase Analytics → DebugView (with debug mode / `-FIRDebugEnabled` as needed on device).

### 2.3 Threat Model (abbreviated — chore)

| Threat | Mitigation |
|--------|------------|
| Committing `GoogleService-Info.plist` / API keys | `.gitignore` entry; docs warn; commit only `firebase_options.dart` if team policy allows (client config is public-by-design in mobile apps) |
| Running analytics without user-visible privacy alignment | App Privacy questionnaire deferred to BL-24; docs cross-link |
| Placeholder left in production build with `FIREBASE_ENABLED=true` | Tests fail if placeholder message remains |

### 2.4 Build Scope

✅ Ready to proceed  
**In scope:** `lib/firebase_options.dart`, `firebase.json`, analytics/launch docs, firebase options tests, Master-Plan BL-22 task 6.2 closure  
**Out of scope:** `docs/PRODUCT-WEDGE.md`, S2-05 UI, backend features  

## 3. Tasks

### 3.1 Task Tree

- [x] **1.** FlutterFire configure (owner/agent with Firebase CLI auth)
  - [x] 1.1 Ensure iOS app exists in Firebase project `mitoosa-2121b` for `dev.atoosa.mitoosa` — _AC-001, AC-002_
  - [x] 1.2 Run `flutterfire configure --project=mitoosa-2121b --platforms=ios` — _AC-001, AC-002_
  - [x] 1.3 Confirm `GoogleService-Info.plist` on disk and gitignored — _AC-002, AC-004_
- [x] **2.** Tests and docs
  - [x] 2.1 Update `firebase_options_test.dart` for configured iOS options — _AC-001_
  - [x] 2.2 Update `docs/ANALYTICS-SETUP.md` with project ID and DebugView checklist — _AC-003, AC-005_
  - [x] 2.3 Update `docs/IPHONE-LAUNCH-READINESS.md` checkboxes — _AC-006_
- [x] **3.** Verification
  - [x] 3.1 `dart analyze` + `flutter test` — all green — _AC-001_
  - [ ] 3.2 Manual DebugView verification — _AC-005_ `[manual-deferred: 2026-06-19; ship policy 2026-06-20]`

### 3.2 Wave Plan

**Wave 1 (completed):** 1.1, 1.2, 1.3 — Firebase console/app registration and local FlutterFire generation are dependency-ordered.
**Wave 2 (parallel after Wave 1):** 2.1, 2.2, 2.3 — tests and docs can be updated independently after generated config exists.
**Wave 3 (sequential after Wave 2):** 3.1 — run `dart analyze` and `flutter test` after code/docs updates land.
**Wave 4 (manual-deferred after Wave 3):** 3.2 — DebugView verification requires a device/simulator run and Firebase console access.

### 3.3 Test Plan

See `docs/AgToosa_TestPlan-BL-23.md`.

## ✅ Spec Approved

Approved: 2026-06-11 (user: approve)
