# Spec: BL-29 — Free-Games Wedge Delivery

> **Story ID:** BL-29
> **Epic:** EP-01 Launch Readiness & Validation
> **Status:** 🏁 Shipped  
> **Estimate:** M
> **Clarity:** ready
> **Spec created:** 2026-07-14

## 1. Requirements

### 1.1 Goal Contract

| Field | Value |
|-------|-------|
| Goal | Deliver the canonical free-games allowance and daily share bonus as real player-facing gameplay behavior. |
| User outcome | Players understand that they receive 25 free games daily and can earn one +40-game share bonus, without misleading credits, energy, or paywall language. |
| Success condition | Starting an eligible game consumes exactly one free-game allowance; a depleted allowance blocks a new game with a native share CTA; a successful first share grants +40 games once per local day; all top-level surfaces say free games. |
| Proof / evidence | Pure-model and provider tests, widget tests for allowance and copy, mocked native-share tests, full flutter test, wedge checklist, and physical iPhone share smoke. |
| Non-goals | VIP/IAP implementation, ads, referral tiers, server authority, altering in-round hearts/diamonds, or edits to docs/PRODUCT-WEDGE.md. |
| Assumptions | The existing local PlayerProgress fields and persistence methods are the canonical allowance store; native share completion is advisory and local anti-abuse remains once per local calendar day. |
| Risks | Consuming at the wrong navigation point charges a player for cancellation; local clock manipulation can affect a local-first daily guard; share callbacks differ by platform. |
| Unresolved questions | None. The user selected the existing canonical wedge: 25 free games and +40 once daily. |

### 1.2 Brownfield Baseline

| Area | Current state | Intended delta |
|------|---------------|----------------|
| Allowance model | PlayerProgress and Hive persistence expose consumeFreeGame and grantShareBonus. | Wire both methods into a user-visible flow. |
| World map | Displays session/energy wording but does not consume allowance. | Display free games and route depletion to a share CTA. |
| Header and credits sheet | Expose CR, credits, bonus sessions, a future shop, and VIP. | Remove top-level credit framing and obsolete economy sheet. |
| Share | share_plus is declared but has no production call path. | Invoke native share through an injectable adapter and award once daily after success. |
| Hearts/diamonds | In-round hint/recovery mechanics exist. | Keep them contextual to gameplay; do not promote them to top-level allowance. |

### 1.3 User Stories

**As a** player, **I want** a clear free-games count before I start a puzzle **so that** I understand my daily access.

**As a** player with no free games left, **I want** one honest way to earn a daily share bonus **so that** I can continue without a forced paywall.

### 1.4 Acceptance Criteria (EARS)

| ID | EARS | Priority |
|----|------|----------|
| AC-001 | WHEN the player views any top-level game entry surface THE SYSTEM SHALL present the remaining allowance as free games, not energy, credits, CR, or bonus sessions. | Must |
| AC-002 | WHEN a player confirms the start of a playable game with available allowance THE SYSTEM SHALL atomically consume exactly one game before gameplay begins. | Must |
| AC-003 | WHEN a player cancels before gameplay begins THE SYSTEM SHALL NOT consume an allowance. | Must |
| AC-004 | WHEN no game allowance remains THE SYSTEM SHALL block a new game and present a share-for-40-games CTA without a paywall, ad, or VIP requirement. | Must |
| AC-005 | WHEN the native share flow reports success for the first time on a local calendar day THE SYSTEM SHALL grant exactly 40 additional games and persist the result. | Must |
| AC-006 | WHEN the player repeats a share on the same local calendar day THE SYSTEM SHALL NOT grant a second bonus and SHALL explain that the daily bonus is already claimed. | Must |
| AC-007 | WHEN currency copy is shown during gameplay THE SYSTEM SHALL keep hearts and diamonds limited to their in-round hint/recovery roles. | Should |

### 1.5 Out of Scope

- Changing the canonical wedge document or adding subscription/IAP products.
- Treating local share as server-verified referral attribution.
- Creating a backend, ad SDK, leaderboard, or cloud entitlement service.
- Altering puzzle scoring, heart rules, diamond rules, or daily streak reward amounts.
- Enrolling BL-29 before explicit approval.

### 1.6 Failure Modes

| AC | Failure mode | Mitigation |
|----|--------------|------------|
| AC-001 | Obsolete CR or energy strings survive in a secondary UI. | Widget/golden copy audit plus targeted source scan in test/review scope. |
| AC-002 | Game is consumed on a tap but player abandons a confirmation dialog. | Consume at final start command, not card selection or modal open. |
| AC-003 | Retry/rebuild consumes more than one game. | Persistence test asserts one idempotent mutation per start action. |
| AC-005 | Share result grants no bonus or grants more than 40. | Adapter/provider test validates success result and amount. |
| AC-006 | Date rollover or repeated callbacks give duplicate bonuses. | Reuse PlayerProgress daily guard and test same-day/next-day cases. |

## 2. Design

### 2.1 Architecture Blueprint

Files to create:

- lib/data/share_bonus_service.dart — narrow adapter around share_plus with a test fake.
- lib/features/progression/free_games_controller.dart — Riverpod-facing start and bonus orchestration; no engine imports.
- focused controller and widget tests under test/features/progression/ and test/widgets/.

Files to change:

- lib/features/navigation/world_map_screen.dart and track-detail entry flow — show free-games status and call the controller at final game start.
- lib/features/main_app/main_app_shell.dart and lib/widgets/app_header.dart — replace the credits top-level affordance with free-games status.
- lib/widgets/credits_menu_sheet.dart — remove or replace with a focused free-games information/share state; no shop/VIP copy.
- lib/features/settings/settings_screen.dart and lib/widgets/hearts_bar.dart — remove top-level share-for-heart or stale economy language; retain in-round heart behavior only.
- lib/data/player_progress_provider.dart and lib/data/hive_persistence_provider.dart — invalidate progress after successful allowance mutations if needed.
- Docs/AgToosa_TestPlan-BL-29.md — test evidence.

The feature layer owns action sequencing. PlayerProgress continues to own local mutation rules. The game engine remains pure and unaware of allowances or sharing.

### 2.2 Data Flow

1. A top-level screen watches PlayerProgress and renders total games available in free-games language.
2. At the final Start Game action, FreeGamesController reads current progress and calls consumeFreeGame with one logical now value.
3. A successful mutation invalidates progress and opens gameplay; failure opens the exhausted-allowance sheet.
4. The exhausted sheet calls ShareBonusService, which delegates to share_plus without exposing a share result as a truth claim in analytics.
5. On a successful platform result, the controller calls grantShareBonus with the same logical date and refreshes progress.
6. The UI shows the updated count or the once-per-day explanation.

### 2.3 Threat Model (STRIDE)

| Threat | Category | Mitigation |
|--------|----------|------------|
| Repeated taps or callbacks create duplicate allowance grants. | Tampering | Serialize controller actions and rely on persisted same-day guard. |
| Device date changes defeat local daily limits. | Tampering | Document local-first limitation; compare normalized local dates and avoid server-authority claims. |
| Share content leaks local progress or identifiers. | Information Disclosure | Share only static marketing copy and public app link; never include UUID, save data, or puzzle state. |
| A depleted state routes around the gate through another entry point. | Elevation of Privilege | Route all gameplay starts through one controller and cover representative entry paths. |
| Native share throws or returns unavailable. | Denial of Service | Keep the app responsive, show a retryable message, and do not consume/award games on failure. |

### 2.4 Build Scope

✅ Ready to proceed — Scope Boundary
Files in scope      : free-games controller/service, world map and track entry, app header/economy sheet, settings copy that describes share/VIP, progress persistence invalidation, focused tests, Docs/AgToosa_TestPlan-BL-29.md, Docs/Master-Plan.md
Directories in scope: lib/features/, lib/widgets/, lib/data/, test/features/, test/widgets/
Out of scope        : docs/PRODUCT-WEDGE.md, IAP, ads, backend/referrals, engine rule changes, active-cycle enrollment

## 3. Tasks

### 3.1 Task Tree

- [ ] **1. Contract tests:** Establish canonical wording and allowance mutation behavior.
  - [ ] 1.1 Add RED tests for free-games copy and obsolete top-level economy terms. — _Requirements: AC-001, AC-007_
  - [ ] 1.2 Add RED tests for consume, cancel, exhausted, success, duplicate, and next-day mutations. — _Requirements: AC-002, AC-003, AC-004, AC-005, AC-006_
- [ ] **2. Orchestration:** Build one controller and native-share adapter.
  - [ ] 2.1 Add an injectable ShareBonusService and platform-result mapping. — _Requirements: AC-005, AC-006_
  - [ ] 2.2 Add FreeGamesController with serialized start/share commands. — _Requirements: AC-002, AC-003, AC-004, AC-005, AC-006_
- [ ] **3. Player surfaces:** Replace obsolete economy views and wire all start paths.
  - [ ] 3.1 Wire final game start through the controller. — _Requirements: AC-002, AC-003, AC-004_
  - [ ] 3.2 Replace header, world-map, settings, and sheet copy with canonical free-games language. — _Requirements: AC-001, AC-007_
  - [ ] 3.3 Implement depleted-share and already-claimed states. — _Requirements: AC-004, AC-005, AC-006_
- [ ] **4. Verification:** Prove the release wedge end to end.
  - [ ] 4.1 Add widget/controller coverage and wedge checklist evidence. — _Requirements: AC-001 through AC-007_
  - [ ] 4.2 Run dart analyze, flutter test, and the wedge copy audit. — _Requirements: AC-001 through AC-007_
  - [ ] 4.3 Run native share once/repeat iPhone smoke. — _Requirements: AC-005, AC-006_ [manual]

### 3.2 Wave Plan

**Wave 1 (parallel):** 1.1, 1.2
**Wave 2 (sequential after Wave 1):** 2.1, 2.2
**Wave 3 (parallel after Wave 2):** 3.1, 3.2
**Wave 4 (sequential after Wave 3):** 3.3, 4.1
**Wave 5 (sequential after Wave 4):** 4.2, 4.3

### 3.3 Test Plan

Test plan: Docs/AgToosa_TestPlan-BL-29.md
AC coverage: 7 ACs mapped to 7 test IDs
Smoke set: T-001, T-002, T-004, T-005, T-006

### 3.4 Work Package DAG

| package_id | wave | depends_on | owned_files | inputs | outputs | merge_order | verification |
|------------|------|------------|-------------|--------|---------|-------------|--------------|
| PKG-1.1 | 1 | — | controller/widget tests | wedge contract | RED copy and mutation tests | 1 | focused flutter test |
| PKG-2.1 | 2 | PKG-1.1 | share_bonus_service.dart | share_plus API | injectable share adapter | 2 | focused flutter test |
| PKG-2.2 | 2 | PKG-1.1, PKG-2.1 | free_games_controller.dart | persistence contract | atomic commands | 3 | focused flutter test |
| PKG-3.1 | 3 | PKG-2.2 | navigation and header widgets | controller | live allowance UI | 4 | focused widget tests |
| PKG-3.2 | 3 | PKG-2.2 | settings/economy widgets | controller | truthful depleted states | 5 | focused widget tests |
| PKG-4.1 | 4 | PKG-3.1, PKG-3.2 | tests and test plan | integrated UI | GREEN evidence | 6 | dart analyze lib test && flutter test |

### 3.5 Story Skill Opportunity Synthesis

No new project skill is proposed. The existing wedge-economy-auditor covers copy review; the implementation is bounded Flutter feature work.

### 3.6 Spec Quality Analyzer

| Check | Result |
|-------|--------|
| All Must ACs map to deterministic unit, provider, or widget tests. | Pass |
| Wedge language is constrained by the unedited canonical document. | Pass |
| Local time and share-result limitations are explicit. | Pass |
| No VIP, ad, or backend implementation is smuggled into scope. | Pass |

## ✅ Spec Approved

Approved: 2026-07-26 14:03
