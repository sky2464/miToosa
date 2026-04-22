# Spec: Aetheric Pulse Visual Redesign

**Status:** Archived  
**Canonical source:** `docs/miToosa Design System/README.md`  
**Produced by:** `/spec` pass — no code has changed yet  
**Next step:** Run `/plan` to break this spec into ordered implementation tasks

---

## Objective

Align the Flutter miToosa app with the full **Aetheric Pulse** visual direction described in `docs/miToosa Design System/README.md`.

### Current state (Kinetic Obsidian)

| Dimension | Current value |
|---|---|
| Surface | `#10131a` |
| Primary accent | Electric Cyan `#00F0FF` |
| Secondary accent | Proton Purple `#7000FF` |
| Fonts | Orbitron + Exo 2 (variable TTFs) |
| Card blur | 16px |
| Card radius (default) | 8px (`radiusLg`) |
| Card border | Top + left only |
| Background | 4 corner blobs (`KineticBackground`) |
| Nav active state | No indicator bar |
| Track icons | Emoji strings |

### Target state (Aetheric Pulse Dark)

| Dimension | Target value |
|---|---|
| Surface | `#0a0d17` |
| Primary | Blue `#3b82f6` |
| Secondary | Purple `#a855f7` |
| Fonts | Inter (variable weight 400–900) |
| Card blur | 24px |
| Card radius (default) | 24px |
| Card border | Uniform 1px all sides |
| Background | Single top-center blue radial glow (`AethericBackground`) |
| Nav active state | 2px top-edge blue bar + blue under-glow |
| Track icons | 3D PNG (from design system assets) |

### What "done" looks like

Every screen matches the Aetheric Pulse aesthetic:

- Dark `#0a0d17` background with one top-center blue radial glow  
- Blue → purple 135° gradient on primary actions and progress fills  
- Inter font throughout; 800–900 weight for hero numerics  
- Glass cards: `rgba(255,255,255,0.08)` fill, `1px solid rgba(255,255,255,0.12)` border (uniform), 24px backdrop blur, 24–32px radii  
- 3D PNG track-category icons rendered in square nested wells  
- Achievement badge PNGs integrated in ProgressScreen  
- Zero hardcoded hex values in widget files — all resolved through `AethericPulseDark.*` tokens

---

## Naming conflict (critical — must resolve before coding)

| Location | Name used | What it means |
|---|---|---|
| `docs/miToosa Design System/README.md` | **Aetheric Pulse** | Dark redesign: Inter, #3b82f6, #0a0d17 |
| `docs/miToosa Design System/DESIGN_SPEC.md` | **Kinetic Obsidian** | Same dark production target (older label) |
| `lib/theme/design_system.dart` existing | `AethericPulse` class | A **soft pastel light** theme — the opposite |

**Resolution (this spec):**

- Rename the existing `AethericPulse` class to `AethericPulseLight` (pastel theme unchanged)  
- Add a new `AethericPulseDark` class with all tokens from the table below  
- Keep `KineticObsidian` class intact (backward compat for tests)  
- Update `MiToosaTheme.darkTheme` to return `AethericPulseDark.themeData`

---

## Tech Stack

- Flutter ≥ 3.5.0, Dart, Riverpod  
- Font: Inter variable font (weight 400–900) — delivery method is an **open question** (see below)  
- Existing: Orbitron + Exo 2 kept in `pubspec.yaml` for `KineticObsidian` fallback  
- Glass: `BackdropFilter` + `Container` decoration (unchanged approach)  
- Assets: PNG icons / badges from `docs/miToosa Design System/assets/`

---

## Commands

```bash
flutter pub get                                               # After pubspec.yaml changes
dart pub run build_runner build --delete-conflicting-outputs  # After any provider changes
dart analyze                                                  # Lint gate (must be zero errors)
flutter test                                                  # Test gate (must pass)
flutter run -d chrome                                         # Visual verification
```

---

## Project Structure — files that change

```
lib/theme/design_system.dart              ← ADD AethericPulseDark class; RENAME AethericPulse → AethericPulseLight
lib/widgets/glass_card.dart               ← UPDATE blur 16→24px; fill; border; shadow; radius default 24px
lib/widgets/kinetic_background.dart       ← UPDATE → surface #0a0d17, single top-center glow (no rename required)
lib/widgets/kinetic_chip.dart             ← CREATE: reusable pill chip widget
lib/widgets/kinetic_progress_bar.dart     ← CREATE: 4px-thick gradient progress bar with glow
lib/features/main_app/main_app_shell.dart ← UPDATE top bar + bottom nav tokens + active-tab indicator
lib/features/main_app/progress_screen.dart        ← UPDATE XP hero, stat grid, progress bars
lib/features/navigation/world_map_screen.dart     ← UPDATE stat pills, track cards with 3D PNG icons
lib/features/main_app/leaderboard_screen.dart     ← UPDATE tokens
lib/features/settings/settings_screen.dart        ← UPDATE tokens
lib/features/auth/login_screen.dart               ← UPDATE hero glow + tokens
lib/features/gameplay/ (all screens)              ← UPDATE tokens (scope TBD — see open questions)
assets/fonts/Inter[slnt,wght].ttf                 ← ADD Inter variable font
assets/icons/*.png                                ← ADD 8 track-category 3D PNGs
assets/badges/*.png                               ← ADD 6 achievement badge PNGs
assets/images/avatars/*.png                       ← VERIFY 12 avatars present
pubspec.yaml                                      ← ADD Inter font; ADD assets/icons/ + assets/badges/
```

---

## Aetheric Pulse Dark — Token Specification

### Colors

| Dart token | Hex / rgba | Role |
|---|---|---|
| `surface` | `#0a0d17` | App background |
| `surfaceEdge` | `#060810` | Deepest edges, splash screens |
| `brandBlue` | `#3b82f6` | Primary brand; buttons, active states |
| `brandPurple` | `#a855f7` | Secondary brand; chips, accents |
| `onSurface` | `#ffffff` | Primary text |
| `onSurfaceSecondary` | `#d1d5db` | Secondary text |
| `onSurfaceMeta` | `#9ca3af` | Metadata labels |
| `onSurfaceMuted` | `#6b7280` | Placeholder / muted |
| `accentCyan` | `#22d3ee` | Toggles, charts, memory track |
| `accentPink` | `#ec4899` | Focus states, accents |
| `accentAmber` | `#facc15` | Energy / VIP gold |
| `accentOrange` | `#fb923c` | Streak / fire motif |
| `glassFill` | `rgba(255,255,255,0.08)` | Glass card background |
| `glassBorder` | `rgba(255,255,255,0.12)` | Glass card border (all 4 sides) |
| `glassHoverBorder` | `rgba(255,255,255,0.18)` | Hover / focus border |
| `activeBorder` | `rgba(59,130,246,0.55)` | Active-state border tint |
| `nestedWell` | `rgba(255,255,255,0.05)` | Icon well inside glass card |
| `primaryGlow` | `rgba(59,130,246,0.40)` | Blue shadow glow |

### Gradients (as Flutter `LinearGradient` / `RadialGradient`)

| Name | Value | Use |
|---|---|---|
| `gradPrimary` | `135°: #3b82f6 → #a855f7` | Primary buttons, progress fills, tab indicators |
| `gradMemory` | `135°: #22d3ee → #3b82f6` | Memory-track accent |
| `heroGlow` | `RadialGradient at top-center: rgba(59,130,246,0.35) → transparent 70%` | Background atmosphere |

### Typography — Inter

| Role | Size | Weight | Letter-spacing |
|---|---|---|---|
| Hero numeric | 56–72 sp | 900 | −0.02 em |
| Display | 40–48 sp | 800 | −0.02 em |
| Headline LG | 28–32 sp | 700 | −0.01 em |
| Headline MD | 20–24 sp | 600 | 0 |
| Body LG | 18 sp | 400 | 0 |
| Body MD | 16 sp | 400 | 0 |
| Label / eyebrow | 11–13 sp | 500–600 | +0.08 em, ALL CAPS |

### Spacing — 4 pt base

| Token | Value |
|---|---|
| `spaceXs` | 4 px |
| `spaceSm` | 8 px |
| `spaceMd` | 16 px |
| `spaceLg` | 20–24 px (card padding) |
| `spaceXl` | 32–48 px (section gaps) |

### Corner radii

| Token | Value | Use |
|---|---|---|
| `radiusChip` | 8–12 px | Chips, tick marks |
| `radiusWell` | 16 px | Nested icon well |
| `radiusSmCard` | 16 px | Small utility cards |
| `radiusCard` | 24 px | Standard glass card |
| `radiusHeroCard` | 32 px | Hero / featured card |
| `radiusHero` | 40 px | Hero container |
| `radiusPill` | 999 px | Buttons, pill chips |

### Shadows

| Token | BoxShadow value | Use |
|---|---|---|
| `cardOuter` | `color: #00000040, blur: 32, offset: (0, 8)` | Glass card outer drop |
| `cardInner` | `color: #FFFFFF05, blur: 20, spread: 0` (inset) | Glass card inner white glow |
| `blueGlow` | `color: #3B82F666, blur: 24` | Active / brand glow |
| `energyGlow` | `color: #FACC1573, blur: 18` | Amber energy glow |

---

## Component Recipes

### GlassCard

```
BackdropFilter(blur: 24)
  └─ Container(
       decoration: BoxDecoration(
         color: Color(0x14FFFFFF),          // rgba(255,255,255,0.08)
         borderRadius: BorderRadius.circular(24),
         border: Border.all(color: Color(0x1FFFFFFF), width: 1), // uniform, all sides
         boxShadow: [cardOuter, cardInner],
       ),
       padding: EdgeInsets.all(20–24),
     )
```

- Default radius: **24** (override to 32 for hero cards)  
- Hover state: border → `glassHoverBorder`, 180ms  
- Press state: scale 0.97, 120ms `easeOutBack`  
- Track icon: placed in a nested well (`nestedWell` color, radius 16px, square aspect ratio)

### AethericBackground

```
Stack(
  children: [
    Container(color: Color(0xFF0A0D17)),   // surface
    Positioned(
      top: -200, left: 0, right: 0,
      child: Container(
        height: 600,
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topCenter,
            colors: [Color(0x593B82F6), Colors.transparent],
            radius: 0.7,
          ),
        ),
      ),
    ),
    // optional: purple bloom, bottom-right, 30% opacity
  ],
)
```

### KineticChip (pill chip)

```
Container(
  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
  decoration: BoxDecoration(
    color: Color(0x33A855F7),   // purple at 20%
    borderRadius: BorderRadius.circular(999),
    border: Border.all(color: Color(0x4DA855F7), width: 1),
  ),
  child: Text(label, style: labelStyle),
)
```

### KineticProgressBar (XP / energy bar)

```
height: 4px
decoration: BoxDecoration(
  gradient: gradPrimary (linear, 0→1 horizontal),
  borderRadius: BorderRadius.circular(999),
  boxShadow: [BoxShadow(color: Color(0x4022D3EE), blurRadius: 8)],
)
```

Track background: `rgba(255,255,255,0.08)`, same height and radius.

### Bottom Navigation — active tab indicator

- Indicator: 2px top-edge `Container`, width = icon width, gradient `gradPrimary`  
- Under-glow: `BoxShadow(color: Color(0x663B82F6), blurRadius: 12)` behind indicator  
- Active icon / label: `brandBlue`  
- Inactive icon / label: `onSurfaceMuted`  
- Background: `glassFill` + `glassBorder` top edge, 24px blur

### Primary Button

```
ElevatedButton(
  style: ElevatedButton.styleFrom(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
  ),
  // Background via gradient ShaderMask: gradPrimary
  child: Text('Label', style: headlineMd.copyWith(fontWeight: FontWeight.w600)),
)
```

Press: scale 0.97, 120ms `easeOutBack`  
Disabled: `onSurfaceMuted`, no gradient

---

## Animation Tokens

| Event | Duration | Curve |
|---|---|---|
| Hover enter/exit | 180ms | `easeInOut` |
| Press / tap | 120ms | `easeOutBack` |
| Normal transition | 300ms | `easeOutCubic` |
| Hero entrance | 600ms | `easeOutBack` |
| Celebration / reward | — | `elasticOut` |

---

## Asset Pipeline

### Source → destination mapping

| Source (design system folder) | Destination in repo |
|---|---|
| `docs/miToosa Design System/assets/icons/*.png` (8 files) | `assets/icons/*.png` |
| `docs/miToosa Design System/assets/badges/*.png` (6 files) | `assets/badges/*.png` |
| `docs/miToosa Design System/assets/avatars/*.png` (12 files) | `assets/images/avatars/*.png` (verify only; may already exist) |

### Inter font

Download Inter variable font (`Inter[slnt,wght].ttf`) from [Google Fonts](https://fonts.google.com/specimen/Inter) or [rsms.me/inter](https://rsms.me/inter) and place at `assets/fonts/Inter[slnt,wght].ttf`.

### `pubspec.yaml` additions

```yaml
fonts:
  - family: Inter
    fonts:
      - asset: assets/fonts/Inter[slnt,wght].ttf

flutter:
  assets:
    - assets/icons/
    - assets/badges/
```

---

## Per-Screen Requirements

### MainAppShell (top bar + bottom nav)

- Top bar: Inter 600 20px title, `onSurface` white, `glassFill` background  
- Bottom nav: `glassFill` + `glassBorder` top edge, 24px blur, active tab = 2px `gradPrimary` top-bar + `blueGlow`  
- All hardcoded `KineticObsidian.*` calls → `AethericPulseDark.*`

### WorldMapScreen (track cards)

- Stat pills row (XP, streak, energy, credits): `KineticChip` pill, horizontal scroll  
- Track card = `GlassCard` (24px radius, standard recipe)  
  - Nested well (16px radius, `nestedWell` color, square) hosting 3D PNG icon  
  - Track name: Inter 600 18px, `onSurface`  
  - Progress: `KineticProgressBar`  
  - No emoji as primary icon representation  
- Locked track: 40% opacity overlay, `onSurfaceMuted` text

### ProgressScreen

- XP hero numeral: Inter 900 64px, gradient `gradPrimary` ShaderMask  
- "Level X" eyebrow: Inter 600 13px ALL CAPS, `onSurfaceMeta`  
- Stat grid (2×2 or 3×2): `GlassCard` cells, `accentAmber` / `accentOrange` accent values  
- XP progress bar: `KineticProgressBar` full-width  
- Achievement badges: 3–6 badge PNGs from `assets/badges/`; locked = 30% opacity

### LeaderboardScreen

- Row background: alternating `glassFill` / transparent  
- Rank 1–3: `accentAmber` gradient crown icon  
- Player row: avatar PNG 40×40 (radius 999px), Inter 500 16px name, `onSurfaceSecondary` XP  
- Own-player row: `activeBorder` left edge highlight

### SettingsScreen

- Section headers: Inter 600 13px ALL CAPS, `onSurfaceMeta`  
- Setting row: `glassFill` card, `onSurface` label, `Switch` using `brandBlue` active color  
- VIP upgrade card: `gradPrimary` border, `accentAmber` badge chip

### LoginScreen

- Hero: `AethericBackground` full-screen  
- Logo / wordmark: Inter 800 40px, `onSurface`  
- Blue glow pulse below logo: `primaryGlow` radial, 600ms hero entrance  
- Primary CTA: `gradPrimary` pill button (see Primary Button recipe above)

### GameplayScreen (scope TBD)

- Round card: `GlassCard` 32px (hero card radius)  
- Option buttons: `GlassCard` 24px radius, press scale 0.97  
- Timer bar: `KineticProgressBar` cyan fill (`accentCyan`)  
- Correct flash: `blueGlow` + scale 1.05, `elasticOut`  
- Incorrect flash: `accentPink` border, 300ms fade

---

## Gap Analysis (current code vs. this spec)

| Widget / file | What changes |
|---|---|
| `GlassCard` | blur 16→24, fill `Color(0x14FFFFFF)`, uniform border, shadow pair, default radius 8→24 |
| `KineticBackground` | surface `#10131a`→`#0a0d17`, corner blobs→single top-center glow |
| `design_system.dart` | Add `AethericPulseDark`; rename `AethericPulse`→`AethericPulseLight`; update `MiToosaTheme.darkTheme` |
| `main_app_shell.dart` | Bottom nav active-tab indicator (none→2px gradPrimary bar + blueGlow) |
| `world_map_screen.dart` | Stat pills row (missing); 3D PNG icon in nested well (currently emoji) |
| `progress_screen.dart` | Hero numeral weight/gradient; KineticProgressBar; badge PNGs |
| `pubspec.yaml` | Inter font; `assets/icons/`; `assets/badges/` |
| `assets/` | Missing: `fonts/Inter*.ttf`, `icons/*.png`, `badges/*.png` |

---

## Open Questions

> These must be resolved before the `/build` pass begins.

**Q1 — Inter font delivery**  
Bundle the TTF directly in `assets/fonts/` (consistent with Orbitron/Exo 2 pattern, offline-safe), OR add `google_fonts` package (adds auto-caching + simpler code, ~60 KB overhead)?  
*Recommendation: bundle TTF locally for consistency and offline play.*

**Q2 — GameplayScreen scope**  
Should `GameplayScreen` and its overlays be updated in this redesign pass, or deferred to a separate pass once the shell and navigation screens are stable?  
*Recommendation: defer GameplayScreen to a follow-up pass; mark as Phase 5 in the plan.*

**Q3 — MiToosaTheme.darkTheme timing**  
Switch `MiToosaTheme.darkTheme` to return `AethericPulseDark.themeData` immediately (single cutover), OR feature-flag it behind a Dart `const` to allow both themes at runtime?  
*Recommendation: immediate cutover — feature flags add complexity; tests should be updated alongside the token rename.*

**Q4 — AethericPulseLight preservation**  
The current `AethericPulse` class is a pastel light theme that may not be used in production. After renaming to `AethericPulseLight`, should it be kept, archived, or deleted?  
*Recommendation: keep but mark as unused until a light-mode feature is planned.*

---

## Testing Strategy

- No new test framework. Existing `flutter test` gate.  
- After each widget update: `dart analyze` (zero errors) + `flutter test` (zero regressions).  
- Visual verification: `flutter run -d chrome`; compare against `docs/miToosa Design System/` screenshots.  
- Acceptance: build succeeds, `dart analyze` zero errors, `flutter test` zero regressions, visual match to spec.

---

## Boundaries

**Always:**

- `dart analyze` + `flutter test` before every commit  
- Match spec token values exactly — no approximations  
- Keep `KineticObsidian` class intact (tests depend on it)

**Ask first:**

- Adding `google_fonts` package (size/dependency decision)  
- Deleting any existing test  
- Removing `AethericPulseLight` class entirely

**Never:**

- Commit secrets  
- Remove failing tests without approval  
- Skip the `dart analyze` gate  
- Use hardcoded hex values in widget files

---

## Success Criteria

- [ ] `dart analyze` returns zero errors after all changes  
- [ ] `flutter test` passes with zero regressions  
- [ ] `design_system.dart` contains `AethericPulseDark` class with all tokens listed above  
- [ ] `GlassCard` default: 24px blur, `rgba(255,255,255,0.08)` fill, uniform 1px `rgba(255,255,255,0.12)` border, outer + inner shadow, 24px radius  
- [ ] `KineticBackground` (or renamed `AethericBackground`): `#0a0d17` surface + top-center blue radial glow  
- [ ] 3D PNG track icons present in `assets/icons/` and rendered in WorldMapScreen track cards  
- [ ] Achievement badge PNGs in `assets/badges/`  
- [ ] Inter font bundled and declared in `pubspec.yaml`  
- [ ] Bottom nav active tab: 2px top-edge `gradPrimary` indicator + blue glow  
- [ ] WorldMapScreen: stat pills horizontal-scroll row (XP, streak, energy, credits)  
- [ ] All main screens resolve colors through `AethericPulseDark.*` tokens (no hardcoded hex)  
- [ ] No emoji used as primary track category icons  
- [ ] `MiToosaTheme.darkTheme` returns `AethericPulseDark.themeData`

---

*This spec is the source of truth for the Aetheric Pulse redesign. Run `/plan` next to convert these requirements into an ordered implementation task list.*
