# [0001] Seeded Tutorial Demos via PuzzleGenerator

**Status**: Proposed  
**Date**: 2026-06-14  
**Deciders**: AI agent + human review (pending BL-24 approval)

## Context

BL-24 replaces the static `HowToPlayModal` with interactive tap-through demos for all 23 tracks. Hand-authoring 23 fixed puzzles in JSON is high maintenance; `PuzzleGenerator` already supports injectable `Random` for determinism in tests.

## Decision

Generate tutorial demo puzzles with `PuzzleGenerator(Random(trackSeed))` where `trackSeed` is derived from a stable hash of `track.id`, using easy `DifficultyParameters` (minimal shapes/choices). Store no separate tutorial puzzle asset file in v1.

## Rationale

- One code path covers all `PuzzleRule` variants automatically.
- Widget/unit tests can assert stable puzzle output per track id.
- Avoids new JSON asset maintenance when tracks change.

## Consequences

### Positive

- All tracks get demos without per-track authoring.
- Reuses `ShapeRenderer` and puzzle models from gameplay.

### Negative

- Generator changes could alter demo puzzles (mitigate with golden-hash tests per representative track).
- Text-heavy rules (math, cipher) may need copy tweaks in the modal chrome, not the generator output.

## Alternatives Considered

| Option | Rejected because |
|--------|------------------|
| `assets/content/tutorial_demos.json` | 23 hand-authored puzzles; drift risk |
| Animated coach marks only | Does not teach tap-to-answer muscle memory |
| Live gameplay with `isTutorial` flag | Hearts/timer/session coupling; higher regression risk |
