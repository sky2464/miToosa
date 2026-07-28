# Evidence Ledger — BL-32

> **Story:** BL-32 — Privacy, consent, and iOS release configuration  
> **Updated:** 2026-07-27 (ship)

| Phase | AC | Artifact | Pointer | Verification | Exit |
|-------|----|----------|---------|--------------|------|
| build | AC-001 | test-log | test/core/analytics_consent_service_test.dart | T-001 bootstrap order | 0 |
| build | AC-002 | test-log | analytics_consent_service_test.dart | T-002 ad flags denied | 0 |
| build | AC-003 | test-log | privacy_preferences_repository_test.dart | T-003 persist opt-out | 0 |
| build | AC-004 | test-log | analytics_privacy_settings_test.dart | T-004 disclosure + policy route | 0 |
| build | AC-005 | test-log | iphone_launch_readiness_test.dart | T-005 plist + manifest | 0 |
| build | AC-006 | test-log | iphone_launch_readiness_test.dart + docs | T-006 doc audit | 0 |
| review | — | review | docs/archived/review-BL-32.md | PASS 0 critical | 0 |
| ship | — | ship-check | docs/archived/ship-check-BL-32.md | repo ship PASS | 0 |
| ship | — | test-log | full suite | 944 tests | 0 |
