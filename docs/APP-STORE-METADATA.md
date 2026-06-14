# App Store Metadata Draft

Use this draft when creating the iOS App Store Connect record for the iPhone launch.

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
| Privacy Policy URL | TODO: publish and paste final URL |
| Support URL | TODO: publish and paste final URL |
| Marketing URL | Optional |

## Review notes

- No account is required.
- Progress is local-first.
- Firebase + Google Analytics are enabled for launch analytics only.
- No leaderboard, social graph, IAP, VIP, server sync, gambling, contests, chat, or user-generated content in this launch.
- If App Review asks how to test analytics, launch a release/TestFlight build with `FIREBASE_ENABLED=true` and play one session.

## App Privacy questionnaire guide

Answer from the actual release build behavior, not future plans.

- Declare Firebase + Google Analytics usage when `FIREBASE_ENABLED=true` is used for release.
- Local Hive progress stays on device.
- Anonymous local player ID is not an account, email, phone number, or real name.
- Do not declare leaderboard, ads, purchases, referrals, or server sync unless those features are actually enabled in the submitted build.
- Keep `docs/PRIVACY-POLICY.md` aligned with the final public Privacy Policy URL.

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

Required: one to ten iPhone screenshots.

Capture final release screens after TestFlight install on a real iPhone or iOS Simulator matching App Store screenshot sizes:

- Onboarding/value screen.
- Tracks/home screen.
- Gameplay screen.
- Progress/streak screen.
- Settings/privacy or local-first screen.

Quality bar:

- No debug banners.
- No placeholder URLs.
- No impossible progress values.
- No clipped text or layout overflow.
- Screenshots only show features available in the submitted build.

