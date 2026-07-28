# Test Plan — BL-31 Truthful Launch Surfaces

> **Spec:** [spec-BL-31.md](archived/spec-BL-31.md)
> **Status:** Approved — GREEN evidence logged (2026-07-26 build)
> **Created:** 2026-07-14

## Scope & Strategy

Exercise release navigation and Settings as the player sees them. Reset uses a fake persistence layer for deterministic confirmation, failure, and relaunch behavior.

## AC Coverage Matrix

| AC ID | EARS summary | Priority | Test IDs | Category | Smoke |
|-------|--------------|----------|----------|----------|-------|
| AC-001 | Release shell has only supported destinations | Must | T-001 | Widget | T-001 @smoke |
| AC-002 | Settings has no inert/stale controls | Must | T-002 | Widget/source audit | T-002 @smoke |
| AC-003 | Reset asks confirmation | Must | T-003 | Widget | T-003 @smoke |
| AC-004 | Confirmed reset creates fresh progress | Must | T-004 | Persistence/controller | T-004 @smoke |
| AC-005 | Cancel/failure preserves data | Must | T-005 | Widget/persistence | — |
| AC-006 | No reachable preview surface remains | Must | T-006 | Widget/static | T-006 @smoke |

## Test Catalog

### T-001 — Supported release tab list @smoke
- **AC:** AC-001
- **Steps:** Build MainAppShell and inspect all tabs/destinations.
- **Pass:** No leaderboard or unsupported route is visible/reachable.
- **Negative:** Tab switching cannot reach a demo screen.

### T-002 — Truthful Settings catalog @smoke
- **AC:** AC-002
- **Steps:** Build Settings at narrow and normal iPhone widths; inspect row actions/text.
- **Pass:** Only implemented actions remain; no stale version, profile, VIP, share, or reminder controls appear.
- **Negative:** A control without a behavior is a failing test.

### T-003 — Reset confirmation @smoke
- **AC:** AC-003
- **Steps:** Tap Reset Progress from populated state.
- **Pass:** Destructive confirmation appears and Cancel is non-destructive.
- **Negative:** Tapping outside/dismissing dialog preserves data.

### T-004 — Confirmed reset refreshes state @smoke
- **AC:** AC-004
- **Steps:** Confirm reset using a populated fake store and observe provider/UI after reload.
- **Pass:** Fresh PlayerProgress uses the original player ID; old stats/tutorials/allowance state are removed.
- **Negative:** Identity/key material is not reset by this operation.

### T-005 — Reset persistence failure
- **AC:** AC-005
- **Steps:** Make the fake store fail reset.
- **Pass:** Existing state remains and a recoverable generic message appears.
- **Negative:** Partial progress is not shown as a successful reset.

### T-006 — Preview and POC reachability audit @smoke
- **AC:** AC-006
- **Steps:** Run route/widget tests and targeted source scan for preview claims.
- **Pass:** Release surfaces have no reachable backend leaderboard, local multiplayer, or preview wording.
- **Negative:** Deferred source code alone is allowed only when not in release navigation.

## Regression

    dart analyze lib test
    flutter test
    rg -n -i "preview live|coming soon|local play|leaderboard" lib/features lib/widgets --glob '*.dart'

## Manual iPhone Smoke

| Test | Owner | Date | Result |
|------|-------|------|--------|
| Verify release tabs and Settings do not show deferred features | | | ⬜ |
| Confirm Reset Progress, relaunch, and inspect fresh state | | | ⬜ |

## RED / GREEN Evidence Log

| Test ID | Phase | Result | Evidence |
|---------|-------|--------|----------|
| T-001 | GREEN | PASS | `test/features/settings/truthful_launch_surfaces_test.dart` — 4-tab shell, no Leaders |
| T-002 | GREEN | PASS | `test/features/settings/truthful_launch_surfaces_test.dart` — no VIP/share/reminder/profile |
| T-003 | GREEN | PASS | `test/features/settings/reset_progress_controller_test.dart` — cancel + dismiss |
| T-004 | GREEN | PASS | `test/features/settings/reset_progress_controller_test.dart` — confirm resets stats, keeps ID |
| T-005 | GREEN | PASS | `test/features/settings/reset_progress_controller_test.dart` — failure preserves data |
| T-006 | GREEN | PASS | `truthful_launch_surfaces_test.dart` — no local play; source scan clean |

`dart analyze lib test` — 0 issues · `flutter test` — **929/929** PASS (2026-07-26)
