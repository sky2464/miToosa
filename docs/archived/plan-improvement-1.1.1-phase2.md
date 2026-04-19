# Plan: improvement-1.1.1 — Phase 2

> Remaining work from spec `improvement-1.1.1`.  
> Phase 1 landed the engine/model/token layer. Phase 2 wires the remaining UI, data persistence, and session flow.

---

## Overview

Phase 1 (completed) delivered:
- Dependency housekeeping (v1.4.0+1, SDK >=3.11.0)
- Design system tokens (colors, fonts, shadows, animations)
- XP engine (stars-based `computeXP`, hint penalty)
- Audio 404 fix (extension list trimmed)
- Content expansion (50-level tracks, gentler difficulty ramp, `puzzlesPerSession` constant)
- Timer mechanics (DifficultyTier enum, CountdownTimerWidget, GameplayState fields, view model methods, gameplay screen integration)

Phase 2 covers the **user-facing features** that depend on that foundation:
1. PlayerProgress schema v6 (new XP + time fields, Hive migration)
2. Difficulty selection UI (bottom sheet on level tap)
3. 60-puzzle session flow (session manager in view model)
4. Soft game over + session complete screens
5. Live header XP display
6. Track detail screen polish (XP badges, difficulty indicators, lock state)
7. Between-puzzle grace period (timer pause during transitions)

---

## Architecture Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Schema migration | Defaults in Hive adapter (v6) | Same pattern as v1-v5; no data loss |
| Difficulty selection | Modal bottom sheet | Lightweight, no extra route; consistent with level-tap UX |
| Session manager | State in GameplayViewModel | Already owns puzzle lifecycle; minimal new surface |
| Game over screen | Overlay in GameplayScreen | Avoids navigation churn; overlay dismisses to track detail |
| Best time storage | `Map<String, int>` (seconds) | Int is Hive-friendly; milliseconds excessive for ≤30 min sessions |
| Level XP storage | `Map<String, int>` | Parallel to existing `levelStars` pattern |

---

## Phased Task List

### Phase 2A — Data Layer (no UI changes)

#### Task 1: PlayerProgress schema v6
- **Description**: Add `dailyXP`, `dailyXPDate`, `levelXP`, `levelBestTime`, `levelBestDifficulty` fields to `PlayerProgress`. Update Hive adapter with safe defaults.
- **Acceptance criteria**:
  - New fields present with correct types and defaults
  - Adapter reads old data (schema ≤5) without error; new fields get defaults
  - `recordLevelXP(levelId, xp)` updates `levelXP` map (best-of)
  - `recordLevelTime(levelId, seconds)` updates `levelBestTime` (best-of)
  - `recordLevelDifficulty(levelId, tier)` updates `levelBestDifficulty`
  - `dailyXP` resets when `dailyXPDate` differs from today
- **Verification**: `flutter test test/data/`
- **Dependencies**: None
- **Files**:
  - `lib/data/player_progress.dart` (model + helpers)
  - `lib/data/player_progress_adapter.dart` (Hive read/write, field indices 27-31)
  - `test/data/player_progress_test.dart` (new tests)
- **Size**: M (3 files, schema migration pattern well-established)

---

### Phase 2B — Session Flow (core gameplay changes)

#### Task 2: Difficulty selection bottom sheet
- **Description**: When user taps a playable level in `TrackDetailScreen`, show a bottom sheet with Easy/Medium/Hard/Challenge options. Pass selected `DifficultyTier` to `GameplayScreen`.
- **Acceptance criteria**:
  - Bottom sheet appears on level tap (only for unlocked levels)
  - Each tier shows name, timer duration, and icon
  - Selection navigates to `GameplayScreen` with `difficultyTier` parameter
  - `GameplayScreen` constructor accepts optional `DifficultyTier`
  - View model calls `setDifficultyTier()` on init
- **Verification**: Manual test + widget test for bottom sheet
- **Dependencies**: None (DifficultyTier enum already exists)
- **Files**:
  - `lib/features/navigation/track_detail_screen.dart` (bottom sheet + navigation)
  - `lib/features/gameplay/gameplay_screen.dart` (constructor param)
  - `test/features/navigation/track_detail_screen_test.dart` (new)
- **Size**: S (1 new widget, 1 param addition)

#### Task 3: 60-puzzle session flow
- **Description**: Wire `puzzlesPerSession = 60` into the gameplay loop. `GameplayViewModel` tracks puzzle index (1-60), generates next puzzle on correct answer, and completes session after 60 puzzles.
- **Acceptance criteria**:
  - Session starts at puzzle 1/60
  - Header shows "Puzzle X / 60"
  - Correct answer advances to next puzzle (puzzle timer resets)
  - After puzzle 60 completed → session complete
  - Wrong answer: lose heart, timer continues, may retry same puzzle
  - 0 hearts → game over (partial progress)
- **Verification**: Unit tests for session state machine; `flutter test`
- **Dependencies**: Task 2 (difficulty selection)
- **Files**:
  - `lib/features/gameplay/gameplay_view_model.dart` (session loop, puzzle counter)
  - `lib/features/gameplay/gameplay_screen.dart` (puzzle counter in header)
  - `lib/core/content_provider.dart` (puzzlesPerSession already defined)
  - `test/features/gameplay/gameplay_view_model_test.dart` (session flow tests)
- **Size**: M (state machine changes, 4 files)

#### Task 4: Between-puzzle grace period
- **Description**: Pause the puzzle timer during answer feedback animation and next-puzzle transition. ~1 second grace before next timer starts.
- **Acceptance criteria**:
  - On correct/wrong answer → `pausePuzzleTimer()` called immediately
  - After feedback animation (~800ms) → `resetPuzzleTimer()` + `resumePuzzleTimer()` for next puzzle
  - Grace period prevents timer from ticking during visual transitions
- **Verification**: Unit test: timer does not tick during paused state
- **Dependencies**: Task 3 (session flow)
- **Files**:
  - `lib/features/gameplay/gameplay_screen.dart` (pause/resume calls in answer handler)
- **Size**: XS (timing coordination only)

---

### ✅ Checkpoint A — Session mechanics verified
**Gate**: All session flow tests pass. Play a full 60-puzzle session on simulator with Easy difficulty. Timer pauses between puzzles. Hearts deplete on wrong answers.

---

### Phase 2C — Completion Screens

#### Task 5: Soft game over overlay
- **Description**: When hearts reach 0 or session timer expires, show an overlay with partial XP earned, puzzles completed count, and "Retry" / "Back to Track" buttons.
- **Acceptance criteria**:
  - Overlay appears on 0 hearts or session timeout
  - Shows: puzzles completed / 60, XP earned, stars equivalent
  - "Retry" restarts same level+difficulty
  - "Back to Track" navigates to TrackDetailScreen
  - Partial XP saved to progress
- **Verification**: Widget test for overlay; manual test game over flow
- **Dependencies**: Task 3 (session flow), Task 1 (XP persistence)
- **Files**:
  - `lib/features/gameplay/gameplay_screen.dart` (overlay widget + trigger)
  - `lib/features/gameplay/gameplay_view_model.dart` (game over state)
- **Size**: S (overlay widget, 2 files)

#### Task 6: Session complete screen
- **Description**: After 60 puzzles completed, show completion overlay with: level XP earned, stars, completion time, track total XP, daily XP total. Save results to progress.
- **Acceptance criteria**:
  - Overlay shows on session complete
  - Displays: stars (staggered animation), XP earned, completion time, daily total
  - "Next Level" advances to next unlocked level (or back to track if last)
  - "Back to Track" returns to TrackDetailScreen
  - Saves: `levelXP`, `levelBestTime`, `levelBestDifficulty`, `dailyXP`, `totalXP`
- **Verification**: Widget test; integration test for save flow
- **Dependencies**: Task 1 (schema v6), Task 3 (session flow)
- **Files**:
  - `lib/features/gameplay/gameplay_screen.dart` (completion overlay)
  - `lib/data/player_progress.dart` (save helpers)
  - `lib/data/hive_persistence_provider.dart` (persist call)
- **Size**: M (overlay + persistence wiring, staggered animation)

---

### ✅ Checkpoint B — End-to-end session lifecycle verified
**Gate**: Full cycle works: select difficulty → play 60 puzzles → see completion screen → XP saved to progress. Game over flow also verified.

---

### Phase 2D — XP Display & Polish

#### Task 7: Live header XP display
- **Description**: Show current level XP in the header during gameplay. Starts at potential max (10) and decreases on each mistake in real time.
- **Acceptance criteria**:
  - Header shows "XP: 10" at session start
  - Each wrong answer decreases displayed XP per `computeXP` formula
  - Hint usage decreases XP by 1
  - Never shows below 1
  - Animates change (subtle color flash on decrease)
- **Verification**: Widget test; visual verification
- **Dependencies**: Task 3 (session flow active)
- **Files**:
  - `lib/features/gameplay/gameplay_screen.dart` (header XP widget)
  - `lib/features/gameplay/gameplay_view_model.dart` (expose live XP)
- **Size**: S (display logic, 2 files)

#### Task 8: Track detail screen polish
- **Description**: Enhance 50-level grid with star indicators, XP badges, difficulty tier completed, lock state, and best time display. Apply design system shadows and animations.
- **Acceptance criteria**:
  - Completed levels show: star count, best XP, best difficulty icon
  - Current level has pulse animation (using `springBouncy`)
  - Locked levels show lock icon, dimmed
  - Best time shown for completed levels (if available)
  - Grid uses `shadowCard` preset
  - Responsive: 5 columns on phone, 7 on tablet
- **Verification**: Widget test; visual screenshot comparison
- **Dependencies**: Task 1 (schema v6 for XP/time/difficulty data), Task 6 (data populated)
- **Files**:
  - `lib/features/navigation/track_detail_screen.dart` (grid rebuild)
  - `lib/theme/design_system.dart` (possibly new level-tile constants)
- **Size**: M (visual overhaul of existing grid)

#### Task 9: Progression gate
- **Description**: Lock next level until current level achieves minimum XP. Gate: need ≥ 6 XP (3+ stars) on current level to unlock next.
- **Acceptance criteria**:
  - Level N+1 locked until `levelXP[trackId_N] >= 6`
  - Lock state visible in grid (Task 8)
  - First level of each track always unlocked
  - Player can replay completed levels to improve score
- **Verification**: Unit test for unlock logic; integration with grid
- **Dependencies**: Task 1 (levelXP field), Task 8 (lock display)
- **Files**:
  - `lib/features/navigation/track_detail_screen.dart` (unlock check)
  - `lib/core/engine/progression_engine.dart` (gate threshold constant)
- **Size**: S (conditional check, 2 files)

---

### ✅ Checkpoint C — Feature complete
**Gate**: All remaining spec items verified. `flutter test` all pass. `dart analyze` clean. Manual walkthrough of full flow: world map → track → difficulty select → play 60 → complete → XP saved → next level unlocked.

---

## Risks

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| Hive schema v6 migration breaks existing saves | Low | High | Defaults in adapter; test with v5 fixture data |
| 60-puzzle sessions feel too long | Medium | Medium | Make count configurable per difficulty tier if needed |
| Timer grace period feels janky | Medium | Low | Tune animation duration; user-test on real device |
| Level grid with 50 items scrolls poorly | Low | Medium | `SliverGrid` already used; verify with profiling |
| `computeXP` live display flickers | Low | Low | Debounce visual updates |

---

## Open Questions

1. **Should Easy/Challenge have different puzzle counts?** (Spec says 60 for all — confirm or adjust)
2. **XP gate threshold: 6 or 7?** (Spec says "7+ XP" in one place, "minimum cumulative" in another — propose 6 = 3 stars as baseline)
3. **Should completed levels show best difficulty tier as text or icon?** (Propose: colored dot — green/yellow/orange/red)
4. **RunTimerOverlay upgrade** — deprioritized from this plan; existing overlay functional. Revisit in v1.2.0?

---

## Execution Order

```
Task 1 (schema v6)           ──────┐
Task 2 (difficulty selection) ──┐  │
                                ▼  │
Task 3 (60-puzzle session)  ◄──┘  │
Task 4 (grace period)       ◄──┘  │
                                   │
         ── Checkpoint A ──        │
                                   │
Task 5 (game over)          ◄─────┤
Task 6 (session complete)   ◄─────┘
                                
         ── Checkpoint B ──

Task 7 (live header XP)
Task 8 (track detail polish)
Task 9 (progression gate)

         ── Checkpoint C ──
```

**Parallelizable**: Tasks 1 and 2 can proceed in parallel (no shared files).  
**Sequential after**: Tasks 3-4 depend on Task 2; Tasks 5-6 depend on Tasks 1+3; Tasks 7-9 depend on Tasks 1+6.
