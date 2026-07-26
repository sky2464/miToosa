# Spec: BL-35 — Reachable Daily Rewards, Streaks, and Achievements

> **Story ID:** BL-35
> **Epic:** EP-01 Launch Readiness & Validation
> **Status:** ⬜ Backlog
> **Estimate:** M
> **Clarity:** ready
> **Spec created:** 2026-07-14

## 1. Requirements

### 1.1 Goal Contract

| Field | Value |
|-------|-------|
| Goal | Make the existing daily reward, streak calendar, and achievements systems reachable through normal player flow. |
| User outcome | Players can claim an earned daily reward, understand their streak, and review achievements without discovering hidden/dead screens. |
| Success condition | Eligible players see or can reach daily rewards from a normal post-onboarding surface; a daily claim persists once per local day; Progress contains accessible routes to streak and achievement detail; browsing does not mutate rewards or progress. |
| Proof / evidence | Model/controller tests, widget navigation tests, accessibility checks, dart analyze, flutter test, and physical iPhone daily-reward/streak smoke. |
| Non-goals | Push notifications, new reward amounts, referral tiers, VIP/IAP, backend challenges, or a change to docs/PRODUCT-WEDGE.md. |
| Assumptions | Existing PlayerProgress daily/streak/achievement fields and UI screens are the starting point; BL-28 has established an onboarding gate before engagement prompts. |
| Risks | A modal can interrupt onboarding/gameplay or claim twice after rebuild; stale progress state can present incorrect reward availability. |
| Unresolved questions | None. The user approved the recommended normal-flow wiring. |

### 1.2 Brownfield Baseline

| Area | Current state | Intended delta |
|------|---------------|----------------|
| Daily rewards | DailyRewardsModal exists but has no production entry point. | Surface it after onboarding with a persistent Progress entry point. |
| Streak details | StreakCalendarScreen exists but is not reachable in normal navigation. | Add a clear route from Progress/streak summary. |
| Achievements | AchievementsScreen exists but is not reachable in normal navigation. | Add a clear route from Progress/achievement summary. |
| Persistence | PlayerProgress has daily claim and streak fields. | Use existing mutation behavior through an explicit controller. |

### 1.3 User Stories

**As a** returning player, **I want** to claim a daily reward when I earn it **so that** I feel a reason to return without hunting for a hidden screen.

**As a** player, **I want** to open my streak and achievements from Progress **so that** my recent effort is visible and understandable.

### 1.4 Acceptance Criteria (EARS)

| ID | EARS | Priority |
|----|------|----------|
| AC-001 | WHEN an onboarded player opens the app with an unclaimed daily reward THE SYSTEM SHALL offer a reachable daily-reward surface without interrupting onboarding or an active puzzle. | Must |
| AC-002 | WHEN a player claims an available daily reward THE SYSTEM SHALL persist one claim for the local calendar day and refresh visible progress. | Must |
| AC-003 | WHEN the daily reward has already been claimed for the local calendar day THE SYSTEM SHALL show the next-availability state and SHALL NOT grant a duplicate reward. | Must |
| AC-004 | WHEN a player views Progress THE SYSTEM SHALL provide reachable labeled routes to streak-calendar and achievements detail. | Must |
| AC-005 | WHEN a player opens or dismisses engagement detail THE SYSTEM SHALL NOT mutate reward, streak, XP, currency, or achievement state without an explicit claim/action. | Must |
| AC-006 | WHEN engagement surfaces render THE SYSTEM SHALL meet semantic-label, 44pt target, portrait, Dynamic Type, and reduced-motion requirements. | Should |

### 1.5 Out of Scope

- Notifications/reminders, deep links, server-scheduled rewards, new currencies, and social/leaderboard rewards.
- Changes to reward calculations, streak milestone amounts, hearts/diamonds, or free-games allowance.
- A redesign of the Progress screen beyond routes/cards needed to make existing systems usable.
- In-app tutorial content (BL-24) and onboarding root routing (BL-28).

### 1.6 Failure Modes

| AC | Failure mode | Mitigation |
|----|--------------|------------|
| AC-001 | Modal appears over onboarding or a live puzzle. | Gate auto-prompt on completed onboarding and idle shell state. |
| AC-002 | Two rebuilds claim the reward twice. | Serialize claim controller and prove persisted same-day guard. |
| AC-003 | UI still offers claim after reload. | Cold-load test after claim with deterministic date. |
| AC-004 | Detail screens are hidden behind inaccessible or unlabeled targets. | Widget semantics and navigation tests. |
| AC-005 | Viewing a calendar triggers login/claim mutation. | Snapshot progress before and after route opens. |

## 2. Design

### 2.1 Architecture Blueprint

Files to create:

- lib/features/engagement/daily_reward_controller.dart — one controller for availability/claim state and a fakeable clock.
- focused tests under test/features/engagement/.

Files to change:

- lib/features/main_app/main_app_shell.dart or an idle-shell coordinator — present a pending reward only after onboarding is complete.
- lib/features/main_app/progress_screen.dart — add explicit streak and achievements navigation affordances plus daily-reward entry state.
- lib/features/daily_rewards/daily_rewards_modal.dart — accept controller state/callbacks and safe unavailable state.
- lib/features/streak/streak_calendar_screen.dart and lib/features/achievements/achievements_screen.dart — add semantics/return behavior only as required.
- lib/data/player_progress_provider.dart and persistence provider — expose/refresh existing claim mutation without changing reward rules.
- Docs/AgToosa_TestPlan-BL-35.md — test evidence.

### 2.2 Data Flow

1. After BL-28 onboarding is complete, the idle app shell reads current PlayerProgress and a clock-normalized daily-reward availability.
2. If available, it offers the reward surface once per app session; Progress always exposes a later entry point.
3. Claim action calls DailyRewardController, which uses persisted mutation and refreshes PlayerProgress.
4. The modal presents claimed/unavailable state after refresh.
5. Progress routes to streak and achievement detail without calling mutation methods.

### 2.3 Threat Model (STRIDE)

| Threat | Category | Mitigation |
|--------|----------|------------|
| Double-tap/rebuild gives multiple rewards. | Tampering | Single in-flight claim command plus existing persisted daily guard. |
| Device time manipulation changes eligibility. | Tampering | Normalize one local date per command and document local-first limitation. |
| Auto-prompt disrupts active gameplay. | Denial of Service | Present only from idle shell after onboarding and never from GameplayScreen. |
| Engagement route exposes data from another player. | Information Disclosure | Read current local player ID only; no new network/user input. |

### 2.4 Build Scope

✅ Ready to proceed — Scope Boundary
Files in scope      : engagement controller, shell/progress routing, daily reward/streak/achievement screens as needed, existing progress persistence/provider integration, focused tests, Docs/AgToosa_TestPlan-BL-35.md, Docs/Master-Plan.md
Directories in scope: lib/features/engagement/, lib/features/main_app/, lib/features/daily_rewards/, lib/features/streak/, lib/features/achievements/, lib/data/, test/features/engagement/
Out of scope        : notification/reminder system, reward values, free-games economics, backend, active-cycle enrollment

## 3. Tasks

### 3.1 Task Tree

- [ ] **1. Engagement behavior tests:** Lock availability, idempotency, and no-mutation browsing.
  - [ ] 1.1 Add RED availability/claim/relaunch tests with deterministic dates. — _Requirements: AC-001, AC-002, AC-003_
  - [ ] 1.2 Add RED Progress-route and no-mutation detail tests. — _Requirements: AC-004, AC-005, AC-006_
- [ ] **2. Daily reward flow:** Add one coordinated entry/claim path.
  - [ ] 2.1 Add DailyRewardController with fakeable clock and in-flight guard. — _Requirements: AC-002, AC-003_
  - [ ] 2.2 Gate idle-shell offer after onboarding and expose a Progress entry point. — _Requirements: AC-001, AC-003_
  - [ ] 2.3 Wire modal states and progress refresh. — _Requirements: AC-002, AC-003_
- [ ] **3. Detail navigation:** Make existing systems discoverable.
  - [ ] 3.1 Add labeled streak and achievement affordances to Progress. — _Requirements: AC-004, AC-006_
  - [ ] 3.2 Add no-mutation/accessibility regression coverage. — _Requirements: AC-005, AC-006_
- [ ] **4. Verification:** Prove normal player flow.
  - [ ] 4.1 Run dart analyze and flutter test. — _Requirements: AC-001 through AC-006_
  - [ ] 4.2 Run iPhone daily reward, streak, and achievement smoke. — _Requirements: AC-001, AC-002, AC-004, AC-006_ [manual]

### 3.2 Wave Plan

**Wave 1 (parallel):** 1.1, 1.2
**Wave 2 (sequential after Wave 1):** 2.1, 2.2
**Wave 3 (parallel after Wave 2):** 2.3, 3.1
**Wave 4 (sequential after Wave 3):** 3.2, 4.1, 4.2

### 3.3 Test Plan

Test plan: Docs/AgToosa_TestPlan-BL-35.md
AC coverage: 6 ACs mapped to 6 test IDs
Smoke set: T-001, T-002, T-003, T-004

### 3.4 Work Package DAG

| package_id | wave | depends_on | owned_files | inputs | outputs | merge_order | verification |
|------------|------|------------|-------------|--------|---------|-------------|--------------|
| PKG-1.1 | 1 | — | engagement tests | PlayerProgress behavior | RED claim suite | 1 | focused flutter test |
| PKG-1.2 | 1 | — | Progress widget tests | existing detail screens | RED navigation suite | 2 | focused flutter test |
| PKG-2.1 | 2 | PKG-1.1 | daily_reward_controller.dart | persistence/clock | idempotent commands | 3 | focused flutter test |
| PKG-2.2 | 2 | PKG-2.1 | shell/progress/modal | controller state | reachable daily flow | 4 | focused widget test |
| PKG-3.1 | 3 | PKG-1.2, PKG-2.2 | Progress/detail screens | route contract | accessible detail paths | 5 | focused widget test |
| PKG-4.1 | 4 | PKG-3.1 | tests/test plan | integrated flow | GREEN evidence | 6 | dart analyze lib test && flutter test |

### 3.5 Story Skill Opportunity Synthesis

No new project skill is proposed. The existing wedge-economy-auditor remains applicable at review for player-facing reward copy, while the implementation is ordinary Flutter flow work.

### 3.6 Spec Quality Analyzer

| Check | Result |
|-------|--------|
| Existing systems are wired without silently redefining rewards. | Pass |
| Claim idempotency and non-mutating browsing are testable. | Pass |
| Onboarding and gameplay interruption boundaries are explicit. | Pass |
| All Must ACs map to tests. | Pass |
