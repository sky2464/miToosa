# Spec: S1-03 — Manual Wedge QA Walkthrough

**Story ID:** S1-03
**Epic:** EP-01 — Launch Readiness & Validation
**Status:** Draft
**Date:** 2026-05-04
**Author:** AgToosa

---

## Context

`docs/qa/wedge-qa-checklist.md` is complete and covers all four wedge behaviors implemented in
Sprint 0:

- **Task 3** — First-session entry: player reaches gameplay in < 60 seconds from cold launch
- **Task 4** — Free-games allowance: 25 games/day, decrements on play, resets daily
- **Task 5** — Share bonus: +40 games per share, once per day (anti-abuse)
- **Task 6** — Streak reward ladder: gap detection (continued/frozen/broken), 8 milestone thresholds

This is a **process story** — no code changes expected unless failures are found. Run against
`flutter run -d chrome` (local web) while staging URL from S1-01 is pending. If failures are found,
they become new tasks in Master-Plan.md and S1-03 remains open.

---

## Scope

1. Execute the full `docs/qa/wedge-qa-checklist.md` on a fresh browser profile (no existing Hive data)
2. Record all pass/fail results with actual times, amounts, and copy text observed
3. Update `docs/RELEASE-GATES.md` Sprint 1 Gate Log row with outcome, tester name, date, and build
4. File bug tickets in `docs/Master-Plan.md` Blocked section for any failures
5. Mark S1-03 complete only when all checklist items pass (or failures are tracked)

---

## Setup Requirements

- Fresh Chrome profile (or incognito window) — ensures no existing `PlayerProgress` in Hive
- `flutter run -d chrome` running against current `main` branch
- Device clock manipulation capability (Chrome DevTools → Sensors → Override time, or OS clock)
- Timer ready (stopwatch for Task 3)

---

## Acceptance Criteria

| ID | Scenario | Given | When | Then | Priority |
|----|----------|-------|------|------|----------|
| AC-001 | Time-to-gameplay < 60s | Fresh browser profile, app just launched | Timer starts at first paint | Player reaches an interactive game round in < 60 seconds | Must |
| AC-002 | Allowance visible on main screen | Fresh PlayerProgress | App opened | Free games counter visible without navigating to settings | Must |
| AC-003 | Allowance decrements on play | 25 games remaining | One game round completed | Counter shows 24 | Must |
| AC-004 | Depleted state handled gracefully | 0 games remaining | Player starts a new game | Clear UI message shown; no crash or blank screen | Must |
| AC-005 | Share bonus grants +40 | Share prompt visible and accessible | Player taps share + completes | Bonus games counter increases by exactly 40 | Must |
| AC-006 | Share anti-abuse (once per day) | First share already used today | Player taps share again | No additional bonus granted; UI reflects this | Must |
| AC-007 | Share copy updated | Share prompt visible | Tester reads button/prompt copy | Copy refers to bonus games, not "earn a heart" | Should |
| AC-008 | Streak continues next day | Day 1 streak, clock advanced ~20–23h | Player opens app | Streak count increments to 2 | Must |
| AC-009 | Streak breaks after 48h+ (no freeze) | Day 1 streak, clock advanced 50h | Player opens app | Streak resets to 1 | Must |
| AC-010 | Freeze protects streak | Day 1 streak, 1 freeze available, clock advanced 30h | Player opens app | Streak protected (not broken); freeze count decrements | Should |
| AC-011 | Gate Log updated | All items above evaluated | QA session complete | `docs/RELEASE-GATES.md` Sprint 1 row shows Pass/Fail + tester + date + build | Must |

---

## Definition of Done

- [ ] All 11 ACs evaluated; results recorded
- [ ] `docs/RELEASE-GATES.md` Sprint 1 Gate Log row filled in
- [ ] Any failures have corresponding tasks filed in `docs/Master-Plan.md`
- [ ] S1-03 status set to Done in Master-Plan.md (or remains open if failures unresolved)
