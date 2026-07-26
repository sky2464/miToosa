# Test Plan — BL-33 Production Brand Assets

> **Spec:** [spec-BL-33.md](archived/spec-BL-33.md)
> **Status:** Draft pending approval
> **Created:** 2026-07-14

## Scope & Strategy

Validate the source master, generated platform slots, launch asset, and asset provenance before manual visual review. Device screenshots remain the proof for recognizability at real iPhone sizes.

## AC Coverage Matrix

| AC ID | EARS summary | Priority | Test IDs | Category | Smoke |
|-------|--------------|----------|----------|----------|-------|
| AC-001 | Icon is approved readable mark | Must | T-001 | Visual/manual | — |
| AC-002 | Required platform variants exist | Must | T-002 | Static/native | T-002 @smoke |
| AC-003 | Launch surface is branded | Must | T-003 | Static/native | T-003 @smoke |
| AC-004 | Provenance is complete | Must | T-004 | Static | T-004 @smoke |
| AC-005 | Installed brand is consistent | Should | T-005 | Manual device | — |
| AC-006 | No stock/placeholder asset remains | Must | T-006 | Static | T-006 @smoke |

## Test Catalog

### T-001 — Small-size constellation/spark review
- **AC:** AC-001
- **Steps:** Render master-derived icon at common iPhone home-screen and Settings sizes.
- **Pass:** Text-free mark remains recognizable, uncluttered, and not confused with Flutter/default artwork.
- **Negative:** Reject unreadable fine-detail variants.

### T-002 — Generated platform slot inventory @smoke
- **AC:** AC-002
- **Steps:** Run generator and inspect iOS AppIcon Contents.json/PNG slots plus Android launcher resources.
- **Pass:** Every required target slot is populated from the tracked master source.
- **Negative:** Missing, stale, or wrong-dimension file fails.

### T-003 — Native launch surface packaging @smoke
- **AC:** AC-003
- **Steps:** Inspect LaunchScreen assets/storyboard and run iOS config build.
- **Pass:** Branded visual is target-bundled; legacy one-pixel placeholder is unused.
- **Negative:** Blank/default launch fallback fails.

### T-004 — Asset provenance manifest @smoke
- **AC:** AC-004
- **Steps:** Validate manifest fields against all source/generated files.
- **Pass:** Source, license, creator/derivative status, dimensions, hash, and generation command are recorded.
- **Negative:** Missing/unknown source blocks build review.

### T-005 — Device install and cold-launch review
- **AC:** AC-001, AC-003, AC-005
- **Steps:** Install on iPhone, inspect home screen, cold launch, and first in-app screen.
- **Pass:** Icon and launch presentation are coherent with Aetheric Pulse UI.
- **Negative:** Record poor contrast, crop, flicker, or fallback assets.

### T-006 — Placeholder regression @smoke
- **AC:** AC-006
- **Steps:** Compare tracked platform assets to known stock Flutter/one-pixel placeholder signatures.
- **Pass:** No shipped target file matches legacy placeholders.
- **Negative:** Restoring stock asset fails deterministically.

## Regression

    flutter test test/release/brand_assets_test.dart
    flutter test
    flutter build ios --config-only --no-codesign

## RED / GREEN Evidence Log

Populated during /agtoosa-build.
