# Spec: BL-33 — Production Brand Assets

> **Story ID:** BL-33
> **Epic:** EP-01 Launch Readiness & Validation
> **Status:** ⬜ Backlog
> **Estimate:** S
> **Clarity:** ready
> **Spec created:** 2026-07-14

## 1. Requirements

### 1.1 Goal Contract

| Field | Value |
|-------|-------|
| Goal | Replace stock Flutter and placeholder launch assets with a production Aetheric Pulse constellation/spark identity. |
| User outcome | The installed iPhone app presents a recognizable miToosa mark from SpringBoard through launch, without a generic framework icon or blank placeholder screen. |
| Success condition | A text-free constellation/spark master mark produces valid iOS and Android icon variants; native launch assets are branded and non-placeholder; all source/license/provenance details are recorded. |
| Proof / evidence | Asset dimension/hash manifest, generated platform asset inspection, iOS config build, screenshot comparison, dart analyze, flutter test, and physical-device install smoke. |
| Non-goals | A new marketing site, animated promo video, a wordmark, changing in-app design tokens, or modifying docs/PRODUCT-WEDGE.md. |
| Assumptions | The user approved a new Aetheric Pulse constellation/spark mark with no text; source art will be original or explicitly licensed and reviewed before use. |
| Risks | Icon complexity can disappear at small sizes; generated assets can be stale or missing target membership; source art may lack license provenance. |
| Unresolved questions | None. The approved art direction is a text-free constellation/spark mark. |

### 1.2 Brownfield Baseline

| Area | Current state | Intended delta |
|------|---------------|----------------|
| App icon | iOS 1024px icon is the stock Flutter mark. | Replace with the approved custom master-derived asset set. |
| Launch assets | Legacy LaunchImage PNGs are one-pixel placeholders. | Use a real native launch visual that matches the brand system. |
| Display naming | iOS label currently uses Mitoosa casing. | BL-32 updates the metadata to miToosa; this story supplies the visual identity. |
| Asset records | No production brand provenance manifest exists. | Add source, license, dimensions, hashes, and generation commands. |

### 1.3 User Stories

**As a** player, **I want** miToosa to look intentional when I install and open it **so that** I recognize the game immediately.

**As a** maintainer, **I want** repeatable platform asset generation and provenance **so that** future releases cannot regress to placeholders.

### 1.4 Acceptance Criteria (EARS)

| ID | EARS | Priority |
|----|------|----------|
| AC-001 | WHEN the app icon is rendered at iPhone home-screen sizes THE SYSTEM SHALL show the approved constellation/spark mark without text, stock Flutter artwork, or illegible detail. | Must |
| AC-002 | WHEN iOS and Android icon assets are generated THE SYSTEM SHALL derive all required variants from one approved master source and produce no missing target slots. | Must |
| AC-003 | WHEN the native launch surface appears THE SYSTEM SHALL present a branded non-placeholder visual that does not rely on a one-pixel legacy image. | Must |
| AC-004 | WHEN brand assets are added or regenerated THE SYSTEM SHALL record source, license, creator/derivative status, dimensions, hashes, and generation command. | Must |
| AC-005 | WHEN a release build is installed THE SYSTEM SHALL use miToosa visual identity consistently across app icon, launch surface, and existing Aetheric Pulse in-app styling. | Should |
| AC-006 | WHEN automated asset checks run THE SYSTEM SHALL fail if a tracked platform icon is the known stock Flutter image or a required slot is missing. | Must |

### 1.5 Out of Scope

- Copy/logo-wordmark design, new fonts, onboarding rework, or App Store screenshot production.
- Marketing creative, social media packs, videos, and splash animation.
- Any new remote asset downloader or runtime network dependency.
- Privacy/Info.plist naming configuration except coordination with BL-32.

### 1.6 Failure Modes

| AC | Failure mode | Mitigation |
|----|--------------|------------|
| AC-001 | Detailed constellation is unreadable at 60px. | Define small-size test renders and simplify master shape before generation. |
| AC-002 | One platform scale remains stale. | Generate from source in a scripted/reviewable command and validate required paths. |
| AC-003 | Launch screen still falls back to blank/placeholder art. | Inspect compiled iOS launch surface and prohibit legacy one-pixel assets. |
| AC-004 | Art source cannot be proved or re-generated. | Require manifest entry before accepting asset files. |
| AC-006 | A later merge restores stock Flutter icon. | Hash/visual regression test against known placeholder files. |

## 2. Design

### 2.1 Architecture Blueprint

Files to create:

- assets/brand/aetheric_pulse_mark_1024.png — approved master, text-free and source-controlled.
- docs/brand/launch-asset-manifest.md — source/license/dimensions/hashes/generation record.
- tool/generate_brand_assets.dart or a pinned launcher-icon configuration — repeatable asset generation.
- test/release/brand_assets_test.dart — platform slot, dimension, and placeholder regression checks.

Files to change:

- ios/Runner/Assets.xcassets/AppIcon.appiconset/ — generated iOS app icon slots.
- ios/Runner/Base.lproj/LaunchScreen.storyboard and/or referenced asset catalog — branded launch surface.
- android/app/src/main/res/ — generated Android launcher variants.
- pubspec.yaml only if an approved generation tool needs configuration.
- Docs/AgToosa_TestPlan-BL-33.md — test evidence.

The master asset is the source of truth. Generated platform files are checked in so release builds do not depend on a local asset tool.

### 2.2 Data Flow

1. A reviewed master PNG is added with a manifest record.
2. The generation tool produces target-specific icon sizes and launch support assets.
3. Validation checks required paths, dimensions, expected hashes, and absence of legacy placeholder signatures.
4. A config-only iOS build packages assets into the Runner target.
5. Device/simulator screenshots validate small-size legibility and launch presentation.

### 2.3 Threat Model (STRIDE)

| Threat | Category | Mitigation |
|--------|----------|------------|
| Unlicensed third-party art enters a release. | Repudiation | Asset manifest requires source/license/creator status before merge. |
| A generated asset path is replaced with a stock icon. | Tampering | Hash/placeholder regression test and reviewable generator input. |
| Missing asset slot causes install/build failure. | Denial of Service | Validate all required platform slots before release build. |
| Icon embeds unintended personal/trademark content. | Information Disclosure / Spoofing | Use approved original art and human asset review. |

### 2.4 Build Scope

✅ Ready to proceed — Scope Boundary
Files in scope      : approved master mark, generated iOS/Android icon sets, native launch asset/storyboard, asset generator configuration, provenance manifest, asset tests, Docs/AgToosa_TestPlan-BL-33.md, Docs/Master-Plan.md
Directories in scope: assets/brand/, ios/Runner/Assets.xcassets/, ios/Runner/Base.lproj/, android/app/src/main/res/, docs/brand/, test/release/
Out of scope        : marketing assets, app copy, design-system redesign, runtime asset loading, active-cycle enrollment

## 3. Tasks

### 3.1 Task Tree

- [ ] **1. Asset contract tests:** Define source and generated-file requirements before replacement.
  - [ ] 1.1 Add RED tests for required platform slots, dimensions, and placeholder rejection. — _Requirements: AC-002, AC-006_
  - [ ] 1.2 Add a provenance-manifest validation test. — _Requirements: AC-004_
- [ ] **2. Master and generation:** Create the approved identity and reproducible variants.
  - [ ] 2.1 Add the approved constellation/spark master with provenance record. — _Requirements: AC-001, AC-004_
  - [ ] 2.2 Add/pin generation workflow and produce iOS/Android icon variants. — _Requirements: AC-002, AC-006_
- [ ] **3. Native launch surface:** Replace legacy placeholders.
  - [ ] 3.1 Update the iOS launch surface to use branded non-placeholder assets. — _Requirements: AC-003, AC-005_
  - [ ] 3.2 Remove obsolete one-pixel launch-image assets only after launch validation is green. — _Requirements: AC-003_
- [ ] **4. Verification:** Inspect generated and installed presentation.
  - [ ] 4.1 Run asset tests, flutter test, and iOS config build. — _Requirements: AC-002, AC-003, AC-004, AC-006_
  - [ ] 4.2 Capture iPhone home-screen and cold-launch smoke screenshots. — _Requirements: AC-001, AC-003, AC-005_ [manual]

### 3.2 Wave Plan

**Wave 1 (parallel):** 1.1, 1.2
**Wave 2 (sequential after Wave 1):** 2.1, 2.2
**Wave 3 (sequential after Wave 2):** 3.1, 3.2
**Wave 4 (sequential after Wave 3):** 4.1, 4.2

### 3.3 Test Plan

Test plan: Docs/AgToosa_TestPlan-BL-33.md
AC coverage: 6 ACs mapped to 6 test IDs
Smoke set: T-001, T-002, T-003, T-005

### 3.4 Work Package DAG

| package_id | wave | depends_on | owned_files | inputs | outputs | merge_order | verification |
|------------|------|------------|-------------|--------|---------|-------------|--------------|
| PKG-1.1 | 1 | — | brand asset tests | current icon assets | RED regression suite | 1 | flutter test test/release/brand_assets_test.dart |
| PKG-1.2 | 1 | — | asset manifest test | manifest schema | RED provenance suite | 2 | focused flutter test |
| PKG-2.1 | 2 | PKG-1.1, PKG-1.2 | master and manifest | approved direction | source identity | 3 | focused flutter test |
| PKG-2.2 | 2 | PKG-2.1 | generator and platform icons | master mark | generated variants | 4 | focused flutter test |
| PKG-3.1 | 3 | PKG-2.2 | iOS launch assets | generated visuals | branded launch surface | 5 | flutter build ios --config-only --no-codesign |
| PKG-4.1 | 4 | PKG-3.1 | tests/test plan | packaged assets | GREEN evidence | 6 | flutter test && flutter build ios --config-only --no-codesign |

### 3.5 Story Skill Opportunity Synthesis

No new project skill is proposed. Asset generation is a bounded one-story workflow with a checked-in manifest and regression test.

### 3.6 Spec Quality Analyzer

| Check | Result |
|-------|--------|
| Approved visual direction is explicit and no text wordmark is introduced. | Pass |
| Asset provenance and repeatability are required. | Pass |
| Every Must AC has testable platform evidence. | Pass |
| In-app design changes remain out of scope. | Pass |
