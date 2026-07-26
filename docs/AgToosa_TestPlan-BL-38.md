# Test Plan — BL-38 Modularize Oversized Code and Remove Dead Dependencies

> **Spec:** [spec-BL-38.md](archived/spec-BL-38.md)
> **Status:** Draft pending approval
> **Created:** 2026-07-14

## Scope & Strategy

Characterize behavior before moving code, then enforce structural constraints after each extraction. No behavior change is accepted solely because the code compiles; seeded game fixtures, Hive round trips, and widget navigation tests remain the oracle.

## AC Coverage Matrix

| AC ID | EARS summary | Priority | Test IDs | Category | Smoke |
|-------|--------------|----------|----------|----------|-------|
| AC-001 | Target files meet 500-line budget | Must | T-001 | Static | T-001 @smoke |
| AC-002 | Seeded generator behavior preserved | Must | T-002 | Unit characterization | T-002 @smoke |
| AC-003 | Hive serialization preserved | Must | T-003 | Unit/migration | T-003 @smoke |
| AC-004 | UI navigation/state preserved | Must | T-004 | Widget | T-004 @smoke |
| AC-005 | Engine remains pure | Must | T-005 | Static/guard | — |
| AC-006 | Cleanup has no-reader proof | Must | T-006 | Static/dependency | T-006 @smoke |
| AC-007 | Full verification suite passes | Must | T-007 | Regression | T-007 @smoke |

## Test Catalog

### T-001 — Target line budget @smoke
- **AC:** AC-001
- **Steps:** Run static line count for named non-generated target Dart files.
- **Pass:** Each is at or below 500 lines; any exception is generated and explicitly whitelisted.
- **Negative:** New oversized extraction target fails.

### T-002 — Seeded puzzle generator characterization @smoke
- **AC:** AC-002
- **Steps:** Run representative seeded inputs for each existing PuzzleRule before/after extraction.
- **Pass:** Rule, prompt, answers, correct answer, and expected constraints are unchanged.
- **Negative:** Changed random sequence/output fails.

### T-003 — PlayerProgress Hive contract @smoke
- **AC:** AC-003
- **Steps:** Round-trip current and older fixture maps through adapter/model.
- **Pass:** Type ID, field numbers, defaults, and migrations match baseline.
- **Negative:** Field-order/default drift fails.

### T-004 — Gameplay and navigation characterization @smoke
- **AC:** AC-004
- **Steps:** Navigate through representative gameplay/world-map/track-detail interactions with existing fakes.
- **Pass:** State transitions, route results, and visible controls match baseline.
- **Negative:** Extracted widget cannot own/drop provider/navigation state.

### T-005 — Pure engine import audit
- **AC:** AC-005
- **Steps:** Run flutter-engine-guard and import/static checks.
- **Pass:** Core engine has no Flutter, Hive, Riverpod, feature, or UI import.
- **Negative:** Any cross-boundary import fails.

### T-006 — No-reader dependency removal @smoke
- **AC:** AC-006
- **Steps:** Prove no lib/test import/reference to go_router before removal; record retained POC dependencies.
- **Pass:** Dependency is absent after removal and pub resolution is green.
- **Negative:** A remaining production reader blocks deletion.

### T-007 — Full refactor regression @smoke
- **AC:** AC-007
- **Steps:** Run line/import guards, analyzer, full Flutter tests, and whitespace diff check.
- **Pass:** All pass with no unintended generated/persistence changes.
- **Negative:** Any failure blocks merge.

### T-008 — Manual release regression
- **AC:** AC-002, AC-003, AC-004
- **Steps:** Run representative iPhone first-play, relaunch, and catalog smoke after refactor.
- **Pass:** Core player path has no visible behavioral regression.
- **Negative:** Capture exact behavior divergence.

## Regression

    dart analyze lib test
    flutter test
    bash .codex/skills/flutter-engine-guard/scripts/check_engine_boundary.sh
    git diff --check

## RED / GREEN Evidence Log

Populated during /agtoosa-build.
