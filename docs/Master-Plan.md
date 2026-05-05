# Master-Plan

> **Source of truth:** Linear project — always update Linear first, then mirror here.
> **Last mirrored:** 2026-05-04 12:00 (by /agtoosa-init)

## Project Charter

- Product: miToosa — cross-platform cognitive puzzle game (iOS, Android, macOS, Web)
- Linear project URL: <!-- Add your Linear project URL here -->
- GitHub repo: https://github.com/sky2464/miToosa
- Current milestone: v1.5.0 — Pre-Launch (Sprint 1: Launch Readiness & Validation)
- Active cycle: Sprint 1 (2026-04-22 → 2026-05-06)
- Cycle capacity: TBD

## Epics

> Created at `/agtoosa-init`. One row per product area. Link Linear Epic IDs once created.

| ID | Title | Priority | Stories | Status |
|----|-------|----------|---------|--------|
| [TBD] | Epic: Launch Readiness & Validation | P0 | 4 open | Backlog |
| [TBD] | Epic: Platform Release Infrastructure | P1 | 3 open | Backlog |
| [TBD] | Epic: Retention & Monetization Expansion | P2 | 4 open | Backlog |
| [TBD] | Epic: User Experience Polish | P3 | 3 open | Backlog |
| [TBD] | Epic: Technical Debt & Infrastructure | P4 | 3 open | Backlog |

> **Action required:** Create these as Epic issues in Linear and replace [TBD] with actual IDs.

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
| [TBD] | Feature: Staging Deployment & QA Gate | Feature | L | Backlog | 0/? |
| [TBD] | Feature: Analytics Backend Integration | Feature | M | Backlog | 0/? |
| [TBD] | Chore: Manual Wedge QA Walkthrough | Chore | S | Backlog | 0/? |
| [TBD] | Feature: Playtest Survey & Recruitment | Feature | M | Backlog | 0/? |

*(Link Linear issue IDs once created via `/agtoosa-spec`.)*

## Active Tasks

> Task sub-issues under the currently In Progress story. Created at `/agtoosa-build scope`.

| ID | Title | Estimate | Status |
|----|-------|----------|--------|

*(Empty until `/agtoosa-build scope` breaks down the active story.)*

## Backlog

> Priority-ordered stories not yet in an active cycle.

| ID | Title | Type | Estimate | Epic | Priority |
|----|-------|------|----------|------|----------|
| [TBD] | Chore: iOS Provisioning & Signing Setup | Chore | M | Platform Release | P1 |
| [TBD] | Chore: Android Keystore & Signing Setup | Chore | M | Platform Release | P1 |
| [TBD] | Feature: Firebase Project Setup | Feature | M | Platform Release | P1 |
| [TBD] | Feature: Backend Leaderboard (Real-Time) | Feature | L | Retention | P2 |
| [TBD] | Feature: Referral Tiers | Feature | L | Retention | P2 |
| [TBD] | Feature: VIP / Ad-Free IAP | Feature | L | Retention | P2 |
| [TBD] | Enhancement: First-Session Onboarding Optimisation | Improvement | M | UX Polish | P3 |
| [TBD] | Enhancement: Economy Messaging Clarity | Improvement | S | UX Polish | P3 |
| [TBD] | Enhancement: Accessibility Audit (Physical Devices) | Chore | S | UX Polish | P3 |
| [TBD] | Chore: Test Coverage Expansion (integration tests) | Chore | M | Tech Debt | P4 |
| [TBD] | Enhancement: Web Platform Crypto Hardening | Improvement | S | Tech Debt | P4 |

## Blocked

> Issues that cannot progress due to a dependency or decision.

| ID | Title | Blocked by | Since |
|----|-------|-----------|-------|
| [TBD] | Feature: Backend Leaderboard | Playtest — needs D1 ≥40% signal | 2026-04-22 |
| [TBD] | Feature: Referral Tiers | Playtest — wedge must be proven first | 2026-04-22 |
| [TBD] | Feature: VIP / Ad-Free IAP | Playtest — retention must be proven | 2026-04-22 |
| [TBD] | Feature: Playtest Survey | Staging deployment (must exist first) | 2026-04-22 |

## Completed This Cycle

> Stories shipped this sprint. Updated by `/agtoosa-ship`.

| ID | Title | Shipped | Archived Spec |
|----|-------|---------|---------------|

*(Empty — updated by `/agtoosa-ship` as stories close.)*

## Update Log

> Append a row at every phase transition. Never delete rows.

| Date | Event | By |
|------|-------|----|
| 2026-05-04 | /agtoosa-init — initialization complete; context files populated, Epics seeded, TDD enabled | AgToosa |
