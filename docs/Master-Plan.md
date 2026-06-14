# Master-Plan

> **Source of truth for active work.** Completed work lives in `Docs/archived/` — see Completed This Cycle for links.
> **Last updated:** 2026-06-14

## Project Charter

| Field | Value |
|-------|-------|
| Product | miToosa — cross-platform Flutter puzzle game (iOS launch focus for v1.5.0) |
| Goal | Ship v1.5.0 to the iPhone App Store with a validated free-first wedge and Firebase analytics |
| User outcome | Casual puzzle players get ADHD-optimized 3–5 minute sessions without sign-up friction; they understand the 25 free games/day + share bonus model |
| Success condition | App Store submission accepted; TestFlight QA passed on physical iPhone; D1 retention signal ≥40% from playtest; analytics events visible in Firebase DebugView |
| Proof / evidence | `flutter test` green (882 tests); `dart analyze` clean; `docs/LAUNCH.md` manual gates checked; Firebase session events in DebugView; archived BL-22 ship check |
| Non-goals | Android/macOS/Web store launch in v1.5.0; backend leaderboard; IAP/VIP; server sync; referral tiers (see `docs/PRODUCT-WEDGE.md`) |
| Assumptions | Apple Developer account and company formation proceed on owner timeline; Firebase + GA is the launch analytics stack; local-first Hive persistence remains canonical |
| Risks | External gates (company, App Store Connect, Firebase console) block ship; placeholder `firebase_options.dart` until `flutterfire configure`; physical-device QA not yet executed |
| Unresolved questions | Public privacy/support URL hosting; exact App Store review timeline; playtest recruitment post-TestFlight |
| GitHub repo | https://github.com/sky2464/miToosa |
| Milestone | v1.5.0 — iPhone App Store launch |
| Active cycle | Launch Sprint — iPhone readiness + UX polish (2026-06-02 → 2026-06-25) |
| Cycle capacity | 13 story points |
| Current phase | 🟨 Build — BL-23 FlutterFire iOS config (configure complete; DebugView manual pending) |

## Active Cycle

> Stories committed to the current sprint/cycle.
> **Progress:** `███▱▱▱▱▱▱▱ 3/6 tasks` _(BL-23 in progress)_

| ID | Title | Type | Estimate | Status | Tasks Done |
|----|-------|------|----------|--------|-----------|
| BL-23 | Chore: FlutterFire iOS config + verify DebugView | Chore | S | 🟨 In Progress | 3/6 |

Status key: ⬜ Backlog · 🟦 Todo · 🟨 In Progress · ✅ Done · 🚫 Blocked · 🔧 Awaiting Manual · 🏁 Shipped

## Active Tasks

> BL-23 — see `docs/AgToosa_Spec-BL-23-flutterfire-ios.md`

| Task | Status | Notes |
|------|--------|-------|
| 1.1 Ensure iOS app in Firebase `mitoosa-2121b` | ✅ Done | iOS app `dev.atoosa.mitoosa` registered via `flutterfire configure` |
| 1.2 Run `flutterfire configure` | ✅ Done | `mitoosa-2121b`; `firebase_options.dart` + local plist generated |
| 1.3 Confirm plist gitignored | ✅ Done | `ios/Runner/GoogleService-Info.plist` gitignored |
| 2.1 Update `firebase_options_test.dart` | ⬜ Todo | After 1.2 |
| 2.2 Update analytics docs | 🟨 In Progress | Project ID pinned in `docs/ANALYTICS-SETUP.md` |
| 2.3 Update launch readiness checkboxes | ⬜ Todo | After 1.2 |
| 3.1 analyze + test | ⬜ Todo | |
| 3.2 DebugView manual | 🔧 Awaiting Manual | After 1.2 + device run |

## Manual / Deferred Tasks

> Tasks that require a human action outside the agent. These are **not** counted against the health score.

| Story | Task # | Deferred Since | Description |
|-------|--------|----------------|-------------|
| BL-22 | — | 2026-06-03 | Register App ID `dev.atoosa.mitoosa` in Apple Developer |
| BL-22 | — | 2026-06-03 | Create Firebase project + iOS app; run `flutterfire configure` _(superseded by BL-23; project ID `mitoosa-2121b`)_ |
| BL-22 | — | 2026-06-03 | Publish privacy policy and support URLs |
| BL-22 | — | 2026-06-03 | Xcode Archive → TestFlight → App Store submit |
| BL-22 | — | 2026-06-03 | Physical iPhone QA (onboarding, gameplay, share, VoiceOver, offline) |
| EP-01 | — | 2026-05-04 | Company registration (see `docs/COMPANY-REGISTRATION-READINESS.md`) |

## Blocked

> **Status:** ✅ No blocked items

*(Empty — no blocked stories.)*

## Backlog

> Priority-ordered list of upcoming stories and issues.

| ID | Title | Type | Estimate | Epic | Priority | Status |
|----|-------|------|----------|------|----------|--------|
| BL-23 | Chore: App Store metadata + screenshots upload | Chore | M | EP-01 | P0 | ⬜ Backlog |
| BL-24 | Feature: Interactive How-To Demos | Feature | M | EP-04 | P1 | 🟦 Todo |
| BL-25 | Feature: Physical iPhone TestFlight QA pass | Feature | M | EP-01 | P0 | ⬜ Backlog |
| S1-03 | Feature: Manual wedge QA walkthrough | Feature | S | EP-01 | P1 | ⬜ Backlog |
| S1-04 | Feature: Playtest survey + recruitment | Feature | M | EP-01 | P1 | ⬜ Backlog |
| BL-04 | Feature: Backend leaderboard (post-playtest gate) | Feature | L | EP-03 | P2 | ⬜ Backlog |
| BL-05 | Feature: VIP / IAP flow | Feature | L | EP-03 | P2 | ⬜ Backlog |

## Epics

> Created at `/agtoosa-init`. One row per product area.

| ID | Title | Stories | Status |
|----|-------|---------|--------|
| EP-01 | Epic: Launch Readiness & Validation | 8 open / 14 total | 🟨 In Progress |
| EP-02 | Epic: Platform Release Infrastructure | 2 open / 4 total | 🟨 In Progress |
| EP-03 | Epic: Retention & Monetization Expansion | 5 open / 5 total | ⬜ Backlog |
| EP-04 | Epic: User Experience Polish | 1 open / 7 total | 🟨 In Progress |
| EP-05 | Epic: Technical Debt & Infrastructure | 0 open / 4 total | ✅ Mostly Done |

**EP-01 charter:** Prove product-market fit and ship v1.5.0 iPhone launch — staging/analytics where needed, playtest validation, launch docs, and App Store readiness. Success = TestFlight build accepted and wedge KPIs measurable.

**EP-02 charter:** Unblock signed release builds for iOS (primary) and deferred Android. Signing runbooks, bundle IDs, Firebase project wiring, TestFlight pipeline.

**EP-03 charter:** Post-validation monetization and social loops — leaderboard backend, referral tiers, VIP/IAP — gated on playtest metrics per `docs/PRODUCT-WEDGE.md`.

**EP-04 charter:** Aetheric Pulse design system polish — glassmorphism, navigation, tracks UI, accessibility, leaderboard demo UX.

**EP-05 charter:** CI/CD hygiene, dependency maintenance, doc archival, AgToosa framework upgrades.

## Active Diagnosis

*(Empty — no active diagnosis.)*

## Hypotheses

*(Empty — no active diagnosis.)*

## Completed This Cycle

| ID | Title | Shipped | Archived Spec |
|----|-------|---------|--------------|
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

> Older Update Log entries: [update-log-2026-05.md](archived/update-log-2026-05.md)

## Update Log

| Date | Event | By |
|------|-------|----|
| 2026-06-14 | /agtoosa-spec BL-24 — Spec drafted; `docs/archived/spec-BL-24.md` + test plan; 11 ACs (8 Must); estimate M; pending approval | AgToosa |
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
