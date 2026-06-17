# Spec: BL-24 — Interactive How-To Demos

> **Story ID:** BL-24
> **Epic:** EP-01 Launch Readiness & Validation
> **Status:** ⬜ Backlog
> **Estimate:** M
> **Spec created:** 2026-06-14

## 1. Requirements

### 1.1 Goal Contract

| Field | Value |
|-------|-------|
| Goal | Teach players how each puzzle track works before or during first play. |
| User outcome | New players understand the objective for every track and every procedural level without reading long instructions. |
| Success condition | All 23 tracks have valid tutorial definitions; first-entry tutorial shows once; gameplay always shows a compact objective. |
| Proof / evidence | Unit/widget tests, `dart analyze`, `flutter test`, and manual iPhone smoke for onboarding + first track + help reopen. |
| Non-goals | No Rive, Remotion, GIF/video pack, new monetization copy, backend, or edits to `docs/PRODUCT-WEDGE.md`. |
| Assumptions | Native Flutter MVP is the approved asset strategy; story stays in Backlog until explicitly pulled into the Launch Sprint; no manual external service step is required. |
| Risks | Tutorial copy can drift from procedural puzzle behavior; first-entry gating can accidentally affect timers/hearts; small iPhone screens can overflow; icon mapping can hide missing assets with silent fallbacks. |
| Unresolved questions | None for spec generation. |

### 1.2 Brownfield Baseline

| Area | Current state | Intended delta |
|------|---------------|----------------|
| Track count | `assets/content/worlds.json` defines 23 tracks. | Every current track gets a tutorial definition. |
| Puzzle rules | `PuzzleRule` contains the active procedural rule set. | Every current rule maps to a tutorial demo type and objective. |
| How-to modal | `HowToPlayModal` exists but shows static icon/name/subtitle/CTA. | Modal becomes an interactive native Flutter demo surface. |
| Tutorial persistence | `PlayerProgress.seenTutorialWorlds` and `markTutorialSeen` already exist. | First-entry flow actually reads/writes that state. |
| Gameplay help | Gameplay header has a `?` button reopening the modal. | Reopen shows the same interactive demo without gameplay-state mutation. |
| Onboarding | First-run onboarding exists, but app-root routing can bypass it for nonempty anonymous auth. | Root/progress state shows onboarding while `onboardingComplete == false`. |
| Track icons | Track cards request `AP.trackIcon(track.id)`, but current asset names do not cover all track IDs. | Add an explicit mapping to available category icons or safe fallbacks. |

**Repo evidence inventory:** `assets/content/worlds.json`, `lib/core/models/puzzle.dart`, `lib/core/engine/puzzle_generator.dart`, `lib/widgets/how_to_play_modal.dart`, `lib/features/gameplay/gameplay_screen.dart`, `lib/features/navigation/track_detail_screen.dart`, `lib/data/player_progress.dart`, `lib/theme/design_tokens.dart`, `test/widgets/how_to_play_modal_test.dart`.

**Claim boundary:** Spec acceptance is agent-instructed. Runtime behavior is implementation-enforced only after `/agtoosa-build` completes and tests pass.

### 1.3 User Stories

**As a** new player, **I want** an interactive demo before I play an unfamiliar track **so that** I understand what to tap before spending attention or session resources.

**As a** player in a live level, **I want** a compact objective visible near the puzzle prompt **so that** I can quickly understand the current level's goal.

**As a** returning player, **I want** to reopen the how-to demo from gameplay **so that** I can refresh the rule without changing my score, hearts, timer, or progress.

### 1.4 Acceptance Criteria (EARS)

| ID | EARS | Priority |
|----|------|----------|
| AC-001 | WHEN a tutorial definition is loaded THE SYSTEM SHALL validate coverage for all 23 track IDs and all current puzzle rules. | Must |
| AC-002 | WHEN a player enters a track whose tutorial is unseen THE SYSTEM SHALL show the interactive tutorial before timed play starts. | Must |
| AC-003 | WHEN the player dismisses the tutorial THE SYSTEM SHALL persist that track ID in encrypted local progress and skip it on later entries. | Must |
| AC-004 | WHEN the player taps the gameplay help button THE SYSTEM SHALL reopen the tutorial without changing seen state, score, hearts, timer, or progress. | Must |
| AC-005 | WHILE gameplay is active THE SYSTEM SHALL show a compact objective derived from the tutorial rule and live puzzle prompt. | Must |
| AC-006 | WHEN tutorial UI renders THE SYSTEM SHALL meet 44pt touch targets, semantic labels, Dynamic Type tolerance, and reduced-motion behavior. | Must |
| AC-007 | WHEN track artwork is requested THE SYSTEM SHALL map current track IDs to available icon assets or safe fallbacks without broken image noise. | Should |

### 1.5 Out of Scope

- Rive animations, Remotion videos, GIF/video tutorial packs, or new authored animation dependencies.
- Backend, cloud sync, leaderboard changes, or Firebase Analytics event work.
- Economy or monetization copy changes, especially `docs/PRODUCT-WEDGE.md`.
- Rewriting game engines or changing scoring/progression behavior.
- Creating App Store screenshots, promo videos, or social marketing assets.
- Enrolling BL-24 into the active sprint without explicit user approval.

### 1.6 Failure Modes

| AC | Failure mode | Mitigation |
|----|--------------|------------|
| AC-001 | A new track or rule ships without tutorial coverage. | Unit test loads tracks/rules and fails on missing tutorial definitions. |
| AC-002 | Timer starts behind the tutorial or tutorial does not appear. | Widget/integration test asserts unseen track shows tutorial before gameplay timer UI begins. |
| AC-003 | Tutorial repeats every visit or never persists. | Persistence test asserts `seenTutorialWorlds` changes after dismissal and skip occurs next entry. |
| AC-004 | Help reopen mutates progress or gameplay state. | Widget test snapshots seen state, score, hearts, timer, and progress around help reopen. |
| AC-005 | Objective strip is absent or mismatched with the live prompt. | Widget test asserts objective and prompt render together for representative visual/text rules. |
| AC-006 | Modal overflows or is inaccessible on small iPhones. | 320pt viewport widget test plus semantics checks. |
| AC-007 | Track images silently fall back for known tracks. | Unit/widget test verifies ID-to-asset mapping for all 23 tracks. |

## 2. Design

### 2.1 Architecture Blueprint

Files to create:

- `assets/content/tutorials.json` — 23 tutorial definitions keyed by `trackId` and `rule`.
- `lib/core/tutorial/tutorial_definition.dart` — pure Dart model and `TutorialDemoType` enum.
- `lib/core/tutorial/tutorial_repository.dart` — pure Dart/asset-loading adapter that validates tutorial coverage.
- `lib/widgets/tutorial/tutorial_demo_panel.dart` — native Flutter interactive demo surface.
- `lib/widgets/tutorial/tutorial_objective_strip.dart` — compact gameplay objective display.
- `test/core/tutorial/tutorial_repository_test.dart` — coverage and validation tests.
- `test/widgets/tutorial/tutorial_demo_panel_test.dart` — interaction/accessibility tests.
- `test/widgets/tutorial/tutorial_objective_strip_test.dart` — objective rendering tests.
- `test/features/navigation/track_detail_tutorial_test.dart` — first-entry and skip flow tests.
- `Docs/adr/2026-06-14-native-tutorial-demos.md` — decision to use Flutter-native interaction.
- `Docs/adr/2026-06-14-tutorial-content-json.md` — decision to author tutorial definitions in JSON.

Files to change:

- `pubspec.yaml` — register `assets/content/tutorials.json`.
- `lib/core/content_provider.dart` — load or expose tutorial repository alongside tracks without changing engine rules.
- `lib/widgets/how_to_play_modal.dart` — embed the interactive demo and route CTA state.
- `lib/features/navigation/track_detail_screen.dart` — gate first-entry tutorial before difficulty selection and persist dismissal.
- `lib/features/gameplay/gameplay_screen.dart` — render objective strip and preserve `?` reopen without side effects.
- `lib/main.dart` — ensure incomplete onboarding routes to `OnboardingScreen` from root/progress state.
- `lib/theme/design_tokens.dart` or a small helper — map current track IDs to available icon assets/fallbacks.
- `test/widgets/how_to_play_modal_test.dart` — replace static-only expectations with demo behavior.
- `Docs/Master-Plan.md` — backlog row only; no active task enrollment.

Key interfaces:

```dart
class TutorialDefinition {
  final String trackId;
  final PuzzleRule rule;
  final String goal;
  final List<String> steps;
  final TutorialDemoType demoType;
  final String correctAction;
  final String objectiveTemplate;
}

enum TutorialDemoType {
  shapeMatch,
  count,
  oddOneOut,
  sequence,
  binary,
  boolean,
  cipher,
  math,
  geometry,
  physics,
  grid,
}
```

Tutorial copy must stay short, sentence case, and ADHD-friendly. It should explain what to do, not how the code works.

### 2.2 Track Objective Matrix

| Track | Player must do | Interactive method |
|-------|----------------|--------------------|
| Pattern Match | Pick the option identical to the target pattern. | Tap matching shape card. |
| Shape Counter | Count requested shapes. | Tap number option. |
| Odd One Out | Find the item that differs. | Tap odd shape. |
| Color Code | Match the color sequence. | Tap matching color pattern. |
| Missing Piece | Fill the blank in a sequence. | Tap missing item. |
| Sequence | Predict the next item. | Tap next shape. |
| Binary Logic | Convert filled/outlined dots to a number. | Tap decoded number. |
| Logic Gates | Apply AND/OR/XOR. | Tap TRUE/FALSE. |
| Cipher Break | Use the shape-letter key. | Tap decoded text. |
| Add & Subtract | Solve quick arithmetic. | Tap answer. |
| Multiply & Divide | Solve multiplication/division. | Tap answer. |
| Powers & Roots | Solve exponent/root prompt. | Tap answer. |
| Remainders | Find modulo remainder. | Tap answer. |
| Fractions | Simplify or compare the fraction. | Tap fraction. |
| Algebra Lab | Solve for x. | Tap value. |
| Area Master | Calculate area. | Tap answer. |
| Angle Finder | Find missing triangle angle. | Tap angle. |
| Symmetry Lab | Count symmetry lines. | Tap count or infinity. |
| Gravity Drop | Choose heaviest object. | Tap object/weight. |
| Momentum | Predict collision direction. | Tap direction. |
| Balance Lab | Balance lever torque. | Tap missing weight. |
| Number Grid | Complete grid pattern. | Tap missing number. |
| Equation Balance | Make both sides equal. | Tap total/value. |

### 2.3 Data Flow

1. App startup loads tracks and tutorial definitions from bundled assets.
2. `TutorialRepository` validates every `TrackDefinition` has one matching `TutorialDefinition` and every active rule has a supported `TutorialDemoType`.
3. When a player opens a track/level, navigation checks `PlayerProgress.seenTutorialWorlds`.
4. If unseen, `HowToPlayModal` renders `TutorialDemoPanel`; timers and gameplay view models are not started.
5. On demo dismissal, persistence calls `markTutorialSeen(playerId, track.id)`, invalidates `playerProgressProvider`, and continues to difficulty/gameplay.
6. If seen, navigation skips directly to difficulty/gameplay.
7. During gameplay, `TutorialObjectiveStrip` renders the definition objective plus the live puzzle prompt.
8. The gameplay help button reopens the modal in help mode; help mode does not persist or mutate gameplay state.

### 2.4 Threat Model (STRIDE)

| Threat | Category | Mitigation |
|--------|----------|------------|
| Malformed tutorial JSON crashes startup. | Denial of Service | Validate schema with safe fallback and tests; fail visibly during development. |
| Tutorial content drifts from actual puzzle rule. | Tampering / Quality | Coverage tests bind `trackId`, `rule`, and demo type to current `worlds.json` and `PuzzleRule`. |
| Tutorial dismissal grants gameplay progress or affects resources. | Elevation of Privilege | Demo does not use gameplay VM; AC-004/AC-007 tests assert no score/heart/timer/progress mutation. |
| User-controlled prompt text leaks into tutorial UI. | Information Disclosure | Tutorial content is bundled app asset only; no user input or secrets. |
| Repeated modal opens degrade usability. | Denial of Service | Seen-state skip on first-entry path; manual help remains player-triggered. |
| Analytics accidentally records tutorial behavior as gameplay. | Repudiation / Privacy | No analytics/backend work in BL-24; any future telemetry must be separate. |

Trust boundaries: local asset bundle, encrypted Hive progress, player tap input. No new network, auth, secrets, or external APIs.

### 2.5 Build Scope

✅ Ready to proceed — Scope Boundary
Files in scope      : `assets/content/tutorials.json`, `pubspec.yaml`, `lib/core/tutorial/*`, `lib/widgets/tutorial/*`, `lib/widgets/how_to_play_modal.dart`, `lib/features/navigation/track_detail_screen.dart`, `lib/features/gameplay/gameplay_screen.dart`, `lib/main.dart`, `lib/theme/design_tokens.dart`, related tests, BL-24 docs/ADRs
Directories in scope: `assets/content/`, `lib/core/tutorial/`, `lib/widgets/tutorial/`, `test/core/tutorial/`, `test/widgets/tutorial/`, `test/features/navigation/`, `Docs/archived/`, `Docs/adr/`
Out of scope        : `docs/PRODUCT-WEDGE.md`, game engine rule changes, backend/Firebase analytics, App Store media assets, active sprint enrollment, unrelated BL-23 files

### 2.6 Brownfield Drift Resolution

| Drift | Resolution |
|-------|------------|
| Existing BL-24 draft used seeded generator demos instead of JSON content. | Supersede with JSON content ADR because product wants explicit tutorial copy/objectives per track. |
| Existing Master-Plan row pointed BL-24 at EP-04 with Todo status. | Update to EP-01 backlog row to match approved plan. |
| `Docs/Context/CONTEXT.md` referred to seeded `TutorialDemoContent`. | Update terms to reference `tutorials.json` and `TutorialRepository`. |

## 3. Tasks

### 3.1 Task Tree

- [ ] **1. Spec artifacts:** Write BL-24 spec, ADRs, test plan, and Master-Plan backlog row.
  - [ ] 1.1 Create/update BL-24 spec without approval marker — _Requirements: AC-001, AC-002, AC-003, AC-004, AC-005, AC-006, AC-007_
  - [ ] 1.2 Create BL-24 test plan with AC coverage and smoke set — _Requirements: AC-001, AC-002, AC-003, AC-004, AC-005, AC-006, AC-007_
  - [ ] 1.3 Create ADRs for native Flutter demos and JSON tutorial content — _Requirements: AC-001, AC-006_
  - [ ] 1.4 Update `Docs/Master-Plan.md` backlog row only — _Requirements: AC-001_
- [ ] **2. Tutorial content:** Define `tutorials.json`, validation model, and all 23 track objectives.
  - [ ] 2.1 Add `assets/content/tutorials.json` with all track definitions — _Requirements: AC-001_
  - [ ] 2.2 Add `TutorialDefinition`, `TutorialDemoType`, and repository validation — _Requirements: AC-001_
  - [ ] 2.3 Register tutorial asset in `pubspec.yaml` — _Requirements: AC-001_
- [ ] **3. Tutorial UI:** Build reusable interactive demo modal with success state and accessibility.
  - [ ] 3.1 Build `TutorialDemoPanel` using Flutter widgets and existing shape rendering — _Requirements: AC-002, AC-006_
  - [ ] 3.2 Update `HowToPlayModal` to host the demo, feedback, and CTA state — _Requirements: AC-002, AC-006_
- [ ] **4. Flow wiring:** Show first-entry tutorial once, preserve `?` reopen, add gameplay objective strip.
  - [ ] 4.1 Gate unseen track entry before timed play starts — _Requirements: AC-002_
  - [ ] 4.2 Persist dismissal and skip seen tracks — _Requirements: AC-003_
  - [ ] 4.3 Preserve gameplay help reopen without mutation — _Requirements: AC-004_
  - [ ] 4.4 Add gameplay objective strip from tutorial definition and live prompt — _Requirements: AC-005_
  - [ ] 4.5 Ensure root onboarding still appears when `onboardingComplete == false` — _Requirements: AC-006_
- [ ] **5. Asset mapping:** Fix track ID to available PNG mapping with fallbacks.
  - [ ] 5.1 Add explicit track ID to icon asset mapping for all 23 tracks — _Requirements: AC-007_
  - [ ] 5.2 Add tests proving no known track falls through to broken image noise — _Requirements: AC-007_
- [ ] **6. Verification:** Add unit/widget tests, run gates, and document manual smoke.
  - [ ] 6.1 Add coverage tests for tutorial definitions and rule mapping — _Requirements: AC-001_
  - [ ] 6.2 Add widget/integration tests for first-entry, skip, help reopen, objective strip, accessibility, and reduced motion — _Requirements: AC-002, AC-003, AC-004, AC-005, AC-006_
  - [ ] 6.3 Run `dart analyze` and `flutter test`; record manual iPhone smoke as deferred evidence if not executable locally — _Requirements: AC-001, AC-002, AC-003, AC-004, AC-005, AC-006, AC-007_

### 3.2 Wave Plan

**Wave 1 (parallel):** 2.1, 2.2, 3.1, 6.1
**Wave 2 (sequential after Wave 1):** 2.3, 3.2, 4.1, 4.2
**Wave 3 (sequential after Wave 2):** 4.3, 4.4, 4.5, 5.1, 5.2
**Wave 4 (sequential after Wave 3):** 6.2, 6.3

### 3.3 Test Plan

Test plan: `Docs/AgToosa_TestPlan-BL-24.md`
AC coverage: 7 ACs mapped to 7 test IDs
Smoke set: 5 tests tagged `@smoke`

### 3.4 Spec Quality Analyzer

| Check | Result |
|-------|--------|
| Every Must AC is observable and testable. | Pass |
| Goal, non-goals, build scope, ACs, task tree, and test plan are aligned. | Pass |
| Every Must AC maps to at least one test-plan row. | Pass |
| Claim boundaries are stated. | Pass |
| `Docs/Master-Plan.md` remains repo-local source of truth. | Pass |
| No placeholder/TBD requirements remain. | Pass |

### 3.5 Story Skill Opportunity

| Skill name | Trigger description | Purpose | Inputs | Optional resources | Validation | Decision |
|------------|---------------------|---------|--------|--------------------|------------|----------|
| tutorial-content-auditor | Repeated future edits to `tutorials.json` or track/rule content | Check tutorial coverage and copy constraints | `worlds.json`, `tutorials.json`, `PuzzleRule` | None | Unit coverage command | Do not generate now; one story does not justify a project skill. |

## Spec Revision Log

| Rev | Date | Change | Why | Approved |
|-----|------|--------|-----|----------|
| R0 | 2026-06-14 | Initial BL-24 spec aligned to approved plan. | User requested full `/agtoosa-spec` artifacts for interactive how-to demos. | Pending |
