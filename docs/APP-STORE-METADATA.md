# App Store Metadata Draft

Use this draft when creating the iOS App Store Connect record for the iPhone launch.

**Related:** [Privacy Policy](PRIVACY-POLICY.md) · [Support](SUPPORT.md) · [iPhone Launch Readiness](IPHONE-LAUNCH-READINESS.md) · [Launch Plan](LAUNCH.md)

## App information

| Field | Draft value |
|-------|-------------|
| Name | `miToosa` |
| Bundle ID | `dev.atoosa.mitoosa` |
| SKU | `mitoosa-ios` |
| Primary language | English (U.S.) |
| Platform | iOS |
| Launch device focus | iPhone |
| Category | Games |
| Secondary category | Puzzle |
| Price | Free |

## Product page copy

| Field | Draft |
|-------|-------|
| Subtitle | Quick cognitive puzzles |
| Promotional text | Short, focused puzzle sessions built for fast play. |
| Description | miToosa is a local-first puzzle game built around short cognitive sessions. Play pattern, memory, math, and physics-style challenges, build streaks, and keep progress on device without a sign-up wall. |
| Keywords | puzzle,brain,pattern,memory,focus,streak,logic,quick games |
| What's New | Initial iPhone launch. |
| Copyright | Copyright Atoosa Dev. All rights reserved. |
| Privacy Policy URL | `[manual-deferred: owner to publish public HTTPS URL — source: docs/PRIVACY-POLICY.md]` |
| Support URL | `[manual-deferred: owner to publish public HTTPS URL — source: docs/SUPPORT.md]` |
| Marketing URL | Optional |

## Review notes

- No account is required.
- Progress is local-first.
- Firebase + Google Analytics are enabled for launch analytics only when `FIREBASE_ENABLED=true`, and players can opt out in Settings.
- No ad targeting, advertising ID collection, or ad personalization consent is granted.
- No leaderboard, social graph, IAP, VIP, server sync, gambling, contests, chat, or user-generated content in this launch.
- If App Review asks how to test analytics, launch a release/TestFlight build with `FIREBASE_ENABLED=true` and play one session.
- Public policy/support pages: [PRIVACY-POLICY.md](PRIVACY-POLICY.md), [SUPPORT.md](SUPPORT.md).

## App Privacy questionnaire guide

Answer from the actual release build behavior, not future plans.

- Declare Firebase + Google Analytics usage when `FIREBASE_ENABLED=true` is used for release.
- Local Hive progress stays on device.
- Anonymous local player ID is not an account, email, phone number, or real name.
- Do not declare leaderboard, ads, purchases, referrals, or server sync unless those features are actually enabled in the submitted build.
- Keep [docs/PRIVACY-POLICY.md](PRIVACY-POLICY.md) aligned with the final public Privacy Policy URL.

## Age rating guide

Current launch posture:

- No gambling or simulated gambling.
- No loot boxes.
- No contests.
- No chat or user-generated content.
- No web browsing.
- No mature, sexual, horror, or violent content.
- Not submitted as Made for Kids unless that is a deliberate legal/product decision.

## Export compliance guide

The app uses encrypted local storage and platform crypto/keychain behavior. Complete Apple's export compliance flow honestly for the submitted binary and keep any resulting answer/documentation attached to the App Store Connect build record.

## Screenshot capture plan

**Required:** one to ten iPhone screenshots for App Store Connect.

### Device sizes

Capture for the primary iPhone display sizes Apple requests at submit time (typically **6.7"** and **6.5"** iPhone classes). Use a real iPhone or iOS Simulator matching the target resolution. Re-capture if Apple updates required sizes before submit.

### Required scenes

Capture final release screens after TestFlight install (or release build on Simulator):

1. **Onboarding / value** — first-run welcome or value proposition.
2. **Tracks / home** — track picker with glass UI.
3. **Gameplay** — active puzzle session (timer visible, no debug overlay).
4. **Progress / streak** — XP, streak, or completion state.
5. **Settings / privacy** — settings or local-first / privacy posture screen.

### Quality bar

- No debug banners, Flutter inspector overlays, or `DEBUG` ribbons.
- No placeholder URLs or `TODO` text visible in UI.
- No impossible progress values (negative counts, overflow text).
- No clipped text or layout overflow.
- Screenshots only show features available in the submitted build.
- Use production theme; avoid simulator chrome where Apple allows device-frame captures.

**Manual gate:** Upload captured PNGs in App Store Connect — `[manual-deferred: owner after TestFlight build on physical iPhone]`.
