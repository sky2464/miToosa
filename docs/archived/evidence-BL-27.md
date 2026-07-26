# Evidence Ledger — BL-27

> **Story:** BL-27 — Generalize lifecycle verifier project-ID parsing  
> **Claim Boundary:** agent-instructed index; Master-Plan remains SoT  
> **Updated:** 2026-07-26 13:30 (ship)

| Phase | AC | Artifact | Pointer | Verification | Exit | Reviewer | ts |
|-------|----|----------|---------|--------------|------|----------|-----|
| review | AC-001 | test-log | docs/AgToosa_TestPlan-BL-27.md#TDD-Evidence | `bash test/tools/agtoosa_verify_test.sh` T-001 | 0 | AgToosa | 2026-07-26T18:10:00Z |
| review | AC-002 | test-log | test/tools/agtoosa_verify_test.sh | T-002 BL-25 active discovery | 0 | AgToosa | 2026-07-26T18:10:00Z |
| review | AC-003 | test-log | test/tools/agtoosa_verify_test.sh | T-003 shared discovery smoke | 0 | AgToosa | 2026-07-26T18:10:00Z |
| review | AC-004 | test-log | test/tools/agtoosa_verify_test.sh | T-004 invalid-ID negative | 0 | AgToosa | 2026-07-26T18:10:00Z |
| review | AC-005 | verifier | docs/agtoosa-verify.sh | real project JSON mode | 0 | AgToosa | 2026-07-26T18:10:00Z |
| review | AC-006 | test-log | test/tools/agtoosa_verify_test.sh | T-005 DEV-001 compatibility | 0 | AgToosa | 2026-07-26T18:10:00Z |
| review | — | review | docs/archived/review-BL-27.md | 4-persona PASS, 0 Critical | 0 | AgToosa | 2026-07-26T18:15:00Z |
| review | — | cross-model | docs/archived/review-BL-27.md## Cross-Model Review | skipped — low tier tooling chore | — | AgToosa | 2026-07-26T18:15:00Z |
| ship | AC-001–AC-006 | test-log | test/tools/agtoosa_verify_test.sh | fixture suite + verifier JSON | 0 | AgToosa | 2026-07-26T18:30:00Z |
| ship | — | spec | docs/archived/spec-BL-27.md | `## ✅ Spec Approved` present | 0 | AgToosa | 2026-07-26T18:30:00Z |
| ship | — | review | docs/archived/review-BL-27.md | PASS verdict | 0 | AgToosa | 2026-07-26T18:30:00Z |
| ship | — | verifier | docs/agtoosa-verify.sh | `bash docs/agtoosa-verify.sh --format json` | 0 | AgToosa | 2026-07-26T18:30:00Z |
