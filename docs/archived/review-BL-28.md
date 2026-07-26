# Review: BL-28 — First-Run Onboarding Gate

> **Story ID:** BL-28  
> **Review date:** 2026-07-26  
> **Verdict:** PASS  
> **Critical findings:** 0  

## Goal Contract Alignment

| Field | Status | Notes |
|-------|--------|-------|
| Goal | 🟢 Met | Fresh anonymous players route through onboarding before `MainAppShell`. |
| User outcome | 🟢 Met | First-time players see introduction; returning players resume shell. |
| Success condition | 🟢 Met | Declarative root uses auth + `onboardingComplete`; loading/error paths deterministic. |
| Proof | 🟢 Met | 7 routing widget tests; `flutter test` 900/900; `dart analyze` clean. |
| Non-goals | 🟢 Respected | No onboarding copy rewrite, schema change, or tutorial scope creep. |

## Findings

| Severity | Persona | Finding | Evidence | Disposition |
|----------|---------|---------|----------|-------------|
| 🟢 Passed | Security | STRIDE mitigations from spec hold: generic error copy, no storage internals in UI; completion from persisted progress not auth ID. | `root_app_router.dart`; spec §2.3 | No action required. |
| 🟢 Passed | Security | No new network surface; local Hive persistence path unchanged. | Build scope | No action required. |
| 🟢 Passed | Engineering | `RootAppRouter` centralizes destination selection; `login_screen.dart` no longer imperatively replaces root. | Diff | No action required. |
| 🟢 Passed | Engineering | All changed files under 500 lines (`root_app_router.dart` 122 lines). | `wc -l` | No action required. |
| 🟡 Warning | Engineering | ADR `docs/adr/2026-07-14-root-onboarding-state.md` was Proposed — update to **Accepted** on ship. | ADR file | Addressed in ship docs step. |
| 🟡 Warning | Engineering | `OnboardingScreen.onComplete` is `VoidCallback`; async `_completeOnboarding` is fire-and-forget (invalidate may race if tapped twice). | `root_app_router.dart:40` | Accepted — low risk; onboarding CTA is single-shot. |
| 🟢 Passed | Product | Must ACs AC-001–AC-005 satisfied by automated tests. | `AgToosa_TestPlan-BL-28.md` | No action required. |
| 🟡 Warning | Product | AC-006 (iPhone fresh-install ≤60s) remains manual-deferred (task 3.3). | Master-Plan Manual / Deferred | Accepted — owner executes on device. |
| 🟢 Passed | QA | TDD RED/GREEN logged; smoke tests T-001–T-003, T-005 tagged in test plan. | Test plan evidence log | No action required. |
| 🟡 Warning | QA | T-005 end-to-end retry→onboarding path split: error UI test + `AppStartupError` callback unit test (async `overrideWith` throw did not surface error in widget integration). | `root_routing_test.dart` | Accepted — retry callback and error surface covered separately. |

## Cross-Model Review

**Tier:** Low (S fix, local routing, no auth/network expansion).  
**Outcome:** Skipped — virtual 4-persona review sufficient.  
**Rationale:** Declarative Flutter widget gate with deterministic provider overrides; threat model mitigations unchanged.

## Simplification Notes

1. Removed ~40 lines of duplicate `Navigator.pushReplacement` routing from `LoginScreen`.
2. `AppStartupLoading` / `AppStartupError` are co-located with router — acceptable for S story; extract to `lib/app/startup/` only if reused elsewhere.

## Verification Evidence

| Command | Exit | Result |
|---------|------|--------|
| `dart analyze lib test` | 0 | No issues |
| `flutter test test/features/auth/root_routing_test.dart` | 0 | 7/7 passed |
| `flutter test` | 0 | 900/900 passed |
| `bash docs/agtoosa-verify.sh --format json` | 0 | 17 pass, 3 warn, 0 fail |

## Review Gate

No unresolved 🔴 Critical findings. BL-28 can proceed to `/agtoosa-ship`.

**Suggested release:** PATCH — app fix (`v1.5.1` train); no `pubspec.yaml` bump required until store release bundle.
