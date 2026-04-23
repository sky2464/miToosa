# Wedge QA Checklist — Manual Walkthrough

**Purpose:** Close the manual-check gaps for Tasks 3–6 in `docs/update.md`. Run this before Sprint 1 closes.  
**Environment:** Fresh web build at staging URL, or fresh iOS simulator install.  
**Tester:** Any team member who has not seen the onboarding before (or use a fresh simulator profile).  
**Time:** ~15 minutes end-to-end.

Record pass/fail for each item and drop the result into the Gate Log in `docs/RELEASE-GATES.md`.

---

## Setup

- [ ] Clear app data / use a fresh simulator profile (no existing `PlayerProgress` in Hive)
- [ ] Start a timer at first app launch
- [ ] Have the staging URL or `flutter run` ready

---

## Task 3 — First-Session Entry (target: <60 seconds to gameplay)

- [ ] App launches without error
- [ ] Onboarding screens are visible and copy matches the free-first promise ("25 free games daily")
- [ ] **Timer check:** player reaches a real game round in **under 60 seconds** from cold launch
  - Actual time: ______ seconds  `[ ] Pass (< 60s)` / `[ ] Fail (≥ 60s)`
- [ ] The free allowance counter is visible without hunting for it (no drilling into settings)
- [ ] Login / auth path does not block gameplay (anonymous play works)

---

## Task 4 — Free-Games Allowance

- [ ] Allowance count is displayed in the main UI (record where: ____________)
- [ ] Playing a game decrements the counter by 1
- [ ] Counter matches `PlayerProgress.dailyGamesRemaining` (or equivalent field)
- [ ] When allowance reaches 0, the player sees a clear message (not a crash or blank screen)
- [ ] **Daily reset test** (either advance device clock by 24h, or check code path):
  - [ ] After simulated reset, counter returns to 25
  - Method used: `[ ] Device clock advance` / `[ ] Code inspection`

---

## Task 5 — Share Bonus

- [ ] Share prompt is visible and reachable within the normal play flow (record location: ____________)
- [ ] Tapping share launches the native share sheet
- [ ] After a successful share, bonus games are granted (record amount: ____________)
- [ ] **Anti-abuse check:** tapping share a second time on the same day does NOT grant a second bonus
  - [ ] Pass (second share = no additional bonus) / `[ ] Fail`
- [ ] UI copy reflects the new share bonus framing (not "earn a heart")

---

## Task 6 — Streak Reward Ladder

- [ ] Current streak count is displayed on the main screen or progress screen
- [ ] Next milestone reward is visible (e.g., "Play 3 days in a row for 25 coins")
- [ ] **Day 1 → Day 2 test** (advance device clock):
  - [ ] Returning within 24–48 hours continues the streak (count increments)
  - [ ] Returning after 48+ hours without a freeze breaks the streak (count resets)
- [ ] Missing one day with a freeze applied does NOT break the streak
- [ ] Streak reward messaging appears at the 3-day milestone (simulate by advancing clock)

---

## Regression Check

- [ ] `flutter test` passes (zero failures)
- [ ] `dart analyze` reports zero issues
- [ ] No unrelated screens are broken (spot-check: leaderboard, settings, world map)

---

## Results Summary

| Task | Status | Notes |
|------|--------|-------|
| Task 3 — First-session entry | `[ ] Pass` / `[ ] Fail` | Time to gameplay: ___ s |
| Task 4 — Free-games allowance | `[ ] Pass` / `[ ] Fail` | |
| Task 5 — Share bonus | `[ ] Pass` / `[ ] Fail` | |
| Task 6 — Streak reward ladder | `[ ] Pass` / `[ ] Fail` | |
| Regression | `[ ] Pass` / `[ ] Fail` | |

**Overall:** `[ ] All pass — wedge QA complete` / `[ ] Failures found — see bug tickets`

**Tester:** ____________  
**Date:** ____________  
**Build / URL:** ____________

---

## If You Find a Failure

1. Open a bug ticket with: screen, steps to reproduce, expected vs. actual behavior.
2. Unmark the corresponding checkbox in `docs/update.md`.
3. Do not mark Sprint 1 as closed until all items above are green.
