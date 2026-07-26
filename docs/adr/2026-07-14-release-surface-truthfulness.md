# ADR: Release Surfaces Must Be Usable or Unreachable

**Status:** Proposed — pending BL-31 approval
**Date:** 2026-07-14
**Decision owners:** Product owner and miToosa maintainers
**Related story:** BL-31

## Context

The current release UI exposes a static demo leaderboard, local-play POC, inert profile/VIP/share/reminder controls, and a Reset Progress row without a real mutation. These surfaces create a promise that the v1.5.1 release does not fulfill.

## Decision

For the iPhone release, a feature is visible only when its player-facing behavior is implemented and testable. Deferred leaderboard, local multiplayer, profile editing, reminders, and VIP/IAP remain hidden from release navigation. Reset Progress becomes a confirmed local-progress reset that preserves the existing anonymous player identity and encryption-key lifecycle.

## Consequences

- Product claims remain aligned with actual release behavior.
- Deferred POCs can remain in source but not in a reachable player flow.
- Every visible Settings control requires a testable outcome.
- BL-29 separately owns the live free-games share flow; Settings does not present a stale duplicate.

## Alternatives Rejected

- Leave placeholders disabled or labelled coming soon: still creates false expectation at launch.
- Implement backend/social features in this release: exceeds validated launch scope.
- Delete all deferred POC code: unnecessary and risks obscuring future work.
