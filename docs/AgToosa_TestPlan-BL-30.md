# Test Plan — BL-30 Track Catalog Integrity

> **Spec:** [spec-BL-30.md](archived/spec-BL-30.md)
> **Status:** Approved — enrolled Active Cycle (2026-07-26)
> **Created:** 2026-07-14

## Scope & Strategy

Content validation is the primary gate: all shipped tracks, category filters, artwork paths, and registered assets are deterministic bundled data. Widgets prove that validated data reaches the catalog correctly.

## AC Coverage Matrix

| AC ID | EARS summary | Priority | Test IDs | Category | Smoke |
|-------|--------------|----------|----------|----------|-------|
| AC-001 | 23 tracks have valid category/ID | Must | T-001 | Unit | T-001 @smoke |
| AC-002 | Category filters return exact tracks | Must | T-002 | Unit/widget | T-002 @smoke |
| AC-003 | Every card resolves artwork | Must | T-003 | Unit/widget | T-003 @smoke |
| AC-004 | Invalid new row fails validation | Must | T-004 | Unit | — |
| AC-005 | Only used content assets are registered | Must | T-005 | Unit/static | T-005 @smoke |
| AC-006 | New art has provenance | Should | T-006 | Static review | — |

## Test Catalog

### T-001 — Catalog schema coverage @smoke
- **AC:** AC-001
- **Steps:** Load worlds.json through the production parser.
- **Pass:** Exactly 23 unique IDs have a category from the allowlist.
- **Negative:** Missing/unknown/duplicate categories or IDs fail.

### T-002 — Category filter membership @smoke
- **AC:** AC-002
- **Steps:** Select each declared category in the catalog widget.
- **Pass:** Results equal the validated category membership and each declared category has at least one row.
- **Negative:** Default/unknown category does not silently yield an accidental empty state.

### T-003 — Artwork resolution @smoke
- **AC:** AC-003
- **Steps:** Resolve each iconAsset path and build representative cards.
- **Pass:** Every path exists in the asset bundle and every card renders its declared art.
- **Negative:** A missing path fails content validation rather than using an implicit unknown-track fallback.

### T-004 — Invalid content fails fast
- **AC:** AC-004
- **Steps:** Mutate fixture rows to remove metadata, duplicate an ID, or use an outside path.
- **Pass:** Parser/validator rejects each fixture with a useful development error.
- **Negative:** Corrupt content does not reach the UI silently.

### T-005 — Registered asset reader audit @smoke
- **AC:** AC-005
- **Steps:** Assert no production code reads levels.json and inspect pubspec asset registration.
- **Pass:** levels.json is not registered after migration; all remaining registered content has a reader.
- **Negative:** Removing any still-read asset fails the fixture/static check.

### T-006 — Asset provenance manifest
- **AC:** AC-006
- **Steps:** Inspect the track-asset manifest.
- **Pass:** Every added track image has source, license, creator/derivative status, dimensions, and filename.
- **Negative:** Missing provenance blocks completion review.

## Regression

    dart analyze lib test
    flutter test
    flutter build ios --config-only --no-codesign

## RED / GREEN Evidence Log

| Test ID | Phase | Result | Evidence |
|---------|-------|--------|----------|
| T-001 | GREEN | PASS | `catalog_validation_test.dart` — 23 IDs, categories |
| T-002 | GREEN | PASS | `catalog_validation_test.dart` + `tracks_screen_test.dart` |
| T-003 | GREEN | PASS | `rootBundle.load` per iconAsset |
| T-004 | GREEN | PASS | `validateTrackRecord` rejects missing category |
| T-005 | GREEN | PASS | No `levels.json` in lib or pubspec |
| T-006 | GREEN | PASS | `docs/brand/track-asset-manifest.md` |
| T-007 | DEFERRED | manual | iPhone viewport card review (task 4.3) |

**Verification (2026-07-26):** `flutter test` — 920/920 PASS. `dart analyze lib test` — 0 errors.
