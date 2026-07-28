# Spec: BL-31 — Truthful Launch Surfaces

> **Story ID:** BL-31
> **Epic:** EP-01 Launch Readiness & Validation
> **Status:** 🏁 Shipped
> **Estimate:** M
> **Clarity:** ready
> **Spec created:** 2026-07-14

## 1. Requirements

### 1.1 Goal Contract

| Field | Value |
|-------|-------|
| Goal | Ensure every visible v1.5.1 navigation and Settings surface either works as presented or is removed/gated before iPhone launch. |
| User outcome | Players do not encounter demo leaderboards, inert controls, unfinished VIP/share claims, unsupported local multiplayer, or a fake Reset Progress action. |
| Success condition | The shipped shell has only implemented navigation; Settings actions have real outcomes or are absent; Reset Progress has confirmation and resets local game data while preserving the anonymous identity. |
| Proof / evidence | Widget tests for visible routes/actions, persistence reset test, source scan for known preview/stale wording, dart analyze, flutter test, and physical iPhone Settings smoke. |
| Non-goals | Implementing a backend leaderboard, real-time local multiplayer, profile editing, VIP/IAP, or reminders. |
| Assumptions | Deferred features may remain in source as unshipped POCs when unreachable from release navigation; local reset preserves device key material and anonymous player identity. |
| Risks | Hiding a feature can leave dead route references; reset may leave stale provider state or delete encryption keys unexpectedly. |
| Unresolved questions | None. The user chose to hide/gate deferred features and make Reset Progress real. |

### 1.2 Brownfield Baseline

| Area | Current state | Intended delta |
|------|---------------|----------------|
| Leaderboard | Main shell exposes static demo users and a pre-v1.3 preview message. | Remove from release tab navigation; retain only as deferred source or delete if dead. |
| Local play | World map exposes a local multiplayer POC despite iOS local-network configuration mismatch. | Remove release entry; defer to LP-01. |
| Settings | Profile/VIP/share/reminder rows are inert; version is stale. | Remove or replace unsupported rows, and show only truthful supported settings. |
| Reset | Reset copy exists without a handler. | Add confirmation, durable reset, provider refresh, and success feedback. |
| Economy | Settings repeats obsolete share/VIP language. | Remove it; BL-29 owns the free-games share CTA. |

### 1.3 User Stories

**As a** player, **I want** every tab and control I can reach to be usable **so that** I trust the game.

**As a** player, **I want** Reset Progress to actually clear my local game state after confirmation **so that** I can start over.

### 1.4 Acceptance Criteria (EARS)

| ID | EARS | Priority |
|----|------|----------|
| AC-001 | WHEN the release shell renders THE SYSTEM SHALL expose only navigation destinations with an implemented v1.5.1 experience. | Must |
| AC-002 | WHEN a player opens Settings THE SYSTEM SHALL NOT display an inert profile editor, VIP upgrade, share row, daily reminder toggle, or stale preview/version claim. | Must |
| AC-003 | WHEN a player requests Reset Progress THE SYSTEM SHALL require explicit confirmation before changing persisted data. | Must |
| AC-004 | WHEN Reset Progress is confirmed THE SYSTEM SHALL replace progress with a fresh PlayerProgress for the existing anonymous player ID and refresh all affected providers. | Must |
| AC-005 | WHEN Reset Progress is cancelled or persistence fails THE SYSTEM SHALL preserve existing progress and display a recoverable outcome. | Must |
| AC-006 | WHEN the release UI is scanned THE SYSTEM SHALL not expose a reachable backend leaderboard, local multiplayer, or implementation-preview claim. | Must |

### 1.5 Out of Scope

- Building the deferred leaderboard, local multiplayer, profile editor, reminders, or VIP/IAP.
- Changing anonymous authentication, player-ID generation, or encryption-key lifecycle.
- Editing product economics beyond removing stale Settings copy; BL-29 owns the free-games flow.
- Shipping Android/macOS-specific navigation decisions.

### 1.6 Failure Modes

| AC | Failure mode | Mitigation |
|----|--------------|------------|
| AC-001 | A hidden route remains reachable from a deep child widget. | Test shell tab list and release navigation tree. |
| AC-002 | Placeholder controls look interactive but do nothing. | Make unsupported rows absent, not disabled without explanation. |
| AC-004 | Reset deletes identity/key material or leaves stale UI. | Reset only progress payload, invalidate provider, and test relaunch. |
| AC-005 | Dialog dismissal still performs reset. | Test cancel, failure, and double-tap paths. |
| AC-006 | Preview strings survive in a secondary surface. | Targeted source scan plus widget smoke. |

## 2. Design

### 2.1 Architecture Blueprint

Files to create:

- lib/features/settings/reset_progress_controller.dart or a small data-layer reset service with a test fake.
- focused Settings/reset tests under test/features/settings/.

Files to change:

- lib/features/main_app/main_app_shell.dart — remove leaderboard from release tabs and related header assumptions.
- lib/features/navigation/world_map_screen.dart — remove release-local-play entry.
- lib/features/settings/settings_screen.dart — retain only implemented settings and wire Reset Progress.
- lib/data/hive_persistence_provider.dart and player progress provider — add a safe reset operation preserving playerId and refresh state.
- lib/widgets/credits_menu_sheet.dart only as required to remove unrelated stale launch claims; BL-29 owns the free-games replacement.
- Docs/AgToosa_TestPlan-BL-31.md — test evidence.

The feature layer owns confirmation UI. The data layer owns atomic reset and never deletes the keychain identity as part of this story.

### 2.2 Data Flow

1. Release shell builds its tab list from an explicit supported destination list.
2. Settings renders a curated list of active controls.
3. Reset opens a destructive confirmation dialog with cancel as the default.
4. Confirm invokes a persistence reset for the current player ID.
5. Persistence replaces the saved progress and emits a refreshed provider value.
6. The UI returns to a fresh-state experience and displays confirmation.

### 2.3 Threat Model (STRIDE)

| Threat | Category | Mitigation |
|--------|----------|------------|
| Accidental reset destroys player progress. | Denial of Service | Explicit confirmation, cancel default, and no destructive action on dialog dismiss. |
| Reset deletes identity/encryption key and breaks future saves. | Tampering | Scope reset to PlayerProgress record only and retain player ID/key material. |
| Preview controls imply nonexistent online services. | Spoofing | Remove their release routes and claims rather than label them as production. |
| Reset failure exposes Hive internals. | Information Disclosure | Show generic recovery copy and log sanitized diagnostics through approved boundaries. |

### 2.4 Build Scope

✅ Ready to proceed — Scope Boundary
Files in scope      : release shell/navigation, settings screen, reset controller/persistence/provider code, focused tests, Docs/AgToosa_TestPlan-BL-31.md, Docs/Master-Plan.md
Directories in scope: lib/features/main_app/, lib/features/navigation/, lib/features/settings/, lib/data/, test/features/settings/
Out of scope        : leaderboard backend, local-play protocol, profile/VIP/reminder implementation, docs/PRODUCT-WEDGE.md, active-cycle enrollment

## 3. Tasks

### 3.1 Task Tree

- [x] **1. Release-surface tests:** Capture every visible route/action that must be truthful.
  - [x] 1.1 Add RED shell and Settings tests for unsupported route/control absence. — _Requirements: AC-001, AC-002, AC-006_
  - [x] 1.2 Add RED reset confirmation, success, cancel, and failure tests. — _Requirements: AC-003, AC-004, AC-005_
- [x] **2. Gate unsupported experiences:** Trim release navigation and Settings.
  - [x] 2.1 Remove leaderboard and local-play release entry points. — _Requirements: AC-001, AC-006_
  - [x] 2.2 Curate supported Settings rows and eliminate stale copy. — _Requirements: AC-002_
- [x] **3. Implement reset:** Add safe persistence and provider refresh behavior.
  - [x] 3.1 Add a reset operation scoped to game progress for the current player ID. — _Requirements: AC-004, AC-005_
  - [x] 3.2 Wire confirmation dialog, state feedback, and retry handling. — _Requirements: AC-003, AC-004, AC-005_
- [x] **4. Verification:** Prove the release surface is honest.
  - [x] 4.1 Add source-scan/widget regression tests for preview strings and unsupported routes. — _Requirements: AC-001, AC-002, AC-006_
  - [x] 4.2 Run dart analyze and flutter test. — _Requirements: AC-001 through AC-006_
  - [ ] 4.3 Run physical iPhone Settings/reset smoke. — _Requirements: AC-003, AC-004, AC-005_ [manual]

### 3.2 Wave Plan

**Wave 1 (parallel):** 1.1, 1.2
**Wave 2 (parallel after Wave 1):** 2.1, 2.2, 3.1
**Wave 3 (sequential after Wave 2):** 3.2, 4.1
**Wave 4 (sequential after Wave 3):** 4.2, 4.3

### 3.3 Test Plan

Test plan: Docs/AgToosa_TestPlan-BL-31.md
AC coverage: 6 ACs mapped to 6 test IDs
Smoke set: T-001, T-002, T-003, T-004

### 3.4 Work Package DAG

| package_id | wave | depends_on | owned_files | inputs | outputs | merge_order | verification |
|------------|------|------------|-------------|--------|---------|-------------|--------------|
| PKG-1.1 | 1 | — | shell/settings tests | current routes | RED surface tests | 1 | focused flutter test |
| PKG-1.2 | 1 | — | reset tests | persistence fake | RED reset tests | 2 | focused flutter test |
| PKG-2.1 | 2 | PKG-1.1 | shell and navigation files | red surface contract | gated release UI | 3 | focused widget test |
| PKG-2.2 | 2 | PKG-1.2 | data/provider reset code | red reset contract | safe reset mutation | 4 | focused reset test |
| PKG-3.1 | 3 | PKG-2.1, PKG-2.2 | settings screen | surfaced reset service | confirmation flow | 5 | focused settings test |
| PKG-4.1 | 4 | PKG-3.1 | tests and test plan | integrated release UI | GREEN evidence | 6 | dart analyze lib test && flutter test |

### 3.5 Story Skill Opportunity Synthesis

No new project skill is proposed. This story enforces product truthfulness with normal Flutter routing, persistence, and test practices.

### 3.6 Spec Quality Analyzer

| Check | Result |
|-------|--------|
| Every Must AC has a deterministic test plan row. | Pass |
| Deferred features are excluded rather than silently promised. | Pass |
| Reset is limited to local progress and preserves identity. | Pass |
| BL-29 owns active share economics to avoid overlap. | Pass |

## ✅ Spec Approved

Approved: 2026-07-26 16:32
