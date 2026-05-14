# miToosa App — UI Kit

Hi-fi recreation of the miToosa mobile cognitive-puzzle app. Single self-contained prototype with 6 routable screens.

## Files
- `index.html` — entry point. Renders a custom-built iPhone frame with the running prototype inside, plus a caption pane describing the system.
- `tokens.css` — design tokens (color, gradients, glass, motion).
- `components.jsx` — shared primitives: `<GlassCard>`, `<ProgressRing>`, `<StatPill>`, `<PrimaryButton>`, `<GhostButton>`, `<AppHeader>`, `<BottomNav>`, `<Atmosphere>`, `<BrandMark>`, icon set.
- `screen-tracks.jsx` — home / browse puzzles with Daily Spark hero
- `screen-path.jsx` — level constellation path
- `screen-progress.jsx` — XP ring, cognitive radar, milestones
- `screen-leaderboard.jsx` — podium + ranked list
- `screen-settings.jsx` — profile, VIP, system, support
- `screen-game.jsx` — Pattern Match in-puzzle screen
- `app.jsx` — orchestrator + tweaks panel
- `ios-frame.jsx`, `tweaks-panel.jsx` — starter components

## Design system
- **Type**: Inter Tight (variable). Display weights 700–800 at −0.035em tracking. Body 500 at −0.01em. Single-family system.
- **Logo**: Three-node constellation mark + lowercase "mitoosa" wordmark.
- **Surface**: Deep obsidian (`#06080f` → `#0a0d17`), aetheric glass cards over a drifting atmosphere of gradient blobs.
- **Accent**: Blue → purple primary gradient. Cyan, pink, amber, emerald as semantic accents.

## What changed from the previous kit
- Replaced Orbitron + Exo 2 with Inter Tight (sleeker, no text overflow).
- Reworked the wordmark — no more all-caps Material-look brand.
- Dropped the 22px solid device bezel for a 1.5px hairline; phone is now 420×910 with a 48px-radius screen, maximizing usable canvas.
- Larger avatar/icon/badge renders with soft glow halos; no harsh borders.
- Replaced flat zigzag path with the level constellation.
- Added cognitive radar, podium, VIP banner, and the in-puzzle screen.

## Flow
Bottom nav routes between Tracks · Path · Progress · Leaderboard · Settings. From Tracks, "Start session" or any track tile launches the Pattern Match game screen. Tweaks toggle (toolbar) opens a panel for accent palette, atmosphere, glass intensity, and quick-jump navigation.
