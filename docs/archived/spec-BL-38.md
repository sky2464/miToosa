# Spec: BL-38 — Modularize Oversized Code and Remove Dead Dependencies

> **Story ID:** BL-38
> **Epic:** EP-05 Technical Debt & Infrastructure
> **Status:** ⬜ Backlog
> **Estimate:** L
> **Clarity:** ready
> **Spec created:** 2026-07-14

## 1. Requirements

### 1.1 Goal Contract

| Field | Value |
|-------|-------|
| Goal | Reduce launch-risky code concentration by splitting oversized modules along existing boundaries and removing proven-dead dependencies/artifacts without behavior change. |
| User outcome | Players receive the same tested game behavior, while maintainers can safely change gameplay, navigation, and persistence before release. |
| Success condition | Target production Dart files are under 500 lines or are explicitly generated/whitelisted; core engine remains Flutter/Hive-free; all existing behavior tests remain green; go_router and other proven-dead artifacts are removed only after no-reader proof. |
| Proof / evidence | Baseline characterization tests, line-count/import guard, dependency-reader audit, dart analyze, flutter test, engine guard, and diff/review evidence. |
| Non-goals | New player features, a global state-management rewrite, puzzle-rule rebalancing, storage-schema changes, or arbitrary dependency upgrades. |
| Assumptions | Current oversized hotspots are puzzle_generator.dart, gameplay_screen.dart, player_progress.dart, world_map_screen.dart, and track_detail_screen.dart; BL-30 owns levels.json cleanup and BL-34 owns MusicService cleanup. |
| Risks | Mechanical moves can change private-widget state, Hive adapter field order, generator randomness, or navigation semantics; shared work can collide with active feature stories. |
| Unresolved questions | None. The user accepted modularization and dead-code cleanup as a product-readiness chore. |

### 1.2 Brownfield Baseline

| Area | Current state | Intended delta |
|------|---------------|----------------|
| Puzzle generator | lib/core/engine/puzzle_generator.dart is about 1,400 lines. | Preserve facade and split rule-specific generation helpers under core engine. |
| Gameplay UI | gameplay_screen.dart is about 1,160 lines. | Extract presentational/widgets/overlays without moving engine logic into UI helpers. |
| Persistence model | player_progress.dart is about 620 lines and contains model plus Hive adapter. | Separate adapter/serialization concerns with field-number tests. |
| Navigation UI | world_map_screen.dart and track_detail_screen.dart are each about 530 lines. | Extract presentational sections and keep route/state orchestration visible. |
| Dead dependency | go_router is declared but has no production import. | Remove after a no-reader test/audit. |
| Related cleanup | levels.json and MusicService have separate owned stories. | Do not edit those artifacts unless dependencies make a coordinated approved build necessary. |

### 1.3 User Stories

**As a** maintainer, **I want** focused modules with clear ownership **so that** launch fixes do not require editing thousand-line files.

**As a** player, **I want** refactoring to preserve game behavior **so that** release polish does not create regressions.

### 1.4 Acceptance Criteria (EARS)

| ID | EARS | Priority |
|----|------|----------|
| AC-001 | WHEN the refactor is complete THE SYSTEM SHALL keep each targeted non-generated production Dart file at or below 500 lines. | Must |
| AC-002 | WHEN puzzle generation is invoked before and after refactoring THE SYSTEM SHALL preserve deterministic seeded outputs and existing rule behavior. | Must |
| AC-003 | WHEN PlayerProgress is serialized/deserialized THE SYSTEM SHALL preserve every existing Hive field number, default, and migration behavior. | Must |
| AC-004 | WHEN gameplay, world-map, or track-detail UI is exercised THE SYSTEM SHALL preserve existing navigation/state behavior while using extracted presentation components. | Must |
| AC-005 | WHEN core-engine source is checked THE SYSTEM SHALL remain free of Flutter, Hive, and feature-layer imports. | Must |
| AC-006 | WHEN a dependency/artifact is removed THE SYSTEM SHALL first prove no production reader/import remains and SHALL retain all unrelated deferred POC dependencies unless explicitly in scope. | Must |
| AC-007 | WHEN the final refactor suite runs THE SYSTEM SHALL pass dart analyze, flutter test, the engine guard, and a diff whitespace check. | Must |

### 1.5 Out of Scope

- Functional behavior changes, redesigns, provider migrations, package version bumps, or architecture rewrites.
- Removing levels.json, MusicService, or local-play/network dependencies without coordinating their owned stories.
- Hive schema bump, new persistence fields, content schema changes, or Firebase changes.
- Enrolling BL-38 in the active cycle before explicit approval.

### 1.6 Failure Modes

| AC | Failure mode | Mitigation |
|----|--------------|------------|
| AC-001 | New small files leave original files still oversized. | Line-count gate checks exact target list at completion. |
| AC-002 | Random generator state shifts after helper extraction. | Seeded characterization fixtures before moves. |
| AC-003 | Hive adapter changes field order/default. | Existing and new round-trip/migration tests run before/after split. |
| AC-004 | Extracted widgets lose provider/state lifecycle. | Widget navigation/state tests around each extracted boundary. |
| AC-005 | Convenience import crosses core-engine architecture boundary. | Run flutter-engine-guard and static import test. |
| AC-006 | Dead-code audit removes a deferred POC dependency. | Explicit no-reader report; network_info_plus is retained unless a separate approved scope proves removal. |

## 2. Design

### 2.1 Architecture Blueprint

Files to create:

- lib/core/engine/generators/ — rule-specific pure Dart generation helpers behind the existing puzzle-generator facade.
- lib/features/gameplay/widgets/ and/or lib/features/gameplay/overlays/ — extracted presentation components with explicit inputs/callbacks.
- lib/features/navigation/widgets/ — world-map/track-detail sections with no hidden navigation ownership.
- lib/data/player_progress_adapter.dart — Hive adapter/field serialization split from model, if compatible with registration.
- test/architecture/line_budget_test.dart and characterization fixtures for generator, persistence, and navigation.

Files to change:

- lib/core/engine/puzzle_generator.dart — facade/orchestration only.
- lib/features/gameplay/gameplay_screen.dart — compose extracted widgets.
- lib/data/player_progress.dart and Hive registration locations — model behavior only with adapter field contract preserved.
- lib/features/navigation/world_map_screen.dart and track_detail_screen.dart — orchestration only.
- pubspec.yaml and pubspec.lock — remove go_router only after no production import proof.
- Docs/AgToosa_TestPlan-BL-38.md — test evidence.

No extracted UI component may import core engine internals beyond typed view-model data. No engine helper may import Flutter, Hive, Riverpod, or UI code.

### 2.2 Data Flow

1. Characterization tests capture seeded generator output, Hive round trips, and core navigation state before moves.
2. Pure rule generators move behind a stable facade.
3. Hive adapter moves with unchanged type ID, field numbers, defaults, and registration behavior.
4. UI sections move into input-driven widgets while screens retain provider/navigation orchestration.
5. Dependency/artifact audit proves readers absent before removing go_router.
6. Full regressions and line/import guards prove the refactor did not change product behavior.

### 2.3 Threat Model (STRIDE)

| Threat | Category | Mitigation |
|--------|----------|------------|
| Refactor changes persisted data interpretation. | Tampering | Field-number/default/migration characterization before adapter move. |
| Core engine imports Flutter/Hive after extraction. | Elevation of Privilege | Run flutter-engine-guard and explicit architecture tests. |
| A moved widget leaks player data through new logging. | Information Disclosure | No new telemetry/logging in refactor scope. |
| Behavioral regression appears only in an untested rule. | Denial of Service | Seeded fixtures across current puzzle-rule set and full suite. |
| Dead dependency removal breaks deferred POC. | Denial of Service | No-reader proof and explicit out-of-scope list before removal. |

### 2.4 Build Scope

✅ Ready to proceed — Scope Boundary
Files in scope      : targeted oversized Dart modules and their extracted helpers, generator/persistence/navigation characterization tests, line/import guards, pubspec go_router cleanup after proof, Docs/AgToosa_TestPlan-BL-38.md, Docs/Master-Plan.md
Directories in scope: lib/core/engine/, lib/features/gameplay/, lib/features/navigation/, lib/data/, test/core/, test/features/, test/architecture/
Out of scope        : feature behavior, Hive schema, levels.json, MusicService, local-play/network POC dependencies, package upgrades, active-cycle enrollment

## 3. Tasks

### 3.1 Task Tree

- [ ] **1. Characterization gates:** Capture current behavior before moving code.
  - [ ] 1.1 Add RED/characterization fixtures for seeded puzzle rules and facade output. — _Requirements: AC-002_
  - [ ] 1.2 Add PlayerProgress adapter field/default/migration characterization tests. — _Requirements: AC-003_
  - [ ] 1.3 Add UI navigation/state and line/import-budget tests. — _Requirements: AC-001, AC-004, AC-005_
  - [ ] 1.4 Produce a no-reader audit for go_router and candidate artifacts. — _Requirements: AC-006_
- [ ] **2. Core and persistence split:** Preserve pure/serialized behavior.
  - [ ] 2.1 Extract pure puzzle-rule helpers behind the existing facade. — _Requirements: AC-001, AC-002, AC-005_
  - [ ] 2.2 Split PlayerProgress adapter from model while preserving registration contract. — _Requirements: AC-001, AC-003_
- [ ] **3. UI split:** Extract presentational sections with stable orchestration.
  - [ ] 3.1 Split gameplay screen overlays/controls into input-driven widgets. — _Requirements: AC-001, AC-004_
  - [ ] 3.2 Split world-map and track-detail sections into navigation widgets. — _Requirements: AC-001, AC-004_
- [ ] **4. Proven cleanup:** Remove only proven-dead configuration.
  - [ ] 4.1 Remove go_router and update lockfile after the no-reader audit is green. — _Requirements: AC-006_
  - [ ] 4.2 Record intentionally retained deferred POC dependencies and cross-story cleanup boundaries. — _Requirements: AC-006_
- [ ] **5. Verification:** Run architecture and product regressions.
  - [ ] 5.1 Run line/import guard, flutter-engine-guard, dart analyze, flutter test, and diff check. — _Requirements: AC-001, AC-002, AC-003, AC-004, AC-005, AC-007_

### 3.2 Wave Plan

**Wave 1 (parallel):** 1.1, 1.2, 1.3, 1.4
**Wave 2 (parallel after Wave 1):** 2.1, 2.2
**Wave 3 (parallel after Wave 2):** 3.1, 3.2, 4.1
**Wave 4 (sequential after Wave 3):** 4.2, 5.1

### 3.3 Test Plan

Test plan: Docs/AgToosa_TestPlan-BL-38.md
AC coverage: 7 ACs mapped to 8 test IDs
Smoke set: T-001, T-002, T-003, T-004, T-006, T-007

### 3.4 Work Package DAG

| package_id | wave | depends_on | owned_files | inputs | outputs | merge_order | verification |
|------------|------|------------|-------------|--------|---------|-------------|--------------|
| PKG-1.1 | 1 | — | characterization tests | current modules | baseline behavior suite | 1 | focused flutter test |
| PKG-1.2 | 1 | — | line/import/audit tests | source inventory | RED structural gates | 2 | focused flutter test |
| PKG-2.1 | 2 | PKG-1.1, PKG-1.2 | core engine files | seeded fixtures | pure generator split | 3 | flutter-engine-guard + focused test |
| PKG-2.2 | 2 | PKG-1.1 | PlayerProgress model/adapter | Hive fixtures | serialization split | 4 | focused persistence test |
| PKG-3.1 | 3 | PKG-2.1, PKG-2.2 | gameplay/navigation UI | stable interfaces | component splits | 5 | focused widget tests |
| PKG-3.2 | 3 | PKG-1.2 | pubspec/lockfile | no-reader report | go_router removal | 6 | flutter pub get && rg -n go_router lib test |
| PKG-4.1 | 4 | PKG-3.1, PKG-3.2 | tests/test plan | integrated refactor | GREEN evidence | 7 | dart analyze lib test && flutter test |

### 3.5 Story Skill Opportunity Synthesis

No new project skill is proposed. flutter-engine-guard and hive-schema-guard already cover the high-risk existing boundaries, while line-count and import tests make the story self-verifying.

### 3.6 Spec Quality Analyzer

| Check | Result |
|-------|--------|
| Characterization precedes mechanical moves. | Pass |
| Feature changes and adjacent cleanup are explicitly excluded. | Pass |
| Core-engine/Hive boundaries have dedicated guards. | Pass |
| All Must ACs map to tests. | Pass |
