# Test Plan — BL-37 Privacy-Respecting Crash Resilience

> **Spec:** [spec-BL-37.md](archived/spec-BL-37.md)
> **Status:** Draft pending approval
> **Created:** 2026-07-14

## Scope & Strategy

Use fake reporters to verify handler and privacy behavior without sending real errors. Native/device proof is restricted to a controlled nonfatal record attempt, never a production-visible crash button.

## AC Coverage Matrix

| AC ID | EARS summary | Priority | Test IDs | Category | Smoke |
|-------|--------------|----------|----------|----------|-------|
| AC-001 | Enabled bootstrap configures reporter | Must | T-001 | Unit/bootstrap | T-001 @smoke |
| AC-002 | Fatal handlers report safely | Must | T-002 | Unit | T-002 @smoke |
| AC-003 | Nonfatal reporting is sanitized | Must | T-003 | Unit | T-003 @smoke |
| AC-004 | Opt-out prevents reporting | Must | T-004 | Unit/integration | T-004 @smoke |
| AC-005 | Config and disclosures align | Must | T-005 | Static/native | — |
| AC-006 | Controlled nonfatal smoke works | Must | T-006 | Unit/manual device | T-006 @smoke |

## Test Catalog

### T-001 — Diagnostics-enabled bootstrap @smoke
- **AC:** AC-001
- **Steps:** Bootstrap with Firebase enabled and diagnostics preference true using fake reporter/factory.
- **Pass:** Firebase reporter is initialized once and collection is enabled after preference resolution.
- **Negative:** Firebase-disabled build selects no-op reporter.

### T-002 — Framework and async handler contract @smoke
- **AC:** AC-002
- **Steps:** Invoke captured FlutterError and PlatformDispatcher error handlers with synthetic error/stack.
- **Pass:** Fatal reporter calls occur once and platform handler returns expected handled value.
- **Negative:** Reporter failure does not recurse or throw into handler.

### T-003 — Nonfatal sanitization @smoke
- **AC:** AC-003
- **Steps:** Report a sanctioned nonfatal with messages containing UUID-like/progress-like fragments and excess keys.
- **Pass:** Reporter receives bounded category/context with sensitive fragments removed.
- **Negative:** Arbitrary map/object dumps are rejected.

### T-004 — Opt-out disables diagnostics @smoke
- **AC:** AC-004
- **Steps:** Bootstrap/change privacy preference to disabled and try fatal/nonfatal calls.
- **Pass:** Collection is disabled and fake transport sends no report.
- **Negative:** Direct Firebase calls outside reporter boundary fail static audit.

### T-005 — Platform and disclosure alignment
- **AC:** AC-005
- **Steps:** Verify pubspec, FlutterFire configuration, Settings text, policy, and App Store docs.
- **Pass:** Crashlytics is configured and described as anonymous optional diagnostics.
- **Negative:** User IDs/ads/remote logging claims are absent.

### T-006 — Controlled nonfatal smoke @smoke
- **AC:** AC-006
- **Steps:** Run injected fake smoke in automated test, then invoke debug-only bounded nonfatal path in a Firebase-enabled device build.
- **Pass:** Test sees one sanitized report attempt; manual console record has matching static category.
- **Negative:** No production Settings crash/test control exists.

### T-007 — Crashlytics configuration build
- **AC:** AC-001, AC-005
- **Steps:** Run dependency resolution and iOS config build after FlutterFire configuration.
- **Pass:** Native plugins resolve and build config completes.
- **Negative:** Missing plugin/config build error fails.

## Regression

    dart analyze lib test
    flutter test
    flutter build ios --config-only --no-codesign

## Manual Firebase Evidence

| Test | Owner | Date | Result |
|------|-------|------|--------|
| Firebase Console shows controlled nonfatal category with diagnostics enabled | | | ⬜ |
| Diagnostics-disabled device produces no new controlled report | | | ⬜ |

## RED / GREEN Evidence Log

Populated during /agtoosa-build.
