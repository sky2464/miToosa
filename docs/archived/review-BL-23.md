# Review: BL-23 — FlutterFire iOS Config + Verify DebugView

> **Story ID:** BL-23  
> **Review date:** 2026-06-20  
> **Verdict:** PASS  
> **Critical findings:** 0  

## Goal Contract Alignment

| Field | Status | Notes |
|-------|--------|-------|
| Outcome | 🟢 Met (automated) | `firebase_options.dart` and local plist target project `mitoosa-2121b` / bundle `dev.atoosa.mitoosa`. |
| User | 🟢 Met | Launch operator runbooks and DebugView checklist in `docs/ANALYTICS-SETUP.md`. |
| Success | 🟡 Partial | Automated config path complete; live DebugView event proof deferred to T-005. |
| Proof | 🟢 Met | `flutter test` green (887); BL-23 smoke/doc tests pass; manual sign-off row open for T-005. |
| Non-goals | 🟢 Respected | No Android/Web Firebase, no PRODUCT-WEDGE changes, no App Store submit. |

## Findings

| Severity | Persona | Finding | Evidence | Disposition |
|----------|---------|---------|----------|-------------|
| 🟢 Passed | Security | `GoogleService-Info.plist` remains gitignored; threat model mitigations from spec hold. | `.gitignore`; T-004; `test/data/firebase_options_test.dart`. | No action required. |
| 🟢 Passed | Security | Debug-only analytics pulse events (`mitoosa_debug_ping` / `mitoosa_debug_pulse`) are gated on `kDebugMode` and do not run in release builds. | `lib/main.dart` lines 38–58. | No action required. |
| 🟡 Warning | Security | Analytics consent flags are granted unconditionally when Firebase is enabled; App Privacy questionnaire still external. | `lib/main.dart` `setConsent`; BL-24 backlog. | Accepted — matches existing launch analytics scaffold. |
| 🟢 Passed | Engineering | Change stays within docs/config/test scope; no file exceeds 500 lines; architecture boundaries unchanged. | Spec §2.1; `Docs/Master-Architecture.md` telemetry path. | No action required. |
| 🟢 Passed | Engineering | `test/helpers/test_safe_theme.dart` fixes InkSparkle shader failures in widget tests without production theme changes. | 887/887 tests pass. | No action required. |
| 🟡 Warning | Engineering | Debug `Timer.periodic` for analytics pulse is never cancelled (debug-only lifetime). | `lib/main.dart` | Accepted for DebugView verification window; remove or gate before long-term debug cleanup if desired. |
| 🟡 Warning | Engineering | Google Analytics admin enablement in Firebase console remains an owner checkbox (`IPHONE-LAUNCH-READINESS.md`). | Manual owner checklist | Accepted — out of repo automation scope. |
| 🟢 Passed | Product | FlutterFire configure closes BL-22 task 6.2; launch readiness and analytics docs updated. | `docs/IPHONE-LAUNCH-READINESS.md`; `docs/ANALYTICS-SETUP.md`. | No action required. |
| 🟢 Passed | QA | Must ACs AC-001–AC-004 covered by automated tests T-001–T-004; AC-006 covered by T-006. | `docs/AgToosa_TestPlan-BL-23.md`. | No action required. |
| 🟡 Warning | QA | AC-005 / T-005 DebugView manual verification remains `[manual-deferred: 2026-06-19]`. | Test plan sign-off table | Accepted — does not block repo ship; owner completes before App Store analytics gate. |
| 🟡 Warning | QA | `tags: ['smoke']` used without `smoke` declared in `dart_test.yaml` (harmless runner warning). | `firebase_options_test.dart` test output | Optional: add tag to `dart_test.yaml` in a follow-up DX chore. |

## Simplification Notes

No refactors required for ship. Optional follow-ups (non-blocking):

1. Extract debug analytics ping/pulse into a small debug-only helper if `main.dart` grows further.
2. Register `smoke` in `dart_test.yaml` to silence tag warnings.
3. Owner completes T-005 DebugView checklist and fills manual sign-off row.

## Verification Evidence

| Command | Exit | Result |
|---------|------|--------|
| `dart analyze lib test` | 0 | No issues found |
| `flutter test test/data/firebase_options_test.dart test/release/iphone_launch_readiness_test.dart` | 0 | 10/10 passed |
| `flutter test` | 0 | 887/887 passed |

**Warnings (non-blocking):** Root `dart analyze` reports errors under `build/ios/SourcePackages/…/example/` from cached SPM artifacts — excluded from gate; project `lib`/`test` analyze is clean.

## Review Gate

No unresolved 🔴 Critical findings. BL-23 can proceed to `/agtoosa-ship`. Complete T-005 DebugView manual sign-off before treating analytics as launch-verified in production.

**Suggested release:** `1.5.1` (PATCH+1 chore on v1.5.0 train per ADR-005).
