# Test Plan — BL-32 Privacy, Consent, and iOS Release Configuration

> **Spec:** [spec-BL-32.md](archived/spec-BL-32.md)
> **Status:** Approved — GREEN evidence captured 2026-07-27
> **Created:** 2026-07-14

## Scope & Strategy

Use fakes around Firebase analytics so collection and consent ordering are deterministic. Use static tests plus native commands for iOS metadata and the privacy manifest. Device proof confirms the actual Settings experience.

## AC Coverage Matrix

| AC ID | EARS summary | Priority | Test IDs | Category | Smoke |
|-------|--------------|----------|----------|----------|-------|
| AC-001 | Preference loads before collection | Must | T-001 | Unit/bootstrap | T-001 @smoke |
| AC-002 | Analytics only; all ad flags denied | Must | T-002 | Unit | T-002 @smoke |
| AC-003 | Opt-out persists and disables collection | Must | T-003 | Unit/widget | T-003 @smoke |
| AC-004 | Settings disclosure is clear | Must | T-004 | Widget | — |
| AC-005 | iOS release metadata/manifest are valid | Must | T-005 | Static/native | T-005 @smoke |
| AC-006 | Policy and metadata match source | Must | T-006 | Static review | T-006 @smoke |

## Test Catalog

### T-001 — Bootstrap applies saved privacy preference first @smoke
- **AC:** AC-001
- **Steps:** Use a fake preferences repository with true and false values and a fake analytics adapter recording calls.
- **Pass:** Preference read completes before collection is enabled/disabled.
- **Negative:** No analytics API invocation occurs before the value is resolved.

### T-002 — Ad consent is always denied @smoke
- **AC:** AC-002
- **Steps:** Apply both analytics-enabled and analytics-disabled states.
- **Pass:** analytics storage follows preference; ad storage, ad user data, and ad personalization are false in every call.
- **Negative:** A future true ad flag fails the test.

### T-003 — Opt-out survives relaunch @smoke
- **AC:** AC-003
- **Steps:** Toggle analytics off, recreate repository/service, and bootstrap again.
- **Pass:** UI and adapter both start disabled after relaunch; enabling later applies analytics-only consent.
- **Negative:** Failed persistence restores prior visible choice.

### T-004 — Disclosure and policy route
- **AC:** AC-004
- **Steps:** Render Settings with both preference values and tap policy affordance.
- **Pass:** Plain-language anonymous analytics explanation, effect of opt-out, and policy route/link are accessible.
- **Negative:** No ad/marketing language or unimplemented link appears.

### T-005 — iOS metadata and privacy manifest @smoke
- **AC:** AC-005
- **Steps:** Inspect Info.plist and PrivacyInfo.xcprivacy, lint manifest, and run config-only iOS build.
- **Pass:** miToosa name, portrait iPhone orientation, no unused local-network description, and valid target-bundled manifest are present.
- **Negative:** Malformed/missing/unbundled manifest or landscape iPhone release configuration fails.

### T-006 — Disclosure source-to-doc audit @smoke
- **AC:** AC-006
- **Steps:** Compare Settings copy, privacy policy, App Store metadata, and consent adapter contract.
- **Pass:** They all state anonymous optional analytics and no ad targeting; game progress stays local.
- **Negative:** Any contradiction blocks review.

### T-007 — iPhone privacy setting smoke
- **AC:** AC-003, AC-004, AC-005
- **Steps:** Toggle anonymous analytics off/on on an iPhone, force-quit, relaunch, and inspect disclosure.
- **Pass:** Choice persists and the app remains usable.
- **Negative:** Record unexpected permission prompt or collection state.

## Regression

    dart analyze lib test
    flutter test
    plutil -lint ios/Runner/PrivacyInfo.xcprivacy
    flutter build ios --config-only --no-codesign

## RED / GREEN Evidence Log

| Test ID | RED | GREEN |
|---------|-----|-------|
| T-001 | 2026-07-27 bootstrap order test added | 2026-07-27 PASS |
| T-002 | 2026-07-27 ad consent tests added | 2026-07-27 PASS |
| T-003 | 2026-07-27 persist/relaunch tests added | 2026-07-27 PASS |
| T-004 | 2026-07-27 Settings disclosure tests added | 2026-07-27 PASS |
| T-005 | 2026-07-27 plist/manifest static tests added | 2026-07-27 PASS |
| T-006 | 2026-07-27 doc audit test added | 2026-07-27 PASS |
| T-007 | — | manual-deferred |
