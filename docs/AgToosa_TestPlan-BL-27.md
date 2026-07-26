# Test Plan — BL-27 Lifecycle Verifier Project-ID Parsing

> **Spec:** [docs/archived/spec-BL-27.md](archived/spec-BL-27.md)  
> **Status:** Build complete (2026-07-26)  
> **Created:** 2026-07-14

## Scope

Verify that the repository-local Bash verifier recognizes project-specific IDs without widening discovery beyond first-column IDs in bounded Master-Plan tables.

## Test Cases

### T-001 — EP-* epic recognition `@smoke`

- **Category:** Shell fixture
- **AC:** AC-001, AC-005
- **Steps:** Run the verifier against a temporary Master-Plan containing an `EP-01` row under `## Epics`.
- **Pass:** JSON findings omit `G2-epics`.
- **Negative:** An empty or malformed Epics table emits `G2-epics`.

### T-002 — BL-* active story discovery

- **Category:** Shell fixture
- **AC:** AC-002
- **Steps:** Run the verifier against a temporary plan with active `BL-25`, approved spec, test plan, task tree, and wave plan.
- **Pass:** It evaluates the story artifacts and omits `G3-idle`.
- **Negative:** An Active Cycle without a valid first-column ID emits `G3-idle`.

### T-003 — Shared discovery for review and evidence `@smoke`

- **Category:** Shell fixture
- **AC:** AC-003
- **Steps:** Enable a synthetic evidence profile and create a done-boundary `BL-25` row.
- **Pass:** Review and evidence-profile checks report against `BL-25`, not an empty ID set.

### T-004 — Bounded invalid-ID handling

- **Category:** Shell fixture
- **AC:** AC-004
- **Steps:** Place `BL-25` in prose and invalid tokens (`bl-25`, `BL-abc`, `2026-07-14`) in first cells.
- **Pass:** None are discovered as lifecycle IDs.

### T-005 — DEV-* backward compatibility `@smoke`

- **Category:** Shell fixture
- **AC:** AC-006
- **Steps:** Run the verifier against a synthetic `DEV-001` epic and active story.
- **Pass:** Discovery behavior remains green.

## TDD Evidence

RED evidence — 1.1
Command: `bash test/tools/agtoosa_verify_test.sh` (against pre-patch `docs/agtoosa-verify.sh`)
Exit code: 1
Failure excerpt: real project emitted `G2-epics` and `G3-idle` despite EP-01/BL-25 rows in Master-Plan

RED evidence — 1.2
Command: `bash docs/agtoosa-verify.sh --root <fixture> --format json`
Exit code: 1
Failure excerpt: EP-01 + BL-25 synthetic fixture failed epic/active discovery (DEV-###-only parser)

GREEN evidence — 3.1
Command: `bash -n docs/agtoosa-verify.sh && bash test/tools/agtoosa_verify_test.sh && bash docs/agtoosa-verify.sh --format json`
Exit code: 0
Failure excerpt: n/a — 6 fixture assertions passed; real project verifier exit 0 (17 pass, 3 warn, 0 fail)

## Regression Commands

```bash
bash -n docs/agtoosa-verify.sh
bash test/tools/agtoosa_verify_test.sh
bash docs/agtoosa-verify.sh --format json
git diff --check
```

## TDD Evidence

RED and GREEN evidence are intentionally empty until `/agtoosa-build` executes the approved task tree.
