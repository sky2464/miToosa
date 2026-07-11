# Test Plan — BL-26 App Store Metadata + Screenshots Prep

> **Spec:** [docs/archived/spec-BL-26.md](archived/spec-BL-26.md)  
> **Coverage target:** 80% (per `docs/Context/workflow.md`)  
> **Generated:** 2026-07-11  
> **Mode:** `/agtoosa-spec quick`

## Scope & Strategy

BL-26 is a docs/tests chore. Automated tests extend `test/release/iphone_launch_readiness_test.dart` to guard metadata, privacy, support, and screenshot checklist content. URL hosting and ASC upload remain manual.

## AC Coverage Matrix

| AC ID | EARS summary | Priority | Test IDs | Category | Smoke |
|-------|--------------|----------|----------|----------|-------|
| AC-001 | Metadata complete + `manual-deferred` URL pattern | Must | T-001 | Unit / Docs | T-001 `@smoke` |
| AC-002 | Privacy policy aligned to Firebase+GA | Must | T-002 | Unit / Docs | T-002 `@smoke` |
| AC-003 | `docs/SUPPORT.md` present with contact/links | Must | T-003 | Unit / Docs | T-003 `@smoke` |
| AC-004 | Screenshot checklist (scenes + quality bar) | Must | T-004 | Unit / Docs | — |
| AC-005 | Launch readiness + LAUNCH cross-links; manual gates deferred | Must | T-005 | Unit / Docs | — |
| AC-006 | Readiness test suite asserts AC-001–AC-005 surfaces | Must | T-001–T-005 | Unit | T-001 `@smoke` |
| AC-007 | `manual-deferred` distinguishes unpublished URLs | Should | T-001 | Unit / Docs | — |

## Test Catalog

### T-001 — App Store metadata draft is complete `@smoke`
- **Category:** Unit / Docs
- **AC:** AC-001, AC-007
- **Steps:** Run `flutter test test/release/iphone_launch_readiness_test.dart` (metadata assertions).
- **Pass:** `APP-STORE-METADATA.md` contains Name, Subtitle, Description, Keywords, What's New, Privacy Policy URL, Support URL; URL fields use `manual-deferred` (not bare `TODO`).

### T-002 — Privacy policy matches launch analytics posture `@smoke`
- **Category:** Unit / Docs
- **AC:** AC-002
- **Steps:** Assert `docs/PRIVACY-POLICY.md` mentions Firebase and/or Google Analytics (or `FIREBASE_ENABLED`) and does not claim zero network when analytics enabled.
- **Pass:** Analytics disclosure present; contradictory “no network / no analytics” claims removed or scoped.

### T-003 — Support page exists `@smoke`
- **Category:** Unit / Docs
- **AC:** AC-003
- **Steps:** Assert `docs/SUPPORT.md` exists with contact channel and links to privacy and/or user guide.
- **Pass:** File present with required headings/sections.

### T-004 — Screenshot checklist is actionable
- **Category:** Unit / Docs
- **AC:** AC-004
- **Steps:** Assert metadata/screenshot section lists required scenes and a quality bar (no debug banners).
- **Pass:** Onboarding, tracks, gameplay, progress/streak, settings/privacy (or equivalent) present; quality guidance present.

### T-005 — Launch docs cross-link BL-26 artifacts and keep manual gates open
- **Category:** Unit / Docs
- **AC:** AC-005
- **Steps:** Assert `IPHONE-LAUNCH-READINESS.md` / `LAUNCH.md` reference metadata, privacy, support; URL publish / ASC upload remain unchecked manual items.
- **Pass:** Cross-links present; manual gates not falsely marked complete.

### T-006 — Manual: publish Privacy + Support URLs
- **Category:** Manual / External
- **AC:** AC-001, AC-005
- **Steps:** Host pages; paste live HTTPS URLs into ASC and update metadata fields.
- **Pass:** Live URLs open publicly; App Store Connect fields populated.

### T-007 — Manual: capture and upload iPhone screenshots
- **Category:** Manual / External
- **AC:** AC-004, AC-005
- **Steps:** Capture per checklist; upload in App Store Connect.
- **Pass:** Required device sizes uploaded; no debug overlays.

## Regression

- `dart analyze` — clean
- `flutter test` — full suite green after test updates
- No `pubspec.yaml` version bump required for this chore

## Smoke set

`T-001`, `T-002`, `T-003`
