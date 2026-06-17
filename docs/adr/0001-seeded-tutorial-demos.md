# [0001] Seeded Tutorial Demos via PuzzleGenerator

**Status**: Superseded by `2026-06-14-tutorial-content-json.md`
**Date**: 2026-06-14
**Deciders**: AI agent + human review (pending BL-24 approval)

## Context

BL-24 replaces the static `HowToPlayModal` with interactive tap-through demos for all 23 tracks. This ADR proposed seeded demos from `PuzzleGenerator`, but the approved BL-24 plan requires explicit tutorial definitions in `assets/content/tutorials.json` so goals, steps, demo type, correct action, and objective copy can be reviewed per track.

## Decision

Do not use this ADR as the active BL-24 implementation decision. Use `2026-06-14-tutorial-content-json.md` for tutorial content and `2026-06-14-native-tutorial-demos.md` for the demo rendering strategy.

## Rationale

The seeded-only approach was superseded because it does not provide enough control over player-facing tutorial copy and per-track objective language.

## Consequences

### Positive

- Historical record of an alternative considered for BL-24.

### Negative

- Not the active decision. Future implementers should not follow this ADR for BL-24.

## Alternatives Considered

| Option | Rejected because |
|--------|------------------|
| `assets/content/tutorial_demos.json` | 23 hand-authored puzzles; drift risk |
| Animated coach marks only | Does not teach tap-to-answer muscle memory |
| Live gameplay with `isTutorial` flag | Hearts/timer/session coupling; higher regression risk |
