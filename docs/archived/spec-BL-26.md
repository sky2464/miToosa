# Spec: BL-26 — App Store Metadata + Screenshots Prep

> **Story ID:** BL-26  
> **Epic:** EP-01 Launch Readiness & Validation  
> **Status:** 🟦 Todo  
> **Estimate:** M  
> **Spec created:** 2026-07-11  
> **Mode:** `/agtoosa-spec quick`  
> **Renumber note:** Replaces backlog item formerly labeled BL-23 (App Store metadata). Shipped BL-23 remains FlutterFire iOS config.

## 1. Requirements

### 1.1 Goal Contract

| Field | Value |
|-------|-------|
| Goal | Make App Store Connect metadata, privacy/support copy, and screenshot capture guidance launch-ready in-repo so the owner can publish URLs and upload assets without rediscovering requirements |
| User outcome | Owner pastes finalized product-page copy, App Privacy answers, and screenshot checklist into ASC; public Privacy/Support pages have in-repo source of truth ready to host |
| Success condition | Metadata draft complete with `manual-deferred` URL placeholders; privacy policy aligned to Firebase+GA launch posture; `docs/SUPPORT.md` exists; screenshot checklist complete; automated doc guards green |
| Proof / evidence | `flutter test test/release/iphone_launch_readiness_test.dart` green; `dart analyze` clean; Must ACs mapped in `docs/AgToosa_TestPlan-BL-26.md`; manual URL publish + ASC upload remain deferred |
| Non-goals | Live URL hosting; ASC metadata/screenshot upload; TestFlight archive/upload; physical iPhone QA (BL-25); company registration; App Store submit; editing `docs/PRODUCT-WEDGE.md`; `pubspec.yaml` version bump |
| Assumptions | Hybrid scope — agent owns docs/tests; owner owns hosting + ASC execution; Firebase+GA remains the launch analytics stack when `FIREBASE_ENABLED=true` |
| Risks | Privacy copy mismatch vs analytics causes App Review rejection; owner delayed on hosting blocks submit; screenshots captured with debug banners fail quality bar |
| Unresolved questions | Exact public hosting host (GitHub Pages vs other) — left to owner; TestFlight upload remains under BL-22 manual gates |

### 1.2 User Stories

**As a** launch operator, **I want** finalized App Store metadata and screenshot guidance in-repo **so that** I can complete ASC product-page fields without drafting copy from scratch.

**As a** privacy owner, **I want** an accurate privacy policy and support page draft aligned to Firebase + Google Analytics **so that** published URLs match the submitted build.

### 1.3 Acceptance Criteria (EARS)

| ID | EARS | Priority |
|----|------|----------|
| AC-001 | WHEN `docs/APP-STORE-METADATA.md` is inspected THE SYSTEM SHALL contain complete product-page draft fields (name, subtitle, description, keywords, What's New, review notes, age/export/privacy guides) and SHALL mark Privacy Policy URL and Support URL with a consistent `manual-deferred` placeholder pattern (not bare `TODO`). | Must |
| AC-002 | WHEN `docs/PRIVACY-POLICY.md` is inspected THE SYSTEM SHALL describe local-first Hive/keychain storage **and** Firebase + Google Analytics behavior when `FIREBASE_ENABLED=true`, and SHALL NOT claim zero network transmission while launch analytics remain enabled. | Must |
| AC-003 | WHEN support documentation is inspected THE SYSTEM SHALL provide `docs/SUPPORT.md` with contact channels, response expectations, and links to privacy/user-guide artifacts suitable for public Support URL hosting. | Must |
| AC-004 | WHEN screenshot readiness is inspected THE SYSTEM SHALL provide a checklist of required iPhone scenes (onboarding, tracks, gameplay, progress/streak, settings/privacy), size/device guidance, and a quality bar (no debug banners, placeholders, or impossible state). | Must |
| AC-005 | WHEN `docs/IPHONE-LAUNCH-READINESS.md` and `docs/LAUNCH.md` are inspected THE SYSTEM SHALL cross-link metadata, privacy, support, and screenshot artifacts and SHALL keep owner URL publish and ASC upload gates as unchecked manual-deferred items. | Must |
| AC-006 | WHEN `flutter test test/release/iphone_launch_readiness_test.dart` runs THE SYSTEM SHALL assert privacy and support doc existence/required sections, metadata field completeness including `manual-deferred` URL pattern, screenshot checklist presence, and absence of stale iOS launch bundle IDs. | Must |
| AC-007 | IF the owner has not yet published live URLs THEN WHEN metadata URL fields are read THE SYSTEM SHALL distinguish deferred external publish from incomplete draft copy via the `manual-deferred` pattern. | Should |

### 1.4 Out of Scope

- Publishing live HTTPS Privacy/Support URLs (owner manual-deferred).
- Pasting metadata or uploading screenshots in App Store Connect.
- Xcode Archive, TestFlight upload, physical device QA (BL-25), App Store submit.
- Company/EIN/bank registration.
- Capturing or committing screenshot PNG/JPG assets into the repo.
- Modifying `docs/PRODUCT-WEDGE.md`.
- Bumping `pubspec.yaml` version for this docs/tests chore.
- Firebase DebugView manual sign-off (BL-23 T-005 remains separate).

### 1.5 Brownfield Drift Baseline

| Item | Current state | Intended delta |
|------|---------------|----------------|
| Metadata draft | Exists; Privacy/Support URLs are bare `TODO` | Replace with `manual-deferred` pattern; tighten screenshot checklist |
| Privacy policy | Claims no network/analytics (2026-04-17) — conflicts with Firebase+GA launch | Align copy to `FIREBASE_ENABLED=true` analytics |
| Support page | Missing (`SUPPORT.md` not found) | Add `docs/SUPPORT.md` |
| Doc tests | Guard metadata headings + launch docs; no privacy/support/URL-pattern asserts | Extend `iphone_launch_readiness_test.dart` |
| Screenshots | Text guidance only; no asset folder | Expand checklist only — no binary assets |
| Claim boundary | Docs + tests = agent-instructed; ASC/hosting = manual | Unchanged |

## 2. Design

### 2.1 Architecture Blueprint

Docs/tests-only chore. No Flutter feature modules, engines, or Hive schema changes.

| Surface | Change |
|---------|--------|
| `docs/APP-STORE-METADATA.md` | Finalize copy; `manual-deferred` URL placeholders; expand screenshot checklist |
| `docs/PRIVACY-POLICY.md` | Align analytics/network disclosures to launch posture |
| `docs/SUPPORT.md` | **New** — public support page source |
| `docs/IPHONE-LAUNCH-READINESS.md`, `docs/LAUNCH.md` | Cross-links + manual-deferred gate wording |
| `test/release/iphone_launch_readiness_test.dart` | New assertions for AC-001–AC-006 |
| `docs/AgToosa_TestPlan-BL-26.md` | AC → test ID mapping |
| `docs/Master-Plan.md` | Active Cycle enrollment; BL-23→BL-26 renumber |

### 2.2 Data Flow

1. Agent finalizes in-repo privacy, support, metadata, and screenshot checklist.
2. Automated tests guard required sections and `manual-deferred` URL pattern.
3. Owner hosts Privacy/Support pages and pastes live URLs into ASC + metadata fields.
4. Owner captures screenshots per checklist and uploads in App Store Connect.
5. BL-25 physical TestFlight QA proceeds after a TestFlight build exists (separate story).

### 2.3 Threat Model (abbreviated — `quick` mode)

| Threat | Category | Mitigation |
|--------|----------|------------|
| Public privacy policy omits Firebase/GA while release enables analytics | Information Disclosure / Repudiation | AC-002 + doc tests require analytics disclosure |
| Stale personal contact / inconsistent support channels | Spoofing / Repudiation | AC-003 SUPPORT.md as single support source; cross-link privacy contact |
| Owner submits screenshots with debug overlays | Tampering / Repudiation | AC-004 quality bar in checklist |
| Bare `TODO` URLs mistaken for complete publish | Repudiation | AC-001/AC-007 `manual-deferred` pattern + tests |

### 2.4 Build Scope

✅ Ready to proceed — Scope Boundary  
Files in scope: `docs/APP-STORE-METADATA.md`, `docs/PRIVACY-POLICY.md`, `docs/SUPPORT.md` (new), `docs/IPHONE-LAUNCH-READINESS.md`, `docs/LAUNCH.md`, `test/release/iphone_launch_readiness_test.dart`, `docs/AgToosa_TestPlan-BL-26.md`, `docs/archived/spec-BL-26.md`, `docs/Master-Plan.md`  
Directories in scope: `docs/`, `docs/archived/`, `test/release/`  
Out of scope: `docs/PRODUCT-WEDGE.md`, `pubspec.yaml` version, ASC/TestFlight execution, screenshot binaries, company registration, BL-25 physical QA

## 3. Tasks

### 3.1 Task Tree

- [ ] **1.** Privacy + support copy
  - [ ] 1.1 Align `docs/PRIVACY-POLICY.md` to Firebase+GA launch posture — _Requirements: AC-002_
  - [ ] 1.2 Add `docs/SUPPORT.md` with contact, expectations, and cross-links — _Requirements: AC-003_
- [ ] **2.** Metadata + screenshot checklist
  - [ ] 2.1 Finalize `docs/APP-STORE-METADATA.md` with `manual-deferred` URL placeholders — _Requirements: AC-001, AC-007_
  - [ ] 2.2 Expand screenshot capture checklist (scenes, sizes, quality bar) — _Requirements: AC-004_
  - [ ] 2.3 Sync `IPHONE-LAUNCH-READINESS.md` + `LAUNCH.md` cross-links and manual gates — _Requirements: AC-005_
- [ ] **3.** Automated guards + closure
  - [ ] 3.1 Extend `test/release/iphone_launch_readiness_test.dart` — _Requirements: AC-006_
  - [ ] 3.2 Verify `dart analyze` + targeted/full test suite green — _Requirements: AC-001–AC-006_
- [ ] **4.** Manual external gates
  - [ ] 4.1 Publish Privacy Policy + Support URLs and paste finals into ASC/metadata — _Requirements: AC-001, AC-005_ `[manual-deferred: 2026-07-11]`
  - [ ] 4.2 Capture iPhone screenshots per checklist and upload in App Store Connect — _Requirements: AC-004, AC-005_ `[manual-deferred: 2026-07-11]`

### 3.2 Wave Plan

**Wave 1 (parallel):** 1.1, 1.2  
**Wave 2 (sequential after Wave 1):** 2.1, 2.2, 2.3  
**Wave 3 (sequential):** 3.1, 3.2  
**Manual/deferred:** 4.1, 4.2  

### 3.3 Test Plan

See `docs/AgToosa_TestPlan-BL-26.md`.

### 3.4 Interview Record

| Q | Answer |
|---|--------|
| Q1 Scope | **A** Hybrid — repo docs/checklists + automated guards + manual ASC/screenshot sign-off |
| Q2 URLs | **A** Docs-ready — finalize in-repo copy; owner publishes URLs as manual-deferred |

---

⏳ **Awaiting approval** — reply **Approve** to append `## ✅ Spec Approved` and proceed to `/agtoosa-build`, or request edits.
