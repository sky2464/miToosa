# Master-Plan

> **Source of truth for active work.** Completed work lives in `Docs/archived/` — see Completed This Cycle for links.
> **Last updated:** 2026-07-12 (/agtoosa-spec BL-25)

## Project Charter

| Field | Value |
|-------|-------|
| Product | miToosa — cross-platform Flutter puzzle game (iOS launch focus for v1.5.0) |
| Goal | Ship v1.5.1 to the iPhone App Store with a validated free-first wedge and Firebase analytics |
| User outcome | Casual puzzle players get ADHD-optimized 3–5 minute sessions without sign-up friction; they understand the 25 free games/day + share bonus model |
| Success condition | App Store submission accepted; TestFlight QA passed on physical iPhone; D1 retention signal ≥40% from playtest; analytics events visible in Firebase DebugView |
| Proof / evidence | `flutter test` green (892 tests); `dart analyze` clean on lib/test; BL-26 metadata/docs guards shipped; BL-23 FlutterFire shipped; T-005 DebugView manual pending |
| Non-goals | Android/macOS/Web store launch in v1.5.0; backend leaderboard; IAP/VIP; server sync; referral tiers (see `docs/PRODUCT-WEDGE.md`) |
| Assumptions | Apple Developer account and company formation proceed on owner timeline; Firebase + GA is the launch analytics stack; local-first Hive persistence remains canonical |
| Risks | External gates (company, App Store Connect, Firebase console) block store release; physical-device QA not yet executed |
| Unresolved questions | Public privacy/support URL hosting; exact App Store review timeline; playtest recruitment post-TestFlight |
| GitHub repo | https://github.com/sky2464/miToosa |
| Milestone | v1.5.1 (next) — iPhone App Store launch |
| Active cycle | Launch Sprint — iPhone readiness + UX polish (2026-06-02 → 2026-06-25) |
| Cycle capacity | 13 story points |
| Current phase | 🟦 Spec — BL-25 enrolled Active Cycle; awaiting approval |

## Active Cycle

> Stories committed to the current sprint/cycle.

| ID | Title | Type | Estimate | Status | Tasks Done |
|----|-------|------|----------|--------|-----------|
| BL-25 | Feature: Physical iPhone TestFlight QA pass | Feature | M | 🟦 Todo | 0/5 |

Status key: ⬜ Backlog · 🟦 Todo · 🟨 In Progress · ✅ Done · 🚫 Blocked · 🔧 Awaiting Manual · 🏁 Shipped

## Active Tasks

### BL-25 — Physical iPhone TestFlight QA pass

- [ ] **1.** QA documentation: TestFlight checklist + evidence template
  - [ ] 1.1 Create `docs/qa/iphone-testflight-qa-checklist.md` — _Requirements: AC-001_
  - [ ] 1.2 Create `docs/qa/iphone-testflight-evidence-template.md` — _Requirements: AC-002_
  - [ ] 1.3 Cross-link from `IPHONE-LAUNCH-READINESS.md`, `LAUNCH.md`, `wedge-qa-checklist.md` — _Requirements: AC-001, AC-012_
- [ ] **2.** Automated guards
  - [ ] 2.1 Extend `test/release/iphone_launch_readiness_test.dart` — _Requirements: AC-012_
  - [ ] 2.2 Run `dart analyze lib test` and `flutter test` — _Requirements: AC-012_
- [ ] **3.** Manual TestFlight QA execution (physical iPhone)
  - [ ] 3.1 Install TestFlight build on physical iPhone — _Requirements: AC-003_ `[manual-deferred]`
  - [ ] 3.2 Cold launch + onboarding; time-to-first-game ≤60s — _Requirements: AC-003, AC-004, AC-015_ `[manual-deferred]`
  - [ ] 3.3 Complete full 3-round gameplay session — _Requirements: AC-005_ `[manual-deferred]`
  - [ ] 3.4 Share flow: +40 once; second share denied — _Requirements: AC-006_ `[manual-deferred]`
  - [ ] 3.5 Offline mode gameplay + relaunch — _Requirements: AC-007_ `[manual-deferred]`
  - [ ] 3.6 VoiceOver smoke + Dynamic Type largest — _Requirements: AC-008, AC-013_ `[manual-deferred]`
  - [ ] 3.7 Wedge copy walkthrough — _Requirements: AC-009_ `[manual-deferred]`
  - [ ] 3.8 Force-quit persistence check — _Requirements: AC-011_ `[manual-deferred]`
  - [ ] 3.9 Settings/support link scan — _Requirements: AC-014_ `[manual-deferred]`
- [ ] **4.** Analytics verification
  - [ ] 4.1 Firebase DebugView spot-check (`FIREBASE_ENABLED=true`) — _Requirements: AC-010_ `[manual-deferred]`
- [ ] **5.** Evidence closure
  - [ ] 5.1 Complete dated evidence file; gate log in `RELEASE-GATES.md` — _Requirements: AC-002, AC-003–AC-011_ `[manual-deferred]`
  - [ ] 5.2 Mark Physical iPhone QA complete in launch docs + Master-Plan — _Requirements: AC-003–AC-011_ `[manual-deferred]`

## Manual / Deferred Tasks

> Tasks that require a human action outside the agent. These are **not** counted against the health score.

| Story | Task # | Deferred Since | Description |
|-------|--------|----------------|-------------|
| BL-26 | 4.1 | 2026-07-11 | Publish Privacy Policy + Support URLs and paste finals into ASC/metadata |
| BL-26 | 4.2 | 2026-07-11 | Capture iPhone screenshots per checklist and upload in App Store Connect |
| BL-22 | — | 2026-06-03 | Register App ID `dev.atoosa.mitoosa` in Apple Developer |
| BL-22 | — | 2026-06-03 | Create Firebase project + iOS app; run `flutterfire configure` _(superseded by BL-23; project ID `mitoosa-2121b`)_ |
| BL-22 | — | 2026-06-03 | Publish privacy policy and support URLs |
| BL-22 | — | 2026-06-03 | Xcode Archive → TestFlight → App Store submit |
| BL-22 | — | 2026-06-03 | Physical iPhone QA (onboarding, gameplay, share, VoiceOver, offline) |
| EP-01 | — | 2026-05-04 | Company registration (see `docs/COMPANY-REGISTRATION-READINESS.md`) |
| BL-23 | 3.2 | 2026-06-19 | Manual DebugView verification after physical device/simulator run with `FIREBASE_ENABLED=true` |

## Blocked

> **Status:** ✅ No blocked items

*(Empty — no blocked stories.)*

## Backlog

> Priority-ordered list of upcoming stories and issues.

| ID | Title | Type | Estimate | Epic | Priority | Status |
|----|-------|------|----------|------|----------|--------|
| BL-24 | Feature: Interactive how-to demos | Feature | M | EP-01 | P1 | ⬜ Backlog |
| S1-03 | Feature: Manual wedge QA walkthrough | Feature | S | EP-01 | P1 | ⬜ Backlog |
| S1-04 | Feature: Playtest survey + recruitment | Feature | M | EP-01 | P1 | ⬜ Backlog |
| BL-04 | Feature: Backend leaderboard (post-playtest gate) | Feature | L | EP-03 | P2 | ⬜ Backlog |
| BL-05 | Feature: VIP / IAP flow | Feature | L | EP-03 | P2 | ⬜ Backlog |
| DX-01 | Chore: Complete gstack `/plan-tune` QA + ship docs | Chore | XS | EP-05 | P4 | ⬜ Backlog |
| LP-01 | Chore: Local network QR play (deferred POC) | Chore | L | EP-05 | P3 | ⬜ Backlog |

## Epics

> Created at `/agtoosa-init`. One row per product area.

| ID | Title | Stories | Status |
|----|-------|---------|--------|
| EP-01 | Epic: Launch Readiness & Validation | 5 open / 16 total | 🟨 In Progress |
| EP-02 | Epic: Platform Release Infrastructure | 0 open / 4 total | 🟨 In Progress |
| EP-03 | Epic: Retention & Monetization Expansion | 2 open / 5 total | ⬜ Backlog |
| EP-04 | Epic: User Experience Polish | 0 open / 6 total | ✅ Mostly Done |
| EP-05 | Epic: Technical Debt & Infrastructure | 2 open / 7 total | 🟨 In Progress |

**EP-01 charter:** Prove product-market fit and ship v1.5.1 iPhone launch — staging/analytics where needed, playtest validation, launch docs, and App Store readiness. Success = TestFlight build accepted and wedge KPIs measurable.

**EP-02 charter:** Unblock signed release builds for iOS (primary) and deferred Android. Signing runbooks, bundle IDs, Firebase project wiring, TestFlight pipeline.

**EP-03 charter:** Post-validation monetization and social loops — leaderboard backend (BL-04), VIP/IAP (BL-05), referral tiers (charter only — backlog story TBD) — gated on playtest metrics per `docs/PRODUCT-WEDGE.md`.

**EP-04 charter:** Aetheric Pulse design system polish — glassmorphism, navigation, tracks UI, accessibility, leaderboard demo UX.

**EP-05 charter:** CI/CD hygiene, dependency maintenance, doc archival, AgToosa framework upgrades. Local multiplayer POC (`lib/features/local_play/`) tracked as deferred experimentation — not v1.5.1 launch scope.

## Active Diagnosis

*(Empty — no active diagnosis.)*

## Hypotheses

*(Empty — no active diagnosis.)*

## Completed This Cycle

| ID | Title | Shipped | Archived Spec |
|----|-------|---------|--------------|
| BL-26 | Chore: App Store metadata + screenshots prep | 2026-07-11 | [spec-BL-26.md](archived/spec-BL-26.md) |
| BL-23 | Chore: FlutterFire iOS config + verify DebugView | 2026-06-20 | [spec-BL-23.md](archived/spec-BL-23.md) |
| S2-05 | Feature: Tracks UI fixes (theme-aware glass, header menus) | 2026-06-11 | [spec-S2-05.md](archived/spec-S2-05.md) |
| BL-22 | Chore: iPhone launch readiness prep (docs, bundle ID, Firebase scaffold) | 2026-06-03 | [spec-BL-22.md](archived/spec-BL-22.md) |
| S1-01 | Feature: Staging deployment & QA gate | 2026-05-11 | [spec-S1-01.md](archived/spec-S1-01.md) |
| S1-02 | Feature: Analytics backend integration (Firebase scaffold) | 2026-05-11 | [spec-s1-02.md](archived/spec-s1-02.md) |
| S1-05 | Chore: Doc cleanup & archive hygiene | 2026-05-04 | [spec-cleanup-001.md](archived/spec-cleanup-001.md) |
| S2-01 | Feature: Leaderboard screen (demo data) | 2026-05-15 | [spec-S2-01.md](archived/spec-S2-01.md) |
| S2-02 | Feature: VIP card UI (non-functional upgrade) | 2026-05-15 | [spec-S2-02.md](archived/spec-S2-02.md) |
| S2-03 | Feature: Settings & profile polish | 2026-05-15 | [spec-S2-03.md](archived/spec-S2-03.md) |
| S2-04 | Feature: Navigation & shell polish | 2026-05-15 | [spec-S2-04.md](archived/spec-S2-04.md) |
| BL-01 | Chore: iOS signing setup | 2026-05-15 | [spec-BL-01-BL-02-platform-signing.md](archived/spec-BL-01-BL-02-platform-signing.md) |
| BL-21 | Chore: Remove expensive CI/CD workflows | 2026-05-15 | [spec-BL-21.md](archived/spec-BL-21.md) |
| BL-19 | Chore: Sanitize embedded prompt-injection text in design-system docs | 2026-05-16 | [spec-BL-19.md](archived/spec-BL-19.md) |
| AP-01 | Feature: Aetheric Pulse Dark redesign | 2026-04-22 | [spec-aetheric-pulse-redesign.md](archived/spec-aetheric-pulse-redesign.md) |
| LR-01 | Chore: Launch readiness LAUNCH.md closeout | 2026-04-17 | [spec-launch-readiness-v1.md](archived/spec-launch-readiness-v1.md) |
| EL-01 | Feature: Engagement loop (hearts, hints, stars, run timer) | 2026-04-17 | [spec-engagement-loop-v1.md](archived/spec-engagement-loop-v1.md) |
| LT-01 | Feature: Local telemetry collection v1 | 2026-04-17 | [spec-local-telemetry-collection-v1.md](archived/spec-local-telemetry-collection-v1.md) |
| DM-01 | Chore: Dependency & skill maintenance system | 2026-04-15 | [spec-dependency-skill-maintenance-v1.md](archived/spec-dependency-skill-maintenance-v1.md) |
| IT-01 | Feature: iToosa → miToosa feature migration v1 | 2025-07-24 | [spec-itoosa-feature-migration-v1.md](archived/spec-itoosa-feature-migration-v1.md) |

> Older Update Log entries: [update-log-2026-05.md](archived/update-log-2026-05.md)

## Update Log

| Date | Event | By |
|------|-------|----|
| 2026-07-12 | /agtoosa-spec BL-25 — Spec drafted; enrolled Active Cycle; awaiting approval | AgToosa |
| 2026-07-12 | /agtoosa-task — Reconciled 7 orphaned historical specs + BL-23 duplicate cleanup | AgToosa |
| 2026-07-11 | /agtoosa-ship — Ship 🚀 repo ship PASS — BL-26 — readiness tests 10/10; spec archived; URL publish + ASC screenshots manual-deferred | AgToosa |
| 2026-07-11 | /agtoosa-review — Review ✅ Approved — BL-26 — 0 critical, 8 warnings; `docs/archived/review-BL-26.md` | AgToosa |
| 2026-07-11 | /agtoosa-review — Review 🔍 Started — BL-26 — 4-persona review running | AgToosa |
| 2026-07-11 | /agtoosa-build BL-26 — Build ✅ complete — 7/7 automated tasks; 892 tests green; `dart analyze lib test` clean; 2 manual-deferred (URL publish, ASC screenshots); status → Awaiting Manual | AgToosa |
| 2026-07-11 | /agtoosa-build BL-26 — Build 🏗️ Started — 7 automated tasks; scope: privacy, support, metadata, launch docs, readiness tests | AgToosa |
| 2026-07-11 | /agtoosa-init — Phase E ✅ — 4 specialists approved and materialized: flutter-engine-guard, wedge-economy-auditor, iphone-launch-gate, hive-schema-guard → `docs/Context/specialists.md` | AgToosa |
| 2026-07-11 | /agtoosa-init — Init ✅ full refresh (option B) — codebase scan; Master-Architecture v2026-07-11; epics reconciled; 887 tests / schema v7 / Firebase iOS wired; Phases E–G pending approval | AgToosa |
| 2026-07-11 | /agtoosa-spec BL-26 — Spec ✅ Approved — `docs/archived/spec-BL-26.md`; estimate M; enrolled in Active Cycle | User |
| 2026-07-11 | /agtoosa-spec BL-26 — Spec drafted (quick); renumbered backlog metadata from BL-23→BL-26; enrolled Active Cycle; awaiting approval | AgToosa |
| 2026-06-20 | /agtoosa-ship — Ship 🚀 repo ship PASS — BL-23 — smoke 3/3; spec archived; T-005 DebugView manual-deferred | AgToosa |
| 2026-06-20 | /agtoosa-build BL-23 — Tasks 🟢 2.2, 2.3, 3.1 complete; 887 tests green; `@smoke` tags; ink_sparkle widget-test fix | AgToosa |
| 2026-06-20 | /agtoosa-review BL-23 — Review ✅ Approved — 0 critical, 5 warnings; `docs/archived/review-BL-23.md` | AgToosa |
| 2026-06-20 | /agtoosa-review BL-23 — Review 🔍 Started — 4-persona review | AgToosa |
| 2026-06-19 | /agtoosa-status follow-up — Reconciled BL-23 task tree/counter, added Wave Plan, aligned v1.5.0 changelog parity, and re-tracked DX-01/BL-19 source-of-truth entries | AgToosa |
| 2026-06-14 | /agtoosa-spec BL-24 — Spec drafted; `docs/archived/spec-BL-24.md` + test plan + ADRs; 7 ACs (6 Must); estimate M; backlog only; pending approval | AgToosa |
| 2026-06-14 | /agtoosa-build BL-23 — Firebase CLI reauth OK; `flutterfire configure` complete; `firebase_options_test.dart` updated (4 tests green) | AgToosa |
| 2026-06-11 | /agtoosa-build BL-23 — Build 🏗️ Started; spec approved; blocked on `firebase login --reauth` for `flutterfire configure` | AgToosa |
| 2026-06-11 | /agtoosa-spec BL-23 — Spec ✅ approved; `docs/AgToosa_Spec-BL-23-flutterfire-ios.md` + test plan | AgToosa |
| 2026-06-11 | /agtoosa-ship S2-05 — Ship 🚀 repo ship PASS; spec archived; manual iOS deploy deferred | AgToosa |
| 2026-06-11 | /agtoosa-review S2-05 — Review ✅ Approved — 0 critical, 7 warnings; `docs/archived/review-S2-05.md` | AgToosa |
| 2026-06-11 | /agtoosa-review S2-05 — Review 🔍 Started — 4-persona review | AgToosa |
| 2026-06-11 | /agtoosa-init re-run — Master-Plan repopulated after AgToosa v5.3.0 template reset; Master-Architecture refreshed; context confirmed; 882 tests passing | AgToosa |
| 2026-06-03 | /agtoosa-ship BL-22 — iPhone launch readiness docs/config shipped; manual App Store gates deferred | AgToosa |
| 2026-05-15 | /agtoosa-ship compaction — update log archived to `archived/update-log-2026-05.md` | AgToosa |
| 2026-05-04 | /agtoosa-init — initialization complete; context files populated, Epics seeded, TDD enabled | AgToosa |
