# Ship Check — BL-32

> **Story:** BL-32 — Privacy, consent, and iOS release configuration  
> **Date:** 2026-07-27  
> **Verdict:** repo ship PASS  

## Readiness Gate

| Check | Status |
|-------|--------|
| Goal Contract satisfied | ✅ |
| Spec approved | ✅ |
| Review approved (0 critical) | ✅ |
| `flutter test` green | ✅ 944/944 |
| `dart analyze` clean | ✅ |
| Privacy manifest lint | ✅ `plutil -lint` OK |
| Changelog entry | ✅ |
| Manual deferred documented | ✅ task 4.2 |

## Deploy

Repo-only ship — no App Store submission in scope.

## Deferred

- Task 4.2 — iPhone analytics enable/disable/relaunch smoke (owner)
