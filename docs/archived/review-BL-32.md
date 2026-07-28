# Review: BL-32 — Privacy, Consent, and iOS Release Configuration

> **Story ID:** BL-32  
> **Review date:** 2026-07-27  
> **Verdict:** PASS  
> **Critical findings:** 0  

## Goal Contract Alignment

| Field | Status | Notes |
|-------|--------|-------|
| Goal | 🟢 Met | Analytics default-on, disclosed, opt-out in Settings; ad consent permanently denied. |
| User outcome | 🟢 Met | Settings Privacy section with toggle + policy route; bootstrap loads preference before collection. |
| Success condition | 🟢 Met | `AnalyticsConsentService` centralizes consent; iOS plist + `PrivacyInfo.xcprivacy` aligned. |
| Proof | 🟢 Met | T-001–T-006 GREEN; 944/944 `flutter test`; `plutil -lint` OK. |
| Non-goals | 🟢 Respected | No Crashlytics, ATT, ads, or Hive schema bump. |

## Findings

| Severity | Persona | Finding | Disposition |
|----------|---------|---------|-------------|
| 🟢 Passed | Security | Single consent boundary; unit tests assert all ad flags false on every apply. | No action |
| 🟢 Passed | Security | `FIREBASE_ANALYTICS_COLLECTION_ENABLED=false` in Info.plist; preference loaded before enable in bootstrap. | No action |
| 🟢 Passed | Engineering | Three-layer split: repository → service → Settings controller; files under 500 lines. | No action |
| 🟡 Warning | Product | Task 4.2 iPhone opt-out/relaunch smoke manual-deferred. | Owner |
| 🟢 Passed | QA | AC-001–AC-006 mapped to tests T-001–T-006; focused + release guards green. | No action |

## Verification Evidence

| Command | Exit | Result |
|---------|------|--------|
| `dart analyze lib test` | 0 | 0 issues |
| `flutter test` | 0 | 944/944 |
| `plutil -lint ios/Runner/PrivacyInfo.xcprivacy` | 0 | OK |

## Cross-Model Review

**Skipped** — consent/iOS metadata scope; STRIDE mitigations verified in Part 1.

## Review Gate

No unresolved 🔴 Critical findings. BL-32 can proceed to `/agtoosa-ship`.
