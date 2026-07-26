# ADR: Production Asset Provenance and Generation

**Status:** Proposed — pending BL-30, BL-33, and BL-34 approval
**Date:** 2026-07-14
**Decision owners:** Product owner and miToosa maintainers
**Related stories:** BL-30, BL-33, BL-34

## Context

The catalog has incomplete icon mapping, the app icon is stock Flutter, launch images are placeholders, and audio assets are documented as generated test tones. Product-ready assets need both recognizable design and a durable source/licensing trail.

## Decision

Every new production visual or audio asset must have a repository manifest entry documenting source, license, creator or derivative status, dimensions/format, hash where practical, and generation command. Platform icon sets derive from one approved text-free Aetheric Pulse constellation/spark master. Catalog images and SFX are validated before release packaging; generated placeholders are not production assets.

## Consequences

- Asset provenance is reviewable without external memory.
- Platform variants are reproducible and testable.
- Asset acquisition/generation becomes a scoped build task rather than an ad hoc manual step.
- No remote asset dependency or runtime downloader is introduced.

## Alternatives Rejected

- Continue shipping placeholders until store submission: weakens release credibility.
- Use untracked downloaded artwork/audio: cannot prove license or repeat generation.
- Add a text wordmark to the app icon: rejected by the selected visual direction.
