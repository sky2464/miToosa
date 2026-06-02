# Test Plan: BL-21 — Streamline GitHub Automation and CI/CD

> **Spec reference:** [Docs/archived/spec-BL-21.md](archived/spec-BL-21.md)
> **Coverage target:** Every Must AC mapped to ≥1 test.

---

## AC Coverage Table

| AC | Description | Test IDs | Category |
|----|-------------|----------|----------|
| AC-001 | PR targets run lightweight, cached static analysis and test validation | T-001, T-002, T-008 | Bash/CI |
| AC-002 | `scripts/verify_docs_archival.sh` runs if `docs/**.md` changes | T-003 | Bash/CI |
| AC-003 | `scripts/check_prompt_injection.sh` runs if `docs/mitoosa-design-system-2/**` changes | T-004 | Bash/CI |
| AC-004 | Expensive, LLM-based, and scheduled cron workflows deleted from `.github/workflows/` | T-005 | Static-scan |
| AC-005 | Local verification and deploy scripts remain fully functional and unchanged | T-006 | Bash/Local |
| AC-006 | Caching leveraged in `pr-validation.yml` to minimize runner compute time | T-007 | Static-scan |

---

## Test Details

| ID | Test Name | AC | @smoke |
|----|-----------|-----|--------|
| T-001 | `unified_pr_validation_syntax` — Validate `.github/workflows/pr-validation.yml` exists, is syntactically valid YAML, and triggers on `pull_request` to `main` (and `workflow_dispatch`). | AC-001 | @smoke |
| T-002 | `format_analysis_and_test_execution` — Verify `.github/workflows/pr-validation.yml` contains steps executing `dart format --set-exit-if-changed`, `dart analyze`, and `flutter test`. | AC-001 | @smoke |
| T-003 | `docs_archival_filtered_execution` — Verify `.github/workflows/pr-validation.yml` contains conditional step triggering `scripts/verify_docs_archival.sh` on changes to `docs/**/*.md` or `docs/**.md`. | AC-002 | |
| T-004 | `prompt_injection_filtered_execution` — Verify `.github/workflows/pr-validation.yml` contains conditional step triggering `scripts/check_prompt_injection.sh docs/mitoosa-design-system-2/` on changes to `docs/mitoosa-design-system-2/**`. | AC-003 | |
| T-005 | `expensive_workflows_deleted` — Verify that `claude-code-review.yml`, `claude.yml`, `daily-health-check.yml`, `dependency-maintenance.yml`, `docs-archival-check.yml`, `prompt-injection-guard.yml`, and `web-build.yml` are absent from `.github/workflows/`. | AC-004 | @smoke |
| T-006 | `local_scripts_functional` — Execute `dart format`, `dart analyze`, and `flutter test` locally to ensure the test suite is fully passing (870/870 tests green) and local scripts remain untouched. | AC-005 | @smoke |
| T-007 | `workflow_uses_caching` — Verify that `.github/workflows/pr-validation.yml` leverages `actions/cache` or has `cache: true` configured on `subosito/flutter-action` to ensure optimized execution speed. | AC-006 | |
| T-008 | `verify_pr_script_parity` — Run `bash test/scripts/verify_pr_workflow_test.sh`; assert `scripts/verify-pr.sh` exists, is executable, and mirrors format/analyze/test plus conditional guards. | AC-001, AC-005 | @smoke |

---

## Notes

- All tests are static or bash-based checks of the repository state.
- Test T-006 represents local execution of the verification suite to prove the codebase remains 100% green and intact.
