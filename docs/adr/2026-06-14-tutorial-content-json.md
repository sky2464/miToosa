# Tutorial Content JSON

**Status**: Proposed
**Date**: 2026-06-14
**Deciders**: AI agent + human review

## Context

miToosa currently defines 23 tracks in `assets/content/worlds.json` and procedural rules in Dart. BL-24 needs explicit player-facing tutorial goals, steps, demo types, correct actions, and objective text for every track. Relying only on generated puzzle prompts would not give enough control over short, ADHD-friendly copy.

## Decision

Store tutorial definitions in `assets/content/tutorials.json`, loaded by a small `TutorialRepository` or `ContentProvider` extension. Runtime validation must ensure every current track ID and rule has exactly one matching tutorial definition.

## Rationale

JSON keeps tutorial content close to existing bundled game content while leaving engines pure Dart. It lets copy be reviewed independently from procedural puzzle generation and gives tests a single source for coverage assertions.

## Consequences

### Positive

- Product copy for all 23 tracks is explicit and reviewable.
- New tracks can fail fast in tests when tutorial coverage is missing.
- No new service, backend, or dependency is required.
- The live gameplay objective strip can reuse the same definitions.

### Negative

- Tutorial content must be maintained when tracks or rules change.
- Schema validation must be strict enough to catch drift.
- Very visual demo layouts still need Flutter code, not JSON alone.

## Alternatives Considered

| Option | Rejected because |
|--------|------------------|
| Seeded `PuzzleGenerator` demos only | Produces deterministic examples but does not capture reviewed per-track goals, steps, and objective copy. |
| Hard-coded Dart map | Harder for non-engineering review and mixes content with implementation. |
| Extend `worlds.json` directly | Coupling track metadata and tutorial UX would make the core track list noisier. |
| Remote-config tutorial content | Adds external dependency and launch/privacy surface outside BL-24. |
