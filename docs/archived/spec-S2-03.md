# Spec: S2-03 — Aetheric Pulse Game Screen Chrome Refresh

> **Story ID:** S2-03
> **Epic:** EP-04 — User Experience Polish
> **Parent:** S2-01 (Aetheric Pulse UI Redesign — foundation shipped 2026-05-14)
> **Status:** 🟦 Todo
> **Estimate:** M (2–3 d)
> **Spec created:** 2026-05-14

---

## 1. Requirements

### 1.1 User Stories

**As a** player, **I want** the gameplay screen to match the rest of the redesigned app **so that** the brand feels consistent and the most-played surface looks premium.

### 1.2 Acceptance Criteria (EARS)

| ID | EARS | Priority |
|----|------|----------|
| AC-001 | WHEN the player enters a gameplay session THE SYSTEM SHALL display refreshed top chrome — circular back button, centered eyebrow (track name + level), and a 5-dot progress bar showing puzzle position within the session | Must |
| AC-002 | WHILE the puzzle countdown is **≤ 4 seconds** THE SYSTEM SHALL render the timer pill in pink tint (`#EC4899`) with a `pulse-glow` animation; otherwise blue tint (`#60A5FA`) | Must |
| AC-003 | WHEN the gameplay options grid renders THE SYSTEM SHALL show selected option with a cyan glow border and unselected options with the glass-card recipe | Must |
| AC-004 | WHEN the player taps the Hint or Submit CTA THE SYSTEM SHALL use the new `GhostButton` (Hint) and `PrimaryButton` (Submit) widgets from the S2-01 widget library | Must |
| AC-005 | WHEN the gameplay screen renders THE SYSTEM SHALL preserve all existing `GameplayEngine` state machine behavior — phase transitions, scoring, hints, lifecycle events, telemetry hooks | Must |

### 1.3 Out of Scope

- Changes to `GameplayEngine` or any engine-level logic (pure UI chrome refresh only)
- New gameplay mechanics or rules
- Sound/haptics rewiring (existing services continue to be called the same way)
- Game-over and session-complete overlays — these are separate from chrome and can stay as-is

---

## 2. Design

### 2.1 Architecture Blueprint

**Files to modify:**
- `lib/features/gameplay/gameplay_screen.dart` — refresh chrome only. Preserve all `GameplayViewModel` reads/writes.

**Files referenced (no changes):**
- `lib/widgets/primary_button.dart`, `lib/widgets/ghost_button.dart` — already built in S2-01
- `lib/widgets/atmosphere.dart` — for the cyan-accent background
- `lib/theme/design_tokens.dart` — `AP.cyan`, `AP.pink`, `AP.gradPrimary`, `AP.blueLight`
- `lib/widgets/countdown_timer_widget.dart`, `lib/widgets/run_timer_overlay.dart`, `lib/widgets/hint_button.dart` — keep as-is (or fold into new chrome if cleaner)

### 2.2 Data Flow

1. Player taps Play → `GameplayScreen` built with track + level + session metadata.
2. Top chrome reads from `widget.levelIndex`, `widget.sessionStartLevelIndex`, `widget.runTotalLevels`.
3. Timer pill watches `_remainingSeconds`; tint switches at 4-second threshold.
4. Options grid reads from `_currentPuzzle.options` and `_selectedOptionIndex`; selection updates view state only (no engine call until submit).
5. On Submit: existing `GameplayViewModel.submit(option)` path runs unchanged — feedback toast, scoring, transition to next puzzle.

### 2.3 Threat Model (STRIDE)

| Threat | Category | Mitigation |
|--------|----------|------------|
| Timer color flicker causes rebuild storm | DoS | Use `ValueNotifier<int>` for timer rather than `setState` per tick; rebuild only the pill, not the whole screen |
| Cyan-glow option border masks colorblind-unsafe selection state | Information Disclosure | Pair cyan border with a subtle scale-up (1.02×) so selection is conveyed in 2 channels |
| Engine regression — chrome refactor breaks puzzle scoring | Tampering | Comprehensive widget test that walks select → submit → next puzzle, with a real `GameplayEngine` |

### 2.4 Build Scope

```
✅ Ready to proceed — Scope Boundary
Files in scope      : lib/features/gameplay/gameplay_screen.dart
Directories in scope: lib/features/gameplay/
Out of scope        : lib/core/engine/ (engine logic untouched),
                      lib/widgets/feedback_toast.dart,
                      game_over_overlay.dart, session_complete_overlay.dart
```

---

## 3. Tasks

### 3.1 Task Tree

- [ ] **1.** Top chrome
  - [ ] 1.1 Replace existing top bar with circular back button + centered eyebrow + 5-dot progress bar — _Requirements: AC-001_
  - [ ] 1.2 Replace timer widget call site with new timer pill (blue ≤4s → pink + pulse) — _Requirements: AC-002_
- [ ] **2.** Options grid
  - [ ] 2.1 Wrap option cards in glass-card recipe; cyan glow border + 1.02× scale on selected — _Requirements: AC-003_
- [ ] **3.** Bottom CTAs
  - [ ] 3.1 Replace existing hint button with `GhostButton` — _Requirements: AC-004_
  - [ ] 3.2 Replace existing submit button with `PrimaryButton` (full-width, glow on enabled) — _Requirements: AC-004_
- [ ] **4.** Preservation tests
  - [ ] 4.1 Widget test: full puzzle flow (select → submit → next) using real engine, no chrome regressions — _Requirements: AC-005_
  - [ ] 4.2 Widget test: timer pill color switches at 4s threshold — _Requirements: AC-002_
  - [ ] 4.3 Widget test: option selection shows cyan border + scale — _Requirements: AC-003_
  - [ ] 4.4 `dart analyze` clean, `flutter test` 100% — _Requirements: AC-005_

### 3.2 Wave Plan

**Wave 1 (parallel):** 1.1, 1.2, 2.1, 3.1, 3.2 (independent chrome swaps)
**Wave 2 (parallel):** 4.1, 4.2, 4.3
**Wave 3 (sequential):** 4.4

### 3.3 Test Plan

Coverage target: 80%. Existing engine tests must keep passing; add 3 new widget tests for chrome behavior.

---

## ✅ Spec Approved

Approved: 2026-05-14 12:00
