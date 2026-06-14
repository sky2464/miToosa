# Test Plan — BL-22 iPhone Launch Readiness Prep

> **Spec:** [docs/archived/spec-BL-22.md](archived/spec-BL-22.md)  
> **Coverage target:** 80% (per `docs/Context/workflow.md` → `coverage_threshold`)  
> **Generated:** 2026-06-03  

## Scope & Strategy

BL-22 is a docs/config readiness story. Automated tests assert repo state, launch docs, and stale-ID guardrails. Manual checks cover external systems that require owner credentials or physical devices.

## AC Coverage Matrix

| AC ID | EARS summary | Priority | Test IDs | Category | Negative / edge | Smoke |
|-------|--------------|----------|----------|----------|-----------------|-------|
| AC-001 | iOS project uses `dev.atoosa.mitoosa` | Must | T-001 | Unit / Config | T-002 stale IDs | T-001 `@smoke` |
| AC-002 | Launch docs state iPhone/iOS only | Must | T-003 | Unit / Docs | T-002 stale multi-platform launch IDs | T-003 `@smoke` |
| AC-003 | Firebase + Google Analytics launch path documented | Must | T-004, T-009 | Unit / Manual | T-010 missing generated config | T-004 `@smoke` |
| AC-004 | App Store metadata/privacy/compliance guidance exists | Must | T-005, T-011 | Unit / Manual | T-011 privacy mismatch | T-005 `@smoke` |
| AC-005 | Company-readiness checklist exists | Must | T-006 | Unit / Docs | — | T-006 `@smoke` |
| AC-006 | Manual external gates documented | Must | T-003, T-007, T-011 | Unit / Manual | T-011 physical QA not complete | T-007 `@smoke` |
| AC-007 | Stale active bundle IDs rejected | Must | T-002 | Unit / Docs | inherent negative path | T-002 `@smoke` |
| AC-008 | Firebase placeholder fails closed with iOS guidance | Should | T-008 | Unit | enabled before config | — |

## Test Catalog

### T-001 — iOS Runner bundle ID is locked `@smoke`
- **Category:** Unit / Config
- **AC:** AC-001
- **Steps:** Run `flutter test test/release/signing_config_test.dart`.
- **Pass:** Test finds `dev.atoosa.mitoosa` for Runner and `dev.atoosa.mitoosa.RunnerTests` for RunnerTests.

### T-002 — Active launch docs reject stale iOS bundle IDs `@smoke`
- **Category:** Unit / Docs
- **AC:** AC-007
- **Steps:** Run `flutter test test/release/iphone_launch_readiness_test.dart`.
- **Pass:** Active launch docs do not contain active instructions for `com.mitoosa.app` or `com.chicademy.mitoosa`.

### T-003 — iPhone launch checklist exists `@smoke`
- **Category:** Unit / Docs
- **AC:** AC-002, AC-006
- **Steps:** Read `docs/IPHONE-LAUNCH-READINESS.md`.
- **Pass:** Checklist states iPhone/iOS only and includes TestFlight install on a real iPhone.

### T-004 — Firebase + Google Analytics release decision documented `@smoke`
- **Category:** Unit / Docs
- **AC:** AC-003
- **Steps:** Read `docs/ANALYTICS-SETUP.md` and `docs/IPHONE-LAUNCH-READINESS.md`.
- **Pass:** Docs mention Firebase + Google Analytics, `FIREBASE_ENABLED=true`, and `flutterfire configure --platforms=ios`.

### T-005 — App Store metadata fields are present `@smoke`
- **Category:** Unit / Docs
- **AC:** AC-004
- **Steps:** Run `flutter test test/release/iphone_launch_readiness_test.dart`.
- **Pass:** Metadata draft includes name, subtitle, category, keywords, privacy URL, support URL, age rating, export compliance, and screenshot plan.

### T-006 — Company readiness checklist is present `@smoke`
- **Category:** Unit / Docs
- **AC:** AC-005
- **Steps:** Run `flutter test test/release/iphone_launch_readiness_test.dart`.
- **Pass:** Checklist includes legal entity, DBA, registered agent, principal address, EIN, bank account, and IP/assets.

### T-007 — Manual external gates are documented `@smoke`
- **Category:** Unit / Docs
- **AC:** AC-006
- **Steps:** Read `docs/IPHONE-LAUNCH-READINESS.md`.
- **Pass:** Apple App ID, Firebase iOS app, public URLs, Xcode Archive/TestFlight, and real iPhone QA are listed.

### T-008 — Firebase placeholder fails closed
- **Category:** Unit
- **AC:** AC-008
- **Steps:** Run `flutter test test/data/firebase_options_test.dart`.
- **Pass:** Placeholder throws `UnsupportedError` with FlutterFire configuration guidance.

### T-009 — Firebase DebugView manual check
- **Category:** Manual / External
- **AC:** AC-003
- **Preconditions:** Firebase project/iOS app exists and generated options are installed.
- **Steps:** Run `flutter run --dart-define=FIREBASE_ENABLED=true`, trigger a session, and open Firebase Analytics DebugView.
- **Pass:** At least one launch/session event appears in DebugView.

### T-010 — Xcode Archive and TestFlight manual check
- **Category:** Manual / E2E
- **AC:** AC-006
- **Preconditions:** Apple App ID, Distribution certificate, and signing are configured.
- **Steps:** Archive in Xcode, validate, upload to TestFlight, install on a real iPhone.
- **Pass:** Build installs and cold launches from TestFlight.

### T-011 — App Privacy and physical QA manual check
- **Category:** Manual / QA
- **AC:** AC-004, AC-006
- **Steps:** Complete App Privacy answers, then run the physical iPhone QA checklist.
- **Pass:** Privacy answers match Firebase/GA release behavior; no broken links, placeholders, overflow, or accessibility blockers are found.

## Smoke Set

- T-001
- T-002
- T-003
- T-004
- T-005
- T-006
- T-007

