# Sprint 1 — Post-Redesign: Close the Wedge, Ship to Staging, Run the Playtest

**Status:** Archived — 2026-04-24
**Date:** 2026-04-22
**Sprint goal:** Prove the coded wedge works with real users before building anything new.

## Gap Analysis: Redesign vs. Reality

| Task | Claimed | Reality |
|------|---------|---------|
| Task 1 — Source of truth | ✅ Done | ✅ Confirmed. `PRODUCT-WEDGE.md` authoritative. |
| Task 2 — KPI taxonomy | ✅ Done | ✅ Confirmed. Telemetry events in Hive. |
| Task 3 — First-session friction | ✅ Code done | ⚠️ Manual verification never ran. |
| Task 4 — Free-games allowance | ✅ Code + persistence tests | ⚠️ Manual check skipped. |
| Task 5 — Share bonus | ✅ Code done | ⚠️ Manual verification never ran. |
| Task 6 — Streak reward ladder | ✅ Persistence tests | ⚠️ Manual check skipped. |
| Task 11 — Release gates | ✅ Documented | ❌ Staging URL missing. Gate never exercised. |
| Task 7 — Referral tiers | DEFERRED | ✅ Correctly deferred (needs backend). |
| Task 8 — VIP/IAP | DEFERRED | ✅ Correctly deferred (needs playtest data). |
| Task 9 — Landing page | DEFERRED | ✅ Correctly deferred (needs external infra). |
| Task 10 — Playtest | DEFERRED | ❌ Zero demand signal. Product is pre-product. |

## Problem Statement

The wedge features (Tasks 3–6) are coded and pass automated tests, but no human has verified the product works as described. The release gate (Task 11) has never been exercised. The product has not been playtested. Without closing these gaps, any further feature investment (backend leaderboard, referral tiers, VIP) is building on an unproven foundation.

## Goals

1. **G1 — Wedge verified:** Human walks the full product loop (first session → game → share → streak) in under 10 minutes with no economy confusion.
2. **G2 — Staging operational:** Public web staging URL exists, `/qa`-reviewed, recorded as the release gate target.
3. **G3 — Analytics backend selected:** Team agrees on KPI data destination so playtest data is capturable.
4. **G4 — Playtest launched:** 15–20 testers recruited, survey live, first responses captured within sprint.
5. **G5 — No new features start until G1–G4 are green.**

## Requirements

### Must-Have (P0)

**M1 — Manual wedge QA walkthrough**
Run full product loop: fresh install → onboarding → first game → share → streak day 1 → return next day.
- Acceptance: Written walkthrough confirms each manual-check checkbox in `update.md` is green, or raises a bug ticket per failure.

**M2 — Staging deployment target selected and live**
Pick web host (Vercel, Firebase Hosting, Netlify), deploy web build, record URL in `CLAUDE.md` and `docs/RELEASE-GATES.md`.
- Acceptance: URL loads app, passes `/qa` review, is recorded as official staging target.

**M3 — Analytics backend decision**
Agree on analytics destination, integrate SDK, confirm at least one event (session start) appears in dashboard.
- Acceptance: One real event visible in analytics dashboard from a manual test session.

**M4 — Playtest recruitment opens**
15–20 testers identified. Survey drafted, reviewed, linked from staging URL.
- Acceptance: ≥5 responses captured by end of sprint.

**M5 — `docs/RELEASE-GATES.md` created and operational**
Documents: staging URL, `/qa` process, branch → review → staging → qa → merge sequence. Gate exercised on this sprint's staging deployment.
- Acceptance: One full gate sequence run and logged before sprint closes.

## Success Metrics

| Metric | Target | Timeframe |
|--------|--------|-----------|
| Manual QA P0 bugs | Zero | Sprint |
| Staging uptime | URL responds | Sprint |
| Analytics events firing | ≥1 confirmed | Sprint |
| Playtest responses | ≥5 by sprint end | Sprint |
| First-session time to gameplay | <60 seconds | Sprint |
| D1 return rate | ≥40% | 1 week post-playtest |
| Session completion rate | ≥70% | 1 week post-playtest |
| Share rate (day 1) | ≥20% of sessions | 1 week post-playtest |
| "Would you pay for VIP?" | ≥30% yes/maybe | Playtest survey |

## Timeline

```
Week 1
├── Day 1-2:  Select web host, deploy staging build, run /qa
├── Day 2-3:  Manual wedge QA walkthrough (Tasks 3-6)
├── Day 3:    Select analytics backend, confirm one event fires
└── Day 4-5:  Playtest survey drafted, recruitment opens

Week 2
├── Day 1-3:  Playtest sessions running, first responses captured
├── Day 3-4:  RELEASE-GATES.md finalized with real staging URL
└── Day 5:    Sprint retro — go/no-go on Sprint 2 feature set
```

**Hard gate:** No Sprint 2 features scoped until playtest has ≥5 responses and manual wedge QA is green.

**Archived:** 2026-04-24
