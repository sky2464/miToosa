# Test Plan — BL-35 Reachable Daily Rewards, Streaks, and Achievements

> **Spec:** [spec-BL-35.md](archived/spec-BL-35.md)
> **Status:** Draft pending approval
> **Created:** 2026-07-14

## Scope & Strategy

Use a fakeable clock and persistence store to make reward availability deterministic. Widget tests cover normal routes and prove that browsing engagement detail does not mutate state.

## AC Coverage Matrix

| AC ID | EARS summary | Priority | Test IDs | Category | Smoke |
|-------|--------------|----------|----------|----------|-------|
| AC-001 | Available reward is normally reachable | Must | T-001 | Widget/controller | T-001 @smoke |
| AC-002 | Claim persists once today | Must | T-002 | Controller/persistence | T-002 @smoke |
| AC-003 | Claimed day blocks duplicate | Must | T-003 | Controller/widget | T-003 @smoke |
| AC-004 | Progress routes to streak/achievements | Must | T-004 | Widget | T-004 @smoke |
| AC-005 | Browsing detail is non-mutating | Must | T-005 | Widget/persistence | — |
| AC-006 | Engagement UI is accessible | Should | T-006 | Widget/accessibility | — |

## Test Catalog

### T-001 — Eligible reward entry @smoke
- **AC:** AC-001
- **Steps:** Use onboarded, idle progress with an unclaimed reward; build shell and Progress.
- **Pass:** An eligible player receives a safe idle offer and can reopen it from Progress.
- **Negative:** It does not appear over onboarding or GameplayScreen.

### T-002 — One daily claim persists @smoke
- **AC:** AC-002
- **Steps:** Claim with a fixed date, reload progress, and inspect reward/stats state.
- **Pass:** One documented reward is persisted and visible progress refreshes.
- **Negative:** Double tap/in-flight rebuild cannot create a second mutation.

### T-003 — Already-claimed state @smoke
- **AC:** AC-003
- **Steps:** Attempt a second claim on the same date, then advance one day.
- **Pass:** Same-day state denies duplicate; next day becomes eligible according to existing rule.
- **Negative:** Modal CTA is not still a second claim action.

### T-004 — Reachable detail routes @smoke
- **AC:** AC-004
- **Steps:** Open Progress and activate streak/achievement controls.
- **Pass:** Both detail screens are reachable with labeled back/return behavior.
- **Negative:** No hidden-only route or dead control remains.

### T-005 — Detail browsing preserves progress
- **AC:** AC-005
- **Steps:** Snapshot PlayerProgress, open/dismiss/reopen streak and achievements.
- **Pass:** Snapshot is unchanged without explicit claim/action.
- **Negative:** Viewing does not call login, reward, or progress mutation.

### T-006 — Engagement accessibility layout
- **AC:** AC-006
- **Steps:** Render at narrow/high-text/reduced-motion settings and inspect semantics.
- **Pass:** No overflow; labeled 44pt targets and accessible modal behavior exist.
- **Negative:** Long streak/reward labels remain reachable.

### T-007 — iPhone engagement smoke
- **AC:** AC-001, AC-002, AC-004, AC-006
- **Steps:** Launch on an eligible date, claim once, inspect Progress/streak/achievements, enable large text.
- **Pass:** Normal flow is reachable and usable.
- **Negative:** Record interruption, duplicate reward, or inaccessible target.

## Regression

    dart analyze lib test
    flutter test

## RED / GREEN Evidence Log

Populated during /agtoosa-build.
