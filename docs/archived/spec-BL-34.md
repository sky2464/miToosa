# Spec: BL-34 — Production SFX and Persisted Preferences

> **Story ID:** BL-34
> **Epic:** EP-04 User Experience Polish
> **Status:** ⬜ Backlog
> **Estimate:** S
> **Clarity:** ready
> **Spec created:** 2026-07-14

## 1. Requirements

### 1.1 Goal Contract

| Field | Value |
|-------|-------|
| Goal | Replace generated test tones with production SFX, persist sound/haptic settings, and remove unsupported background-music controls. |
| User outcome | Puzzle feedback sounds intentional when enabled, stays quiet when disabled, and respects the player's choice after relaunch. |
| Success condition | All shipped SFX are production-ready with provenance; Sound and Haptics settings persist locally; no Music setting or unused MusicService remains; disabled settings suppress output. |
| Proof / evidence | Audio-preference/service tests, widget tests, asset/provenance audit, dart analyze, flutter test, and physical iPhone sound/haptic smoke. |
| Non-goals | Background music, streaming audio, voice acting, new gameplay rules, remote audio downloads, or a change to docs/PRODUCT-WEDGE.md. |
| Assumptions | The user selected production SFX only; shared_preferences is the right store for device-local audio/haptic preferences and does not require PlayerProgress schema changes. |
| Risks | Audio plugins can fail silently on simulator; an asset can be licensed incorrectly; toggles can update UI but not runtime playback. |
| Unresolved questions | None. The user chose production SFX and removal of the Music control. |

### 1.2 Brownfield Baseline

| Area | Current state | Intended delta |
|------|---------------|----------------|
| SFX assets | README identifies generated test tones; both WAV and OGG variants exist. | Replace with curated production assets and source/license record. |
| Music | MusicService exists but no production music is played. | Remove the service and Music Settings control. |
| Preferences | Sound/Haptics controls are transient or incomplete. | Persist and apply both preferences across relaunch. |
| Feedback | Gameplay can trigger audio/haptics directly. | Route through a preference-aware feedback service. |

### 1.3 User Stories

**As a** player, **I want** satisfying puzzle feedback that I can silence **so that** the game fits my environment.

**As a** player, **I want** my sound and haptic choices remembered **so that** I do not have to reset them every session.

### 1.4 Acceptance Criteria (EARS)

| ID | EARS | Priority |
|----|------|----------|
| AC-001 | WHEN gameplay feedback requests a shipped sound THE SYSTEM SHALL use a production-ready bundled SFX asset with recorded provenance. | Must |
| AC-002 | WHEN Sound is disabled THE SYSTEM SHALL not invoke audio playback for gameplay feedback. | Must |
| AC-003 | WHEN Haptics is disabled THE SYSTEM SHALL not invoke haptic feedback for gameplay feedback. | Must |
| AC-004 | WHEN a player changes Sound or Haptics THE SYSTEM SHALL persist the choice and apply it after cold relaunch. | Must |
| AC-005 | WHEN Settings renders THE SYSTEM SHALL expose Sound and Haptics but SHALL NOT expose a Music control or unsupported background-music claim. | Must |
| AC-006 | WHEN a supported audio/haptic plugin is unavailable or playback fails THE SYSTEM SHALL keep gameplay responsive and fail quietly with sanitized diagnostics. | Should |

### 1.5 Out of Scope

- Background music, playlists, music licensing, streaming, and media controls.
- New monetization audio, voice chat, accessibility narration, or remote settings sync.
- Changing puzzle timing/scoring based on audio/haptics.
- PlayerProgress/Hive schema migration.

### 1.6 Failure Modes

| AC | Failure mode | Mitigation |
|----|--------------|------------|
| AC-001 | A test-tone file is left registered or a new asset lacks a license. | Manifest/test validates registered files against approved source record. |
| AC-002 | Disable switch does not reach direct AudioPlayer callers. | Centralize feedback calls in a service and scan/replace direct callers. |
| AC-003 | Haptic call bypasses preference. | Use a shared feedback boundary with fake tests. |
| AC-004 | Toggle reverts after relaunch. | Repository cold-read test. |
| AC-006 | Plugin exception interrupts game completion. | Catch plugin-specific error at the feedback boundary; never block engine/UI state. |

## 2. Design

### 2.1 Architecture Blueprint

Files to create:

- lib/data/feedback_preferences_repository.dart — persisted sound/haptics values and fake.
- lib/core/feedback_service.dart — preference-aware audio/haptic boundary with injectable player/haptic adapters.
- assets/audio/LICENSES.md — per-file source/license/attribution record.
- focused tests under test/data/ and test/core/.

Files to change:

- assets/audio/README.md and registered sound files — replace test tones and document production set.
- lib/core/music_service.dart — remove after callers are proven absent.
- lib/features/settings/settings_screen.dart — keep persisted Sound/Haptics controls and remove Music control.
- gameplay widgets/services that invoke feedback — use FeedbackService only.
- Docs/AgToosa_TestPlan-BL-34.md — test evidence.

The engine emits gameplay outcomes without platform calls. The feature/core feedback service decides whether to play/haptic based on persisted preferences.

### 2.2 Data Flow

1. App bootstrap or provider reads Sound/Haptics preferences from shared_preferences.
2. Settings writes a changed value and emits the updated preference state.
3. Gameplay outcome requests success/failure/hint feedback through FeedbackService.
4. The service checks preference before calling audio or haptic adapter.
5. Adapter failures are contained and do not modify gameplay state.

### 2.3 Threat Model (STRIDE)

| Threat | Category | Mitigation |
|--------|----------|------------|
| Unlicensed asset is shipped. | Repudiation | LICENSES.md and automated manifest validation. |
| A direct caller bypasses disabled preference. | Tampering | One service boundary plus targeted source scan. |
| Audio exception blocks a puzzle result. | Denial of Service | Catch/contain failures asynchronously at boundary. |
| Logs reveal user or puzzle data through diagnostics. | Information Disclosure | Log only static event type/error class, never progress or identifiers. |

### 2.4 Build Scope

✅ Ready to proceed — Scope Boundary
Files in scope      : production SFX assets and license record, feedback preferences repository/service, Settings audio/haptic controls, direct feedback callers, MusicService removal, focused tests, Docs/AgToosa_TestPlan-BL-34.md, Docs/Master-Plan.md
Directories in scope: assets/audio/, lib/data/, lib/core/, lib/features/settings/, lib/features/gameplay/, test/
Out of scope        : music, voice, remote audio, PlayerProgress schema, game-engine changes, active-cycle enrollment

## 3. Tasks

### 3.1 Task Tree

- [ ] **1. Preference and asset tests:** Establish RED constraints.
  - [ ] 1.1 Add RED tests for persisted Sound/Haptics choices and suppressed adapters. — _Requirements: AC-002, AC-003, AC-004_
  - [ ] 1.2 Add RED asset/provenance and no-Music-control tests. — _Requirements: AC-001, AC-005_
- [ ] **2. Feedback architecture:** Add safe preference-aware boundaries.
  - [ ] 2.1 Add feedback preferences repository and provider. — _Requirements: AC-004_
  - [ ] 2.2 Add FeedbackService and migrate direct audio/haptic callers. — _Requirements: AC-002, AC-003, AC-006_
- [ ] **3. Assets and Settings:** Ship production feedback only.
  - [ ] 3.1 Replace generated tones and write LICENSES.md/README provenance. — _Requirements: AC-001_
  - [ ] 3.2 Remove MusicService/control and wire persisted Settings controls. — _Requirements: AC-004, AC-005_
- [ ] **4. Verification:** Prove behavior on test and device.
  - [ ] 4.1 Add regression scan, run dart analyze and flutter test. — _Requirements: AC-001 through AC-006_
  - [ ] 4.2 Run physical iPhone enabled/disabled audio and haptic smoke. — _Requirements: AC-002, AC-003, AC-004_ [manual]

### 3.2 Wave Plan

**Wave 1 (parallel):** 1.1, 1.2
**Wave 2 (parallel after Wave 1):** 2.1, 3.1
**Wave 3 (sequential after Wave 2):** 2.2, 3.2
**Wave 4 (sequential after Wave 3):** 4.1, 4.2

### 3.3 Test Plan

Test plan: Docs/AgToosa_TestPlan-BL-34.md
AC coverage: 6 ACs mapped to 6 test IDs
Smoke set: T-001, T-002, T-003, T-004

### 3.4 Work Package DAG

| package_id | wave | depends_on | owned_files | inputs | outputs | merge_order | verification |
|------------|------|------------|-------------|--------|---------|-------------|--------------|
| PKG-1.1 | 1 | — | preferences/feedback tests | current callers | RED service tests | 1 | focused flutter test |
| PKG-1.2 | 1 | — | asset/settings tests | audio inventory | RED asset/UI tests | 2 | focused flutter test |
| PKG-2.1 | 2 | PKG-1.1 | preferences repository | shared_preferences | persisted state | 3 | focused flutter test |
| PKG-2.2 | 2 | PKG-1.2 | audio assets/license docs | approved SFX sources | production inventory | 4 | focused asset test |
| PKG-3.1 | 3 | PKG-2.1, PKG-2.2 | feedback service/callers | preferences/assets | guarded feedback | 5 | focused flutter test |
| PKG-3.2 | 3 | PKG-3.1 | Settings/MusicService | feedback state | truthful controls | 6 | focused widget test |
| PKG-4.1 | 4 | PKG-3.2 | tests/test plan | integrated behavior | GREEN evidence | 7 | dart analyze lib test && flutter test |

### 3.5 Story Skill Opportunity Synthesis

No new project skill is proposed. This is a contained asset and preference feature with normal Flutter test coverage.

### 3.6 Spec Quality Analyzer

| Check | Result |
|-------|--------|
| The approved no-music decision is explicit. | Pass |
| Every Must AC maps to a deterministic test. | Pass |
| Asset provenance is a precondition, not a release afterthought. | Pass |
| Gameplay engine remains platform-free. | Pass |
