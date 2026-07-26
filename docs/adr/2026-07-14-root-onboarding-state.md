# ADR: Root Onboarding State Gate

**Status:** Accepted — BL-28 shipped 2026-07-26
**Date:** 2026-07-14
**Decision owners:** Product owner and miToosa maintainers
**Related story:** BL-28

## Context

Anonymous authentication creates a nonempty local player ID before a player has necessarily completed onboarding. Root routing currently treats that ID as sufficient to show the main application shell, bypassing the onboarding experience.

## Decision

The root application widget will derive destination from both authentication state and persisted PlayerProgress.onboardingComplete. A nonempty player ID alone does not grant access to MainAppShell. Root routing remains declarative; child screens may persist onboarding completion but must not independently own root replacement behavior.

## Consequences

- Fresh players reach onboarding reliably.
- Returning players remain fast-path resumes.
- Root tests must cover loading, error, fresh, completed, and post-completion states.
- Per-track tutorial behavior remains a separate BL-24 concern.

## Alternatives Rejected

- Infer completion from local player-ID existence: already causes the bypass.
- Move all routing into LoginScreen: duplicates app-root ownership and risks navigation races.
- Store completion outside PlayerProgress: adds unnecessary state split.
