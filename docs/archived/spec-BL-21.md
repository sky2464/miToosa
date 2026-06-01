# Spec: BL-21 — Streamline GitHub Automation and CI/CD

> **Story ID:** BL-21
> **GitHub Issue:** N/A (Master-Plan.md source of truth)
> **Epic:** EP-05 — Technical Debt & Infrastructure
> **Status:** ✅ Done
> **Type:** Chore
> **Priority:** Low
> **Estimate:** S
> **Spec created:** 2026-05-20

---

## Build Scope

✅ Ready to proceed — Scope Boundary
Files in scope      :
- `.github/workflows/claude-code-review.yml` (deleted)
- `.github/workflows/claude.yml` (deleted)
- `.github/workflows/daily-health-check.yml` (deleted)
- `.github/workflows/dependency-maintenance.yml` (deleted)
- `.github/workflows/docs-archival-check.yml` (deleted)
- `.github/workflows/prompt-injection-guard.yml` (deleted)
- `.github/workflows/web-build.yml` (deleted)
- `.github/workflows/pr-validation.yml` (new — unified PR check)
- `docs/decisions/remove-expensive-ci-cd.md` (new — ADR)
- `docs/Context/CONTEXT.md` (new — domain terms)
- `docs/Context/tech-stack.md` (modified)
- `docs/Master-Plan.md` (modified)
Out of scope        :
- Modifying local testing/verification scripts (`scripts/deploy-staging.sh`, `scripts/check_prompt_injection.sh`, `scripts/verify_docs_archival.sh`)
- Production code changes in `lib/` or `test/`
- Modifying the local Flutter/Dart test environment or configuration

---

## 1. Requirements

### 1.1 User Stories

**As a** repository maintainer, **I want** to remove expensive scheduled and interactive Claude AI GitHub Actions **so that** we eliminate high compute costs and external LLM token bills.

**As a** developer contributing to the codebase, **I want** a unified, cached, and lightweight pull-request validation workflow **so that** we enforce code quality, static analysis, and test suites quickly and automatically on every PR.

**As a** core contributor, **I want** all existing local deployment and verification scripts to remain operational and clean **so that** development workflows are not disrupted.

### 1.2 Acceptance Criteria (EARS)

| ID | EARS | Priority |
|----|------|----------|
| AC-001 | WHEN a developer triggers CI on a Pull Request targeting `main` THE SYSTEM SHALL run a lightweight `pr-validation.yml` workflow checking Dart formatting, static analysis, and running unit/widget tests. | Must |
| AC-002 | WHEN the PR contains changes to documentation (`docs/**.md`) THE SYSTEM SHALL execute `scripts/verify_docs_archival.sh` inside the `pr-validation.yml` run to ensure correctness. | Must |
| AC-003 | WHEN the PR contains changes to the design system (`docs/mitoosa-design-system-2/**`) THE SYSTEM SHALL execute `scripts/check_prompt_injection.sh` inside the `pr-validation.yml` run to ensure no injection patterns exist. | Must |
| AC-004 | WHEN the workflows catalog is updated THE SYSTEM SHALL have deleted `claude-code-review.yml`, `claude.yml`, `daily-health-check.yml`, `dependency-maintenance.yml`, `docs-archival-check.yml`, `prompt-injection-guard.yml`, and `web-build.yml` from `.github/workflows/`. | Must |
| AC-005 | WHILE the expensive scheduled and LLM workflows are deleted in CI THE SYSTEM SHALL retain all local verification and deployment scripts (`scripts/deploy-staging.sh`, `scripts/check_prompt_injection.sh`, `scripts/verify_docs_archival.sh`) fully operational for manual/local developer use. | Must |
| AC-006 | WHEN actions are run in the `pr-validation.yml` workflow THE SYSTEM SHALL leverage actions caching (`actions/cache` or `subosito/flutter-action` cache) to minimize runner compute time and optimize setup speed. | Must |

### 1.3 Out of Scope

- Rewriting the local game logic or testing frameworks.
- Deploying to production environments from CI (kept local only to protect credentials).
- Modifying security allowlists or adding any runtime detection.

---

## 2. Design

### 2.1 Architecture Blueprint

We are consolidating all CI behaviors into a single, path-filtered PR validation workflow:

- **Deleted Workflows**: Removes all interactive LLM workflows and crons, dropping compute consumption significantly.
- **Unified `pr-validation.yml`**:
  - Triggers only on Pull Requests targeting `main`.
  - Sets up Flutter via `subosito/flutter-action@v2` with `cache: true`.
  - Runs `flutter pub get` and checks formatting/analyzes code.
  - Runs full test suite `flutter test`.
  - Performs path-based checks:
    - Runs `scripts/verify_docs_archival.sh` only if `docs/**.md` changes.
    - Runs `scripts/check_prompt_injection.sh docs/mitoosa-design-system-2/` only if design files change.

### 2.2 STRIDE Threat Model

| Threat | Category | Mitigation |
|--------|----------|------------|
| Secrets exposure in CI runners (e.g. Firebase deploy tokens) | Information Disclosure | Delete the `web-build.yml` deploying staging; require all deployments to run locally from dev machines via `scripts/deploy-staging.sh`. |
| Malicious PR introducing prompt injections | Tampering | Keep the path-based prompt injection guard running in `pr-validation.yml` so any doc changes are scanned before merge. |
| Insecure dependencies or code quality regression | Tampering | Unified static analysis and `flutter test` run on all incoming PRs. |
| CI runner compute minute exhaustion | Denial of Service | Consolidated workflow runs only on PRs, eliminating crons, and leverages caching to finish in < 3 minutes. |

---

## 3. Tasks

### 3.1 Task Tree

- [x] **1.** Documentation & Speccing
  - [x] 1.1 Create `docs/Context/CONTEXT.md` to register canonical domain dictionary terms. — _Requirements: AC-005_
  - [x] 1.2 Draft ADR `docs/decisions/remove-expensive-ci-cd.md` in `Proposed` status. — _Requirements: AC-004, AC-005_
  - [x] 1.3 Generate Executable Spec `docs/archived/spec-BL-21.md` with 6 EARS ACs. — _Requirements: All ACs_
  - [x] 1.4 Create `docs/AgToosa_TestPlan-BL-21.md` mapping ACs to verification steps T-001 through T-007. — _Requirements: All ACs_
- [x] **2.** GitHub Workflow Deletions
  - [x] 2.1 Delete expensive Claude workflows (`claude.yml`, `claude-code-review.yml`). — _Requirements: AC-004_
  - [x] 2.2 Delete expensive cron & redundant check workflows (`daily-health-check.yml`, `dependency-maintenance.yml`, `docs-archival-check.yml`, `prompt-injection-guard.yml`, `web-build.yml`). — _Requirements: AC-004_
- [x] **3.** Unified Validation Workflow
  - [x] 3.1 Create `.github/workflows/pr-validation.yml` triggering only on Pull Requests targeting `main`. — _Requirements: AC-001_
  - [x] 3.2 Configure `pr-validation.yml` to run standard Flutter setup, cache dependencies, run `dart analyze`, and `flutter test`. — _Requirements: AC-001, AC-006_
  - [x] 3.3 Integrate conditional/path-filtered execution of local guards (`check_prompt_injection.sh` if design system changes, `verify_docs_archival.sh` if documentation changes). — _Requirements: AC-002, AC-003_
- [x] **4.** Finishing & Verification
  - [x] 4.1 Update ADR `docs/decisions/remove-expensive-ci-cd.md` to `Accepted` status. — _Requirements: AC-004_
  - [x] 4.2 Update workflow list in `docs/Context/tech-stack.md` to reflect `pr-validation.yml`. — _Requirements: AC-001_
  - [x] 4.3 Verify `scripts/deploy-staging.sh` runs successfully. `[manual-done]` — _Requirements: AC-005_
  - [x] 4.4 Verify local testing frameworks are fully operational and all tests pass (870/870 tests passing). — _Requirements: AC-005_
  - [x] 4.5 Re-reconcile `docs/Master-Plan.md` tables and Update Log. — _Requirements: All ACs_

### 3.2 Test Plan

Verification Steps:
- **T-001**: Verify deleted workflow files are absent.
- **T-002**: Verify unified workflow has correct syntax and PR triggers.
- **T-003**: Verify static analysis and test suite pass locally.
- **T-004**: Verify path-filtering in workflow behaves as expected.
- **T-005**: Verify local deployment script functions.
- **T-006**: Verify ADR is marked as Accepted.
- **T-007**: Verify Master-Plan and Tech-Stack documentation are consistent.

---

## ✅ Spec Approved

Approved: 2026-05-20 03:00
