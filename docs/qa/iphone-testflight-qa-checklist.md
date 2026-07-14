# iPhone TestFlight QA Checklist

Use this checklist on a physical iPhone running the TestFlight build. Record every result in `iphone-testflight-evidence-[YYYY-MM-DD].md` created from the companion template. Do not mark launch-readiness gates complete until every Must scenario passes.

## Preconditions

- [ ] TestFlight build is installed for bundle `dev.atoosa.mitoosa`.
- [ ] Build number, device model, iOS version, tester, and date are recorded.
- [ ] A fresh install or cleared local app state is available for onboarding timing.
- [ ] For Firebase DebugView, launch with `FIREBASE_ENABLED=true` and enable Firebase debug mode per `docs/ANALYTICS-SETUP.md`.

## Cold Launch

- [ ] Force-quit the app, relaunch from the Home Screen, and confirm it reaches a usable screen without a crash or indefinite splash.

## Onboarding

- [ ] Start timing at cold launch and complete onboarding to the first playable round in 60 seconds or less.
- [ ] Confirm anonymous play proceeds without an authentication wall.

## Full Gameplay Session

- [ ] Complete one three-round session and return to the map or session summary without a soft lock.

## Share Bonus

- [ ] Share once and confirm the allowance increases by 40 free games.
- [ ] Attempt a second share on the same day and confirm it does not grant another bonus.

## Offline Mode

- [ ] Enable Airplane Mode, launch the app, complete one round, force-quit, and relaunch.
- [ ] Confirm local gameplay remains available without a network or sign-in prompt.

## VoiceOver

- [ ] Enable VoiceOver and navigate onboarding, a track entry point, and one gameplay control.
- [ ] Confirm each critical control has a useful spoken label.

## Dynamic Type

- [ ] Set iOS text size to its largest setting and inspect onboarding and gameplay instructions.
- [ ] Confirm no critical instructions are clipped or hidden.

## Wedge Copy

- [ ] Confirm the player-facing allowance presents 25 daily free games.
- [ ] Confirm sharing is framed as a +40 free-games bonus and no paywall blocks initial value.

## Force-Quit Persistence

- [ ] Note allowance, streak, and progress; force-quit and relaunch.
- [ ] Confirm the recorded state is restored.

## Settings and Support Links

- [ ] Open settings, privacy, and support entry points.
- [ ] Confirm no link opens a blank page, crashes the app, or exposes an unresolved placeholder.

## Firebase DebugView

- [ ] With `FIREBASE_ENABLED=true`, launch and start a session.
- [ ] Confirm at least one session, screen, or `mitoosa_debug_ping` event appears in Firebase Analytics DebugView within 60 seconds.

## Result

- [ ] All Must scenarios pass.
- [ ] Any failure is recorded with reproduction steps and linked to a follow-up defect before launch readiness is marked complete.
