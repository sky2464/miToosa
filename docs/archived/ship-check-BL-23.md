# Ship Check: BL-23 — FlutterFire iOS Config + Verify DebugView

> **Date:** 2026-06-20  
> **Verdict:** PASS for repo config/docs/test ship  
> **Deployment:** No App Store / TestFlight deployment performed; iOS store release remains manual per `docs/IPHONE-LAUNCH-READINESS.md`.

## Readiness Gate

| Check | Result | Evidence |
|-------|--------|----------|
| Goal Contract satisfied | ✅ Pass (automated) | AC-001–AC-004, AC-006 met; AC-005 manual deferred per launch policy. |
| Spec approved | ✅ Pass | `docs/archived/spec-BL-23.md` contains `## ✅ Spec Approved`. |
| Acceptance criteria exist | ✅ Pass | 6 Must + 1 Should AC rows in archived spec. |
| Review completed | ✅ Pass | `docs/archived/review-BL-23.md` — 0 Critical, 5 warnings. |
| Tests pass | ✅ Pass | `flutter test` — 887/887. |
| Smoke tests tagged | ✅ Pass | 3 tests with `tags: ['smoke']` in `firebase_options_test.dart`; `flutter test --tags smoke` — 3/3. |
| Changelog entry drafted | ✅ Pass | `Docs/AgToosa_Changelog.md` — [1.5.1] BL-23 entry. |
| No WIP commits remain | ✅ Pass | No `WIP:` subject lines on `main`. |
| Verifier | ⚠️ Known false positive | `agtoosa-verify.sh` expects `DEV-XXX` epic IDs; project uses `EP-XX`. Non-blocking. |

## Smoke Tests

| Command | Exit | Result |
|---------|------|--------|
| `flutter test --tags smoke` | 0 | 3/3 passed |
| `flutter test` | 0 | 887/887 passed |

## Manual Deferred Gates

- **T-005 DebugView** — owner runs `flutter run -d iPhone --dart-define=FIREBASE_ENABLED=true` and confirms events in Firebase Console → Analytics → DebugView (checklist in `docs/ANALYTICS-SETUP.md`).
- Google Analytics enablement in Firebase admin console.
- Xcode Archive → TestFlight → App Store submit.
- Physical iPhone QA and App Privacy review.

These do not block this repo-level FlutterFire configuration ship.

## Deploy Evidence

**[manual]** iOS App Store deployment is owner-operated. No CI deploy command documented in `Docs/Context/tech-stack.md` for store release. Repo ship records config + docs + test coverage only.
