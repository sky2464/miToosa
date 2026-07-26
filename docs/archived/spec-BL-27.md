# Spec: BL-27 — Generalize Lifecycle Verifier Project-ID Parsing

> **Story ID:** BL-27  
> **Epic:** EP-05 Technical Debt & Infrastructure  
> **Status:** 🏁 Shipped  
> **Estimate:** XS  
> **Spec created:** 2026-07-14

## 1. Requirements

### 1.1 Goal Contract

| Field | Value |
|-------|-------|
| Goal | Make the repository-local lifecycle verifier recognize the project IDs already used in `docs/Master-Plan.md`. |
| User outcome | Maintainers get accurate verifier results for EP-* epics and BL-* stories without changing the project plan to fit a hard-coded DEV-* convention. |
| Success condition | `bash docs/agtoosa-verify.sh --format json` recognizes EP-01 and active BL-25, evaluates its lifecycle artifacts, and no longer reports G2-epics or G3-idle solely because of ID prefixes. |
| Proof / evidence | Focused fixture-based shell tests cover the supported ID forms and negative cases; the real-project verifier exits without the ID-prefix findings; `git diff --check` passes. |
| Non-goals | Changing AgToosa's upstream generator/template, changing project IDs, parsing arbitrary Markdown text, modifying Flutter/Dart code, or changing lifecycle gate semantics beyond ID discovery. |
| Assumptions | Project IDs remain uppercase prefix plus hyphen plus one or more digits; valid IDs appear in the first column of Master-Plan pipe tables. |
| Risks | An over-broad regex could treat status text, dates, or prose as IDs and generate false lifecycle findings; a narrow allowlist could fail on future valid project prefixes. |
| Unresolved questions | None. This is a project-local compatibility patch; upstream generalization is explicitly out of scope. |

### 1.2 User Stories

**As a** project maintainer, **I want** the local verifier to discover my EP-* and BL-* rows **so that** its health findings reflect the actual Master-Plan state.

**As a** maintainer, **I want** all verifier gates to share one bounded ID-discovery rule **so that** active-cycle, review, duplicate, and evidence-profile checks cannot disagree.

### 1.3 Acceptance Criteria (EARS)

| ID | EARS | Priority |
|----|------|----------|
| AC-001 | WHEN the verifier inspects `## Epics`, THE SYSTEM SHALL recognize a first-column project ID with an uppercase alphabetic prefix and numeric suffix, including `EP-01`. | Must |
| AC-002 | WHEN the verifier inspects `## Active Cycle`, THE SYSTEM SHALL discover first-column story IDs such as `BL-25` and run the existing spec, EARS, threat-model, test-plan, task-tree, and wave-plan checks for each discovered story. | Must |
| AC-003 | WHEN the verifier discovers IDs for duplicate, done-boundary review, or evidence-profile checks, THE SYSTEM SHALL use the same project-ID rule as Gates 2 and 3. | Must |
| AC-004 | WHEN a table row contains a non-ID first-column value or an ID-looking value outside the relevant table, THE SYSTEM SHALL NOT treat it as a project story or epic. | Must |
| AC-005 | WHEN the current miToosa Master-Plan is verified, THE SYSTEM SHALL not emit `G2-epics` or `G3-idle` due to the former `DEV-###`-only parser. | Must |
| AC-006 | WHEN the patch is run in a repository that still uses `DEV-###` identifiers, THE SYSTEM SHALL preserve existing ID discovery behavior. | Should |

### 1.4 Out of Scope

- Upstream AgToosa generator/template changes or cross-repository rollout.
- Semantic validation of project-ID ownership, title formats, or story status values.
- Any change to the current finding severity, strict-mode behavior, output schema, or JSON escaping.
- Flutter app, Firebase, and iOS launch behavior.

## 2. Design

### 2.1 Architecture Blueprint

| File / artifact | Change |
|-----------------|--------|
| `docs/agtoosa-verify.sh` | Introduce one project-ID extraction pattern/helper and replace the five `DEV-###`-specific scans in Gates 2, 3, 4, and 7. |
| `test/tools/agtoosa_verify_test.sh` | Add self-contained fixture tests that invoke the verifier against minimal temporary project roots. |
| `docs/AgToosa_TestPlan-BL-27.md` | Record AC mapping and future RED/GREEN evidence. |
| `docs/Master-Plan.md` | Move BL-27 into the active cycle only after explicit approval and scheduling; no Active Tasks mutation in this draft. |

### 2.2 Parsing Contract

Define a project ID as `^[A-Z][A-Z0-9]*-[0-9]+$` in the first cell of a Markdown table row. The verifier shall extract IDs only from the bounded `## Epics` or `## Active Cycle` section currently being evaluated; it shall not scan arbitrary prose, changelog rows, acceptance criteria, or filenames.

The same helper/pattern shall supply epic existence, active-story discovery, done-boundary review, duplicate-ID telemetry, and optional evidence-profile discovery.

### 2.3 Compatibility and Rollout

This is a backwards-compatible local patch. Existing `DEV-###` IDs match the generalized rule. No data migration, config change, or user action is required. The patch is intentionally not copied to the upstream generator; a separate upstream issue is required if portability becomes necessary.

### 2.4 Threat Model

| Threat | Risk | Mitigation |
|--------|------|------------|
| Tampering | Crafted prose mimics an ID and alters verifier scope. | Extract only the first table cell inside bounded lifecycle sections. |
| Denial of service | A malformed plan yields excessive work or noisy findings. | Preserve current bounded section scans and existing `MAX_FINDINGS` limit. |
| Information disclosure | Fixture output could expose repository data. | Fixtures use temporary synthetic project roots and no secrets. |
| Spoofing | Non-story table rows are accepted as lifecycle stories. | Require the complete uppercase-prefix/numeric-suffix token and relevant table column/section. |

## 3. Tasks

### 3.1 Task Tree

- [x] **1.** Add failing verifier fixture tests
  - [x] 1.1 Add synthetic EP-01 + BL-25 fixture and assert the pre-patch verifier emits the known ID-prefix findings — _Requirements: AC-001, AC-002, AC-005_
  - [x] 1.2 Add DEV-001 compatibility and invalid-ID negative fixtures — _Requirements: AC-004, AC-006_
- [x] **2.** Generalize ID discovery
  - [x] 2.1 Add a single bounded project-ID extraction helper/pattern in `docs/agtoosa-verify.sh` — _Requirements: AC-001, AC-002, AC-003, AC-004, AC-006_
  - [x] 2.2 Replace the Gate 2, 3, 4, and 7 `DEV-###` scans with the shared helper/pattern — _Requirements: AC-001, AC-002, AC-003_
- [x] **3.** Verify the local patch
  - [x] 3.1 Run the fixture test suite, real-project verifier JSON mode, and shell syntax check — _Requirements: AC-001–AC-006_

### Wave Plan

**Wave 1 (sequential):** 1.1, 1.2 — establish RED fixture coverage before implementation.

**Wave 2 (sequential after Wave 1):** 2.1, 2.2 — implementation shares `docs/agtoosa-verify.sh` and must be merged as one coherent parser change.

**Wave 3 (sequential after Wave 2):** 3.1 — verify fixtures and the real project after the parser is updated.

### 3.2 Wave Plan (detail)

**Wave 1 (sequential):** 1.1, 1.2 — establish RED fixture coverage before implementation.

**Wave 2 (sequential after Wave 1):** 2.1, 2.2 — implementation shares `docs/agtoosa-verify.sh` and must be merged as one coherent parser change.

**Wave 3 (sequential after Wave 2):** 3.1 — verify fixtures and the real project after the parser is updated.

### 3.3 Test Plan

Test plan: `docs/AgToosa_TestPlan-BL-27.md`  
AC coverage: 6 ACs mapped to 5 test IDs  
Smoke set: T-001, T-003, T-005

### 3.4 Work Package DAG

| package_id | wave | depends_on | owned_files | inputs | outputs | merge_order | verification |
|------------|------|------------|-------------|--------|---------|-------------|--------------|
| PKG-1.1 | 1 | — | `test/tools/agtoosa_verify_test.sh` | current verifier + synthetic fixture plan | RED fixture | 1 | `bash test/tools/agtoosa_verify_test.sh` |
| PKG-1.2 | 1 | PKG-1.1 | `test/tools/agtoosa_verify_test.sh` | task 1.1 fixture | DEV compatibility and invalid-ID cases | 2 | `bash test/tools/agtoosa_verify_test.sh` |
| PKG-2.1 | 2 | PKG-1.2 | `docs/agtoosa-verify.sh` | failing fixture suite | shared ID parser | 3 | `bash -n docs/agtoosa-verify.sh` |
| PKG-2.2 | 2 | PKG-2.1 | `docs/agtoosa-verify.sh` | shared parser | all lifecycle scans use it | 4 | `bash test/tools/agtoosa_verify_test.sh` |
| PKG-3.1 | 3 | PKG-2.2 | `docs/AgToosa_TestPlan-BL-27.md`, `docs/Master-Plan.md` | completed patch | GREEN evidence and task tracking | 5 | `bash test/tools/agtoosa_verify_test.sh && bash docs/agtoosa-verify.sh --format json` |

## ✅ Spec Approved

Approved: 2026-07-14  
Enrollment: Queue BL-27 immediately after BL-25's automated tasks complete. Keep BL-25 as the sole Active Cycle story until then.
