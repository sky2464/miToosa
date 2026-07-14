# Test Plan — BL-25 Physical iPhone TestFlight QA Pass

> **Spec:** [docs/archived/spec-BL-25.md](archived/spec-BL-25.md)  
> **Coverage target:** 80% (per `docs/Context/workflow.md`)  
> **Generated:** 2026-07-12  
> **Mode:** `/agtoosa-spec` full flow

## Scope & Strategy

BL-25 is primarily a **manual physical-device QA** story. Automated tests guard checklist/template documentation in `test/release/iphone_launch_readiness_test.dart`. Manual tests execute on a TestFlight build installed on a physical iPhone. DebugView verification (BL-23 T-005) is folded into AC-010.

**Prerequisites:** TestFlight build uploaded (BL-22 manual 6.4); `ios/Runner/GoogleService-Info.plist` present locally; Google Analytics linked to Firebase project `mitoosa-2121b`.

## AC Coverage Matrix

| AC ID | EARS summary | Priority | Test IDs | Category | Smoke |
|-------|--------------|----------|----------|----------|-------|
| AC-001 | TestFlight QA checklist enumerates all scenarios | Must | T-001 | Docs | T-001 `@smoke` |
| AC-002 | Evidence template with build/device/tester fields | Must | T-002 | Docs | T-002 `@smoke` |
| AC-003 | Cold launch on physical iPhone without crash | Must | T-003 | Manual / E2E | T-003 `@smoke` |
| AC-004 | Onboarding → playable round ≤60s | Must | T-004 | Manual / E2E | T-004 `@smoke` |
| AC-005 | Full 3-round session completes | Must | T-005 | Manual / E2E | — |
| AC-006 | Share +40 once; no second bonus same day | Must | T-006 | Manual / E2E | — |
| AC-007 | Offline gameplay with local Hive | Must | T-007 | Manual / E2E | — |
| AC-008 | VoiceOver smoke on primary flows | Must | T-008 | Manual / A11y | T-008 `@smoke` |
| AC-009 | Wedge copy: 25 free games, +40 share | Must | T-009 | Manual / Product | T-009 `@smoke` |
| AC-010 | DebugView event within 60s | Must | T-010 | Manual / Analytics | T-010 `@smoke` |
| AC-011 | Persistence after force quit | Must | T-011 | Manual / E2E | — |
| AC-012 | Release test asserts checklist + template | Must | T-001, T-002, T-012 | Unit / Docs | T-012 `@smoke` |
| AC-013 | Dynamic Type largest — no critical clip | Should | T-013 | Manual / A11y | — |
| AC-014 | Settings links — no dead placeholders | Should | T-014 | Manual / E2E | — |
| AC-015 | Time-to-first-game captured | Could | T-004, T-015 | Manual | — |

## Test Catalog

### T-001 — TestFlight QA checklist exists with required scenarios `@smoke`
- **Category:** Docs
- **AC:** AC-001, AC-012
- **Steps:** Assert `docs/qa/iphone-testflight-qa-checklist.md` contains headings/scenarios for cold launch, onboarding, gameplay, settings, share, offline, VoiceOver, Dynamic Type, wedge copy, persistence.
- **Pass:** File exists; all scenario keywords present.
- **Negative:** Missing offline or VoiceOver section → fail.

### T-002 — Evidence template has required fields `@smoke`
- **Category:** Docs
- **AC:** AC-002, AC-012
- **Steps:** Assert `docs/qa/iphone-testflight-evidence-template.md` includes build number, device model, iOS version, tester, date, per-AC pass/fail.
- **Pass:** Template complete.
- **Negative:** Missing build number field → fail.

### T-003 — TestFlight cold launch `@smoke`
- **Category:** Manual / E2E
- **AC:** AC-003
- **Preconditions:** TestFlight build installed; fresh or known state.
- **Steps:** Kill app → launch from home screen → observe splash → app shell.
- **Pass:** No crash; reaches navigable UI within 30s.
- **Negative:** Crash on launch or infinite splash → P0 defect.

### T-004 — Time-to-first-game ≤60s `@smoke`
- **Category:** Manual / E2E
- **AC:** AC-004, AC-015
- **Preconditions:** Fresh install or cleared data.
- **Steps:** Start timer at cold launch → complete onboarding → start first real round.
- **Pass:** ≤60 seconds; record actual time in evidence.
- **Negative:** Auth wall or >60s → fail AC-004.

### T-005 — Full gameplay session
- **Category:** Manual / E2E
- **AC:** AC-005
- **Steps:** Play complete 3-round session on one track.
- **Pass:** Session completes; returns to map or summary without crash.
- **Negative:** Soft-lock mid-round → P0 defect.

### T-006 — Share bonus anti-abuse
- **Category:** Manual / E2E
- **AC:** AC-006
- **Steps:** Note allowance → share once → verify +40 → attempt second share same day.
- **Pass:** First share grants bonus; second does not.
- **Negative:** Double bonus same day → P1 economy defect.

### T-007 — Offline gameplay
- **Category:** Manual / E2E
- **AC:** AC-007
- **Steps:** Enable airplane mode → launch → play one round → relaunch offline.
- **Pass:** Gameplay works; no sign-in block.
- **Negative:** Network error blocks play → fail.

### T-008 — VoiceOver smoke `@smoke`
- **Category:** Manual / A11y
- **AC:** AC-008
- **Steps:** Enable VoiceOver → navigate onboarding CTA → enter track → one gameplay control.
- **Pass:** Non-empty labels on each step.
- **Negative:** Unlabeled icon-only control on critical path → P1 a11y defect.

### T-009 — Wedge economy copy `@smoke`
- **Category:** Manual / Product
- **AC:** AC-009
- **Steps:** Read onboarding + main UI allowance/share strings against `docs/PRODUCT-WEDGE.md`.
- **Pass:** "25" daily free games visible; share described as +40 games; no paywall-before-value.
- **Negative:** "Energy" as top-level unit without free-games framing → fail (known risk: `world_map_screen.dart` Semantics).

### T-010 — Firebase DebugView spot-check `@smoke`
- **Category:** Manual / Analytics
- **AC:** AC-010
- **Preconditions:** `FIREBASE_ENABLED=true` build; GA linked; debug mode on device per `docs/ANALYTICS-SETUP.md`.
- **Steps:** Launch → start session → open Firebase Console → Analytics → DebugView.
- **Pass:** ≥1 event within 60s (`mitoosa_debug_ping`, session, or screen event).
- **Negative:** No events after 60s → fail; closes BL-23 T-005 on pass.

### T-011 — Force-quit persistence
- **Category:** Manual / E2E
- **AC:** AC-011
- **Steps:** Play → note allowance/streak/level → force quit → relaunch.
- **Pass:** State restored.
- **Negative:** Reset to fresh player → P0 data defect.

### T-012 — Release readiness test guards QA artifacts `@smoke`
- **Category:** Unit / Docs
- **AC:** AC-012
- **Steps:** `flutter test test/release/iphone_launch_readiness_test.dart`
- **Pass:** Tests for checklist + template pass.
- **Negative:** Test failure → block merge.

### T-013 — Dynamic Type largest
- **Category:** Manual / A11y
- **AC:** AC-013
- **Steps:** Settings → Accessibility → Largest Text → view onboarding + gameplay instructions.
- **Pass:** No clipped critical text.
- **Negative:** Overflow hiding instructions → P2 defect.

### T-014 — Settings link scan
- **Category:** Manual / E2E
- **AC:** AC-014
- **Steps:** Open settings/support/privacy entry points in TestFlight build.
- **Pass:** No tappable dead `manual-deferred` URLs.
- **Negative:** Crash or blank web view on support link → P1.

### T-015 — Time-to-first-game metric (optional)
- **Category:** Manual
- **AC:** AC-015
- **Steps:** Record seconds from T-004 in evidence template.
- **Pass:** Numeric value captured.

## Regression

```bash
dart analyze lib test
flutter test
flutter test test/release/
```

## Smoke set

`T-001`, `T-002`, `T-003`, `T-004`, `T-008`, `T-009`, `T-010`, `T-012`

## TDD Evidence

```
RED evidence — 1.1, 1.2, 1.3, 2.1
Command: flutter test test/release/iphone_launch_readiness_test.dart --name "TestFlight QA artifacts"
Exit code: 1
Failure excerpt: Expected: true; Actual: <false> (TestFlight QA checklist did not exist)

GREEN evidence — 1.1, 1.2, 1.3, 2.1
Command: flutter test test/release/iphone_launch_readiness_test.dart
Exit code: 0

GREEN evidence — 2.2
Command: dart analyze lib test && flutter test --reporter compact
Exit code: 0 (893 tests passed)

GREEN evidence — iphone-launch-gate
Command: flutter test test/release/
Exit code: 0 (18 tests passed)
```

Manual evidence blocks (T-003–T-011, T-013–T-014) are captured in `docs/qa/iphone-testflight-evidence-[YYYY-MM-DD].md` during `/agtoosa-build` Wave 4.
