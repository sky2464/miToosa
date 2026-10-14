# iPhone accessibility smoke (BL-36)

Physical-device procedure for VoiceOver, Dynamic Type, and Reduce Motion. Automated coverage lives in `test/accessibility/core_flow_accessibility_test.dart`.

## Prerequisites

- TestFlight or release-profile build on a physical iPhone
- VoiceOver, largest Dynamic Type, and Reduce Motion available in Settings

## Core flow (≈15 minutes)

1. **Onboarding** — Enable VoiceOver; cold launch; verify primary CTA has a non-empty label; disable VoiceOver for gameplay timing.
2. **World map** — Open a track card; confirm track entry control is reachable (44pt) and labeled.
3. **Gameplay** — Start a level; verify help (`?`) and at least one answer option have semantics labels.
4. **Progress** — Open Progress tab; verify streak, achievements, and daily reward rows are labeled.
5. **Settings** — Open Settings; verify toggles (sound, analytics) announce state.
6. **Dynamic Type** — Set largest text size; repeat steps 1 and 3; confirm no clipped instructional text on onboarding and gameplay objective strip.
7. **Reduce Motion** — Enable Reduce Motion; launch app; confirm decorative pulses/animations are suppressed without freezing timers.

## Evidence

Record pass/fail in `docs/qa/iphone-testflight-evidence-template.md` (BL-25 AC-008 / AC-013 cross-link).
