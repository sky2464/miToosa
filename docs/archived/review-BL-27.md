# Review: BL-27 — Generalize Lifecycle Verifier Project-ID Parsing

> **Story ID:** BL-27  
> **Review date:** 2026-07-26  
> **Verdict:** PASS  
> **Critical findings:** 0  

## Goal Contract Alignment

| Field | Status | Notes |
|-------|--------|-------|
| Goal | 🟢 Met | Verifier recognizes EP-* / BL-* IDs from bounded Master-Plan tables. |
| User outcome | 🟢 Met | Maintainers get accurate lifecycle findings without DEV-* fiction. |
| Success condition | 🟢 Met | Real project verifier exit 0; no `G2-epics` / `G3-idle` from prefix parser. |
| Proof | 🟢 Met | `test/tools/agtoosa_verify_test.sh` 6/6; JSON verifier 19 pass / 0 fail. |
| Non-goals | 🟢 Respected | No upstream generator change; no Flutter/Dart edits. |

## Findings

| Severity | Persona | Finding | Evidence | Disposition |
|----------|---------|---------|----------|-------------|
| 🟢 Passed | Security | STRIDE mitigations hold: bounded section scans, no shell eval, fixture roots synthetic. | Spec §2.3; `agtoosa-verify.sh` helpers | No action required. |
| 🟢 Passed | Security | No secrets in fixture tests; temp dirs cleaned on exit. | `agtoosa_verify_test.sh` | No action required. |
| 🟡 Warning | Security | Duplicate-ID telemetry now scans all table first-columns — could count AC-* if ever placed in column 1. | `_agtoosa_master_plan_table_ids` | Accepted — Master-Plan convention uses story/epic IDs only. |
| 🟢 Passed | Engineering | Shared helper replaces five DEV-specific scans; fixture coverage for EP/BL/DEV/invalid. | Diff `agtoosa-verify.sh`; test suite | No action required. |
| 🟡 Warning | Engineering | `docs/agtoosa-verify.sh` is 737 lines (exceeds 500-line project limit). | `wc -l` | Accepted — pre-existing size; BL-38 owns modularization. |
| 🟢 Passed | Engineering | No Master Architecture boundary violations (tooling-only). | Spec build scope | No action required. |
| 🟢 Passed | Product | All Must ACs AC-001–AC-006 satisfied. | Test plan T-001–T-005; fixture assertions | No action required. |
| 🟢 Passed | QA | RED/GREEN evidence recorded; Must AC coverage complete. | `AgToosa_TestPlan-BL-27.md` | No action required. |
| 🟡 Warning | QA | No `flutter test` run required for shell-only story — fixture suite is sufficient. | Build scope | Accepted — chore limited to Bash verifier. |

## Cross-Model Review

**Tier:** Low (XS chore, Bash tooling, no runtime surface).  
**Outcome:** Skipped — virtual 4-persona review sufficient.  
**Rationale:** Local verifier patch with deterministic fixtures; no auth/network/player data paths.

## Simplification Notes

1. Removed unused `_agtoosa_is_project_id` bash helper (dead code after awk-based extraction).
2. Optional follow-up: extract ID helpers to `docs/lib/agtoosa-verify-ids.sh` under BL-38 modularization.

## Verification Evidence

| Command | Exit | Result |
|---------|------|--------|
| `bash -n docs/agtoosa-verify.sh` | 0 | Syntax OK |
| `bash test/tools/agtoosa_verify_test.sh` | 0 | 6/6 passed |
| `bash docs/agtoosa-verify.sh --format json` | 0 | 19 pass, 2 warn, 0 fail |
| `git diff --check` | 0 | Clean |

## Review Gate

No unresolved 🔴 Critical findings. BL-27 can proceed to `/agtoosa-ship`.

**Suggested release:** Chore — no `pubspec.yaml` bump; changelog under `[Unreleased]`.
