# miToosa Design System

> Design system for **miToosa** — a free-first cognitive puzzle / brain-training mobile game built with Flutter. This system codifies the **"Aetheric Pulse" redesign direction**: a dark glassmorphic surface, blue→purple gradients, soft outer glows, generous rounded corners, and 3D rendered category icons.

---

## What is miToosa?

miToosa is a free-to-play IQ / brain puzzle game with **23 unique tracks**, each testing a different cognitive skill (Pattern Match, Shape Counter, Logic Gates, Cipher Break, Algebra Lab, Symmetry Lab, etc). Sessions are short (3–5 minutes); every player gets 25 free games daily — no sign-up paywall. Sharing the app with a friend grants a 40-game bonus. Optional VIP / ad-free is a convenience layer, never a gate.

Three top-level tabs: **Tracks** (browse & play puzzles), **Progress** (XP, cognitive skills, achievements), **Leaderboard**.

## Sources used to build this system

- **Codebase:** `miToosa/` — Flutter app. Key files:
  - `lib/theme/design_system.dart` — colors, type, spacing, shadow tokens (current production theme — the *softer* iToosa palette).
  - `lib/widgets/glass_card.dart` — glassmorphic container primitive.
  - `lib/features/main_app/main_app_shell.dart` — 3-tab bottom-nav shell.
  - `lib/features/gameplay/`, `lib/features/navigation/world_map_screen.dart` — gameplay & world-map flows.
  - `assets/content/worlds.json` — the 23 track definitions (name, subtitle, rule, emoji icon, level count).
  - `docs/PRODUCT-WEDGE.md`, `docs/USER-GUIDE.md` — product copy, tone, economy language.
- **Redesign mockups:** `Redesign/` — target visual direction (the basis of *this* system).
  - `code.html` — the canonical Tailwind-based redesign of the Tracks dashboard. Source of truth for color values, gradients, glass treatment, type scale.
  - `screen.png`, `mitoosa_training_dashboard_*/screen.png` — multiple dashboard variants, settings, level-complete, gameplay screens.
  - `mitoosa_progress_stats/screen.png`, `mitoosa_leaderboard_ranking/screen.png` — Progress & Leaderboard targets.
  - `a_set_of_6_achievement_badge_icons.../`, `a_set_of_8_diverse_user_avatar_icons.../` — pre-rendered badge & avatar art.
  - `individual_game_category_icon_for_*` — 3D rendered track icons (8 categories).
- **GitHub:** `sky2464/miToosa` — same Flutter codebase mirrored.

> Note: the current production `design_system.dart` is the *softer* iToosa palette (light periwinkle, Nunito + Quicksand). The Redesign folder represents an **upcoming** dark glassmorphic direction. **This design system codifies the redesign**, not the current production theme.

---

## CONTENT FUNDAMENTALS — voice, tone, copy

**Persona.** Friendly, encouraging, slightly playful coach. Never bossy. Never gamified-shouty (no "CRUSH IT!"). Confident and direct, with a soft edge — the app is for adults who want to feel sharp, not children who need stickers.

**Voice rules.**

- **Address the player as "you".** Never "the user". The system rarely says "I" — it speaks as the product, not as a character.
- **Sentence case for everything** except proper nouns and the brand mark ("miToosa") which always uses its specific lowercase-i + capital-T styling.
- **Short. Always.** Track subtitles are 3–5 words. Empty states are one sentence. Buttons are one or two words.
- **Verbs over nouns** for actions: "Play", "Replay", "Next Level", "Share", not "Start a session".
- **Numbers carry meaning.** Show progress as `4/10`, not "almost halfway". Show XP as `+200 XP`, not "great gain!".
- **No jargon.** Don't say "session", say "game". Don't say "telemetry", don't say "engagement loop".
- **No exclamation marks** in metadata or chrome. They are reserved for celebratory moments — `LEVEL COMPLETE!`, `Streak saved!`. One per screen, max.
- **No emoji in chrome / UI labels.** Emoji *do* appear inline in the codebase (`worlds.json` uses 🧩, 🔢, 👁️) as fallbacks — but in the **redesign** they are replaced by 3D rendered PNG icons. Treat emoji as a fallback only, not a brand element.

**Sample copy (from the codebase + redesigns).**

| Surface | Copy |
|---|---|
| Brand mark | `miToosa` |
| Track subtitles | "Match identical patterns" · "Count and calculate" · "Find what doesn't belong" · "Crack the code" · "Solve for X" |
| Hero stat | `600 XP` / `Daily Goal` / `60% Done` |
| Stat pills | `250` · `10/10 Energy` · `7 Day Streak` |
| Section headers | `Training Tracks` · `Cognitive Skills` · `Milestones & Achievements` |
| Difficulty | `Easy` · `Medium` · `Hard` |
| CTA primary | `Play` · `Next Level` · `Replay` |
| Celebration | `LEVEL COMPLETE!` (all-caps reserved for this single moment) |
| Achievement state | `Unlocked` (cyan glow) · `Locked` (greyed) |
| Difficulty meta | `Progress  4/10` (uppercase eyebrow + tabular number) |
| Empty / coming-soon | "Leaderboard — coming soon in v1.3" |

**Casing rules.** Title Case is reserved for: section headers (`Training Tracks`), screen titles (`Progress Stats`), proper nouns (`Pattern Match`, `Daily Spark`). Eyebrows + meta labels use UPPERCASE with letter-spacing (`PROGRESS  4/10`). Body copy is sentence case.

**Tone snippets (extracted, not invented).**

- Onboarding: *"What miToosa is about"*, *"Tap the correct answer before time runs out"*, *"Browse puzzle categories and pick your challenge"*.
- Adaptive difficulty doc: *"miToosa adjusts to your skill level. If you're consistently scoring high, puzzles get harder. If you're struggling, they ease up."*
- Privacy: *"miToosa stores all data locally on your device. No data is sent to any server."*

The vibe is **calm confidence with sparkle**. Visuals do the celebrating; copy stays understated.

---

## VISUAL FOUNDATIONS — the "Aetheric Pulse" system

### Background & atmosphere
- **Surface:** near-black with a slight blue cast — `#0a0d17`. Edges deepen to `#060810`.
- **Hero glow:** a single radial gradient anchored top-center, blue (`rgba(59,130,246,0.35)`) fading to transparent. Sometimes a second purple bloom near the bottom-right corner. This is the signature "aetheric" backdrop — present on every screen.
- No noise. No grain. No solid fills behind cards — the blur shows the glow through.

### Color
- **Primary brand pair:** blue `#3b82f6` and purple `#a855f7`. They almost never appear alone — they appear as a 135° gradient (`--grad-primary`).
- **Foreground:** pure white for primary text, `#d1d5db` for secondary, `#9ca3af` for metadata, `#6b7280` for muted.
- **Accent palette:** cyan `#22d3ee` (toggles, charts), pink `#ec4899`, amber `#facc15` (Energy / VIP gold), orange `#fb923c` (Streak / fire).
- Color is **structurally meaningful**: blue→purple = progress; cyan→blue = memory/info; magenta = focus; amber/orange = energy/streak; gold = premium.

### Type
- **Display & body:** Inter (400 / 500 / 600 / 700 / 800 / 900). Tight letter-spacing on display sizes (`-0.02em`). Heavy weights (800–900) for big numerics like `600 XP`, `LEVEL COMPLETE!`.
- The current production app uses **Nunito + Quicksand** — those remain available as fallbacks for the Flutter side, but the redesign standardizes on Inter.
- Tabular numerics for any score, XP, progress fraction.
- ALL CAPS only for tiny eyebrows (`PROGRESS`) and the single celebratory moment (`LEVEL COMPLETE!`).

### Spacing
- 4pt base. Card inner padding is **20–24 px**. Section vertical rhythm is 32–48 px. Bottom safe-area gutter is 24–32 px (above the bottom nav).

### Backgrounds (cards & containers)
- **Glass card** is the workhorse: `rgba(255,255,255,0.08)` fill, 1px `rgba(255,255,255,0.12)` border, 24px backdrop blur, inset white glow + outer dark drop. Radii are large — **24–32 px** for cards, **40+ px** for hero pills, **999 px** (full pill) for badges and CTAs.
- Nested wells inside cards are darker (`rgba(255,255,255,0.04–0.05)`) with smaller radius (16–20 px).
- No hand-drawn illustrations. No repeating patterns. No textures. The "decoration" is glow + gradient + glass.

### Animation
- **Easing:** primarily `easeOutBack` (`--ease-snappy`) for entrances; `easeOutCubic` (`--ease-smooth`) for layout shifts. `elasticOut` for celebratory moments only (level-complete trophy).
- **Duration:** 180 ms for hover/press, 300 ms for normal transitions, 600 ms for hero entrances.
- Progress rings *fill in*, not pop in. XP numbers count up, not snap. Bouncy entrances on success states.
- No fades-in on page load — content is present, glow pulses underneath.

### Hover / press states
- **Hover:** brightness up ~6%, border lightens to `rgba(255,255,255,0.18)`. No scale on hover.
- **Press:** scale `0.97`, 120 ms. Subtle. No color change.
- Active tab: top edge gets a 2 px blue bar with `box-shadow: 0 0 8px var(--brand-blue-glow)` and label color shifts to `--brand-blue-50`.

### Borders & strokes
- All card borders are 1 px (occasionally 1.5 px on emphasized states). Always `rgba(255,255,255, x)` — the system has **no dark borders**, only "lit edges" because everything sits on a dark base.
- Active state border: `rgba(59,130,246,0.55)` with a matching outer glow.

### Shadows / elevation
- Outer drop: `0 8px 32px rgba(0,0,0,0.25)` (cards), `0 18px 50px rgba(0,0,0,0.45)` (modals).
- Inner glow: `inset 0 0 20px rgba(255,255,255,0.02)` — reads as "lit from within".
- **Color glows** (the signature): `0 0 24px rgba(59,130,246,0.40)` for primary, `0 0 18px rgba(250,204,21,0.45)` for energy, etc. Used on progress rings, active tab indicators, glow bars.

### Transparency & blur
- Blur is used **whenever a surface sits over the hero glow** — that's almost everywhere. 24 px standard, 32 px for modals.
- Avoid blur on small chrome (≤ 32 px elements) — it costs perf for no visual gain.

### Layout rules
- **Mobile-first, max width 28 rem (≈ 448 px).** All key surfaces center horizontally inside that frame.
- **Bottom nav is fixed**, glass, sits above the safe-area inset. Top nav is **flowing** (no chrome bar — content scrolls under).
- Pills row scrolls horizontally with a hidden scrollbar.
- Hero element (XP ring, trophy) is **centered and dominant** — no competing chrome.

### Imagery vibe
- **3D rendered category icons** — colorful, shiny, slight rim-light, deep navy backdrop matching the app surface. Bright but not neon. Plastic-toy quality.
- **Achievement badges** — circular metal medallions (bronze / silver / gold) with wings, blue gem accents, locked = grayscale + padlock.
- **Avatars** — flat-illustrated portraits on solid color rings, occasional gold-crown / silver-laurel framing for top ranks.
- All imagery is sourced as PNG. **Do not draw your own SVG approximations.**

### Corner radii catalogue
- 8 / 12 — chips, ticks
- 16 — small cards, nested wells
- 24 — most cards
- 32 — hero / featured cards
- 40 — outer hero containers
- 999 (pill) — buttons, stat chips, progress bars

### What cards look like (the recipe)
1. Background: `rgba(255,255,255,0.08)` over `backdrop-filter: blur(24px)`.
2. Border: `1px solid rgba(255,255,255,0.12)`.
3. Radius: 24–32 px.
4. Shadow: `0 8px 32px rgba(0,0,0,0.25), inset 0 0 20px rgba(255,255,255,0.02)`.
5. Padding: 20–24 px.
6. Hero icon sits in a nested well (`rgba(255,255,255,0.05)`, radius 16, square aspect).
7. Title centered, bold; subtitle centered, muted.
8. A meta row at the bottom (uppercase eyebrow + numeric).
9. A gradient-glow progress bar.

---

## ICONOGRAPHY

miToosa uses **three distinct icon systems**, each for a specific purpose:

1. **Track / category icons → 3D rendered PNGs.** Bright colorful 3D objects (puzzle pieces, color wheel, gears + chains, glowing brain, calculator, ascending bars, numbered blocks, wireframe cube). Sit centered in a square nested well, 96–128 px. Located in `assets/icons/track_*.png`. **Always copy these in — never approximate with SVG or emoji.** In the production codebase, the corresponding `worlds.json` uses emoji as fallbacks (🧩, 🔢, 👁️, 🎨, 🧠, 🔄, 💻, ⚡, 🔐, ➕, ✖️, 📐, 🎯, 🍕, 🔬…) — this is a **stopgap**, not a brand element.
2. **UI / chrome icons → line icons via Lucide CDN.** Stroke icons for navigation, settings, actions. Used in: bottom nav (target, trending-up, trophy), top-right gear, back chevron, hint question-mark, replay arrow, share, etc. **Stroke 1.75–2 px, currentColor, 20–24 px size.** Lucide is the substitute — the original Flutter app uses Material Icons (`Icons.public`, `Icons.trending_up`, `Icons.leaderboard`); Lucide's `target`, `trending-up`, `trophy` are visually equivalent and carry the same line-icon energy as the redesign mocks. **Flag: Lucide is a substitution.** If you need exact Material Icons, the font file is in `miToosa/assets/fonts/MaterialIcons-Regular.ttf` and can be brought in.
3. **Stat / decorative icons → small PNGs (or, in this kit, gradient-filled SVG glyphs).** The `250` diamond, `10/10` lightning bolt, `7 Day Streak` flame in the dashboard pills are tiny rendered PNG glyphs in the redesign. We ship gradient-filled SVG approximations in the UI kit (`PillIcon.jsx`) — **flag: these are placeholders**; replace with the rendered PNGs once supplied.
4. **Achievement badges → rendered PNG sprite.** Bronze/silver/gold medallions with wings (`assets/brand/achievement_badges_set.png`). Sliced from the source sheet as needed.
5. **Avatars → rendered PNG sprite.** Flat-illustrated portraits on color rings (`assets/brand/user_avatars_set.png`).

**Emoji policy:** acceptable as a fallback in dev; **not** part of the brand. The redesign replaces every emoji with a rendered icon.

**Unicode-as-icon policy:** never. Use Lucide stroke icons or rendered PNGs.

---

## Files in this design system

```
README.md                  ← you are here
SKILL.md                   ← agent-skill manifest
colors_and_type.css        ← all design tokens (CSS vars + element classes)
fonts/                     ← Inter, Nunito, Quicksand (Google Fonts CDN; local fallbacks live in miToosa/assets/fonts)
assets/
  icons/                   ← 3D track icons (PNG)
  brand/                   ← achievement badges, avatars, key target screens
preview/                   ← the design-system cards rendered in the Design System tab
ui_kits/
  mitoosa_app/             ← the phone-app UI kit (index.html + JSX components)
```

## Index — what to read next

- Want to use the tokens? → `colors_and_type.css`
- Want to see every component visually? → open `ui_kits/mitoosa_app/index.html`
- Want the design system overview cards? → see the **Design System** tab (or open files in `preview/`)
- Building a slide / mock for miToosa? → start by importing `colors_and_type.css`, copying the relevant icon from `assets/icons/`, and using a `.ds-glass` card.

---

## Caveats & substitutions (read me!)

- **Stat-pill glyphs** (diamond / lightning / flame in the dashboard chips) are recreated as gradient SVG. The originals are rendered 3D PNGs that weren't broken out individually in `Redesign/` — only the composite mockups have them.
- **Bottom-nav icons** in the redesign mocks are rendered PNG miniatures. Substituted with Lucide line icons of equivalent shape.
- **Achievement badges & avatars** are shipped as the original combined sprite sheets. Slice them when needed; we don't have individual cutouts.
- **Inter** is the canonical UI font for the redesign (used by `Redesign/code.html`). The current Flutter production theme uses **Nunito + Quicksand** — both are kept available in the system as fallbacks, but new design work should default to Inter.
