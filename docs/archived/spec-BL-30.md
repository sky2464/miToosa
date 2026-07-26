# Spec: BL-30 — Track Catalog Integrity

> **Story ID:** BL-30
> **Epic:** EP-01 Launch Readiness & Validation
> **Status:** ⬜ Backlog
> **Estimate:** M
> **Clarity:** ready
> **Spec created:** 2026-07-14

## 1. Requirements

### 1.1 Goal Contract

| Field | Value |
|-------|-------|
| Goal | Make all 23 shipped puzzle tracks discoverable, correctly categorized, and intentionally illustrated. |
| User outcome | Players can filter the catalog without empty accidental results and recognize every track through a consistent visual identity. |
| Success condition | Every worlds.json entry has an approved category and artwork mapping; each catalog filter yields its declared tracks; no inactive static level artifact remains registered. |
| Proof / evidence | Asset/content validation tests, filter widget tests, catalog snapshot test, dart analyze, flutter test, and iPhone visual smoke. |
| Non-goals | Changing puzzle rules, removing any of the 23 tracks, adding a CMS/backend, or authoring a new static level system. |
| Assumptions | The 23 procedural tracks in worlds.json are the shipped catalog; planned visual assets are original or licensed with provenance recorded. |
| Risks | Hand-edited JSON can drift from source assets, and asset names can be valid paths but wrong for the track. |
| Unresolved questions | None. The user chose to keep all 23 tracks, add categories, complete visual mapping, and validate content. |

### 1.2 Brownfield Baseline

| Area | Current state | Intended delta |
|------|---------------|----------------|
| Catalog data | worlds.json contains 23 tracks but category is absent. | Add explicit category and artwork metadata to every row. |
| Filters | ContentProvider falls back to Default; category filters have no matching rows. | Validate nonempty, known categories and render correct result sets. |
| Artwork | Eight track icons cover only part of the catalog. | Supply an intentional image mapping for every shipped track. |
| Static levels | levels.json is registered but not consumed by ContentProvider. | Remove the unused registered artifact and document procedural-only source of truth. |

### 1.3 User Stories

**As a** player, **I want** category filters to show real puzzles **so that** I can choose a type of challenge quickly.

**As a** player, **I want** each track to have intentional artwork **so that** the catalog is easy to scan.

### 1.4 Acceptance Criteria (EARS)

| ID | EARS | Priority |
|----|------|----------|
| AC-001 | WHEN catalog content loads THE SYSTEM SHALL validate that all 23 track records have a nonempty approved category and unique ID. | Must |
| AC-002 | WHEN a player selects a catalog category THE SYSTEM SHALL show exactly the tracks assigned to that category and SHALL NOT show an accidental empty result. | Must |
| AC-003 | WHEN a track card renders THE SYSTEM SHALL resolve its declared artwork to an existing bundled image with no silent unknown-track fallback. | Must |
| AC-004 | WHEN a new track is added without category or artwork metadata THE SYSTEM SHALL fail content validation in test and development mode. | Must |
| AC-005 | WHEN the app is packaged THE SYSTEM SHALL register only content assets that have a production reader, and SHALL remove the unused static levels.json registration. | Must |
| AC-006 | WHEN content is updated THE SYSTEM SHALL record the asset source/provenance and required dimensions for newly introduced track art. | Should |

### 1.5 Out of Scope

- Removing, renaming, or rebalancing the existing 23 tracks.
- New puzzle types, level editor, remote content, or a gallery redesign.
- Tutorial content behavior beyond consuming the same validated track IDs.
- Brand app icon/splash production, which belongs to BL-33.

### 1.6 Failure Modes

| AC | Failure mode | Mitigation |
|----|--------------|------------|
| AC-001 | JSON parses but a category is misspelled. | Define an enum/allowlist and validate at repository load. |
| AC-002 | Filter buttons expose an empty Default category. | Generate available filters from validated categories or test each declared filter. |
| AC-003 | The image path exists in source but is omitted from pubspec assets. | Load/resolve every declared path in a validation test. |
| AC-004 | A future row accidentally relies on fallback art. | Fail fast for explicit catalog entries; safe fallback only for unexpected corrupted data. |
| AC-005 | Removing levels.json breaks an unknown reader. | Prove no production reader before removing registration and add a repository regression test. |

## 2. Design

### 2.1 Architecture Blueprint

Files to create:

- assets/content/catalog_manifest.json or an equivalent typed metadata extension, only if worlds.json cannot cleanly carry category/artwork fields.
- assets/images/icons/track_*.png for missing shipped tracks, with Docs/brand/track-asset-manifest.md provenance.
- test/core/content/catalog_validation_test.dart — content, category, and asset integrity.

Files to change:

- assets/content/worlds.json — add category and iconAsset metadata to all 23 records.
- lib/core/content_provider.dart and related track model — parse and validate category/artwork values.
- lib/features/navigation/world_map_screen.dart and track list/card widgets — use validated categories and explicit asset paths.
- pubspec.yaml — remove levels.json from registered assets after proving it unused; register any new asset directory as needed.
- Docs/AgToosa_TestPlan-BL-30.md — test evidence.

The core content layer owns schema validation. UI only consumes validated track definitions; it does not infer categories or manufacture asset names.

### 2.2 Data Flow

1. Bundled catalog JSON loads through ContentProvider.
2. The provider validates unique IDs, approved category values, one artwork path per track, and asset-path existence.
3. Validated categories drive the filter control and valid tracks drive its result count.
4. Track cards render the declared iconAsset path.
5. The validation suite fails before build if content or assets drift.

### 2.3 Threat Model (STRIDE)

| Threat | Category | Mitigation |
|--------|----------|------------|
| A malformed bundled catalog crashes startup. | Denial of Service | Validate with clear development errors and a production-safe fallback screen. |
| A crafted content row points outside bundled assets. | Tampering | Accept only normalized asset paths below assets/images/icons/. |
| Asset provenance is missing or license-incompatible. | Repudiation | Record source, license, creator, and derivative status in the asset manifest. |
| Category filtering hides tracks unintentionally. | Denial of Service | Test each category against exact expected IDs and nonzero count. |

### 2.4 Build Scope

✅ Ready to proceed — Scope Boundary
Files in scope      : assets/content/worlds.json, track icon assets and provenance manifest, content provider/models, catalog filters/cards, pubspec.yaml asset registration, catalog tests, Docs/AgToosa_TestPlan-BL-30.md, Docs/Master-Plan.md
Directories in scope: assets/content/, assets/images/icons/, lib/core/, lib/features/navigation/, test/core/content/, docs/brand/
Out of scope        : puzzle engine rules, BL-33 app icon/splash, tutorial implementation, remote catalog/CMS, active-cycle enrollment

## 3. Tasks

### 3.1 Task Tree

- [ ] **1. Catalog contract tests:** Lock the expected 23-track schema before changing data.
  - [ ] 1.1 Add RED validation tests for IDs, categories, icon paths, and category membership. — _Requirements: AC-001, AC-002, AC-003, AC-004_
  - [ ] 1.2 Add a RED test proving levels.json has no production reader before de-registration. — _Requirements: AC-005_
- [ ] **2. Content and assets:** Author the complete metadata and visual inventory.
  - [ ] 2.1 Define category allowlist and add category/iconAsset to every worlds.json row. — _Requirements: AC-001, AC-002, AC-004_
  - [ ] 2.2 Add missing original/licensed track art and provenance manifest. — _Requirements: AC-003, AC-006_
- [ ] **3. Content consumer:** Parse and render validated records.
  - [ ] 3.1 Make ContentProvider validate and expose typed category/artwork metadata. — _Requirements: AC-001, AC-003, AC-004_
  - [ ] 3.2 Update filters and cards to consume declared metadata. — _Requirements: AC-002, AC-003_
  - [ ] 3.3 Remove unused levels.json registration after the reader proof is green. — _Requirements: AC-005_
- [ ] **4. Verification:** Exercise all catalog paths.
  - [ ] 4.1 Add widget coverage for each category and visual mapping. — _Requirements: AC-002, AC-003_
  - [ ] 4.2 Run dart analyze and flutter test. — _Requirements: AC-001 through AC-005_
  - [ ] 4.3 Review all 23 cards on an iPhone-size viewport. — _Requirements: AC-002, AC-003_ [manual]

### 3.2 Wave Plan

**Wave 1 (parallel):** 1.1, 1.2
**Wave 2 (parallel after Wave 1):** 2.1, 2.2
**Wave 3 (sequential after Wave 2):** 3.1, 3.2, 3.3
**Wave 4 (sequential after Wave 3):** 4.1, 4.2, 4.3

### 3.3 Test Plan

Test plan: Docs/AgToosa_TestPlan-BL-30.md
AC coverage: 6 ACs mapped to 6 test IDs
Smoke set: T-001, T-002, T-003, T-005

### 3.4 Work Package DAG

| package_id | wave | depends_on | owned_files | inputs | outputs | merge_order | verification |
|------------|------|------------|-------------|--------|---------|-------------|--------------|
| PKG-1.1 | 1 | — | catalog validation tests | existing worlds.json | RED content contract | 1 | flutter test test/core/content/catalog_validation_test.dart |
| PKG-2.1 | 2 | PKG-1.1 | worlds.json | category schema | complete metadata | 2 | focused content test |
| PKG-2.2 | 2 | PKG-1.1 | icon assets and manifest | art brief | complete art inventory | 3 | focused content test |
| PKG-3.1 | 3 | PKG-2.1, PKG-2.2 | content provider/models | valid content | typed validation | 4 | focused content test |
| PKG-3.2 | 3 | PKG-3.1 | navigation UI and pubspec | typed data | correct filters/cards | 5 | focused widget test |
| PKG-4.1 | 4 | PKG-3.2 | tests and test plan | integrated catalog | GREEN evidence | 6 | dart analyze lib test && flutter test |

### 3.5 Story Skill Opportunity Synthesis

No new project skill is proposed. Asset provenance is a narrow manifest requirement and catalog validation belongs in ordinary Flutter/content tests.

### 3.6 Spec Quality Analyzer

| Check | Result |
|-------|--------|
| All 23-track requirements are observable through data and widget tests. | Pass |
| Content ownership is isolated from UI filtering. | Pass |
| Asset licensing/provenance is explicit. | Pass |
| Static level cleanup has a no-reader proof before removal. | Pass |
