# ADR: Anonymous Diagnostics Consent Boundary

**Status:** Proposed — pending BL-32 and BL-37 approval
**Date:** 2026-07-14
**Decision owners:** Product owner and miToosa maintainers
**Related stories:** BL-32, BL-37

## Context

Firebase analytics is configured with unconditional analytics and advertising consent flags. The iPhone release needs useful anonymous diagnostics without ad targeting or a privacy choice that applies inconsistently across analytics and crash reports.

## Decision

Anonymous diagnostics are enabled by default with clear in-app disclosure and a durable opt-out. Bootstrap disables native automatic collection until the persisted choice has been loaded, then explicitly applies the choice. Analytics storage follows that choice. Ad storage, ad user data, and ad personalization are always denied. After BL-37, Crashlytics collection follows the same anonymous diagnostics preference and reports only sanitized bounded context.

## Consequences

- The player has one understandable privacy control rather than overlapping toggles.
- No advertising/ATT/IDFA work is introduced.
- Firebase calls are centralized behind testable adapters.
- Privacy policy, App Store metadata, and PrivacyInfo.xcprivacy require synchronized review.

## Alternatives Rejected

- Grant all Firebase consent categories: violates the selected release posture.
- Enable native collection before preference load: weakens opt-out semantics.
- Keep crash reporting active after diagnostics opt-out: less privacy-respecting and harder to explain.
