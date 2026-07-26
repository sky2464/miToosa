# Test Plan — BL-36 iPhone Accessibility and Device Hardening

> **Spec:** [spec-BL-36.md](archived/spec-BL-36.md)
> **Status:** Draft pending approval
> **Created:** 2026-07-14

## Scope & Strategy

Exercise the core launch routes with accessibility MediaQuery settings and inspect their semantics. Device verification remains required for actual VoiceOver focus ordering and iOS system behavior.

## AC Coverage Matrix

| AC ID | EARS summary | Priority | Test IDs | Category | Smoke |
|-------|--------------|----------|----------|----------|-------|
| AC-001 | Core controls have semantics | Must | T-001 | Widget semantics | T-001 @smoke |
| AC-002 | Core actions have 44pt targets | Must | T-002 | Widget layout | T-002 @smoke |
| AC-003 | High text avoids clipping | Must | T-003 | Widget layout | T-003 @smoke |
| AC-004 | Reduced motion preserves state | Must | T-004 | Widget/unit | T-004 @smoke |
| AC-005 | Portrait narrow widths navigate | Must | T-005 | Widget layout | T-005 @smoke |
| AC-006 | iPhone a11y smoke passes | Must | T-006 | Manual device | — |

## Test Catalog

### T-001 — Semantic core-flow sweep @smoke
- **AC:** AC-001
- **Steps:** Build onboarding, shell, world map, gameplay, Progress, and Settings; inspect semantic tree.
- **Pass:** Every actionable control has understandable label/role and selected/disabled values when applicable.
- **Negative:** Icon-only/unlabeled or duplicate conflicting semantics fail.

### T-002 — Minimum interaction geometry @smoke
- **AC:** AC-002
- **Steps:** Measure core controls/dialog actions in widget tests.
- **Pass:** Targets are at least 44 logical pixels or exposed as equivalent accessible controls.
- **Negative:** Decorative visible glyphs are not the only interaction surface.

### T-003 — High text layout matrix @smoke
- **AC:** AC-003
- **Steps:** Render core routes at supported high text scale and 320pt width.
- **Pass:** Critical copy/CTAs remain visible, scrollable, and non-overlapping.
- **Negative:** RenderFlex overflow/clipped destructive actions fail.

### T-004 — Reduced-motion state preservation @smoke
- **AC:** AC-004
- **Steps:** Render representative animated UI with disableAnimations/accessibility navigation true and progress game state.
- **Pass:** Decorative transitions stop/simplify; engine/timer/result state remains deterministic.
- **Negative:** MediaQuery mode does not change puzzle result or resource state.

### T-005 — Portrait route smoke @smoke
- **AC:** AC-005
- **Steps:** Navigate onboarding, world map, track detail, gameplay, Progress, and Settings at 320/375/430pt portrait widths.
- **Pass:** No overflow and all primary back/next actions remain reachable.
- **Negative:** Safe area/system padding does not cover controls.

### T-006 — Physical iPhone accessibility smoke
- **AC:** AC-006
- **Steps:** On iPhone enable VoiceOver, largest Dynamic Type, Reduce Motion, and run core first-play/settings flow.
- **Pass:** Focus order, announcements, layout, and behavior have no blocker.
- **Negative:** Record exact screen/control/blocker and attach to BL-25/BL-36 evidence.

### T-007 — Accessibility regression checklist
- **AC:** AC-001 through AC-006
- **Steps:** Complete docs/qa/iphone-accessibility-smoke.md during review.
- **Pass:** All automated/manual outcomes are recorded.
- **Negative:** Missing manual proof blocks launch sign-off.

## Regression

    dart analyze lib test
    flutter test

## RED / GREEN Evidence Log

Populated during /agtoosa-build.
