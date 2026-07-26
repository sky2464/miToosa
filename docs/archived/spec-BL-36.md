# Spec: BL-36 — iPhone Accessibility and Device Hardening

> **Story ID:** BL-36
> **Epic:** EP-01 Launch Readiness & Validation
> **Status:** ⬜ Backlog
> **Estimate:** M
> **Clarity:** ready
> **Spec created:** 2026-07-14

## 1. Requirements

### 1.1 Goal Contract

| Field | Value |
|-------|-------|
| Goal | Make the iPhone launch surface usable with VoiceOver, large text, reduced motion, portrait constraints, and touch accessibility. |
| User outcome | Players can understand and operate core game, navigation, and Settings flows without clipped text, inaccessible controls, or unnecessary motion. |
| Success condition | Core screens expose meaningful semantics and 44pt targets; text stays usable at the project's supported high scale; reduced-motion disables nonessential movement; 320pt/portrait layouts do not overflow; physical VoiceOver smoke passes. |
| Proof / evidence | Widget semantics/layout/motion tests, accessibility checklist, dart analyze, flutter test, and physical iPhone VoiceOver/Dynamic Type/reduced-motion evidence. |
| Non-goals | Full localization, Switch Control certification, tablet landscape redesign, haptic/audio work (BL-34), or new game rules. |
| Assumptions | v1.5.1 is iPhone portrait focused; existing Aetheric Pulse components can be incrementally hardened rather than replaced. |
| Risks | Large text can reveal nested-widget overflow; semantic labels can drift from visual labels; animation control can leak into gameplay timing. |
| Unresolved questions | None. The user accepted the recommended accessibility/device-hardening scope. |

### 1.2 Brownfield Baseline

| Area | Current state | Intended delta |
|------|---------------|----------------|
| Semantics | Some controls have labels, coverage is uneven. | Audit core routes and give all actionable controls useful labels/roles/values. |
| Typography | Desktop/default widget tests dominate. | Cover narrow iPhone portrait and large text scale without overflow. |
| Motion | Visual motion exists across game/UI surfaces. | Respect disableAnimations/reduce-motion without altering game logic. |
| Device proof | BL-25 contains manual VoiceOver/Dynamic Type tasks. | Expand/close reusable accessibility evidence and cross-link manual gate. |

### 1.3 User Stories

**As a** VoiceOver user, **I want** core controls announced clearly **so that** I can navigate and play without guessing.

**As a** player using large text or reduced motion, **I want** the interface to remain legible and calm **so that** device settings do not make the game unusable.

### 1.4 Acceptance Criteria (EARS)

| ID | EARS | Priority |
|----|------|----------|
| AC-001 | WHEN a core launch screen renders THE SYSTEM SHALL expose semantic labels, roles, and state values for its actionable controls. | Must |
| AC-002 | WHEN any core action is available THE SYSTEM SHALL provide a hit target of at least 44 logical pixels or an equivalent accessible semantic control. | Must |
| AC-003 | WHEN text scale is set to the supported high accessibility scale THE SYSTEM SHALL avoid clipped/overlapping critical text on onboarding, navigation, gameplay, Progress, and Settings. | Must |
| AC-004 | WHEN the device requests reduced motion THE SYSTEM SHALL suppress nonessential visual animation while preserving deterministic game state/timers. | Must |
| AC-005 | WHEN the app runs in iPhone portrait at 320pt and common release widths THE SYSTEM SHALL keep core flows navigable with no render overflow. | Must |
| AC-006 | WHEN VoiceOver, Dynamic Type, and Reduce Motion are enabled on a physical iPhone THE SYSTEM SHALL complete the documented core-flow smoke without blocker findings. | Must |

### 1.5 Out of Scope

- Broad tablet/landscape redesign, screen-reader localization, voice input, and external accessibility certification.
- New product features, tutorial content rewrites, or monetization copy changes.
- Audio/haptic behavior, which belongs to BL-34.
- Modifying game engine algorithm behavior to slow/accelerate puzzles.

### 1.6 Failure Modes

| AC | Failure mode | Mitigation |
|----|--------------|------------|
| AC-001 | Icon-only controls are unlabeled or duplicate text. | Semantics tree test for each core route. |
| AC-002 | Visual touch area is too small despite a label. | Widget size assertion and padded semantic button wrapper. |
| AC-003 | Long labels overflow only at high text scale. | Fixed 320pt and high-scale widget test matrix. |
| AC-004 | Reduced motion pauses/changes timer logic. | Keep animation concerns in UI layer and snapshot engine state. |
| AC-005 | Dialogs/cards get obscured by system safe areas. | Portrait/SafeArea test fixtures and device smoke. |
| AC-006 | Automation misses platform VoiceOver focus order. | Manual evidence table stays required for release. |

## 2. Design

### 2.1 Architecture Blueprint

Files to create:

- test/accessibility/core_flow_accessibility_test.dart — shared semantic/layout/motion fixtures.
- docs/qa/iphone-accessibility-smoke.md — concise manual VoiceOver, Dynamic Type, Reduce Motion, and portrait procedure.

Files to change:

- lib/theme/design_system.dart and shared widgets such as app header, buttons, dialogs, and chips — minimum viable semantic/target/motion primitives.
- lib/features/auth/, lib/features/main_app/, lib/features/navigation/, lib/features/gameplay/, and lib/features/settings/ — core-route corrections identified by tests.
- Docs/AgToosa_TestPlan-BL-36.md and BL-25 checklist cross-links — evidence ownership.

Accessibility wrappers and layout fixes remain in UI layers. Core engines must not import Flutter or MediaQuery behavior.

### 2.2 Data Flow

1. Core widgets receive MediaQuery text scale, accessibleNavigation, and disableAnimations values.
2. Shared components derive stable layout constraints and suppress only decorative animations when requested.
3. Feature controls expose Semantics labels/value/state and minimum target constraints.
4. Automated tests build core flows at multiple viewport/text/motion settings.
5. The physical iPhone checklist verifies VoiceOver focus order and real system behavior.

### 2.3 Threat Model (STRIDE)

| Threat | Category | Mitigation |
|--------|----------|------------|
| Motion request is ignored and causes a usability barrier. | Denial of Service | Central reduced-motion helper and widget tests. |
| Accessibility label leaks internal/debug state. | Information Disclosure | Use player-facing labels only; no identifiers or raw errors. |
| Large text hides destructive/important action. | Elevation of Privilege | Fixed viewport/high-scale tests for confirmation and primary controls. |
| Semantics tree misrepresents disabled/selected status. | Spoofing | Test labels, roles, and values against visual state. |

### 2.4 Build Scope

✅ Ready to proceed — Scope Boundary
Files in scope      : shared UI accessibility primitives, core route widget fixes, accessibility test fixtures/checklist, BL-25 cross-links, Docs/AgToosa_TestPlan-BL-36.md, Docs/Master-Plan.md
Directories in scope: lib/theme/, lib/widgets/, lib/features/auth/, lib/features/main_app/, lib/features/navigation/, lib/features/gameplay/, lib/features/settings/, test/accessibility/, docs/qa/
Out of scope        : engines, tablets/landscape redesign, localization, audio/haptics, active-cycle enrollment

## 3. Tasks

### 3.1 Task Tree

- [ ] **1. Accessibility baseline tests:** Establish a failing release-screen matrix.
  - [ ] 1.1 Add semantic/target tests for onboarding, shell, world map, gameplay, Progress, and Settings. — _Requirements: AC-001, AC-002_
  - [ ] 1.2 Add high-scale/narrow-portrait/reduced-motion fixtures. — _Requirements: AC-003, AC-004, AC-005_
- [ ] **2. Shared primitives:** Fix repeatable violations centrally.
  - [ ] 2.1 Add/adjust semantic and minimum-target helpers in common widgets. — _Requirements: AC-001, AC-002_
  - [ ] 2.2 Add reduced-motion presentation helper that does not touch engine timing. — _Requirements: AC-004_
- [ ] **3. Core route hardening:** Correct concrete failures revealed by tests.
  - [ ] 3.1 Fix text/layout/semantics in onboarding and navigation/Progress/Settings. — _Requirements: AC-001, AC-002, AC-003, AC-005_
  - [ ] 3.2 Fix gameplay semantics/layout/motion behavior. — _Requirements: AC-001, AC-002, AC-003, AC-004, AC-005_
- [ ] **4. Verification:** Capture automated and device proof.
  - [ ] 4.1 Run dart analyze and flutter test with accessibility matrix. — _Requirements: AC-001 through AC-005_
  - [ ] 4.2 Execute and record physical iPhone VoiceOver, Dynamic Type, Reduce Motion, and portrait smoke. — _Requirements: AC-006_ [manual]

### 3.2 Wave Plan

**Wave 1 (parallel):** 1.1, 1.2
**Wave 2 (parallel after Wave 1):** 2.1, 2.2
**Wave 3 (parallel after Wave 2):** 3.1, 3.2
**Wave 4 (sequential after Wave 3):** 4.1, 4.2

### 3.3 Test Plan

Test plan: Docs/AgToosa_TestPlan-BL-36.md
AC coverage: 6 ACs mapped to 7 test IDs
Smoke set: T-001, T-002, T-003, T-004, T-005

### 3.4 Work Package DAG

| package_id | wave | depends_on | owned_files | inputs | outputs | merge_order | verification |
|------------|------|------------|-------------|--------|---------|-------------|--------------|
| PKG-1.1 | 1 | — | accessibility tests | current routes | RED semantic/target suite | 1 | flutter test test/accessibility/core_flow_accessibility_test.dart |
| PKG-1.2 | 1 | — | accessibility tests | current layout | RED viewport/motion suite | 2 | focused flutter test |
| PKG-2.1 | 2 | PKG-1.1 | shared UI widgets | red tests | reusable a11y helpers | 3 | focused flutter test |
| PKG-2.2 | 2 | PKG-1.2 | theme/shared motion helper | MediaQuery contract | reduced-motion boundary | 4 | focused flutter test |
| PKG-3.1 | 3 | PKG-2.1, PKG-2.2 | feature widgets | shared helpers | corrected core routes | 5 | focused widget tests |
| PKG-4.1 | 4 | PKG-3.1 | tests/checklist | integrated UI | GREEN evidence | 6 | dart analyze lib test && flutter test |

### 3.5 Story Skill Opportunity Synthesis

No new project skill is proposed. iphone-launch-gate already owns launch-phase manual proof; the implementation is standard Flutter accessibility hardening.

### 3.6 Spec Quality Analyzer

| Check | Result |
|-------|--------|
| Accessibility requirements are specific to core release flows. | Pass |
| Automated evidence and unavoidable device proof are distinguished. | Pass |
| Engine/UI separation is preserved. | Pass |
| All Must ACs map to tests. | Pass |
