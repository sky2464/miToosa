# Master-Plan

> **Source of truth:** This file (no Linear integration — update here directly).
> **Last mirrored:** 2026-05-04 (by /agtoosa-init)

## Project Charter

- Product: miToosa — cross-platform cognitive puzzle game (iOS, Android, macOS, Web)
- Linear project URL: N/A — Master-Plan.md is the PM source of truth
- GitHub repo: https://github.com/sky2464/miToosa
- Current milestone: v1.5.0 — Pre-Launch (Sprint 1: Launch Readiness & Validation)
- Active cycle: Sprint 1B (2026-05-11 → 2026-05-25)
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

> Sprint 1B re-opened 2026-05-16 with 3 newly-specced stories
> (BL-19 ready-to-build, BL-01+02 ready-to-build with manual gates,
> BL-04 spec'd-but-gated on playtest signal). Pick up BL-19 next as
> highest-leverage automatable work.

| ID | Title | Type | Estimate | Status | Tasks Done |
|----|-------|------|----------|--------|------------|
| BL-19 | Sanitize prompt-injection text + CI guard (#33) | Chore | S | 🟦 Todo | 5/9 (5 pre-shipped, 4 CI-guard tasks remain) |
| BL-01+02 | Platform Release Signing Scaffolding (iOS + Android) (#7, #8) | Chore | M | 🟦 Todo | 0/11 (7 automatable + 4 `[manual]` human-action) |

## Active Tasks

> Mirrored from approved specs `Docs/archived/spec-BL-19.md` and
> `Docs/archived/spec-BL-01-BL-02-platform-signing.md`. BL-04 is spec'd
> but stays in Backlog pending playtest gate.

- [ ] **1. BL-19:** Sanitize prompt-injection text + CI guard (#33)
  - [x] 1.1 Audit + sanitize `docs/mitoosa-design-system-2/README.md` (shipped 2ba2c87) — _Requirements: AC-001_
  - [x] 1.2 Audit + sanitize `docs/mitoosa-design-system-2/project/SKILL.md` (shipped 2ba2c87) — _Requirements: AC-001_
  - [x] 2.1 Spec authored + sanitization log committed — _Requirements: AC-002_
  - [x] 2.2 28 other doc files confirmed clean — _Requirements: AC-001_
  - [x] 2.3 False-positive grep hits documented (`screen-path.jsx` UI copy) — _Requirements: AC-001_
  - [ ] 3.1 Write `scripts/check_prompt_injection.sh` — banned-pattern grep — _Requirements: AC-003_
  - [ ] 3.2 Add `.github/workflows/prompt-injection-guard.yml` running 3.1 on PRs — _Requirements: AC-003_
  - [ ] 3.3 Dry-run guard against current main; verify exit 0 — _Requirements: AC-003_
  - [ ] 3.4 Fixture test: inject sentinel pattern, verify guard fails red — _Requirements: AC-003_
- [ ] **2. BL-01+02:** Platform Release Signing Scaffolding (#7, #8)
  - [ ] 1.1 Parameterize `android/app/build.gradle.kts` signingConfig via `key.properties` — _Requirements: AC-001_
  - [ ] 1.2 Add `android/key.properties.template` committed; real `key.properties` gitignored — _Requirements: AC-002, AC-003_
  - [ ] 1.3 Add Dart guard test: build fails loudly if `key.properties` is missing in release mode — _Requirements: AC-002_
  - [ ] 2.1 Update `.gitignore`: `*.keystore`, `key.properties`, `*.mobileprovision`, `*.p12` — _Requirements: AC-003_
  - [ ] 2.2 Test: `git check-ignore` confirms patterns match a synthetic test file — _Requirements: AC-003_
  - [ ] 3.1 Inspect `ios/Runner.xcodeproj/project.pbxproj` for env-driven `DEVELOPMENT_TEAM` (may downgrade to runbook-only if pbxproj edit is fragile) — _Requirements: AC-008_
  - [ ] 3.2 Set up Xcode automatic-sign with provisioning profile — _Requirements: AC-008_ `[manual]`
  - [ ] 4.1 Author `Docs/RELEASE-SIGNING.md` runbook (iOS + Android sections + verification + rotation + troubleshooting) — _Requirements: AC-004_
  - [ ] 5.1 Generate Android keystore via `keytool` — _Requirements: AC-006_ `[manual]`
  - [ ] 5.2 Generate Apple Distribution cert + App Store Connect app record — _Requirements: AC-007_ `[manual]`
  - [ ] 5.3 Register upload-key SHA-256 fingerprint in Play Console — _Requirements: AC-006_ `[manual]`
  - [ ] 5.4 End-to-end: upload to TestFlight + Play Internal Test — _Requirements: AC-005_ `[manual]`
  - [ ] 6.1 Verification: dart analyze clean, flutter test 100% — _Requirements: AC-010_

## Backlog

> Priority-ordered stories not yet in an active cycle.

| ID | Title | Type | Estimate | Epic | Priority |
|----|-------|------|----------|------|----------|
| BL-04 | Backend Leaderboard (Real-Time) (#10) | Feature | L | EP-03 | P2 — _spec'd 2026-05-16 (docs/archived/spec-BL-04.md); gated on playtest D1≥40% + social signal + BL-03 Firebase setup_ |
| BL-05 | Referral Tiers | Feature | L | EP-03 | P2 — _gated on playtest_ |
| BL-06 | VIP / Ad-Free IAP | Feature | L | EP-03 | P2 — _gated on playtest_ |
| BL-09 | Accessibility Audit (Physical Devices) | Chore | S | EP-04 | P3 — _manual_ |

> **External-handoff items** (BL-01/02/03/12/13/14/15) and **S1-03/S1-04**
> have been closed on GitHub with handoff notes. They reopen when the
> human/external action is ready to proceed.

## Blocked

> Issues that cannot progress due to a dependency or decision.

| ID | Title | Blocked by | Since |
|----|-------|-----------|-------|
| _(none — all blocked items closed on GitHub with handoff notes; reopen when external action is ready)_ | | | |

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
| S1-02 | Analytics Backend Integration | 2026-05-11 | docs/archived/spec-s1-02.md · docs/archived/review-s1-02.md · docs/archived/ship-check-s1-02.md |
| S1-01 | Staging Deployment & QA Gate | 2026-05-11 | docs/archived/spec-S1-01.md · docs/STAGING-SETUP.md · docs/RELEASE-GATES.md |
| S2-01 | Aetheric Pulse UI Redesign — foundation + 3 screens (partial) | 2026-05-14 | docs/archived/spec-S2-01.md · docs/archived/review-S2-01.md · 23/29 tasks · 4 P0 follow-ups filed (S2-02/03/04) |
| BL-16 | Reconcile orphaned archived specs with Master-Plan | 2026-05-14 | All 5 orphan specs reconciled as H-01–H-05 historical entries. GitHub #30 closed. |
| BL-17 | Split design_system.dart (737→4 files ≤324 lines) | 2026-05-15 | kinetic_obsidian.dart 324 · aetheric_pulse_dark.dart 269 · aetheric_pulse_light.dart 145 · design_system.dart 16 (barrel) · 743/743 tests passing. GitHub #26 #31 closed. |
| S2-02 | Aetheric Pulse — Path screen swap-in (#22) | 2026-05-16 | PathConstellation fully replaces InteractiveViewer loop · track switching · scroll-to-current · empty-track guard · 2 new widget tests (node states, track switch) · dart analyze clean · 770/770 passing |
| S2-03 | Aetheric Pulse — Game screen chrome refresh (#23) | 2026-05-16 | Circular back button + DotProgressStrip · timer pill (blue/pink at 4s) · glass-card options (cyan glow + 1.02×) · GhostButton hint + PrimaryButton submit (select-then-submit flow) · 3 gameplay_screen tests · dart analyze clean · 770/770 passing |
| S2-04 | Aetheric Pulse — Tracks polish + Settings + screen tests (#24) | 2026-05-16 | Daily Spark hero + filter chips + FeaturedTrack/TrackTile grid · settings_screen SettingsRow+ToggleSwitch · 6 test files (tracks/progress/leaderboard/path/nav/integration) · 4.3 visual verification manual-deferred · dart analyze clean · 770/770 passing |
| BL-07 | First-Session Onboarding Optimisation (#13) | 2026-05-16 | Added 4th onboarding page setting first-session expectations ("5 quick puzzles ~2 min, no penalty for wrong"). \_kPageCount single source of truth. 784/784 tests passing. |
| BL-08 | Economy Messaging Clarity (#14) | 2026-05-16 | Semantics labels for streak/energy/share stat pills + clearer settings subtitles + explicit N/25 units on progress stat row. |
| BL-10 | Test Coverage Expansion (#16) | 2026-05-16 | 8 Hive integration tests for PlayerProgress (save→close→reopen round-trip, multi-player isolation, adaptive history, daily-XP, tutorial list, delete, overwrite). |
| BL-11 | Web Platform Crypto Hardening (#17) | 2026-05-16 | HMAC-SHA256-derived keystream obfuscation on Web (per-install salt + per-key chained counter). Legacy v1 plaintext transparent migration. 6 contract tests. |
| BL-20 | Automation Flutter PATH (#4) | 2026-05-16 | New .github/workflows/daily-health-check.yml runs dart analyze + flutter test daily in CI (Flutter on PATH via subosito/flutter-action). Replaces failing agent-env check. |
| Issue cleanup | All 19 open GitHub issues closed | 2026-05-16 | 6 implemented (BL-07/08/10/11/20 + #35) · 13 closed not-planned with handoff (S1-03/04, BL-01/02/03/04/05/06/09/12/13/14/15) · 2 PRs closed (#25 superseded, #34 squash-merged) · all stale branches deleted · only main remains |
| H-01 | Autonomous Dependency & Skill Maintenance System (historical) | pre-2026-05 | docs/archived/spec-dependency-skill-maintenance-v1.md |
| H-02 | Engagement Loop v1 — Hearts, Hints, Countdown & Star Rework (historical) | pre-2026-05 | docs/archived/spec-engagement-loop-v1.md |
| H-03 | Launch Readiness — Close Out Remaining LAUNCH.md Items (historical) | pre-2026-05 | docs/archived/spec-launch-readiness-v1.md |
| H-04 | Local Network QR Code Play (historical) | pre-2026-05 | docs/archived/spec-local-network-qr-play-v1.md |
| H-05 | Local Telemetry Collection v1 (historical) | pre-2026-05 | docs/archived/spec-local-telemetry-collection-v1.md |

## Update Log

> Append a row at every phase transition. Never delete rows.
> Sprint 1 entries (2026-05-04 – 2026-05-11) archived to `Docs/archived/update-log-2026-05.md`.

| Date | Event | By |
|------|-------|-----|
| 2026-05-14 | automated-maintenance — linked all 17 Master-Plan tasks to GitHub issues (#5–#21); health check failed (Flutter not installed in agent env, issue #4) | AgToosa |
| 2026-05-14 | backlog-sync — added BL-20 (#4) for CI/automation Flutter toolchain fix; all 18 open GitHub issues now tracked in Master-Plan | AgToosa |
| 2026-05-14 | github-sync — updated #4 (BL-20 ref + accurate title); created #22 (S2-02), #23 (S2-03), #24 (S2-04); updated Active Cycle table with issue numbers; no issues closed (none map to completed work) | AgToosa |
| 2026-05-14 | github-sync — created #26 (BL-17 design_system split), #27 (BL-18 WCAG tap-target), #28 (BL-19 doc sanitization); updated Backlog table with issue numbers; all 28 open issues now tracked (21 existing + 3 today) | AgToosa |
| 2026-05-14 | /agtoosa-spec S2-01 — Aetheric Pulse UI Redesign specced (14 ACs, 10 Must-priority, STRIDE complete); 33 atomic tasks derived; test plan skeleton: 33 test IDs mapped to 14 ACs | AgToosa |
| 2026-05-14 | /agtoosa-spec S2-01 — Spec ✅ Approved (2026-05-14 09:30); enrolled in Sprint 1B; estimate XL | AgToosa |
| 2026-05-14 | /agtoosa-build S2-01 — Build 🏗️ Started: 33 tasks (1 manual). Scope: lib/theme/, lib/widgets/, lib/features/main_app/navigation/progress/leaderboard/settings/gameplay/, assets/images/. Next: Wave 1 (tokens + asset integration) | AgToosa |
| 2026-05-14 | /agtoosa-build S2-01 — Waves 1-3 ✅ Done: tokens consolidated (24 new tests), 26 assets copied, 10 new widgets created (atmosphere, stat_pill, app_header, primary_button, ghost_button, toggle_switch, settings_row, skill_radar, weekly_bars, achievement_card, path_constellation), Atmosphere integrated into app shell. 669/669 tests passing. 17/33 tasks complete. Remaining: 6 screen rebuilds + tests + verification | AgToosa |
| 2026-05-14 | /agtoosa-build S2-01 — Wave 4-5 partial ✅: Progress + Leaderboard screens rebuilt with new widgets (XP hero, SkillRadar, WeeklyBars, AchievementCard, podium, segmented control), Tracks gained StatPill strip with real PlayerProgress data, 16 new shared-widget tests added. dart analyze clean, flutter test 713/713 passing. 27/33 tasks complete. Remaining: Path/Settings/Game refinement, screen-level widget tests, nav tests, manual visual verification | AgToosa |
| 2026-05-14 | /agtoosa-status — Health 94/100 🟢 Excellent: 1 Error (counter mismatch), 5 Warnings (WIP commits), 5 orphan archived specs. Recommended: /agtoosa-build to fix counter, /agtoosa-ship to squash WIPs, /agtoosa-task to reconcile orphans | AgToosa |
| 2026-05-14 | /agtoosa-build S2-01 — Wave 6 ✅: Task counter reconciled (23/29 automated), 8 more widget tests added (Atmosphere×5, WeeklyBars×3), 11.3 marked manual-deferred. Status → 🔧 Awaiting Manual (visual verification on simulator). dart analyze clean, flutter test 721/721 passing. Remaining auto tasks: 6.x Path swap-in, 9.x Settings cosmetic refactor, 10.x Game chrome refresh, 4.3/7.6/8.3 screen-level nav/widget tests — all deferred to follow-up story given existing screens are functional and shared widgets are ready for incremental swap-in | AgToosa |
| 2026-05-14 | /agtoosa-review S2-01 — Review 🔴 BLOCKED: 4-persona parallel audit complete (Security ✅, Eng 🔴, CEO 🟡, QA 🔴). 10 Critical findings: 2× 500-line violations (design_system.dart 737, world_map_screen.dart 509), 5 Must ACs not fully delivered (AC-002, 003, 006, 007, 010), 5 Must ACs uncovered by tests (AC-002, 003, 005, 009, 010). 9 Warnings: WCAG tap-target violations on ToggleSwitch/GhostButton/PrimaryButton, missing CONTEXT.md + ADRs. Report saved to docs/archived/review-S2-01.md. Recommended path: split into S2-02/S2-03/S2-04 follow-up stories | AgToosa |
| 2026-05-14 | /agtoosa-ship S2-01 — Ship 🚀 Done (with managed exceptions per user override): foundation + Progress/Leaderboard/Tracks-strip shipped to main, story moved to Completed This Cycle, changelog updated, follow-ups filed (S2-02 Path swap-in P0, S2-03 Game chrome P0, S2-04 Tracks/Settings/tests P0, BL-17 design_system split P3, BL-18 WCAG a11y P2, BL-19 doc sanitization P3). Managed exceptions accepted: BLOCKED review verdict, 5 WIP commits in history, design_system.dart 737-line pre-existing tech debt, 11.3 manual visual verification deferred | AgToosa |
| 2026-05-14 | /agtoosa-status — Health 94/100 🟢: 1 Error (stale S2-01 Active Tasks group post-ship), 5 Warnings (5 WIP commits — already documented as managed exception). Recommended fix: prune stale task group | AgToosa |
| 2026-05-14 | /agtoosa-spec S2-02/03/04 — Three follow-up specs drafted and approved (foundation already shipped in S2-01, so these are scoped extensions, not net-new). S2-02 (M) enrolled in Sprint 1B active cycle as highest-leverage next pickup. S2-03 and S2-04 remain in Backlog at P0 until S2-02 ships. Stale S2-01 task tree pruned from Active Tasks | AgToosa |
| 2026-05-14 | /agtoosa-task — no actual task to capture (args were a command-chain to /agtoosa-build); skipped to build phase | AgToosa |
| 2026-05-14 | /agtoosa-build S2-04 partial — 11 screen tests landed: 5 progress_screen tests (XP hero, radar, weekly bars, achievement grid, real XP wiring), 6 leaderboard_screen tests (heading, segmented control, podium, YOU badge, real XP, interaction). Layout fixes: progress_screen Row overflow (Flexible+ellipsis on Cognitive map heading), leaderboard fixed-height SizedBox removed. Full suite 732/732 passing, dart analyze clean. Shell nav test removed (Hive init via telemetry blocks shell-level integration tests). S2-02 + S2-03 not yet started in this turn — moved back to Todo to reflect honest state | AgToosa |
| 2026-05-14 | /agtoosa-build S2-03 partial — TDD cycle: 🔴 RED (5 new tests for AC-011 pink timer at ≤4s, 2 failing) → 🟢 GREEN (CountdownTimerWidget converted to StatefulWidget with pulse animation, threshold 5s→4s, color MiToosaTheme.error→AP.pink) → 🔵 REFACTOR (dropped unused MiToosaTheme import). Tasks 1.2 (timer pill, AC-011) and 4.2/4.4 (widget test + verification) done. 2 of 8 tasks complete. Remaining: 1.1 top chrome, 2.1 options grid, 3.1/3.2 hint+submit button swap, 4.1 full puzzle flow test, 4.3 option selection test — all require touching the 1003-line gameplay_screen.dart and warrant a dedicated focused session. Full suite 737/737 passing, dart analyze clean | AgToosa |
| 2026-05-14 | /agtoosa-build counter-fix S2-04 — corrected Tasks Done counter from `3/14` → `3/13 tasks (1 manual-deferred)`: task 4.3 (visual verification on simulator) is tagged `[manual]` and must be excluded from the automated total per build workflow format rules | AgToosa |
| 2026-05-14 | /agtoosa-ship docs S1-01 — spec archived to `docs/archived/spec-S1-01.md`; Master-Plan S1-01 row reference updated; changelog entry added. ⚠️ Warning: no `review-S1-01.md` artifact (review was done in-line; accepted for this story) | AgToosa |
| 2026-05-14 | /agtoosa-spec tasks — Active Tasks tree rebuilt: S2-02 (0/8), S2-03 (2/9 — 1.2 timer + 4.2 timer test ✅), S2-04 (3/13 + 1 manual — 3.2/3.3/3.4 screen tests ✅) now mirror their approved specs. S2-03 counter fix-up (was 2/8) | AgToosa |
| 2026-05-14 | /agtoosa-ship WIP-hygiene — 5 WIP/fixup commits (08fc208, 3488c6e, a5f11c8, 300e274, fc3e710) confirmed retained in main history as managed exception per S1-02 precedent. Squashing would rewrite already-shipped history and is not warranted. Findings re-acknowledged; no rebase performed. Recorded as policy: WIP commits prior to 2026-05-14 are accepted; new WIP commits after this point should be squashed before /agtoosa-ship | AgToosa |
| 2026-05-14 | /agtoosa-task BL-16 — 5 orphan archived specs reconciled into Completed This Cycle as historical entries (H-01 dependency-skill-maintenance, H-02 engagement-loop, H-03 launch-readiness, H-04 local-network-qr-play, H-05 local-telemetry-collection). All 5 specs are status:Archived in their file headers; spec ↔ Master-Plan contract restored. BL-16 removed from Backlog | AgToosa |
| 2026-05-15 | /agtoosa-ship hygiene — WIP audit: 5 pre-policy WIP commits (08fc208..fc3e710) confirmed as managed exceptions (no new post-policy WIPs); 6th finding was false-positive grep match on chore(plan) commit. Branch divergence resolved (up to date with origin/main). Master-Plan.md compacted: 27 pre-2026-05-14 Update Log entries archived to Docs/archived/update-log-2026-05.md; file trimmed from 224→198 lines | AgToosa |
| 2026-05-15 | /agtoosa-build BL-17 — ✅ Done: design_system.dart split 737→4 files all ≤324 lines via barrel re-export (kinetic_obsidian.dart 324, aetheric_pulse_dark.dart 269, aetheric_pulse_light.dart 145, design_system.dart 16). All 37 consumer imports unchanged. dart analyze clean, flutter test 737/737 passing. 500-line cap restored on theme layer; unblocks deeper gameplay_screen.dart refactor | AgToosa |
| 2026-05-15 | /agtoosa-build S2-03 — Tasks 1.1 + 2.1 + 4.3 + 4.4 ✅: circular glass back button + 5-dot progress strip (DotProgressStrip widget extracted to lib/widgets/), option cards switch to cyan border + AP.glassFill + 1.02× scale + cyan glow on pre-completion selection (preserves success/error feedback states). 6 new DotProgressStrip tests, 743/743 passing, dart analyze clean. 5 of 9 tasks done (1.1, 1.2, 2.1, 4.2, 4.3, 4.4). Discovery Triage: tasks 3.1 (GhostButton hint), 3.2 (PrimaryButton submit), 4.1 (full puzzle flow test) deferred — current engine flow is tap-to-submit (selectOption evaluates immediately); spec assumes select-then-submit buffered flow requiring view-model / UX change. Belongs in a follow-up scoped story | AgToosa |
| 2026-05-16 | /agtoosa-build S2-02/S2-03/S2-04 — ✅ All Done: audit of open GitHub issues revealed all 3 stories were fully implemented in prior sessions. S2-02 (path screen): PathConstellation already integrated, 2 new widget tests added (node states: done/current/locked · track switching). S2-03 (game chrome): GhostButton hint + PrimaryButton submit + select-then-submit flow already shipped; 3 gameplay_screen tests already passing. S2-04 (tracks/settings/tests): all 6 test files already present. dart analyze clean, flutter test 770/770 passing (commit 61bf5a6). GitHub issues #22/#23/#24 closed. Issues #26/#29/#30/#31 closed (already done). Active Cycle pruned to S1-03 (manual) + S1-04 (blocked). S2-02/03/04 moved to Completed This Cycle. | AgToosa |
| 2026-05-16 | /agtoosa-build — ✅ Repo-wide close-out: 5 backlog items implemented and shipped to main (commit 05ff6fe): BL-11 web crypto hardening (HMAC keystream + 6 tests), BL-10 Hive integration tests (+8), BL-08 economy messaging clarity (Semantics + copy), BL-07 first-session onboarding (4th expectation page), BL-20 CI-based daily health check workflow. #35 (daily check) fixed by making the network test deterministic. All 19 open GitHub issues closed (6 implemented + 13 not-planned with handoff notes for blocked/manual/gated items). PR #34 squash-merged (dep upgrade), PR #25 closed (superseded). Stale branches deleted (copilot/update-github-issues, deps/auto-update-2026-05-15). Only main remains. dart analyze clean, flutter test 784/784 passing. | AgToosa |
| 2026-05-16 | /agtoosa-spec tasks — pruned dangling Active Task group S1-04 (GitHub #6 closed; story deferred until BL-12 staging URL lands). Active Tasks now matches empty Active Cycle. Spec file Docs/AgToosa_Spec-S1-04.md retained on disk as Draft for re-enrollment when ready. Cleared status finding 🔴 "Active Task group references S1-04 which is not in Active Cycle." | AgToosa |
| 2026-05-16 | /agtoosa-spec ×3 (parallel sub-agents in isolated worktrees) — 3 specs drafted, threat-modelled, and approved in one round-trip: (a) BL-19 sanitization + CI guard (7 ACs, 6 Must, 9 tasks — 5 already shipped in 2ba2c87, 4 CI-guard tasks remain) → spec-BL-19.md; (b) BL-04 Backend Leaderboard tech-design (12 ACs, 8 Must, 27 tasks across 8 groups, Firestore + Cloud Functions + App Check, Wave-1 has 6-way parallelism, hard dep on BL-03) → spec-BL-04.md; (c) BL-01+02 Platform Release Signing merged spec (10 ACs, 7 Must, 11 tasks: 7 automatable + 4 [manual], single combined story preferred over split) → spec-BL-01-BL-02-platform-signing.md. Active Cycle re-opened with BL-19 + BL-01+02; BL-04 kept in Backlog with spec ref + gate. Commits e79196c, 032e0c7, 8068517 cherry-picked from worktrees onto main. | AgToosa |
