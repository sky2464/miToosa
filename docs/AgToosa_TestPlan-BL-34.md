# Test Plan — BL-34 Production SFX and Persisted Preferences

> **Spec:** [spec-BL-34.md](archived/spec-BL-34.md)
> **Status:** Draft pending approval
> **Created:** 2026-07-14

## Scope & Strategy

Fakes around audio and haptics prove preference enforcement without a device. Static asset validation proves provenance and the removal of test tones/Music UI. iPhone smoke confirms platform output.

## AC Coverage Matrix

| AC ID | EARS summary | Priority | Test IDs | Category | Smoke |
|-------|--------------|----------|----------|----------|-------|
| AC-001 | Production SFX have provenance | Must | T-001 | Static/unit | T-001 @smoke |
| AC-002 | Sound-disabled blocks playback | Must | T-002 | Unit | T-002 @smoke |
| AC-003 | Haptics-disabled blocks feedback | Must | T-003 | Unit | T-003 @smoke |
| AC-004 | Choices persist across relaunch | Must | T-004 | Repository/widget | T-004 @smoke |
| AC-005 | No Music control/service remains | Must | T-005 | Widget/static | T-005 @smoke |
| AC-006 | Plugin failure is contained | Should | T-006 | Unit | — |

## Test Catalog

### T-001 — Shipped SFX provenance @smoke
- **AC:** AC-001
- **Steps:** Enumerate registered audio assets and their LICENSES.md entries.
- **Pass:** Every shipped SFX is production-ready, documented, and no generated test-tone file is registered.
- **Negative:** Missing source/license or an old test asset fails.

### T-002 — Sound preference guards audio @smoke
- **AC:** AC-002
- **Steps:** Request success/failure/hint feedback with fake player and sound true/false.
- **Pass:** Fake player receives calls only when Sound is enabled.
- **Negative:** Direct caller cannot bypass FeedbackService.

### T-003 — Haptic preference guards haptics @smoke
- **AC:** AC-003
- **Steps:** Request feedback with fake haptic adapter and haptics true/false.
- **Pass:** Haptic adapter is silent when disabled.
- **Negative:** Audio and haptic preferences remain independent.

### T-004 — Persisted preference lifecycle @smoke
- **AC:** AC-004
- **Steps:** Change values, recreate repository/providers, and render Settings.
- **Pass:** Stored values drive both UI and service after cold read.
- **Negative:** Write failure does not claim success.

### T-005 — Truthful Settings audio controls @smoke
- **AC:** AC-005
- **Steps:** Render Settings and run source inventory.
- **Pass:** Sound/Haptics controls exist and Music control/MusicService are absent.
- **Negative:** No background-music claim remains.

### T-006 — Adapter failure containment
- **AC:** AC-006
- **Steps:** Make fake audio/haptic adapter throw.
- **Pass:** Gameplay command succeeds; service reports only sanitized diagnostics.
- **Negative:** No unhandled exception reaches UI.

### T-007 — Physical iPhone feedback smoke
- **AC:** AC-002, AC-003, AC-004
- **Steps:** Toggle Sound/Haptics each way, complete representative puzzle events, force-quit, relaunch.
- **Pass:** Output follows preferences and remains persisted.
- **Negative:** Record platform-specific playback/haptic failure.

## Regression

    dart analyze lib test
    flutter test
    rg -n "MusicService|Music" lib/features/settings lib/core --glob '*.dart'

## RED / GREEN Evidence Log

Populated during /agtoosa-build.
