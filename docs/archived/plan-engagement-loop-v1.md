# Implementation Plan: Engagement Loop v1

> Spec: [docs/spec-engagement-loop-v1.md](spec-engagement-loop-v1.md)

## Overview

12 ordered tasks across 4 phases. Each task is small (S or M), leaves the system in a passing state, and has explicit verification. All pure-Dart foundation work comes first so the engine is correct before any UI touches it.

---

## Dependency Graph

```
[Task 1] Stars 0-5 (ProgressionEngine + GameplayLevel)
    │
    ├──▶ [Task 2] PlayerProgress schema v2 (Hive adapter)
    │         │
    │         └──▶ [Task 6] PlayerProgressProvider mutations
    │
    ├──▶ [Task 3] GameplayState: hintUsed + run fields
    │         │
    │         └──▶ [Task 5] GameplayViewModel: useHint() + run logic
    │
    └──▶ [Task 4] ProgressionEngine: heart-refuel pure logic
              │
              └──▶ [Task 6] PlayerProgressProvider mutations
                        │
            ┌───────────┴────────────────┐
            ▼                            ▼
    [Task 7] HeartsBar widget   [Task 8] HintButton + GameplayScreen
                                         │
                              [Task 9] RunTimerOverlay + GameplayScreen
                                         │
                              [Task 10] HowToPlayModal + WorldMapScreen
                                         │
                              [Task 11] share_plus refuel (⚠ needs approval)
                                         │
                              [Task 12] _saveProgress() wiring + star display
```

---

## Phase 1 — Pure Dart Foundation (no UI, no Hive writes)

### Task 1: Stars 0–5 rework

**Description:** Update `ProgressionEngine.computeStars()` and `GameplayLevel.stars()` to return 0–5. Rethreshold mastery and adaptive multiplier. Add `adaptiveVersion == 1` migration multiplier (×5/3). Update all existing tests and add boundary tests for the new mapping.

**Acceptance criteria:**
- [ ] `computeStars(0)` → 5, `computeStars(1)` → 4, `computeStars(2)` → 3, `computeStars(3)` → 2, `computeStars(4)` → 2, `computeStars(5)` → 1, `computeStars(6)` → 1, `computeStars(7)` → 0
- [ ] `computeMasteryTier`: gold ≥ 4.0, silver ≥ 2.5, bronze < 2.5
- [ ] `computeAdaptiveMultiplier`: increase at avg ≥ 4.0, decrease at avg < 2.0
- [ ] Migration: loading `adaptiveVersion == 1` history [1,2,3] → scaled to [2,3,5] (rounded), `adaptiveVersion` set to 2
- [ ] All existing progression engine tests updated and passing

**Verification:**
- [ ] `flutter test test/core/engine/progression_engine_test.dart`

**Dependencies:** None

**Files:**
- `lib/core/engine/progression_engine.dart`
- `lib/core/models/gameplay_level.dart`
- `test/core/engine/progression_engine_test.dart`

**Scope:** S (3 files)

---

### Task 2: PlayerProgress schema v2 — hearts, diamonds, refuel, tutorial fields

**Description:** Add 4 new Hive fields to `PlayerProgress` and update `PlayerProgressAdapter`. Fields: `hearts` (int, field 12, default 5), `diamonds` (int, field 13, default 0), `heartRefuelAt` (DateTime?, field 14), `seenTutorialWorlds` (List\<String\>, field 15). Bump `writeByte` field count from 12 to 16. Add null-safe defaults in the `read()` path for backwards compatibility.

**Acceptance criteria:**
- [ ] New `PlayerProgress` objects default to `hearts = 5`, `diamonds = 0`, `heartRefuelAt = null`, `seenTutorialWorlds = []`
- [ ] Old saves missing fields 12–15 load correctly with defaults (no crash)
- [ ] `write()` serialises all 16 fields in correct order
- [ ] `adaptiveVersion == 1` histories are migrated to 0–5 scale in the `read()` path (per Task 1 logic)

**Verification:**
- [ ] `flutter test test/data/player_progress_test.dart`

**Dependencies:** Task 1 (migration logic)

**Files:**
- `lib/data/player_progress.dart`
- `test/data/player_progress_test.dart`

**Scope:** S (2 files)

---

## ✅ Checkpoint A — After Tasks 1–2

```
flutter test
flutter analyze
```

All pure-Dart logic correct. Zero UI changes. Safe to review and merge as a standalone commit before proceeding.

---

## Phase 2 — Engine & ViewModel Logic

### Task 3: GameplayState — add `hintUsed` and run fields

**Description:** Extend `GameplayState` with: `bool hintUsed` (default false), `bool isRunActive` (default false), `Duration runTimeRemaining` (default zero), `int levelsInRun` (default 0), `int levelsCompleted` (default 0). Update `copyWith`. No behaviour changes yet — strictly additive state.

**Acceptance criteria:**
- [ ] `GameplayState.hintUsed` defaults to false; once set via `copyWith`, persists in that state object
- [ ] Run fields serialise/copy correctly through `copyWith`
- [ ] Existing `GameplayState` construction is backward compatible (no required parameters added)

**Verification:**
- [ ] `flutter test`

**Dependencies:** None (independent of Task 1–2 except compile-time)

**Files:**
- `lib/core/engine/gameplay_engine.dart`
- `test/features/gameplay/gameplay_view_model_test.dart` (add state shape tests)

**Scope:** S (2 files)

---

### Task 4: ProgressionEngine — heart-refuel pure logic

**Description:** Add three static methods to `ProgressionEngine`: `shouldRefuelByTime(DateTime? refuelAt, DateTime now)` → bool, `computeNextRefuelTime(DateTime now)` → DateTime, `isLowerLevel(int completedIndex, int targetIndex)` → bool. These are stateless and testable without Flutter.

**Acceptance criteria:**
- [ ] `shouldRefuelByTime(30 minutes ago, now)` → true
- [ ] `shouldRefuelByTime(10 minutes ago, now)` → false
- [ ] `shouldRefuelByTime(null, now)` → false
- [ ] `computeNextRefuelTime(now)` returns `now + 30 minutes`
- [ ] `isLowerLevel(2, 5)` → true; `isLowerLevel(5, 2)` → false; `isLowerLevel(3, 3)` → false

**Verification:**
- [ ] `flutter test test/core/engine/progression_engine_test.dart`

**Dependencies:** None

**Files:**
- `lib/core/engine/progression_engine.dart`
- `test/core/engine/progression_engine_test.dart`

**Scope:** XS (2 files)

---

### Task 5: GameplayViewModel — `useHint()`, star cap, run state methods

**Description:** Add `useHint()` action: deducts 1 heart from `PlayerProgress` (via provider), sets `state.hintUsed = true`. Add `startRun(int totalLevels)`, `tickTimer(Duration elapsed)`, `completeLevel()` actions updating run fields. Stars are now computed as `level.stars(incorrectAttempts, hintUsed: state.hintUsed)` — the hint cap is applied at computation time.

**Acceptance criteria:**
- [ ] `useHint()` with `hearts > 0` → `hintUsed = true`, `hearts` decremented by 1
- [ ] `useHint()` with `hearts == 0` → state unchanged, returns false
- [ ] `computeStars` result is capped at 3 when `hintUsed == true`
- [ ] `startRun(10)` sets `isRunActive = true`, `levelsInRun = 10`, `runTimeRemaining = 10 min`
- [ ] `tickTimer` decrements `runTimeRemaining`; reaching zero sets `isRunActive = false`
- [ ] `completeLevel()` increments `levelsCompleted`; when `levelsCompleted == levelsInRun` and `isRunActive == true` → emits run bonus

**Verification:**
- [ ] `flutter test test/features/gameplay/gameplay_view_model_test.dart`

**Dependencies:** Tasks 2, 3

**Files:**
- `lib/features/gameplay/gameplay_view_model.dart`
- `test/features/gameplay/gameplay_view_model_test.dart`

**Scope:** M (2 files, significant logic additions)

---

### Task 6: PlayerProgressProvider — hearts/diamonds mutation methods

**Description:** Add methods to `HivePersistenceProvider` (and its interface): `deductHeart(String playerId)`, `refuelHeartsWithDiamond(String playerId)`, `addDiamond(String playerId, int count)`, `checkAndRefuelHeart(String playerId, DateTime now)` (time-based refuel), `refuelHeartLowerLevel(String playerId)`, `markTutorialSeen(String playerId, String worldId)`. All methods load, mutate, and save progress; respect max hearts = 5 and `diamonds >= 1` guard.

**Acceptance criteria:**
- [ ] `deductHeart` reduces hearts by 1; floors at 0
- [ ] `refuelHeartsWithDiamond` requires `diamonds >= 1`; sets hearts to 5, decrements diamonds by 1
- [ ] `checkAndRefuelHeart` adds 1 heart if `shouldRefuelByTime()` passes; updates `heartRefuelAt`; does nothing if hearts already at 5
- [ ] `markTutorialSeen` adds worldId to `seenTutorialWorlds` if not already present
- [ ] All methods honour max hearts = 5

**Verification:**
- [ ] `flutter test test/data/player_progress_test.dart`

**Dependencies:** Task 2

**Files:**
- `lib/data/hive_persistence_provider.dart`
- `lib/data/player_progress_provider.dart`
- `test/data/player_progress_test.dart`

**Scope:** M (3 files)

---

## ✅ Checkpoint B — After Tasks 3–6

```
flutter test
flutter analyze
```

All engine and ViewModel logic complete and tested. No UI changes yet. Safe standalone merge.

---

## Phase 3 — UI Widgets

### Task 7: `HeartsBar` and `DiamondBadge` display widgets

**Description:** Create `lib/widgets/hearts_bar.dart`. `HeartsBar` takes `int hearts` (0–5) and `int diamonds` — renders 5 heart icons (filled/empty) + a 💎 diamond count. Add a "Refuel with 💎" button that appears when `hearts < 5 && diamonds >= 1`. Wire into `WorldMapScreen` header row.

**Acceptance criteria:**
- [ ] 5 hearts renders 5 filled hearts
- [ ] 2 hearts renders 2 filled + 3 empty hearts
- [ ] Diamond badge shows correct count
- [ ] "Refuel with 💎" button visible only when `hearts < 5 && diamonds >= 1`
- [ ] Widget renders without overflow on 320px-wide screen

**Verification:**
- [ ] `flutter test` (widget test for HeartsBar)
- [ ] Manual: open WorldMapScreen, inspect hearts display

**Dependencies:** Tasks 2, 6

**Files:**
- `lib/widgets/hearts_bar.dart` (new)
- `lib/features/navigation/world_map_screen.dart`
- `test/widgets/hearts_bar_test.dart` (new)

**Scope:** M (3 files)

---

### Task 8: `HintButton` widget + GameplayScreen integration

**Description:** Create `lib/widgets/hint_button.dart`. A 💡 icon button — disabled if `hint == null`; shows "❤ -1" badge when `hearts > 0`; grayed out + tooltip "No hearts" when `hearts == 0`. On tap: call `useHint()` on ViewModel. Show hint text in a bottom sheet overlay. Add the button to `GameplayScreen`'s header row alongside the existing "?" button placeholder.

**Acceptance criteria:**
- [ ] Button disabled when `level.hint == null`
- [ ] Button shows red heart badge with count when `hearts > 0`
- [ ] Button tap with `hearts > 0` reveals hint in bottom sheet and deducts heart
- [ ] Button tap with `hearts == 0` shows SnackBar "Not enough hearts – use a 💎 or play a lower level"
- [ ] Hint badge is `hintUsed == true` once per level (button becomes "used" state, cannot tap twice)

**Verification:**
- [ ] `flutter test`
- [ ] Manual: tap hint with/without hearts

**Dependencies:** Tasks 5, 7

**Files:**
- `lib/widgets/hint_button.dart` (new)
- `lib/features/gameplay/gameplay_screen.dart`

**Scope:** M (2 files)

---

### Task 9: `RunTimerOverlay` widget + GameplayScreen countdown

**Description:** Create `lib/widgets/run_timer_overlay.dart`. A thin animated progress bar at the top of `GameplayScreen` showing time remaining as a fraction of total run time. Green → yellow → red as time decreases. In `GameplayScreen.initState`, if entering from a "run" (passed via constructor flag), call `startRun()` on the ViewModel and start a `Timer.periodic(1 second)` to `tickTimer`. On timer expire: show banner "Time's up!". On run complete: show Run Bonus overlay ("FULL RUN! 🔥 +1 💎"). Pause/resume via `AppLifecycleListener`.

**Acceptance criteria:**
- [ ] Progress bar visible and animated when `isRunActive == true`
- [ ] Bar colour shifts green → yellow → red as time decreases
- [ ] "Time's up!" banner appears when `runTimeRemaining` reaches zero
- [ ] Run Bonus overlay appears when `levelsCompleted == levelsInRun` with timer still active
- [ ] Timer pauses when app is backgrounded

**Verification:**
- [ ] `flutter test` (timer mock test)
- [ ] Manual: start a run, watch countdown

**Dependencies:** Tasks 5, 7

**Files:**
- `lib/widgets/run_timer_overlay.dart` (new)
- `lib/features/gameplay/gameplay_screen.dart`

**Scope:** M (2 files)

---

### Task 10: `HowToPlayModal` widget + WorldMapScreen first-entry trigger

**Description:** Create `lib/widgets/how_to_play_modal.dart`. A full-screen overlay showing world name, icon, rule description, and a "Let's Go! 🚀" CTA button. In `WorldMapScreen`, on level tap, check `seenTutorialWorlds` — if worldId absent, show modal first; on dismiss, `markTutorialSeen()`, then proceed to gameplay. Add "?" icon button in `GameplayScreen` header that re-shows the modal for the current world.

**Acceptance criteria:**
- [ ] Modal appears on first tap into a world; does not appear on subsequent taps into same world
- [ ] Dismissing modal stores worldId in `seenTutorialWorlds` and navigates to gameplay
- [ ] "?" button on GameplayScreen re-opens modal (no heart cost)
- [ ] Modal content shows world name, icon, subtitle/rule, and CTA

**Verification:**
- [ ] Manual: enter new world → modal shows; back + re-enter → modal skipped
- [ ] `flutter test` (widget test: modal renders; WorldMapScreen integration)

**Dependencies:** Tasks 6, 7

**Files:**
- `lib/widgets/how_to_play_modal.dart` (new)
- `lib/features/navigation/world_map_screen.dart`
- `lib/features/gameplay/gameplay_screen.dart`

**Scope:** M (3 files)

---

## ✅ Checkpoint C — After Tasks 7–10

```
flutter test
flutter analyze
flutter run -d chrome  # manual smoke test of full flow
```

All UI features visible. Complete the manual smoke test matrix:
- [ ] Open world → tutorial modal appears
- [ ] Tap hint → heart deducted, hint shown
- [ ] Run timer starts and counts down
- [ ] Hearts bar and diamond badge render correctly in WorldMapScreen

---

## Phase 4 — Integration & Polish

### Task 11: share_plus refuel path

> **⚠ Requires approval first:** this task adds `share_plus` as a new dependency.

**Description:** Add `share_plus` to `pubspec.yaml`. Add `shareAndRefuel(String playerId)` to `PlayerProgressProvider`. On share: invoke `Share.share(appStoreUrl)`, then grant +1 heart (capped at 5) and record `lastShareDate` (a new Date field — add to `PlayerProgress` as Hive field 16 if approved). Block duplicate grants within the same calendar day.

**Acceptance criteria:**
- [ ] `shareAndRefuel` calls native share sheet
- [ ] Heart +1 granted on share (if under daily limit)
- [ ] Second share same day grants no heart (idempotent)
- [ ] No crash on web (share_plus web fallback)

**Verification:**
- [ ] `flutter test`
- [ ] Manual: tap share on a device

**Dependencies:** Task 6 — **blocked on human approval of share_plus dependency**

**Files:**
- `pubspec.yaml`
- `lib/data/player_progress.dart` (add `lastShareDate` field 16)
- `lib/data/hive_persistence_provider.dart`
- `lib/widgets/hearts_bar.dart` (add share CTA button)

**Scope:** M (4 files)

---

### Task 12: `_saveProgress()` wiring + 5-star display rework

**Description:** Update `_saveProgress()` in `GameplayScreen` to: (a) pass `hintUsed` to star calculation, (b) award +1 diamond for Run Bonus (from ViewModel signal), (c) award +1 heart for completing a lower-indexed level. Update any star-display widgets to render 5 stars instead of 3. Update XP formula if needed (star scale change has no score impact per spec).

**Acceptance criteria:**
- [ ] Stars correctly reflect hint cap (max 3 when hint used)
- [ ] Run Bonus grants +1 diamond on full-run completion
- [ ] Completing level index N when player was blocked at index M > N grants +1 heart
- [ ] All star display widgets show up to 5 stars

**Verification:**
- [ ] `flutter test`
- [ ] Manual full-run from start to finish with/without hints

**Dependencies:** Tasks 5, 8, 9, 10

**Files:**
- `lib/features/gameplay/gameplay_screen.dart`
- `lib/data/hive_persistence_provider.dart`
- Any star-display widget files

**Scope:** S–M (3–4 files)

---

## ✅ Checkpoint D — Final Gate

```
flutter test --coverage
flutter analyze
flutter build apk --release  # or ios
```

- [ ] All 12 tasks complete
- [ ] Zero analyzer warnings
- [ ] All success criteria in spec checked off
- [ ] share_plus task (11) either complete or explicitly deferred to v2

---

## Task Execution Order

```
1 ──▶ 2 ──▶ [Checkpoint A]
      │
      ├──▶ 3
      └──▶ 4 ──▶ 6 ──▶ [Checkpoint B]
                  │
      5 ──────────┘
      │
      ├──▶ 7 ──▶ 8
      │    │ ──▶ 9
      │    └──▶ 10 ──▶ [Checkpoint C]
      │
      └──▶ 11 (pending approval)
           └──▶ 12 ──▶ [Checkpoint D]
```

**Parallelizable after Checkpoint A:** Tasks 3 and 4 can proceed in parallel (no shared files).
