# Test Plan — BL-24 Interactive How-To Demos

> **Spec:** [spec-BL-24.md](archived/spec-BL-24.md)
> **Coverage target:** 80% (per `docs/Context/workflow.md`)
> **Generated:** 2026-06-14

## Scope & Strategy

BL-24 verifies native Flutter tutorial/demo behavior before implementation starts. Automated tests cover tutorial content coverage, first-entry gating, persistence, help reopen, objective rendering, accessibility, and icon mapping. Manual iPhone smoke is proof for the launch-facing experience after implementation.

## AC Coverage Matrix

| AC ID | EARS summary | Priority | Test IDs | Category | Smoke |
|-------|--------------|----------|----------|----------|-------|
| AC-001 | Tutorial definitions cover all tracks and rules | Must | T-001 | Unit | T-001 `@smoke` |
| AC-002 | Unseen track shows tutorial before timed play | Must | T-002 | Widget / Integration | T-002 `@smoke` |
| AC-003 | Dismissal persists seen track and later skips | Must | T-003 | Widget / Integration | T-003 `@smoke` |
| AC-004 | Gameplay help reopens tutorial without mutation | Must | T-004 | Widget | — |
| AC-005 | Gameplay shows compact objective with live prompt | Must | T-005 | Widget | T-005 `@smoke` |
| AC-006 | Tutorial UI accessibility and reduced motion | Must | T-006 | Widget / Accessibility | T-006 `@smoke` |
| AC-007 | Track artwork maps known IDs to assets/fallbacks | Should | T-007 | Unit / Widget | — |

## Test Catalog

### T-001 — Tutorial definitions cover all tracks and rules `@smoke`
- **Category:** Unit
- **AC:** AC-001
- **Steps:** Load `assets/content/worlds.json`, `assets/content/tutorials.json`, and `PuzzleRule.values`.
- **Pass:** Every track ID has one tutorial definition; every definition rule matches the track rule; every active rule maps to a supported `TutorialDemoType`.
- **Negative:** A missing track, unknown rule, duplicate `trackId`, empty `steps`, or missing objective causes the test to fail.

### T-002 — Unseen track shows tutorial before timed play `@smoke`
- **Category:** Widget / Integration
- **AC:** AC-002
- **Steps:** Build the track entry flow with `seenTutorialWorlds=[]`; tap Continue or a playable level.
- **Pass:** `HowToPlayModal` and `TutorialDemoPanel` render before difficulty/gameplay timers start.
- **Negative:** If the difficulty sheet or timer renders first, the test fails.

### T-003 — Tutorial dismissal persists seen state `@smoke`
- **Category:** Widget / Integration
- **AC:** AC-003
- **Steps:** Complete/dismiss the tutorial for a track, reload progress, then re-enter the same track.
- **Pass:** Progress contains the track ID and re-entry skips the tutorial.
- **Negative:** Empty `seenTutorialWorlds` always shows the tutorial; duplicate dismissals do not duplicate IDs.

### T-004 — Gameplay help reopen has no gameplay mutation
- **Category:** Widget
- **AC:** AC-004
- **Steps:** Start gameplay for a seen track, snapshot seen state, score, hearts, timer, and level progress; tap `how_to_play_reopen`; close modal.
- **Pass:** Snapshot values remain unchanged.
- **Negative:** Help reopen must not call `markTutorialSeen`, deduct hearts, pause/resume timers incorrectly, or record level progress.

### T-005 — Objective strip renders live prompt `@smoke`
- **Category:** Widget
- **AC:** AC-005
- **Steps:** Build `GameplayScreen` for representative visual and text tracks.
- **Pass:** A compact objective and the live `level.puzzle.prompt` render without overlap.
- **Negative:** Missing tutorial objective falls back to safe copy and does not crash.

### T-006 — Tutorial UI is accessible and motion-safe `@smoke`
- **Category:** Widget / Accessibility
- **AC:** AC-006
- **Steps:** Render tutorial at 320pt width, high text scale, and reduced-motion media settings.
- **Pass:** No overflow; touch targets are at least 44pt; options and CTA expose semantic labels; reduced motion removes nonessential animation.
- **Negative:** Long math/cipher prompts remain scrollable and reachable.

### T-007 — Track artwork mapping avoids broken assets
- **Category:** Unit / Widget
- **AC:** AC-007
- **Steps:** Resolve icon path for every current track ID.
- **Pass:** Known IDs map to available category PNGs or an explicit safe fallback path; no known track accidentally requests `track_track_N.png` unless that file exists.
- **Negative:** Missing mapping for a current track fails the test.

## Regression

- `dart analyze` — clean
- `flutter test` — full suite green
- `dart pub run build_runner build --delete-conflicting-outputs` — run only if provider/generated files change

## Manual iPhone Smoke

| Test | Owner | Date | Result |
|------|-------|------|--------|
| Fresh install shows onboarding while `onboardingComplete == false` | | | ⬜ |
| First Pattern Match entry shows tutorial before play | | | ⬜ |
| Re-entering Pattern Match skips tutorial | | | ⬜ |
| Gameplay `?` reopens tutorial without score/heart change | | | ⬜ |

## RED / GREEN Evidence Log

_(Populated during `/agtoosa-build` per task.)_
