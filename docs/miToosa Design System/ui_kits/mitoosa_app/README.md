# miToosa App — UI Kit

Pixel-ish recreation of the **miToosa redesign** (dark, glassmorphic, gradient-glow) for a mobile cognitive-puzzle game. Based on `Redesign/code.html` + screens in `Redesign/mitoosa_*` plus the current Flutter app in `miToosa/lib/`.

## Files
- `index.html` — full clickable prototype in an iPhone-sized frame
- `Primitives.jsx` — `<Glass>`, `<StatPill>`, `<ProgressBar>`, `<PrimaryButton>`, `<GhostButton>`, `<Toggle>`, `<Icon.*>`
- `TracksScreen.jsx` — home dashboard with XP ring + horizontal track cards
- `GameScreen.jsx` — in-puzzle (Pattern Match example) with timer + answer grid
- `ProgressScreen.jsx` — XP hero, stat grid, achievement list
- `LeaderboardScreen.jsx` — ranked list with podium tint
- `SettingsScreen.jsx` — profile, account, preferences, reset
- `Shell.jsx` — orchestrator: bottom glass nav, screen router, background glows

## Flow
Tap a Training Track card → enters the Pattern Match game screen. Back chevron returns. Bottom nav toggles Tracks / Progress / Leaderboard / Settings.

## Notes
- Icons for the three stat pills (diamond / energy / streak) are inline SVG stand-ins — the originals in `Redesign/` are CDN URLs, so this approximates the 3D gradient look without the rendered PNGs.
- Track icons, badges, avatars are all sliced from the Redesign sheets — see `assets/track_icons/`, `assets/badges/`, `assets/avatars/`.
- Onboarding / share / VIP upsell screens are not mocked — no source material exists for them yet.
