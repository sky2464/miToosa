# Spec: BL-25 — Physical iPhone TestFlight QA Pass

> **Story ID:** BL-25  
> **Epic:** EP-01 Launch Readiness & Validation  
> **Status:** 🟦 Todo  
> **Estimate:** M  
> **Spec created:** 2026-07-12  
> **Mode:** `/agtoosa-spec` full flow (interview skipped — documented assumptions per user directive)

## 1. Requirements

### 1.1 Goal Contract

| Field | Value |
|-------|-------|
| Goal | Execute and document a physical iPhone QA pass on a TestFlight build covering launch-critical flows before App Store submit |
| User outcome | Launch operator confirms miToosa works on a real iPhone (onboarding → gameplay → share → offline → a11y smoke → wedge copy → analytics) with captured evidence suitable for ship gate and playtest recruitment |
| Success condition | All Must ACs pass on physical iPhone TestFlight build; evidence template completed; automated doc guards green; BL-22/BL-23 manual QA/DebugView gates closed or explicitly deferred with blocker |
| Proof / evidence | Completed `docs/qa/iphone-testflight-evidence-[YYYY-MM-DD].md`; `flutter test test/release/` green; gate log entry in `docs/RELEASE-GATES.md`; DebugView screenshot or checklist sign-off |
| Non-goals | App Store submit; company registration; new product features; TestFlight upload/archive (BL-22 manual); live URL hosting (BL-26 manual); Android/macOS/Web QA; playtest survey recruitment (S1-04) |
| Assumptions | TestFlight build exists or will exist before manual tasks execute (BL-22 task 6.4); owner performs physical-device steps; `FIREBASE_ENABLED=true` release/profile build used for analytics AC; wedge economy per `docs/PRODUCT-WEDGE.md` is canonical; interview skipped — scope inferred from `IPHONE-LAUNCH-READINESS.md`, `wedge-qa-checklist.md`, BL-22/BL-23/BL-26 deferred tasks |
| Risks | No TestFlight build blocks all manual ACs; DebugView requires GA linked + device debug mode; wedge copy drift (e.g. Semantics label uses "energy" vs "free games") fails AC-009; offline test conflated with analytics upload failures |
| Unresolved questions | Exact TestFlight build number at QA time; whether QA runs on fresh install only or also upgrade path — default fresh install per wedge checklist |

### 1.2 User Stories

**As a** launch operator, **I want** a repo-hosted iPhone TestFlight QA checklist and evidence template **so that** physical-device validation is repeatable and auditable without rediscovering scenarios from BL-22.

**As a** product owner, **I want** confirmation that the free-first wedge (25 daily games, +40 share bonus) reads correctly on a real iPhone **so that** playtest recruitment (S1-04) starts from a validated build.

**As a** launch operator, **I want** Firebase DebugView verified on a physical iPhone **so that** BL-23 analytics closure and App Privacy alignment are proven before submit.

### 1.3 Acceptance Criteria (EARS)

| ID | EARS | Priority |
|----|------|----------|
| AC-001 | WHEN `docs/qa/iphone-testflight-qa-checklist.md` is inspected THE SYSTEM SHALL enumerate physical iPhone TestFlight scenarios: cold launch, onboarding, full gameplay session, settings, share flow, offline behavior, VoiceOver smoke, Dynamic Type, wedge economy copy, persistence after force quit, and broken-link/placeholder scan. | Must |
| AC-002 | WHEN `docs/qa/iphone-testflight-evidence-template.md` is inspected THE SYSTEM SHALL provide fields for build number, TestFlight version, device model, iOS version, tester, date, per-AC pass/fail, notes, and screenshot attachment slots. | Must |
| AC-003 | WHEN a TestFlight build is installed on a physical iPhone WHEN the operator cold-launches THE SYSTEM SHALL reach the app shell without crash or indefinite splash. | Must |
| AC-004 | WHEN a fresh install WHEN the operator completes onboarding THE SYSTEM SHALL allow starting a real gameplay round within 60 seconds of cold launch. | Must |
| AC-005 | WHEN the operator completes a full gameplay session THE SYSTEM SHALL finish a 3-round session without crash, soft-lock, or blocker preventing progress. | Must |
| AC-006 | WHEN the operator triggers the daily share flow THE SYSTEM SHALL grant the +40 share bonus once and SHALL NOT grant a second bonus on the same calendar day. | Must |
| AC-007 | WHEN the device has no network connectivity WHEN the operator launches and plays THE SYSTEM SHALL allow gameplay using local Hive persistence without requiring sign-in. | Must |
| AC-008 | WHEN VoiceOver is enabled WHEN the operator navigates home → track → gameplay THE SYSTEM SHALL expose non-empty Semantics labels on primary controls (smoke: at least onboarding CTA, track entry, and one gameplay control). | Must |
| AC-009 | WHEN the main economy UI is inspected THE SYSTEM SHALL present the free-games wedge framing: 25 daily free games visible and share bonus described as +40 games (not paywall-before-value or "unlock the full game" language). | Must |
| AC-010 | WHEN the TestFlight build runs with `FIREBASE_ENABLED=true` WHEN the operator starts a session THE SYSTEM SHALL display at least one miToosa analytics event in Firebase DebugView within 60 seconds. | Must |
| AC-011 | WHEN the operator force-quits and relaunches THE SYSTEM SHALL restore PlayerProgress (allowance, streak, and in-progress track state) without data loss. | Must |
| AC-012 | WHEN `flutter test test/release/iphone_launch_readiness_test.dart` runs THE SYSTEM SHALL assert the TestFlight QA checklist and evidence template exist with required section headings cross-linked from launch docs. | Must |
| AC-013 | WHEN Dynamic Type is set to the largest accessibility size WHEN the operator views onboarding and gameplay THE SYSTEM SHALL avoid clipping critical instructional text. | Should |
| AC-014 | WHEN settings and support entry points are opened THE SYSTEM SHALL not expose broken `manual-deferred` placeholder URLs as tappable dead links in the TestFlight build. | Should |
| AC-015 | IF the operator records timing WHEN evidence is filed THE SYSTEM SHALL capture time-to-first-game in seconds for playtest baseline. | Could |

### 1.4 Out of Scope

- App Store Connect submit for review.
- Company/EIN/bank registration (`docs/COMPANY-REGISTRATION-READINESS.md`).
- Xcode Archive / TestFlight upload (BL-22 manual task 6.4).
- Publishing live Privacy/Support URLs (BL-26 manual tasks 4.1–4.2).
- New gameplay features, economy rule changes, or `docs/PRODUCT-WEDGE.md` edits.
- Automated device farm / Maestro / integration tests against live TestFlight.
- Full WCAG audit (smoke only per AC-008/AC-013).
- Playtest survey design or recruitment (S1-04).

### 1.5 Brownfield Drift Baseline

| Item | Current state | Intended delta | Claim boundary |
|------|---------------|----------------|----------------|
| Physical iPhone QA | Listed in `IPHONE-LAUNCH-READINESS.md` § Physical iPhone QA — all unchecked; duplicated in Master-Plan Manual/Deferred (BL-22) | Dedicated TestFlight checklist + evidence artifact; checkboxes closed on pass | Manual execution |
| DebugView verification | BL-23 task 3.2 / T-005 manual-deferred since 2026-06-19 | Folded into BL-25 AC-010 on physical device | Manual |
| Wedge manual QA | `docs/qa/wedge-qa-checklist.md` targets web/simulator; not TestFlight-specific | iPhone TestFlight checklist adapts wedge tasks 3–6 | Agent docs + manual |
| Release tests | `test/release/iphone_launch_readiness_test.dart` — 10 tests for metadata/privacy/support; no QA checklist asserts | Extend with AC-001/AC-002/AC-012 doc guards | CI-enforced when run in PR |
| Economy copy | `world_map_screen.dart` Semantics uses "energy" label alongside free-games copy — wedge drift risk | QA flags; fix only if AC-009 fails (out of scope unless defect filed) | Manual observation |
| TestFlight build | BL-22 task 6.4 manual-deferred — upload not confirmed | Prerequisite for manual ACs; blocker if missing | Manual / owner |
| DATA-RETENTION.md | States "offline-only, no network" — conflicts with Firebase launch posture | Not in BL-25 scope; note for future doc chore | Roadmap |

**Repo evidence inventory:** `docs/IPHONE-LAUNCH-READINESS.md`, `docs/LAUNCH.md`, `docs/qa/wedge-qa-checklist.md`, `docs/ANALYTICS-SETUP.md`, `test/release/iphone_launch_readiness_test.dart`, `test/release/signing_config_test.dart`, `docs/archived/spec-BL-22.md`, `docs/archived/spec-BL-23.md`, `docs/archived/spec-BL-26.md`, `lib/features/navigation/world_map_screen.dart`, `test/features/navigation/world_map_path_screen_test.dart`.

**Source-of-truth boundary:** `Docs/Master-Plan.md` remains the repo-local source of truth; Firebase Console and TestFlight are evidence sources only.

### 1.6 Specialist Evidence (sequential lanes)

> Specialist lanes ran sequentially (platform does not support parallel subagents).

#### Specialist evidence: iphone-launch-gate

- **Findings:** `flutter test test/release/` — 17/17 passed. Bundle ID `dev.atoosa.mitoosa` locked in docs and `signing_config_test.dart`. Physical iPhone QA section in `IPHONE-LAUNCH-READINESS.md` lists 11 unchecked manual items matching BL-25 scope. Open manual-deferred gates: BL-26 URL publish + screenshots, BL-22 App ID/TestFlight upload, BL-23 DebugView.
- **Files read:** `test/release/iphone_launch_readiness_test.dart`, `test/release/signing_config_test.dart`, `docs/IPHONE-LAUNCH-READINESS.md`, `docs/LAUNCH.md`, `docs/APP-STORE-METADATA.md`
- **Commands:** `flutter test test/release/` (exit 0)
- **Warnings/errors:** TestFlight install not verifiable from repo; manual gates remain open.
- **Recommendations:** Create TestFlight-specific QA checklist; extend readiness test for checklist presence; block manual QA on TestFlight build availability.
- **Spec sections affected:** Goal Contract, ACs, Tasks, Test plan

#### Specialist evidence: wedge-economy-auditor

- **Findings:** `docs/PRODUCT-WEDGE.md` requires top-level "free games" (25 daily, +40 share). `world_map_screen.dart` Semantics label includes `${progress.freeGamesRemaining}/25 energy` — inconsistent with wedge "free games" framing; AC-009 should flag during manual pass. `wedge-qa-checklist.md` covers allowance, share anti-abuse, streak — map into TestFlight checklist. No "unlock the full game" or paywall strings found in `lib/` grep scope.
- **Files read:** `docs/PRODUCT-WEDGE.md`, `docs/qa/wedge-qa-checklist.md`, `lib/features/navigation/world_map_screen.dart`
- **Commands:** ripgrep forbidden economy terms in `lib/` (no paywall hits; "energy" present in Semantics)
- **Warnings/errors:** Semantics "energy" vs wedge "free games" — likely AC-009 fail until fixed in follow-up bug.
- **Recommendations:** Include explicit wedge copy checks in TestFlight checklist; record failures in evidence template; do not edit PRODUCT-WEDGE.
- **Spec sections affected:** ACs (AC-009), Brownfield baseline, Test plan

### 1.7 Interview Record (skipped)

User authorized proceeding with documented assumptions under Goal Contract — no interactive interview. Decision-complete checklist satisfied via codebase research and deferred-task inventory from BL-22/BL-23/BL-26.

## 2. Design

### 2.1 Architecture Blueprint

Docs/tests QA story — no engine, Hive schema, or feature-module changes unless a manual defect requires a follow-up bug.

| Surface | Change |
|---------|--------|
| `docs/qa/iphone-testflight-qa-checklist.md` | **New** — TestFlight physical iPhone scenarios mapped to AC-003–AC-011, AC-013–AC-015 |
| `docs/qa/iphone-testflight-evidence-template.md` | **New** — evidence capture template for manual sign-off |
| `docs/IPHONE-LAUNCH-READINESS.md` | Cross-link TestFlight QA artifacts; keep manual checkboxes until pass |
| `docs/LAUNCH.md` | Cross-link TestFlight QA checklist under Physical iPhone QA |
| `docs/RELEASE-GATES.md` | Gate log entry when QA completes |
| `test/release/iphone_launch_readiness_test.dart` | Assert checklist + template existence and required headings |
| `docs/AgToosa_TestPlan-BL-25.md` | AC → test ID mapping |
| `docs/Master-Plan.md` | Active Cycle enrollment; close BL-22 physical QA deferred row on manual pass |

### 2.2 Data Flow

1. Agent creates TestFlight QA checklist and evidence template; extends release readiness tests.
2. Owner ensures TestFlight build available (BL-22 manual prerequisite).
3. Operator installs TestFlight build on physical iPhone with network for first launch.
4. Operator executes checklist scenarios: onboarding → gameplay → share → offline → VoiceOver → wedge copy → persistence.
5. Operator runs analytics pass with `FIREBASE_ENABLED=true` build; confirms DebugView event (closes BL-23 T-005).
6. Operator copies evidence template to dated file; updates `RELEASE-GATES.md` gate log.
7. On all Must ACs pass, operator checks Physical iPhone QA items in `IPHONE-LAUNCH-READINESS.md` and Master-Plan manual/deferred table.

### 2.3 Threat Model (STRIDE)

| Threat | Category | Mitigation |
|--------|----------|------------|
| TestFlight build tampered or wrong bundle ID installed | Spoofing | Verify bundle `dev.atoosa.mitoosa` in TestFlight; signing_config_test guards repo ID |
| QA evidence fabricated without device run | Repudiation | Evidence template requires build number, device model, dated screenshots; manual claim boundary |
| Analytics events leak PII in DebugView screenshots | Information Disclosure | Redact device tokens/user IDs in evidence; privacy policy aligned (BL-26) |
| Offline QA misinterpreted as "no analytics" for App Privacy | Repudiation | AC-010 separate from AC-007; docs state analytics when online + `FIREBASE_ENABLED=true` |
| Placeholder support/privacy URLs shipped to testers | Tampering / Denial of Service | AC-014 checks for dead links; BL-26 manual-deferred URLs documented |
| Force-quit during Hive write corrupts progress | Tampering | AC-011 persistence check; existing HMAC integrity in PlayerProgress |

### 2.4 Build Scope

✅ Ready to proceed — Scope Boundary  
Files in scope: `docs/qa/iphone-testflight-qa-checklist.md` (new), `docs/qa/iphone-testflight-evidence-template.md` (new), `docs/IPHONE-LAUNCH-READINESS.md`, `docs/LAUNCH.md`, `docs/RELEASE-GATES.md`, `test/release/iphone_launch_readiness_test.dart`, `docs/AgToosa_TestPlan-BL-25.md`, `docs/archived/spec-BL-25.md`, `docs/Master-Plan.md`  
Directories in scope: `docs/qa/`, `docs/`, `test/release/`, `docs/archived/`  
Out of scope: `lib/` feature code (unless defect filed), `docs/PRODUCT-WEDGE.md`, App Store submit, TestFlight upload, company registration, screenshot binaries, `pubspec.yaml` version bump

## 3. Tasks

### 3.1 Task Tree

- [ ] **1.** QA documentation: TestFlight checklist + evidence template
  - [ ] 1.1 Create `docs/qa/iphone-testflight-qa-checklist.md` with scenarios for AC-003–AC-011, AC-013–AC-015 — _Requirements: AC-001_
  - [ ] 1.2 Create `docs/qa/iphone-testflight-evidence-template.md` with build/device/tester fields — _Requirements: AC-002_
  - [ ] 1.3 Cross-link checklist from `IPHONE-LAUNCH-READINESS.md`, `LAUNCH.md`, and `wedge-qa-checklist.md` — _Requirements: AC-001, AC-012_
- [ ] **2.** Automated guards
  - [ ] 2.1 Extend `test/release/iphone_launch_readiness_test.dart` to assert checklist + template sections — _Requirements: AC-012_
  - [ ] 2.2 Run `dart analyze lib test` and `flutter test` — _Requirements: AC-012_
- [ ] **3.** Manual TestFlight QA execution (physical iPhone)
  - [ ] 3.1 Install TestFlight build on physical iPhone; record build/version — _Requirements: AC-003_ `[manual-deferred]`
  - [ ] 3.2 Cold launch + onboarding; verify time-to-first-game ≤60s — _Requirements: AC-003, AC-004, AC-015_ `[manual-deferred]`
  - [ ] 3.3 Complete full 3-round gameplay session — _Requirements: AC-005_ `[manual-deferred]`
  - [ ] 3.4 Share flow: +40 bonus once; second share same day denied — _Requirements: AC-006_ `[manual-deferred]`
  - [ ] 3.5 Offline mode: airplane mode gameplay + relaunch — _Requirements: AC-007_ `[manual-deferred]`
  - [ ] 3.6 VoiceOver smoke + Dynamic Type largest — _Requirements: AC-008, AC-013_ `[manual-deferred]`
  - [ ] 3.7 Wedge copy walkthrough (25 free games, +40 share framing) — _Requirements: AC-009_ `[manual-deferred]`
  - [ ] 3.8 Force-quit persistence check — _Requirements: AC-011_ `[manual-deferred]`
  - [ ] 3.9 Settings/support link scan (no dead placeholders) — _Requirements: AC-014_ `[manual-deferred]`
- [ ] **4.** Analytics verification
  - [ ] 4.1 Firebase DebugView spot-check with `FIREBASE_ENABLED=true` on physical iPhone — _Requirements: AC-010_ `[manual-deferred]`
- [ ] **5.** Evidence closure
  - [ ] 5.1 Complete dated evidence file from template; append gate log in `RELEASE-GATES.md` — _Requirements: AC-002, AC-003–AC-011_ `[manual-deferred]`
  - [ ] 5.2 Mark Physical iPhone QA complete in `IPHONE-LAUNCH-READINESS.md` and Master-Plan manual table — _Requirements: AC-003–AC-011_ `[manual-deferred]`

### 3.2 Wave Plan

**Wave 1 (parallel):** 1.1, 1.2  
**Wave 2 (sequential after Wave 1):** 1.3  
**Wave 3 (sequential after Wave 2):** 2.1, 2.2  
**Wave 4 (manual — requires TestFlight build on device):** 3.1 → 3.2 → 3.3 → 3.4 → 3.5 → 3.6 → 3.7 → 3.8 → 3.9 → 4.1 → 5.1 → 5.2  

_Note: Wave 4 sub-tasks are sequential on one device session; parallelization not applicable._

### 3.3 Test Plan

Test plan: `docs/AgToosa_TestPlan-BL-25.md`  
AC coverage: 15 ACs mapped to 18 test IDs  
Smoke set: 6 tests tagged `@smoke`

### 3.4 Work Package DAG

| package_id | wave | depends_on | owned_files | inputs | outputs | merge_order | verification |
|------------|------|------------|-------------|--------|---------|-------------|--------------|
| PKG-1.1 | 1 | — | `docs/qa/iphone-testflight-qa-checklist.md` | BL-22/BL-26 deferred inventory | checklist file | 1 | `test -s docs/qa/iphone-testflight-qa-checklist.md` |
| PKG-1.2 | 1 | — | `docs/qa/iphone-testflight-evidence-template.md` | AC-002 fields | template file | 1 | `test -s docs/qa/iphone-testflight-evidence-template.md` |
| PKG-1.3 | 2 | PKG-1.1, PKG-1.2 | `docs/IPHONE-LAUNCH-READINESS.md`, `docs/LAUNCH.md` | Wave 1 outputs | cross-linked docs | 2 | `grep -q iphone-testflight-qa-checklist docs/IPHONE-LAUNCH-READINESS.md` |
| PKG-2.1 | 3 | PKG-1.3 | `test/release/iphone_launch_readiness_test.dart` | checklist headings | extended test | 3 | `flutter test test/release/iphone_launch_readiness_test.dart` |
| PKG-2.2 | 3 | PKG-2.1 | — | Wave 3 test file | verify report | 4 | `dart analyze lib test && flutter test` |

Manual packages 3.x–5.x are owner-executed; no `owned_files` in repo until evidence file committed (optional dated evidence under `docs/qa/`).

### 3.5 Spec Quality Analyzer

| Check | Result |
|-------|--------|
| Must ACs unambiguous and testable | Pass |
| No contradiction Goal ↔ scope ↔ tasks ↔ test plan | Pass |
| Every Must AC maps to test plan row | Pass |
| Claim boundaries classified | Pass (manual vs CI vs agent-instructed) |
| No TBD placeholders in requirements | Pass |
| Master-Plan remains source of truth | Pass |

## ✅ Spec Approved

Approved: 2026-07-12 10:19
