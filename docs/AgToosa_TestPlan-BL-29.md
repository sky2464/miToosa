# Test Plan — BL-29 Free-Games Wedge Delivery

> **Spec:** [spec-BL-29.md](archived/spec-BL-29.md)
> **Status:** Approved — shipped 2026-07-26 (repo); T-007 manual-deferred
> **Created:** 2026-07-14

## Scope & Strategy

Verify the local allowance model through pure persistence/controller tests and player-facing surfaces through widgets. Native sharing is injected behind an adapter so success, cancel, and repeated callbacks are deterministic in tests.

## AC Coverage Matrix

| AC ID | EARS summary | Priority | Test IDs | Category | Smoke |
|-------|--------------|----------|----------|----------|-------|
| AC-001 | Top-level copy says free games | Must | T-001 | Widget/source audit | T-001 @smoke |
| AC-002 | Confirmed start consumes one game | Must | T-002 | Controller/persistence | T-002 @smoke |
| AC-003 | Cancel does not consume game | Must | T-003 | Controller/widget | — |
| AC-004 | Exhaustion blocks and offers share | Must | T-004 | Widget | T-004 @smoke |
| AC-005 | First successful share grants +40 | Must | T-005 | Controller/persistence | T-005 @smoke |
| AC-006 | Same-day repeat gets no bonus | Must | T-006 | Controller/persistence | T-006 @smoke |
| AC-007 | Hearts/diamonds stay in-round | Should | T-007 | Widget/source audit | — |

## Test Catalog

### T-001 — Canonical top-level economy copy @smoke
- **AC:** AC-001, AC-007
- **Steps:** Render header, world map, depleted sheet, and Settings; run targeted string audit.
- **Pass:** Free games is the only top-level allowance; CR, credits, energy, bonus sessions, and shop copy are absent.
- **Negative:** Hearts/diamonds may appear only within gameplay/recovery context.

### T-002 — Start consumes exactly once @smoke
- **AC:** AC-002
- **Steps:** Trigger final Start Game with 25 remaining games and a fake persistence store.
- **Pass:** One game is consumed before gameplay is opened.
- **Negative:** Double taps do not consume two games.

### T-003 — Cancel preserves allowance
- **AC:** AC-003
- **Steps:** Open game-entry confirmation and cancel/back out.
- **Pass:** The persisted count is unchanged.
- **Negative:** Card selection, difficulty selection, and modal open do not consume.

### T-004 — Depleted state is free-first @smoke
- **AC:** AC-004
- **Steps:** Render entry with zero total games.
- **Pass:** Gameplay does not start; an accessible Share for +40 games CTA appears with no VIP/ad/paywall copy.
- **Negative:** Alternate entry points cannot bypass the block.

### T-005 — First share grants +40 once @smoke
- **AC:** AC-005
- **Steps:** Fake a successful native share on a day with no bonus claimed.
- **Pass:** Exactly 40 games are added and persisted.
- **Negative:** Failed/cancelled share adds none.

### T-006 — Same-day share anti-abuse @smoke
- **AC:** AC-006
- **Steps:** Repeat successful share on the same date, then advance to next date.
- **Pass:** Same-day reward is denied with clear copy; next-day reward can be granted once.
- **Negative:** Repeated platform callback does not duplicate.

### T-007 — Physical native-share smoke
- **AC:** AC-005, AC-006
- **Steps:** On iPhone, exhaust allowance in a test fixture, run first native share, relaunch, and retry share.
- **Pass:** First share adds +40; second share does not.
- **Negative:** Record unavailable sheet or incorrect persistence.

## Regression

    dart analyze lib test
    flutter test
    rg -n -i "bonus sessions|energy|credits|\bCR\b|unlock the full game" lib/features lib/widgets --glob '*.dart'

## RED / GREEN Evidence Log

| Test ID | Phase | Result | Evidence |
|---------|-------|--------|----------|
| T-001 | GREEN | PASS | `test/features/progression/free_games_copy_test.dart` — header/world-map/depleted sheet copy |
| T-002 | GREEN | PASS | `test/features/progression/free_games_controller_test.dart` — single consume |
| T-003 | GREEN | PASS | Consume gated on difficulty tier confirm in `track_detail_screen.dart` (modal open does not consume) |
| T-004 | GREEN | PASS | `free_games_copy_test.dart` — depleted sheet share CTA |
| T-005 | GREEN | PASS | `free_games_controller_test.dart` — grant +40 on success |
| T-006 | GREEN | PASS | `free_games_controller_test.dart` — same-day block + next-day grant |
| T-007 | DEFERRED | manual | Physical iPhone share smoke (task 4.3) |

**Verification (2026-07-26):** `dart analyze lib test` — 0 errors (6 info). `flutter test` — 910/910 PASS. Copy audit `rg` — no obsolete economy strings in `lib/features` / `lib/widgets` (comment-only hits excluded).
