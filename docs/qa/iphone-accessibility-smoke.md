# iPhone Accessibility Smoke (BL-36 / AC-006)

Manual proof for VoiceOver, Dynamic Type, Reduce Motion, and narrow portrait layouts. Complements automated coverage in `test/accessibility/core_flow_accessibility_test.dart` and maps to **T-006** in [AgToosa_TestPlan-BL-36.md](../AgToosa_TestPlan-BL-36.md).

Record results in the TestFlight evidence template or a dated BL-36 note. Block launch sign-off if any **Must** step fails.

## Preconditions

- Physical iPhone on a TestFlight or release-candidate build (`dev.atoosa.mitoosa`).
- Device model, iOS version, build number, tester, and date recorded.
- Fresh install or cleared app data available for onboarding.

## VoiceOver

1. Enable **Settings → Accessibility → VoiceOver**.
2. Cold launch and complete onboarding (or Skip).
3. From the main shell, open **Tracks**, start a puzzle, and reach Hint + Submit. Confirm the help control and at least one answer option have labels.
4. Open **Progress** and confirm Daily rewards, Streak calendar, and Achievements rows are labeled.
5. Open **Settings** and focus Sound FX and Reset progress. Toggles should announce on/off state.

**Pass:** Each actionable control announces a clear label; selected tabs and toggles reflect state.  
**Fail:** Icon-only controls with no label, duplicate/conflicting names, or unreachable primary actions.

## Dynamic Type

1. Set **Settings → Accessibility → Display & Text Size → Larger Text** to the largest comfortable size (or Maximum).
2. Repeat onboarding (or first screen), main shell header, one gameplay round (including the objective strip), Progress, and Settings.

**Pass:** Critical copy and CTAs remain readable (scroll if needed); no clipped destructive actions.  
**Fail:** RenderFlex overflow, hidden CTAs, or unreadable instructions.

## Reduce Motion

1. Enable **Settings → Accessibility → Motion → Reduce Motion**.
2. Launch login/onboarding and main shell; start one gameplay round and submit an answer.

**Pass:** Decorative motion calms or stops; puzzles still advance and timers behave normally.  
**Fail:** Blocking animation loops or changed scoring/timer outcomes tied to motion settings.

## Portrait widths

1. On the smallest supported iPhone in portrait (e.g. SE / 320pt logical width), repeat: onboarding → shell → Settings → one puzzle.

**Pass:** No layout overflow; bottom nav and primary actions stay reachable above the home indicator.  
**Fail:** Yellow/black overflow stripes or controls obscured by safe areas.

## Cross-links

- Automated matrix: `flutter test test/accessibility/core_flow_accessibility_test.dart`
- Broader device gate: [iphone-testflight-qa-checklist.md](iphone-testflight-qa-checklist.md) (VoiceOver / Dynamic Type sections)
