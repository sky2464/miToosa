# Spec: Engagement Loop v1 — Hearts, Hints, Countdown & Star Rework

**Status:** Draft — Awaiting human review before implementation

---

## Objective

Deepen the dopamine loop and long-session engagement in miToosa through five interrelated features:

1. **How-to-Play Tutorial** — First entry into each world shows a dismissible onboarding modal.
2. **Hint System** — Players can reveal a hint during a puzzle at the cost of 1 heart.
3. **Hearts / Lives System** — 5-heart pool gates continued play; three refuel paths keep sessions accessible.
4. **Diamond Currency** — A second, harder-to-earn currency that provides an instant heart refuel.
5. **Run Countdown Timer** — An urgent per-session timer rewards players who complete a world's level set without leaving.
6. **Stars 0 – 5 Rework** — Expand the star scale from 0–3 to 0–5 for finer granularity and more reward moments.

**Primary user:** A player who opens the app for a focused cognitive session and wants to feel rewarded for sustained focus.

**Success looks like:**
- A player starting a new world sees the tutorial exactly once.
- A player who runs out of hearts can refuel without leaving the app (free paths) or pay with a diamond.
- Hints are always available but feel meaningful because they cost a resource.
- Finishing all levels in one run with the timer active grants a bonus reward.
- All existing star-based persistence (leaderboards, mastery tier, adaptive history) works correctly with the new 0–5 scale.

---

## Tech Stack

| Layer | Technology |
|---|---|
| Framework | Flutter 3.x / Dart ≥ 3.5 |
| State management | Riverpod 3 (riverpod_annotation, code-gen) |
| Local persistence | Hive 2 (typed adapters) |
| Routing | go_router 17 |
| Audio | audioplayers |
| Sharing | to be added: `share_plus` |
| Testing | flutter_test, mocktail |

---

## Commands

```
Fetch deps:       flutter pub get
Code gen:         dart run build_runner build --delete-conflicting-outputs
Test:             flutter test
Test (coverage):  flutter test --coverage
Lint:             flutter analyze
Dev (iOS sim):    flutter run -d iPhone
Dev (web):        flutter run -d chrome
```

---

## Project Structure (relevant paths)

```
lib/
  core/
    engine/
      gameplay_engine.dart       # GameplayState, GameplayPhase (add countdown phase)
      progression_engine.dart    # computeStars() → 0-5 (REWORK HERE)
    models/
      gameplay_level.dart        # stars() → 0-5 (REWORK HERE)
  data/
    player_progress.dart         # Add: hearts, diamonds, heartRefuelAt,
                                 #       seenTutorialWorlds, adaptiveHistory 1-5
    hive_persistence_provider.dart
  features/
    gameplay/
      gameplay_screen.dart       # Add: hint button, heart display, run timer
      gameplay_view_model.dart   # Add: useHint(), countdown, runMode state
    navigation/
      world_map_screen.dart      # Show how-to-play modal on first entry
  widgets/ (NEW)
    how_to_play_modal.dart
    hearts_bar.dart
    run_timer_overlay.dart
    hint_button.dart
test/
  core/
    engine/
      progression_engine_test.dart   # Extend for 0-5 stars
  data/
    player_progress_test.dart        # Add hearts/diamond/tutorial tests
  features/
    gameplay/
      gameplay_view_model_test.dart  # Add hint, hearts, countdown tests
```

---

## Code Style

Existing style — follow exactly:

```dart
// Pure Dart engine logic: static, no Flutter/Hive deps, fully testable
static int computeStars(int incorrectAttempts) {
  if (incorrectAttempts == 0) return 5;
  if (incorrectAttempts == 1) return 4;
  if (incorrectAttempts == 2) return 3;
  if (incorrectAttempts <= 4) return 2;
  if (incorrectAttempts <= 6) return 1;
  return 0;
}

// Riverpod state: sealed phases, copyWith pattern
state = state.copyWith(phase: const PhaseHintRevealed());

// Hive fields: document field index and schema version comment
// Hive field 12 — schema version 2
int hearts;
```

**Naming conventions:**
- Classes: PascalCase (`HeartsRefuelReason`)
- Files: snake_case (`hearts_bar.dart`)
- Hive fields: annotate with `@HiveField(n)` and document schema version

---

## Feature Specifications

### 1. How-to-Play Tutorial

**Trigger:** Player navigates to a world for the first time (never seen in `seenTutorialWorlds`).

**Behaviour:**
- A full-screen overlay modal appears before the first level loads.
- Content: world name, icon, the rule description, a short example (static image or animated widget), and a "Let's go!" CTA.
- On dismiss: mark the world ID in `PlayerProgress.seenTutorialWorlds`.
- A "?" button on the gameplay screen re-opens the tutorial at any time (no heart cost).

**Data changes to `PlayerProgress`:**
```dart
List<String> seenTutorialWorlds; // Hive field 12, schema v2
```

---

### 2. Hint System

**Trigger:** Player taps the hint button (💡) during an active puzzle.

**Behaviour:**
- If `hearts > 0`: deduct 1 heart, reveal `GameplayLevel.hint` text in an overlay. 
- If `hearts == 0`: show "Not enough hearts" snackbar; do not reveal hint.
- If `hint == null`: button is disabled.
- Hint revealed state is local to the current puzzle — does not persist.
- Revealing a hint affects star rating: max stars capped at 3 (out of 5) for that level.

**Star cap when hint used:**
```
hintUsed = false → stars 0–5 (normal)
hintUsed = true  → stars capped at 3
```

---

### 3. Hearts / Lives System

**Pool:** 5 hearts maximum. Starting value for new players: 5.

**Depletion:**
| Event | Hearts change |
|---|---|
| Hint revealed | −1 |
| (Future) time-pressure failure | −1 (reserved) |

**Refuel paths (all free):**

| Method | Hearts gained | Notes |
|---|---|---|
| Time-based | +1 per 30 min | Up to max 5; `heartRefuelAt` timestamp drives this |
| Complete a lower-indexed level | +1 | Level index < current level index in same world |
| Share the app | +1 | One grant per share event (uses share_plus, no-op if already shared today) |

**Diamond refuel (premium):**
- Spending 1 diamond fully refills hearts to 5 instantly.

**`PlayerProgress` data additions:**
```dart
int hearts;          // Hive field 13, schema v2; default 5, max 5
int diamonds;        // Hive field 14, schema v2; default 0
DateTime? heartRefuelAt; // Hive field 15, schema v2; time hearts will reach max naturally
```

**Heart display:** A `HeartsBar` widget shown at the top of `GameplayScreen` and `WorldMapScreen`.

---

### 4. Diamond Currency

**Earning diamonds (out of scope for this spec — reserved for v2):**
- Placeholder: completing a world's full set without losing any hearts.
- Placeholder: achievement unlock rewards.

**Spending diamonds:**
- 1 diamond → full heart refuel (hearts = 5).
- Trigger: player taps "Refuel with Diamond" when hearts < 5 and `diamonds >= 1`.

**Display:** Diamond count shown next to hearts bar using a 💎 icon.

---

### 5. Run Countdown Timer

**What is a "run"?** A session where the player starts a world's first-level (or continues from mid-world) and attempts to complete all remaining levels without navigating away.

**Timer behaviour:**
- Duration: 10 minutes per 10-level world (1 min per level, configurable).
- Starts when a run begins (player taps "Play World" on world map).
- Pauses when app is backgrounded; resumes on foreground.
- Visible as a countdown bar/circle overlay on `GameplayScreen`.
- If timer expires mid-run: run ends, player gets normal stars/XP (no penalty), banner shows "Time's up — try a full run next time!".
- If all levels completed before timer expires: **Run Bonus** granted.

**Run Bonus:**
- +1 diamond.
- Dopamine overlay: "FULL RUN! 🔥 +1 💎 IQ Boost!" animation.

**State (in ViewModel):**
```dart
bool isRunActive;
Duration runTimeRemaining;
int levelsInRun;     // total levels in this world
int levelsCompleted; // how many completed this run
```

---

### 6. Stars 0 – 5 Rework

**Current:** `computeStars()` returns 1–3; stored in `levelStars` and `adaptiveHistory`.

**New:** Returns 0–5.

**New mapping:**
| Incorrect attempts | Stars |
|---|---|
| 0 | 5 |
| 1 | 4 |
| 2 | 3 |
| 3–4 | 2 |
| 5–6 | 1 |
| 7+ | 0 |

**Hint modifier:** Cap at 3 if hint was used during the level.

**`ProgressionEngine` thresholds to update:**

| Threshold | Old (1–3 scale) | New (0–5 scale) |
|---|---|---|
| Mastery: gold | avg ≥ 2.5 | avg ≥ 4.0 |
| Mastery: silver | avg ≥ 1.8 | avg ≥ 2.5 |
| Adaptive: increase difficulty | avg ≥ 2.5 | avg ≥ 4.0 |
| Adaptive: decrease difficulty | avg < 1.5 | avg < 2.0 |

**`adaptiveHistory` migration:** Existing 1–3 values will be multiplied ×(5/3) on read if `adaptiveVersion == 1`. Version bumped to 2 after migration.

**`score()` in `GameplayLevel`:** No change — score is independent of stars.

---

## Testing Strategy

**Framework:** `flutter_test` + widget tests for UI; pure Dart unit tests for engine logic.

**Test locations:**
```
test/core/engine/progression_engine_test.dart  — stars rework + thresholds
test/data/player_progress_test.dart            — hearts/diamonds/tutorial/migration
test/features/gameplay/gameplay_view_model_test.dart — hint, hearts deduction, countdown
```

**Coverage expectations:**
- All engine functions: 100% unit test coverage
- All state transitions (hint, hearts, timer): covered by ViewModel tests
- Migration path (adaptiveVersion 1 → 2): at least one explicit test

**Test levels (for each feature):**
- Stars 0–5: boundary values at 0, 1, 2, 3–4, 5–6, 7+ incorrect attempts
- Hearts: deduct on hint, block hint at 0 hearts, time-based refuel, share refuel, lower-level refuel, diamond refuel
- Tutorial: first world entry shows modal, second entry skips, re-open via "?" works
- Countdown: timer start/pause/resume/expire, run bonus triggers at timer completion

---

## Boundaries

- **Always do:** Run `flutter test` after every change; update Hive adapter field indices when adding fields; update `schemaVersion` comments
- **Ask first:** Adding `share_plus` dependency; any change to Hive box name or encryption key; changing world/level JSON schema; adding a network dependency
- **Never do:** Silently drop `adaptiveHistory` during migration; remove the `integrityHash` check; skip the Hive adapter update when adding `PlayerProgress` fields

---

## Success Criteria

- [ ] A new player opening "Pattern Match" for the first time sees the how-to-play modal; subsequent entries skip it.
- [ ] Tapping the hint button during a puzzle deducts 1 heart and reveals the hint text.
- [ ] With 0 hearts, the hint button shows an error state and does not reveal the hint.
- [ ] Hearts naturally refuel at +1 per 30 minutes (verified via timer mock in tests).
- [ ] Completing a level with a lower index than the blocked level grants +1 heart.
- [ ] Tapping "Share" grants +1 heart (max once per day).
- [ ] Spending 1 diamond refuels hearts to 5.
- [ ] Starting a full world run starts the countdown timer; completing all levels before expiry triggers the Run Bonus (+1 diamond + overlay).
- [ ] `computeStars(0)` returns 5; `computeStars(7)` returns 0.
- [ ] Existing saves with `adaptiveVersion == 1` (stars 1–3) are migrated correctly to the 0–5 scale on load.
- [ ] All tests pass: `flutter test`
- [ ] No analysis errors: `flutter analyze`

---

## Open Questions

1. **Run timer duration:** 1.5 minute (90 seconds) per level (15 min for a 10-level world) — is this the right pressure? Should it scale with world difficulty?
    Sounds good! Yes. 
2. **Heart display:** Should 0 hearts block level access entirely (hard gate) or just block hints and show a warning?
    Since it's fun should be easier and achivable but chalnagging. Medidum is okay, not very hard. 
3. **Diamond earning:** Full earning mechanic is out of scope here — confirm that the only way to earn diamonds in v1 is the Run Bonus. sounds good! Research needed for game strategy on bonus. 
4. **Share refuel:** Should this use a native OS share sheet (share_plus) or be a social deep link? And is "once per day" the right limit?
 Combination of all. Research and pick best of the best. 
5. **Star migration:** Multiply old 1–3 values by 5/3 (rounding). Confirm this is acceptable vs. resetting all historical stars.
Sounds good! 
