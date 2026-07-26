# Spec: BL-28 — First-Run Onboarding Gate

> **Story ID:** BL-28
> **Epic:** EP-01 Launch Readiness & Validation
> **Status:** 🏁 Shipped — repo 2026-07-26 (T-006 iPhone smoke manual-deferred)
> **Estimate:** S
> **Clarity:** ready
> **Spec created:** 2026-07-14

## 1. Requirements

### 1.1 Goal Contract

| Field | Value |
|-------|-------|
| Goal | Route every fresh anonymous player through onboarding before the main application shell. |
| User outcome | A first-time player understands the game and reaches a first playable track without a hidden or bypassed introduction. |
| Success condition | A fresh persisted progress record with onboardingComplete false renders onboarding; a completed record renders the main shell; authentication loading and error states remain deterministic. |
| Proof / evidence | Focused widget tests for fresh, completed, loading, and error routing; full flutter test; dart analyze; physical iPhone fresh-install smoke. |
| Non-goals | Rewriting onboarding content, adding account sign-in, changing tutorial behavior beyond the existing BL-24 dependency, or changing game progression. |
| Assumptions | Anonymous authentication remains the source of a local player ID; onboarding completion stays in encrypted PlayerProgress. |
| Risks | Root routing can flash the wrong screen while providers load or run onboarding twice after relaunch. |
| Unresolved questions | None. The user accepted the recommended launch posture. |

### 1.2 Brownfield Baseline

| Area | Current state | Intended delta |
|------|---------------|----------------|
| Root routing | main.dart routes any nonempty anonymous ID directly to MainAppShell. | Route by both authentication and persisted onboarding state. |
| Anonymous auth | auth_provider.dart creates an ID automatically. | Preserve behavior; it must not imply onboarding completion. |
| Onboarding | LoginScreen owns a needsOnboarding branch. | Extract or reuse the branch behind one root-state decision so it cannot be bypassed. |
| Persistence | PlayerProgress stores onboardingComplete and marks it complete. | Preserve field and migration behavior. |

### 1.3 User Stories

**As a** first-time player, **I want** onboarding to appear before the game shell **so that** I know how to begin.

**As a** returning player, **I want** to resume directly into the game after completing onboarding **so that** startup stays fast.

### 1.4 Acceptance Criteria (EARS)

| ID | EARS | Priority |
|----|------|----------|
| AC-001 | WHEN anonymous authentication resolves for a player whose onboardingComplete is false THE SYSTEM SHALL render onboarding before MainAppShell. | Must |
| AC-002 | WHEN anonymous authentication resolves for a player whose onboardingComplete is true THE SYSTEM SHALL render MainAppShell without showing onboarding. | Must |
| AC-003 | WHEN onboarding completion is persisted THE SYSTEM SHALL update root routing to MainAppShell without requiring an app restart. | Must |
| AC-004 | WHILE authentication or progress data is loading THE SYSTEM SHALL show a deterministic non-interactive loading state and SHALL NOT flash MainAppShell. | Must |
| AC-005 | WHEN authentication or progress loading fails THE SYSTEM SHALL show a recoverable error state with retry rather than silently treating the player as onboarded. | Must |
| AC-006 | WHEN a fresh install is launched on iPhone THE SYSTEM SHALL reach the first playable track through onboarding in 60 seconds or less under normal local startup conditions. | Should |

### 1.5 Out of Scope

- New tutorial/demo content; BL-24 remains the companion story for per-track help.
- Account recovery, cloud synchronization, login-provider UI, or analytics changes.
- Changes to PlayerProgress field numbers or Hive schema.

### 1.6 Failure Modes

| AC | Failure mode | Mitigation |
|----|--------------|------------|
| AC-001 | Auto-created UUID bypasses onboarding. | Root-widget test injects a nonempty ID and false progress state. |
| AC-002 | Returning players are trapped in onboarding. | Completion-state test asserts MainAppShell is the only destination. |
| AC-003 | Completion writes but provider cache stays stale. | Test persistence callback plus provider invalidation/reload path. |
| AC-004 | Main shell flashes during async startup. | Test loading state separately from data states. |
| AC-005 | Broken storage presents an empty login screen. | Recovery/error widget with retry test. |

## 2. Design

### 2.1 Architecture Blueprint

Files to change:

- lib/main.dart — replace the authentication-only home decision with a small root routing state machine.
- lib/features/auth/login_screen.dart — retain onboarding presentation only if it remains the selected root surface; remove duplicate navigation ownership otherwise.
- lib/data/player_progress_provider.dart — expose an explicit refresh or completion mutation only if the existing provider cannot invalidate safely.
- test/main_app_test.dart or new test/features/auth/root_routing_test.dart — cover all root states.
- Docs/AgToosa_TestPlan-BL-28.md — record AC coverage and build evidence.

The root widget owns app destination selection. Feature screens may signal completion, but they must not independently replace the app root.

### 2.2 Data Flow

1. The app initializes content and encrypted local persistence.
2. The auth provider resolves a local anonymous player ID.
3. The progress provider resolves that player's PlayerProgress.
4. The root renders loading, recoverable error, onboarding, or MainAppShell from those two states.
5. Onboarding calls the existing completion persistence method and invalidates or refreshes progress.
6. The root observes onboardingComplete true and renders MainAppShell.

### 2.3 Threat Model (STRIDE)

| Threat | Category | Mitigation |
|--------|----------|------------|
| Corrupt local progress falsely grants completed onboarding. | Tampering | Treat missing/corrupt progress as fresh/recoverable; do not infer completion from auth ID. |
| Repeated root rebuilds cause duplicate navigation. | Denial of Service | Use declarative root state rather than imperative replacement calls. |
| Error details expose storage internals. | Information Disclosure | Present generic recovery copy; log technical details only through the approved error boundary when BL-37 is built. |
| A child screen bypasses the root gate. | Elevation of Privilege | Keep MainAppShell creation in the root routing branch and cover it with widget tests. |

### 2.4 Build Scope

✅ Ready to proceed — Scope Boundary
Files in scope      : lib/main.dart, lib/features/auth/login_screen.dart, lib/data/player_progress_provider.dart if needed, focused routing tests, Docs/AgToosa_TestPlan-BL-28.md, Docs/Master-Plan.md
Directories in scope: lib/features/auth/, lib/data/, test/features/auth/
Out of scope        : docs/PRODUCT-WEDGE.md, tutorial content, game engines, Firebase configuration, active-cycle enrollment

## 3. Tasks

### 3.1 Task Tree

- [x] **1. Root-state tests:** Establish the routing contract before implementation.
  - [x] 1.1 Add a failing fresh-player root-routing widget test. — _Requirements: AC-001_
  - [x] 1.2 Add completed, loading, and error-state tests. — _Requirements: AC-002, AC-004, AC-005_
- [x] **2. Declarative routing:** Make root destination depend on both providers.
  - [x] 2.1 Implement a root-state routing widget or helper in main.dart. — _Requirements: AC-001, AC-002, AC-004, AC-005_
  - [x] 2.2 Remove or isolate duplicate imperative onboarding navigation. — _Requirements: AC-001, AC-002_
  - [x] 2.3 Refresh routing after onboarding completion. — _Requirements: AC-003_
- [ ] **3. Verification:** Prove startup behavior on test and device surfaces.
  - [x] 3.1 Add a no-flash and retry assertion to the widget suite. — _Requirements: AC-004, AC-005_
  - [x] 3.2 Run dart analyze and flutter test. — _Requirements: AC-001, AC-002, AC-003, AC-004, AC-005_
  - [ ] 3.3 Run fresh-install iPhone smoke through first track. — _Requirements: AC-006_ [manual]

### Wave Plan

**Wave 1 (parallel):** 1.1, 1.2  
**Wave 2 (sequential after Wave 1):** 2.1, 2.2  
**Wave 3 (sequential after Wave 2):** 2.3, 3.1  
**Wave 4 (sequential after Wave 3):** 3.2, 3.3  

### 3.2 Wave Plan (detail)

**Wave 1 (parallel):** 1.1, 1.2
**Wave 2 (sequential after Wave 1):** 2.1, 2.2
**Wave 3 (sequential after Wave 2):** 2.3, 3.1
**Wave 4 (sequential after Wave 3):** 3.2, 3.3

### 3.3 Test Plan

Test plan: Docs/AgToosa_TestPlan-BL-28.md
AC coverage: 6 ACs mapped to 6 test IDs
Smoke set: T-001, T-002, T-003, T-005

### 3.4 Work Package DAG

| package_id | wave | depends_on | owned_files | inputs | outputs | merge_order | verification |
|------------|------|------------|-------------|--------|---------|-------------|--------------|
| PKG-1.1 | 1 | — | focused routing test | current providers | RED fresh/completed tests | 1 | flutter test test/features/auth/root_routing_test.dart |
| PKG-1.2 | 1 | — | focused routing test | current providers | RED loading/error tests | 2 | flutter test test/features/auth/root_routing_test.dart |
| PKG-2.1 | 2 | PKG-1.1, PKG-1.2 | lib/main.dart | red suite | declarative root state | 3 | focused flutter test |
| PKG-2.2 | 2 | PKG-2.1 | login screen and provider files | root state | one onboarding owner | 4 | focused flutter test |
| PKG-3.1 | 3 | PKG-2.2 | tests and test plan | green implementation | regression evidence | 5 | dart analyze lib test && flutter test |

### 3.5 Story Skill Opportunity Synthesis

No new project skill is proposed. Root-state routing is a one-story Flutter concern covered by the existing build, test, and iphone-launch-gate workflows.

### 3.6 Spec Quality Analyzer

| Check | Result |
|-------|--------|
| Goal, non-goals, ACs, task tree, and test plan agree. | Pass |
| Every Must AC has an automated test plan entry. | Pass |
| Scope avoids tutorial and persistence-schema overlap. | Pass |
| Approval and cycle enrollment remain user-gated. | Pass |

## ✅ Spec Approved

Approved: 2026-07-26 13:34
