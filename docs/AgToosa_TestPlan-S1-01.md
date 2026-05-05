# AgToosa Test Plan — S1-01 Staging Deployment & QA Gate

Spec reference: `docs/AgToosa_Spec-S1-01.md`
Coverage target: 80% (from `docs/Context/workflow.md`)

## AC Coverage Table

| AC | Test ID | Category | Smoke | Scenario | Expected Result |
|----|---------|----------|-------|----------|-----------------|
| AC-001 | T-001 | Integration | @smoke | CI runs without `FIREBASE_TOKEN` | Analyze/Test/Build pass; deploy step skipped |
| AC-001 | T-002 | Security |  | Push on non-main ref | Deploy step not executed |
| AC-002 | T-003 | Unit | @smoke | `scripts/deploy-staging.sh` exists and executable | Script has shebang, `set -euo pipefail`, and execute bit |
| AC-002 | T-004 | Integration |  | Run script with missing `firebase` | Script fails fast with actionable install message |
| AC-003 | T-005 | Integration | @smoke | Main push with `FIREBASE_TOKEN` set | Firebase deploy step executes |
| AC-003 | T-006 | Security |  | Deploy step runtime logging | Token is only read from env; not echoed |
| AC-004 | T-007 | Unit | @smoke | Review `docs/RELEASE-GATES.md` | Staging status says pending Firebase setup and Sprint 1 build row exists |
| AC-005 | T-008 | Unit | @smoke | Review `docs/STAGING-SETUP.md` | Manual Firebase setup steps documented with command examples |

## Negative/Edge Scenarios

- T-002: Branch gate edge case — deploy never runs on PR refs.
- T-004: Missing CLI dependency edge case — script exits with clear remediation.
- T-006: Secret handling edge case — no plaintext token output.

## Environment Requirements

- GitHub Actions runner with Flutter and npm
- Optional Firebase CLI and valid `FIREBASE_TOKEN` for deploy execution path
- Local shell for script validation (`bash`)
