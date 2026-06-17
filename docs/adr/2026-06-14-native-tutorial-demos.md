# Native Flutter Tutorial Demos

**Status**: Proposed
**Date**: 2026-06-14
**Deciders**: AI agent + human review

## Context

BL-24 needs to teach players how each puzzle track works before or during first play. The options considered were native Flutter widgets, authored Rive animations, GIF/video assets, and Remotion-rendered clips. The current game is procedural, local-first, and iPhone-launch focused, with existing shape rendering, modal, audio, and persistence primitives already available.

## Decision

Implement the first version of track demos as native Flutter interactive widgets. Do not add Rive, Remotion, GIF/video packs, or new media dependencies in BL-24.

## Rationale

Native Flutter keeps the tutorial interactive, testable, accessible, and aligned with live puzzle state. It avoids a second animation/runtime pipeline during launch readiness and lets the implementation reuse existing `ShapeRenderer`, Material icons, Aetheric Pulse tokens, and current audio services.

## Consequences

### Positive

- Fastest path to a working, testable in-app tutorial.
- Works offline and stays local-first.
- Supports semantics, Dynamic Type, reduced motion, and widget tests.
- Avoids heavyweight binary/video assets for procedural content.

### Negative

- Less cinematic than authored Rive/video assets.
- Requires careful UI implementation for every demo type.
- Future marketing videos still need a separate asset pipeline.

## Alternatives Considered

| Option | Rejected because |
|--------|------------------|
| Rive animations | Adds dependency and authored asset workflow before the MVP proves tutorial value. |
| GIF/video tutorial pack | Passive playback does not teach tap interaction and can drift from procedural rules. |
| Remotion-rendered clips | Useful for App Store/social media, not for in-app interactive learning. |
| Static copy only | Current modal pattern is insufficient for “show how each game works.” |
