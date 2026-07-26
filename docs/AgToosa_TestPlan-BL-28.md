# Test Plan — BL-28 First-Run Onboarding Gate

> **Spec:** [spec-BL-28.md](archived/spec-BL-28.md)
> **Status:** Draft pending approval
> **Created:** 2026-07-14

## Scope & Strategy

Test declarative root routing with controlled auth and progress providers. The automated suite covers all state combinations; physical iPhone proof covers actual fresh-install startup timing.

## AC Coverage Matrix

| AC ID | EARS summary | Priority | Test IDs | Category | Smoke |
|-------|--------------|----------|----------|----------|-------|
| AC-001 | Fresh anonymous player sees onboarding | Must | T-001 | Widget | T-001 @smoke |
| AC-002 | Completed player sees shell | Must | T-002 | Widget | T-002 @smoke |
| AC-003 | Completion switches root without relaunch | Must | T-003 | Widget | T-003 @smoke |
| AC-004 | Loading has no shell flash | Must | T-004 | Widget | — |
| AC-005 | Error is recoverable | Must | T-005 | Widget | T-005 @smoke |
| AC-006 | Fresh iPhone reaches first track promptly | Should | T-006 | Manual device | — |

## Test Catalog

### T-001 — Fresh player root gate @smoke
- **AC:** AC-001
- **Steps:** Override auth with a nonempty ID and progress with onboardingComplete false.
- **Pass:** Onboarding renders and MainAppShell does not.
- **Negative:** A nonempty ID alone must not unlock the shell.

### T-002 — Completed player resumes shell @smoke
- **AC:** AC-002
- **Steps:** Override auth with a nonempty ID and progress with onboardingComplete true.
- **Pass:** MainAppShell renders and onboarding does not.
- **Negative:** Returning player is not re-gated.

### T-003 — Completion refreshes root @smoke
- **AC:** AC-003
- **Steps:** Start with false progress, perform completion mutation, and emit refreshed true progress.
- **Pass:** The root changes to MainAppShell without restart or duplicate navigation.
- **Negative:** Stale provider state does not leave onboarding visible.

### T-004 — Loading is stable
- **AC:** AC-004
- **Steps:** Hold auth and then progress in loading state.
- **Pass:** A deterministic loading surface renders with no MainAppShell frame.
- **Negative:** No LoginScreen fallback or destination flash.

### T-005 — Error can recover @smoke
- **AC:** AC-005
- **Steps:** Emit auth/progress error, tap retry, then emit valid fresh progress.
- **Pass:** Generic recovery UI retries and leads to onboarding.
- **Negative:** Raw exception/storage detail is not rendered.

### T-006 — Fresh-install iPhone timing
- **AC:** AC-006
- **Steps:** Install a fresh TestFlight/debug build, cold launch, complete onboarding, and enter first track.
- **Pass:** First playable track is reachable within 60 seconds under normal local conditions.
- **Negative:** Record any blocking blank/flash/routing failure.

## Regression

    dart analyze lib test
    flutter test

## RED / GREEN Evidence Log

Populated during /agtoosa-build.
