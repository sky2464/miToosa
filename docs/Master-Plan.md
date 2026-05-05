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
| S1-02 | Analytics Backend Integration | Feature | M | Todo | 0/1 |
| S1-03 | Manual Wedge QA Walkthrough | Chore | S | Todo | 0/1 |
| S1-04 | Playtest Survey & Recruitment | Feature | M | Todo | 0/1 |

## Active Tasks

> Task sub-issues under the currently In Progress story. Created at `/agtoosa-build scope`.

| ID | Title | Estimate | Status |
|----|-------|----------|--------|
| T-01 | Select web host (Firebase/Vercel/Netlify); record URL in RELEASE-GATES.md | 2h | In Progress |
| T-02 | Integrate analytics SDK; confirm session_start event in dashboard | 4h | Todo |
| T-03 | Fresh install → onboarding → first game → share → streak walkthrough | 2h | Todo |
| T-04 | Fill [STAGING_URL] in SURVEY-TEMPLATE.md; recruit 15–20 testers | 1h | Todo |
| T-05 | Run /agtoosa-qa on staging; update Gate Log row in RELEASE-GATES.md | 3h | Todo |

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

## Blocked

> Issues that cannot progress due to a dependency or decision.

| ID | Title | Blocked by | Since |
|----|-------|-----------|-------|
| B-01 | Staging URL | T-01: Hosting decision pending | 2026-04-22 |
| B-02 | Playtest responses ≥5 | T-04: Survey distribution pending | 2026-04-22 |
| B-03 | TestFlight beta | Apple Developer account provisioning (human action) | 2026-04-22 |
| B-04 | Play Store internal track | Android keystore creation (human action) | 2026-04-22 |
| BL-04 | Backend Leaderboard | Playtest — needs D1 ≥40% signal | 2026-04-22 |
| BL-05 | Referral Tiers | Playtest — wedge must be proven first | 2026-04-22 |
| BL-06 | VIP / Ad-Free IAP | Playtest — retention must be proven | 2026-04-22 |

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
