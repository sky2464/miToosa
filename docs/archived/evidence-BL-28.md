# Evidence Ledger — BL-28

> **Story:** BL-28 — First-run onboarding gate  
> **Claim Boundary:** agent-instructed index; Master-Plan remains SoT  
> **Updated:** 2026-07-26 13:55 (ship)

| Phase | AC | Artifact | Pointer | Verification | Exit | Reviewer | ts |
|-------|----|----------|---------|--------------|------|----------|-----|
| review | AC-001 | test-log | test/features/auth/root_routing_test.dart | T-001 fresh → onboarding | 0 | AgToosa | 2026-07-26T19:45:00Z |
| review | AC-002 | test-log | test/features/auth/root_routing_test.dart | T-002 completed → shell | 0 | AgToosa | 2026-07-26T19:45:00Z |
| review | AC-003 | test-log | test/features/auth/root_routing_test.dart | T-003 skip → shell refresh | 0 | AgToosa | 2026-07-26T19:45:00Z |
| review | AC-004 | test-log | test/features/auth/root_routing_test.dart | T-004 loading no flash | 0 | AgToosa | 2026-07-26T19:45:00Z |
| review | AC-005 | test-log | test/features/auth/root_routing_test.dart | T-005 error + retry callback | 0 | AgToosa | 2026-07-26T19:45:00Z |
| review | AC-006 | manual | Docs/Master-Plan.md Manual / Deferred | T-006 iPhone smoke deferred | — | Owner | 2026-07-26T19:45:00Z |
| review | — | review | docs/archived/review-BL-28.md | 4-persona PASS, 0 Critical | 0 | AgToosa | 2026-07-26T19:50:00Z |
| review | — | cross-model | docs/archived/review-BL-28.md## Cross-Model Review | skipped — low tier routing fix | — | AgToosa | 2026-07-26T19:50:00Z |
| ship | AC-001–AC-005 | test-log | test/features/auth/root_routing_test.dart + full suite | 7 routing + 900 total | 0 | AgToosa | 2026-07-26T19:55:00Z |
| ship | — | spec | docs/archived/spec-BL-28.md | `## ✅ Spec Approved` present | 0 | AgToosa | 2026-07-26T19:55:00Z |
| ship | — | review | docs/archived/review-BL-28.md | PASS verdict | 0 | AgToosa | 2026-07-26T19:55:00Z |
| ship | — | verifier | docs/agtoosa-verify.sh | `bash docs/agtoosa-verify.sh --format json` | 0 | AgToosa | 2026-07-26T19:55:00Z |
| ship | — | adr | docs/adr/2026-07-14-root-onboarding-state.md | status → Accepted | 0 | AgToosa | 2026-07-26T19:55:00Z |
