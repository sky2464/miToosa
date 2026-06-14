# Ship Check: BL-22 — iPhone Launch Readiness Prep

> **Date:** 2026-06-03  
> **Verdict:** PASS for repo docs/config ship  
> **Deployment:** No App Store deployment performed; external App Store/Firebase/company actions remain manual.

## Readiness Gate

| Check | Result | Evidence |
|-------|--------|----------|
| Spec approved | ✅ Pass | `docs/archived/spec-BL-22.md` contains `## ✅ Spec Approved`. |
| Acceptance criteria exist | ✅ Pass | `docs/archived/spec-BL-22.md` contains AC-001 through AC-008 with Must/Should priorities. |
| Review completed | ✅ Pass | `docs/archived/review-BL-22.md` exists with 0 Critical findings. |
| Tests pass | ✅ Pass | `flutter test` passed 876/876. |
| Scoped PR validation gates | ✅ Pass | `dart format` check for BL-22 release tests, `dart analyze`, `flutter pub get`, and `flutter test` ran successfully. |
| Full `scripts/verify-pr.sh` mirror | ⚠️ Not clean | Stops at repo-wide `dart format .` because unrelated non-BL-22 files would be formatted; treat as separate workspace hygiene, not a BL-22 blocker. |
| Smoke tests tagged | ✅ Pass | `docs/AgToosa_TestPlan-BL-22.md` maps smoke tests to Must ACs. |
| Changelog entry drafted | ✅ Pass | `docs/AgToosa_Changelog.md` contains BL-22 entry. |
| No WIP commits remain | ✅ Pass | No new commits were created in this working tree. |

## Manual Deferred Gates

- Apple App ID `dev.atoosa.mitoosa`
- Firebase project/iOS app and FlutterFire configure
- Public privacy/support URLs
- Xcode Archive/TestFlight upload
- Physical iPhone QA and App Privacy review

These are tracked as manual-deferred launch gates and do not block this repo-level docs/config ship.
