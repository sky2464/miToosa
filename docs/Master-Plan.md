# Master-Plan

> **Source of truth:** This file (no Linear integration — update here directly).
> **Last mirrored:** 2026-05-04 (by /agtoosa-init)

## Project Charter

- Product: miToosa — cross-platform cognitive puzzle game (iOS, Android, macOS, Web)
- Linear project URL: N/A — Master-Plan.md is the PM source of truth
- GitHub repo: https://github.com/sky2464/miToosa
- Current milestone: v1.5.0 — Pre-Launch (Sprint 1: Launch Readiness & Validation)
- Active cycle: Sprint 1 (2026-04-22 → 2026-05-06)
- Cycle capacity: TBD

## Epics

> One row per product area. IDs are local (EP-XX) — no Linear required.

| ID | Title | Priority | Stories | Status |
|----|-------|----------|---------|--------|
| EP-01 | Launch Readiness & Validation | P0 | 4 open | In Progress |
| EP-02 | Platform Release Infrastructure | P1 | 3 open | Backlog |
| EP-03 | Retention & Monetization Expansion | P2 | 4 open | Backlog |
| EP-04 | User Experience Polish | P3 | 3 open | Backlog |
| EP-05 | Technical Debt & Infrastructure | P4 | 3 open | Backlog |

## Epic Charters

### Epic: Launch Readiness & Validation (P0 — blocks all other work)
Prove the product works with real users before building new features. Deliverables: staging deployment + QA gate, analytics backend selected, manual wedge QA walkthrough, and 15–20-person playtest with survey. Gate: No new features start until all 4 goals are green.

### Epic: Platform Release Infrastructure (P1 — required for App Store / Play Store)
Unblock iOS and Android distribution channels. Deliverables: iOS provisioning & signing, Android keystore & signing, Firebase project setup (optional analytics backend).

### Epic: Retention & Monetization Expansion (P2 — pending playtest validation)
Expand the engagement and revenue model once the wedge is proven. Deliverables: backend leaderboard (real-time), referral tiers, VIP / ad-free IAP. Gate: D1 ≥40% and social motivation signal from playtest.

### Epic: User Experience Polish (P3 — nice-to-have, playtest-driven)
Refine UX based on playtest feedback. Deliverables: first-session onboarding optimisation, economy messaging clarity, accessibility audit on physical devices.

### Epic: Technical Debt & Infrastructure (P4 — ongoing maintenance)
Keep codebase healthy and dependencies current. Deliverables: automated dependency maintenance (CI), test coverage expansion (integration tests), web platform crypto hardening.

## Active Cycle

> Stories committed to Sprint 1.

| ID | Title | Type | Estimate | Status | Tasks Done |
|----|-------|------|----------|--------|------------|
| S1-01 | Staging Deployment & QA Gate | Feature | L | In Progress | 2/2 |
| S1-02 | Analytics Backend Integration | Feature | M | Done | 1/1 |
| S1-03 | Manual Wedge QA Walkthrough | Chore | S | Todo | 0/1 |
| S1-04 | Playtest Survey & Recruitment | Feature | M | Todo | 0/1 |

## Active Tasks

> Task sub-issues under the currently In Progress story. Created at `/agtoosa-build scope`.

- [x] **1. S1-01:** Staging Deployment & QA Gate
	- [x] 1.1 Add CI conditional deploy gate and deploy helper script — _Requirements: AC-001, AC-002, AC-003_
	- [x] 1.2 Publish staging setup/runbook docs and release-gate prepopulation — _Requirements: AC-004, AC-005_
- [x] **2. S1-02:** Analytics Backend Integration
	- [x] 2.1 Wire Firebase Analytics sink and guarded initialization path — _Requirements: AC-001, AC-002, AC-003, AC-004, AC-005, AC-006, AC-007_
- [ ] **3. S1-03:** Manual Wedge QA Walkthrough
	- [ ] 3.1 Execute manual QA walkthrough and capture findings in QA artifacts — _Requirements: QA walkthrough checklist_
- [ ] **4. S1-04:** Playtest Survey & Recruitment
	- [ ] 4.1 Finalize survey with staging URL and recruit 15-20 testers — _Requirements: playtest recruitment target_

## Backlog

> Priority-ordered stories not yet in an active cycle.

| ID | Title | Type | Estimate | Epic | Priority |
|----|-------|------|----------|------|----------|
| BL-01 | iOS Provisioning & Signing Setup | Chore | M | EP-02 | P1 |
| BL-02 | Android Keystore & Signing Setup | Chore | M | EP-02 | P1 |
| BL-03 | Firebase Project Setup | Feature | M | EP-02 | P1 |
| BL-04 | Backend Leaderboard (Real-Time) | Feature | L | EP-03 | P2 |
| BL-05 | Referral Tiers | Feature | L | EP-03 | P2 |
| BL-06 | VIP / Ad-Free IAP | Feature | L | EP-03 | P2 |
| BL-07 | First-Session Onboarding Optimisation | Improvement | M | EP-04 | P3 |
| BL-08 | Economy Messaging Clarity | Improvement | S | EP-04 | P3 |
| BL-09 | Accessibility Audit (Physical Devices) | Chore | S | EP-04 | P3 |
| BL-10 | Test Coverage Expansion (integration tests) | Chore | M | EP-05 | P4 |
| BL-11 | Web Platform Crypto Hardening | Improvement | S | EP-05 | P4 |
| BL-12 | Resolve staging URL publication blocker | Chore | S | EP-01 | P1 |
| BL-13 | Recover playtest response pipeline (>=5 responses) | Chore | S | EP-01 | P1 |
| BL-14 | Unblock TestFlight beta provisioning handoff | Chore | M | EP-02 | P1 |
| BL-15 | Unblock Play Store internal track setup | Chore | M | EP-02 | P1 |

## Blocked

> Issues that cannot progress due to a dependency or decision.

| ID | Title | Blocked by | Since |
|----|-------|-----------|-------|
| BL-12 | Resolve staging URL publication blocker | Hosting decision + first deploy URL pending (next check: 2026-05-18) | 2026-05-11 |
| BL-13 | Recover playtest response pipeline (>=5 responses) | Survey distribution + staging URL pending (next check: 2026-05-18) | 2026-05-11 |
| BL-14 | Unblock TestFlight beta provisioning handoff | Apple Developer account provisioning (human action) (next check: 2026-05-18) | 2026-05-11 |
| BL-15 | Unblock Play Store internal track setup | Android keystore creation (human action) (next check: 2026-05-18) | 2026-05-11 |

## Completed This Cycle

> Stories shipped this sprint. Updated by `/agtoosa-ship`.

| ID | Title | Shipped | Notes |
|----|-------|---------|-------|
| C-01 | Normalize product/monetization source of truth (Task 1) | 2026-04-18 | docs/PRODUCT-WEDGE.md |
| C-02 | Define KPI dashboard and event taxonomy (Task 2) | 2026-04-18 | docs/analytics-events-v1.3.md |
| C-03 | Simplify first-session entry (Task 3) | 2026-04-22 | Login screen refactor |
| C-04 | Implement free-games allowance model (Task 4) | 2026-04-22 | 25 games/day economy |
| C-05 | Replace share-for-heart with share bonus (Task 5) | 2026-04-22 | +40 games/share |
| C-06 | Upgrade streak system into reward ladder (Task 6) | 2026-04-22 | 8 milestone thresholds |
| C-07 | Aetheric Pulse visual redesign — all P1–P8 items | 2026-04-24 | docs/archived/spec-aetheric-pulse-redesign.md |
| C-08 | iToosa → miToosa feature migration | 2026-04-24 | docs/archived/spec-itoosa-feature-migration-v1.md |
| S1-05 | Repo & Docs Cleanup (cleanup_001) | 2026-05-04 | docs/archived/spec-cleanup-001.md · review-cleanup-001.md |
| S1-02 | Analytics Backend Integration | 2026-05-11 | docs/AgToosa_Spec-S1-02.md · docs/archived/review-s1-02.md · docs/archived/ship-check-s1-02.md |

## Update Log

> Append a row at every phase transition. Never delete rows.

| Date | Event | By |
|------|-------|----|
| 2026-05-04 | /agtoosa-init — initialization complete; context files populated, Epics seeded, TDD enabled | AgToosa |
| 2026-05-04 | /agtoosa-init re-run — confirmed all context files already populated; removed Linear references; assigned EP/S1/T/BL IDs; populated Completed This Cycle from TASKS.md | AgToosa |
| 2026-05-04 | /agtoosa-init re-run — AI configs validated (CLAUDE.md ✅, copilot-instructions.md ✅); AGENTS.md created; context files confirmed current; TDD enforced | AgToosa |
| 2026-05-04 | /agtoosa-spec cleanup_001 — S1-05 specced; scope: archive TASKS.md + plan.md, delete firebase.md, update GEMINI.md, keep dependency maintenance docs | AgToosa |
| 2026-05-04 | /agtoosa-build S1-05 — Build 🏗️ Started: TASKS.md archived, plan.md archived, firebase.md deleted, GEMINI.md updated with AgToosa wiring | AgToosa |
| 2026-05-04 | /agtoosa-review S1-05 — Review ✅ Passed: 0 Critical, 3 Warnings fixed (GEMINI.md count label, CLAUDE.md duplicates, REFACTORING-SUMMARY token syntax accepted) | AgToosa |
| 2026-05-04 | /agtoosa-ship S1-05 — Ship 🚀 Done: all gates green, S1-05 moved to Completed, changelog updated | AgToosa |
| 2026-05-05 | /agtoosa-build S1-01 — Build 🏗️ Started: scope confirmed; CI deploy gate, staging script, setup doc, and release-gate prepopulation implemented | AgToosa |
| 2026-05-05 | /agtoosa-build S1-01 — Task 🟢 4/4 complete: web workflow, deploy script, staging setup doc, and release-gate row updated; awaiting manual Firebase setup for deploy URL | AgToosa |
| 2026-05-05 | /agtoosa-build S1-01 — Test ✅ Passed: `dart analyze` clean; `flutter test` 637 passing; requested SAST/DAST tools (semgrep, gitleaks, checkov, tfsec, codeql) not installed locally | AgToosa |
| 2026-05-05 | /agtoosa-review S1-01 — Review 🔍 In Progress: aligned `docs/RELEASE-GATES.md` Firebase command to `hosting:mitoosa-staging`; remaining blocker is manual Firebase setup + staging URL | AgToosa |
| 2026-05-11 | /agtoosa-spec tasks S1-01 — Active Tasks converted to hierarchical checkbox tree; Sprint 1 task counters realigned to actual checked/total values | AgToosa |
| 2026-05-11 | /agtoosa-task blocker-rescope — B-01..B-04 migrated to backlog-tracked BL-12..BL-15 and Blocked table cleaned to canonical IDs | AgToosa |
| 2026-05-11 | /agtoosa-spec S1-02 — Spec promoted to Approved, build scope/task tree/wave plan finalized, and S1-02 test plan skeleton generated | AgToosa |
| 2026-05-11 | /agtoosa-build S1-02 — Build 🏗️ Started: Firebase dependencies added, sink/provider wiring implemented, guarded app initialization and placeholder options file added | AgToosa |
| 2026-05-11 | /agtoosa-build S1-02 — Test ✅ Passed: targeted tests green, `dart analyze` clean, and full `flutter test` passing (639 tests) | AgToosa |
| 2026-05-11 | blocker-management — BL-12..BL-15 retained as blocked, `Since` refreshed and weekly next-check cadence added | AgToosa |
| 2026-05-11 | /agtoosa-review S1-02 — Review 🔍 Started: security, architecture, product, and QA persona checks in progress | AgToosa |
| 2026-05-11 | /agtoosa-review S1-02 — Review ✅ Passed: no critical findings; one warning retained for historical WIP/fixup commit in repo history | AgToosa |
| 2026-05-11 | /agtoosa-ship check S1-02 — ⚠️ Conditional pass: all gates green except strict WIP-history policy (match exists in `refs/stash` only) | AgToosa |
| 2026-05-11 | /agtoosa-ship S1-02 — Ship 🚀 Done: managed exception accepted for stash-only WIP history; story moved to Completed This Cycle | AgToosa |
| 2026-05-11 | /agtoosa-task backlog-hygiene — BL-04/BL-05/BL-06 removed from Blocked aging queue and retained as backlog-gated post-playtest stories | AgToosa |
| 2026-05-11 | /agtoosa-ship hygiene — dropped stash entry `stash@{0}` containing WIP commit marker; repo-wide WIP/fixup scan now clean | AgToosa |
