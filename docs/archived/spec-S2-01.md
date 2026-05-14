# Spec: S2-01 — Aetheric Pulse UI Redesign

> **Story ID:** S2-01
> **Epic:** EP-04 — User Experience Polish
> **Status:** 🟦 Todo
> **Estimate:** XL
> **Spec created:** 2026-05-14

---

## 1. Requirements

### 1.1 User Stories

**As a** player, **I want** a visually polished dark glassmorphic UI across all screens **so that** the app feels premium, immersive, and worth coming back to.

**As a** player, **I want** to see my real progress, streaks, XP, and achievements in the redesigned screens **so that** I can track my cognitive improvement with accurate data.

**As a** player, **I want** a constellation-style path view for track levels **so that** my journey through each track feels spatial and rewarding.

### 1.2 Acceptance Criteria (EARS)

| ID | EARS | Priority |
|----|------|----------|
| AC-001 | WHEN the app launches THE SYSTEM SHALL render all screens using Aetheric Pulse design tokens (blue #3B82F6 → purple #A855F7 gradient, Inter font, 24px card radii, glassmorphic surfaces on #0A0D17 background) | Must |
| AC-002 | WHEN the player navigates to the Tracks screen THE SYSTEM SHALL display a Daily Spark hero card with progress ring, horizontal stat pills (streak, energy, stars, XP), filter chips, a featured track tile with 3D PNG icon, and a 2-column track grid | Must |
| AC-003 | WHEN the player navigates to the Path screen THE SYSTEM SHALL display a constellation-style level path with S-curve connected nodes (done=green, current=blue with pulse animation, locked=muted, boss=gold) wired to real level progress | Must |
| AC-004 | WHEN the player navigates to the Progress screen THE SYSTEM SHALL display an XP hero ring with real total XP, a cognitive radar chart computed from real skill scores, a weekly XP bar chart, and achievement cards with lock/progress state | Must |
| AC-005 | WHEN the player navigates to the Leaderboard screen THE SYSTEM SHALL display a podium for top 3 with avatar frames, a global/friends/local segmented control, and ranked player rows with the current player highlighted | Must |
| AC-006 | WHEN the player navigates to the Settings screen THE SYSTEM SHALL display a profile card, mastery progress bar, VIP upsell card, account section (invite + notifications), system toggles (sound, music, haptics), and support links | Must |
| AC-007 | WHEN the player enters a gameplay session THE SYSTEM SHALL display the game screen with back button, level indicator, progress dots, countdown timer pill, target pattern, 2×2 option grid, hint button, and submit CTA — all wired to the existing GameplayEngine state machine | Must |
| AC-008 | WHEN any screen loads THE SYSTEM SHALL render animated Atmosphere glow blobs (radial blue/purple gradients) as the background layer beneath all content | Must |
| AC-009 | WHEN the bottom navigation renders THE SYSTEM SHALL display 5 tabs (Tracks, Path, Progress, Leaders, Settings) as a floating glass bar with 24px radius, active tab showing a top blue glow indicator and tinted icon/label | Must |
| AC-010 | WHEN screens display player data THE SYSTEM SHALL read from playerProgressProvider and display real XP, stars, streak count, energy (free games remaining), and per-track level counts — never hardcoded mock data | Must |
| AC-011 | WHILE the game timer is at 4 seconds or below WHEN the game screen renders THE SYSTEM SHALL switch the timer pill to pink tint (#EC4899) with pulse-glow animation | Should |
| AC-012 | WHEN the stat pills row renders THE SYSTEM SHALL support horizontal scroll with hidden scrollbar for overflow | Should |
| AC-013 | IF the player's achievement is locked WHEN viewing the Progress screen THE SYSTEM SHALL display the badge at 50% opacity with grayscale filter and a lock icon overlay, plus a progress bar showing completion fraction | Should |
| AC-014 | IF the player's rank appears in the leaderboard THE SYSTEM SHALL highlight the row with blue background tint, blue border glow, and a "YOU" badge | Should |

**Failure modes (from forcing question 5):**
- AC-001 failure: regression if old KineticObsidian tokens leak into new screens — mitigated by consolidating tokens and widget test assertions on color values
- AC-010 failure: null/empty progress data causes widget exceptions — mitigated by defensive defaults in all data-bound widgets
- AC-008 failure: glassmorphism + animated blobs cause frame drops on low-end devices — mitigated by `RepaintBoundary` isolation and testing on Android emulator with GPU profiling

### 1.3 Out of Scope

- KineticObsidian token set (Orbitron + Exo 2 typography) — the prototypes use Aetheric Pulse; KineticObsidian remains in codebase for reference only
- Tweaks panel from the design prototype (dev-only tool, not a production feature)
- iOS device frame wrapper (prototype scaffold, not production code)
- Actual leaderboard backend API (demo data for non-self players until backend exists per EP-03)
- VIP purchase flow / in-app purchase implementation (UI card renders, but "Upgrade" button is non-functional until EP-03)
- Avatar selection/editing flow (profile card shows current avatar; editing is a separate story)
- Sound/music/haptic engine implementation (toggle state persists, but actual audio/haptic playback is a separate story)
- Light theme variant (AethericPulseLight) — dark mode only for this story
- Onboarding screen redesign (separate story BL-07)

---

## 2. Design

### 2.1 Architecture Blueprint

**New files to create:**

```
lib/widgets/atmosphere.dart           — Animated glow blob background (3 radial gradients + star field)
lib/widgets/stat_pill.dart            — Tinted stat chip with icon, label, and optional glow
lib/widgets/app_header.dart           — Sticky header: avatar ring + gradient "miToosa" mark + credits pill
lib/widgets/primary_button.dart       — Gradient CTA button with press scale + inset shine
lib/widgets/ghost_button.dart         — Outlined ghost button
lib/widgets/skill_radar.dart          — Hexagonal radar chart (CustomPainter, 6-axis)
lib/widgets/weekly_bars.dart          — 7-day XP bar chart (CustomPainter)
lib/widgets/achievement_card.dart     — Badge card with unlocked/locked/progress states
lib/widgets/path_constellation.dart   — Constellation level path (CustomPainter, S-curve nodes + connections)
lib/widgets/toggle_switch.dart        — Animated iOS-style toggle with gradient active state
lib/widgets/settings_row.dart         — Icon + title + subtitle + trailing widget row for settings
lib/theme/design_tokens.dart          — Consolidated Aetheric Pulse token constants (extracted from design_system.dart)
```

**Existing files to modify:**

```
lib/theme/design_system.dart                          — Add missing shadow presets, motion durations; align tokens to prototype values
lib/widgets/glass_card.dart                            — Align fill/border/blur to refined Aetheric Pulse recipe
lib/widgets/progress_ring.dart                         — Update gradient colors and glow shadow
lib/widgets/kinetic_text.dart                          — Align gradient to blue→purple (not cyan→purple)
lib/features/main_app/main_app_shell.dart             — Replace bottom nav with floating glass bar; replace app bar with AppHeader
lib/features/navigation/world_map_screen.dart          — Rebuild as Tracks screen with Daily Spark hero, stat strip, filters, track grid
lib/features/navigation/world_map_path_screen.dart     — Rebuild as Path screen with constellation view
lib/features/progress/progress_screen.dart             — Rebuild with XP hero, cognitive radar, weekly bars, achievements
lib/features/leaderboard/leaderboard_screen.dart       — Rebuild with podium + segmented control + ranked rows
lib/features/settings/settings_screen.dart             — Rebuild with profile, mastery, VIP, toggle sections
lib/features/gameplay/gameplay_screen.dart              — Update chrome, timer pill, pattern shapes, hint/submit layout
pubspec.yaml                                            — Add new asset paths for icons, avatars, badges
```

**Asset files to add:**

```
assets/images/icons/track_pattern_match.png    — 3D puzzle piece icon
assets/images/icons/track_shape_counter.png    — 3D calculator icon
assets/images/icons/track_logic_gates.png      — 3D gears/chains icon
assets/images/icons/track_memory.png           — 3D brain icon
assets/images/icons/track_number_crunch.png    — 3D numbered blocks icon
assets/images/icons/track_sequence.png         — 3D ascending bars icon
assets/images/icons/track_color_code.png       — 3D color wheel icon
assets/images/icons/track_spatial.png          — 3D wireframe cube icon
assets/images/avatars/avatar_1.png … avatar_12.png   — 12 flat-illustrated avatar portraits
assets/images/badges/novice_mind.png           — Bronze medallion badge
assets/images/badges/focus_master.png          — Silver medallion badge
assets/images/badges/memory_marvel.png         — Gold medallion badge
assets/images/badges/logic_legend.png          — Logic badge
assets/images/badges/daily_spark.png           — Streak flame badge
assets/images/badges/ultimate_brain.png        — Master badge
```

**Key interfaces:**

```dart
// Atmosphere — always placed as first child in screen Stack
class Atmosphere extends StatelessWidget {
  final String accent; // 'blue' | 'cyan' | 'pink'
  Widget build(context) → Stack of 3 animated radial gradient blobs + SVG star field
}

// StatPill — horizontal inline chip
class StatPill extends StatelessWidget {
  final Widget icon;
  final String label;
  final StatPillTint tint; // orange, blue, purple, amber, cyan, pink
  final bool glow;
}

// SkillRadar — CustomPainter hexagonal chart
class SkillRadar extends StatelessWidget {
  final List<SkillScore> skills; // name, value 0-100, color
  final double size;
}

// PathConstellation — CustomPainter level path
class PathConstellation extends StatelessWidget {
  final List<PathLevel> levels; // n, state (done/current/locked), type (regular/bonus/boss)
}
```

### 2.2 Data Flow

1. App launches → `main_app_shell.dart` builds `Scaffold` with `Atmosphere` background, `AppHeader` sticky at top, screen content in `IndexedStack`, `BottomNav` floating at bottom.
2. Player navigates tabs → `BottomNav.onChange` updates selected index → `IndexedStack` reveals the target screen.
3. Each screen reads from existing Riverpod providers:
   - `playerProgressProvider` → XP, stars, streak count, free games remaining, per-track level progress, achievement unlock state
   - `gameplayViewModel` → active game phase, timer, selected option, hints remaining
4. Screen widgets map provider state to visual elements:
   - `TracksScreen` computes daily progress from `PlayerProgress.dailyGamesPlayed`, maps track IDs to PNG icon paths, reads per-track level count
   - `PathScreen` generates constellation node list from `PlayerProgress.levelProgress[trackId]`, deriving done/current/locked states
   - `ProgressScreen` computes skill radar values from `PlayerProgress.adaptiveHistory`, weekly XP from `PlayerProgress.dailyXpBreakdown`
   - `LeaderboardScreen` reads player XP for "you" row; non-self rows use demo data until EP-03 backend
   - `SettingsScreen` reads profile info from `PlayerProgress`, toggle state from local preferences
   - `GameplayScreen` reads from `gameplayViewModel` state (phase, timer, options, selected)
5. User actions (play, select, toggle) dispatch through existing engine methods → state updates → UI rebuilds reactively.

### 2.3 Threat Model (STRIDE)

| Threat | Category | Mitigation |
|--------|----------|------------|
| Token regression — old KineticObsidian colors leaking into new screens | Tampering | Consolidate tokens; add widget test assertions checking background/text colors against Aetheric Pulse values |
| Null/empty progress data causing widget exceptions | Denial of Service | All data-bound widgets use `?.` and sensible defaults (0 XP, empty lists, "Level 1"); tested with fresh PlayerProgress |
| Glassmorphism + animated blobs causing frame drops | Denial of Service | Wrap `Atmosphere` in `RepaintBoundary`; use `ImageFilter.blur` only on containers > 32px; profile on Android emulator |
| Asset path mismatch — PNG not found at runtime | Information Disclosure | `pubspec.yaml` asset entries verified in CI; `Image.asset` with `errorBuilder` fallback |
| Demo leaderboard data implying real players exist | Repudiation | Label leaderboard as "Preview" with "Coming soon in v1.3" footer until backend connects |

### 2.4 Build Scope

```
✅ Ready to proceed — Scope Boundary
Files in scope      : lib/theme/design_system.dart, lib/theme/design_tokens.dart,
                       lib/widgets/atmosphere.dart, lib/widgets/stat_pill.dart,
                       lib/widgets/app_header.dart, lib/widgets/glass_card.dart,
                       lib/widgets/primary_button.dart, lib/widgets/ghost_button.dart,
                       lib/widgets/progress_ring.dart, lib/widgets/kinetic_text.dart,
                       lib/widgets/skill_radar.dart, lib/widgets/weekly_bars.dart,
                       lib/widgets/achievement_card.dart, lib/widgets/path_constellation.dart,
                       lib/widgets/toggle_switch.dart, lib/widgets/settings_row.dart,
                       lib/features/main_app/main_app_shell.dart,
                       lib/features/navigation/world_map_screen.dart,
                       lib/features/navigation/world_map_path_screen.dart,
                       lib/features/progress/progress_screen.dart,
                       lib/features/leaderboard/leaderboard_screen.dart,
                       lib/features/settings/settings_screen.dart,
                       lib/features/gameplay/gameplay_screen.dart,
                       pubspec.yaml
Directories in scope: lib/theme/, lib/widgets/, lib/features/main_app/,
                       lib/features/navigation/, lib/features/progress/,
                       lib/features/leaderboard/, lib/features/settings/,
                       lib/features/gameplay/, assets/images/icons/,
                       assets/images/avatars/, assets/images/badges/
Out of scope        : lib/core/engine/ (pure Dart engines — no changes),
                       lib/data/ (Hive persistence — no changes),
                       lib/features/auth/ (login screen — separate story),
                       lib/features/onboarding/ (separate story BL-07),
                       lib/features/local_play/ (multiplayer — no changes),
                       test/core/engine/ (engine tests — no changes needed)
```

---

## 3. Tasks

### 3.1 Task Tree

- [ ] **1.** Design tokens: consolidate and align Aetheric Pulse token system
  - [ ] 1.1 Update `lib/theme/design_system.dart` — add missing shadow presets (`shCardOuter`, `shGlowBlue`, `shGlowEnergy`), motion durations (`durPress: 120ms`, `durHover: 180ms`, `durNormal: 300ms`, `durHero: 600ms`), verify all color hex values match prototype `tokens.css` — _Requirements: AC-001_
  - [ ] 1.2 Create `lib/theme/design_tokens.dart` — extract Aetheric Pulse constants into a clean namespace (`AethericPulse.blue500`, `.gradPrimary`, `.glassFill`, `.radiusCard`, etc.) so screens import one file — _Requirements: AC-001_
  - [ ] 1.3 Write unit tests asserting token values match prototype (color hex, gradient stops, radius, shadow) — _Requirements: AC-001_

- [ ] **2.** Asset integration: copy all PNGs and update pubspec
  - [ ] 2.1 Copy 8 track icon PNGs from `docs/mitoosa-design-system-2/project/assets/icons/` to `assets/images/icons/` — _Requirements: AC-002_
  - [ ] 2.2 Copy 12 avatar PNGs from `docs/mitoosa-design-system-2/project/assets/avatars/` to `assets/images/avatars/` — _Requirements: AC-005, AC-006_
  - [ ] 2.3 Copy 6 badge PNGs from `docs/mitoosa-design-system-2/project/assets/badges/` to `assets/images/badges/` — _Requirements: AC-004, AC-013_
  - [ ] 2.4 Update `pubspec.yaml` with new asset directory entries — _Requirements: AC-002, AC-004, AC-005, AC-006_

- [ ] **3.** Shared components: build reusable widget library
  - [ ] 3.1 Create `lib/widgets/atmosphere.dart` — 3 animated radial gradient blobs + optional star field SVG overlay; parameterized accent color (blue/cyan/pink) — _Requirements: AC-008_
  - [ ] 3.2 Create `lib/widgets/stat_pill.dart` — inline chip with icon slot, label, configurable tint (6 color variants), optional outer glow — _Requirements: AC-002, AC-012_
  - [ ] 3.3 Create `lib/widgets/app_header.dart` — sticky bar: avatar image in gradient ring + "miToosa" gradient text + credits pill with diamond icon — _Requirements: AC-009_
  - [ ] 3.4 Update `lib/widgets/glass_card.dart` — align fill to `rgba(255,255,255,0.045)`, blur to `24px saturate(140%)`, border to `rgba(255,255,255,0.08)`, shadow to `0 8px 24px rgba(0,0,0,0.35)` + inset top highlight; accept optional `accent` glow color — _Requirements: AC-001_
  - [ ] 3.5 Create `lib/widgets/primary_button.dart` — gradient background, pill radius, press scale 0.97, inset shine overlay, optional full-width — _Requirements: AC-002, AC-007_
  - [ ] 3.6 Create `lib/widgets/ghost_button.dart` — outlined with glass fill, pill radius — _Requirements: AC-007_
  - [ ] 3.7 Update `lib/widgets/progress_ring.dart` — use blue→purple gradient stroke, add glow filter on arc, accept `label` and `sublabel` center content — _Requirements: AC-002, AC-004_
  - [ ] 3.8 Create `lib/widgets/toggle_switch.dart` — 42×24px toggle with gradient active fill and spring thumb animation — _Requirements: AC-006_
  - [ ] 3.9 Create `lib/widgets/settings_row.dart` — tinted icon well + title/subtitle + trailing widget; plus `Divider` helper — _Requirements: AC-006_
  - [ ] 3.10 Write widget tests for all shared components (Atmosphere renders, StatPill tints, GlassCard blur, buttons respond to tap) — _Requirements: AC-001, AC-008_

- [ ] **4.** App shell: bottom nav + screen routing
  - [ ] 4.1 Rebuild bottom nav in `main_app_shell.dart` — floating glass bar (24px radius, positioned 14px from bottom), 5-column grid (Tracks/Path/Progress/Leaders/Settings), active tab shows top blue indicator bar + glow + tinted label — _Requirements: AC-009_
  - [ ] 4.2 Replace top app bar with `AppHeader` widget — _Requirements: AC-009_
  - [ ] 4.3 Write navigation tests (tab switching, active state indicators) — _Requirements: AC-009_

- [ ] **5.** Screen: Tracks (world_map_screen.dart)
  - [ ] 5.1 Rebuild screen layout: `Atmosphere` bg → `AppHeader` → Daily Spark hero `GlassCard` (eyebrow timer, title, XP reward copy, `ProgressRing` with game count, 5-dot skill sequence bar, `PrimaryButton` "Start session") — _Requirements: AC-002_
  - [ ] 5.2 Add stat pills strip: streak, energy, stars, XP — horizontal scroll with `no-scrollbar` — _Requirements: AC-002, AC-012, AC-013_
  - [ ] 5.3 Add filter chips row (all/memory/logic/speed/spatial) with active blue highlight — _Requirements: AC-002_
  - [ ] 5.4 Create `FeaturedTrack` widget — full-width tile with track PNG icon in nested well, progress bar, play button — _Requirements: AC-002_
  - [ ] 5.5 Create `TrackTile` widget — square card with PNG icon, name, skill/level meta, accent glow — _Requirements: AC-002_
  - [ ] 5.6 Wire to `playerProgressProvider` for real daily progress, streak, energy, XP, per-track level counts — _Requirements: AC-010_
  - [ ] 5.7 Write widget tests — _Requirements: AC-002, AC-010_

- [ ] **6.** Screen: Path (world_map_path_screen.dart)
  - [ ] 6.1 Create `lib/widgets/path_constellation.dart` — `CustomPainter` rendering S-curve SVG path with dashed/solid segments, node circles (done=green, current=blue+pulse, locked=muted, boss=gold+crown), "You are here" label on current node — _Requirements: AC-003_
  - [ ] 6.2 Rebuild screen layout: `Atmosphere` → `AppHeader` → hero band `GlassCard` (track name, level X of Y, tier progress bar, track icon) → legend chips → `PathConstellation` — _Requirements: AC-003_
  - [ ] 6.3 Wire to `playerProgressProvider` for real level progress per track — _Requirements: AC-003, AC-010_
  - [ ] 6.4 Write widget tests (node state rendering, path line connections) — _Requirements: AC-003_

- [ ] **7.** Screen: Progress (progress_screen.dart)
  - [ ] 7.1 Create `lib/widgets/skill_radar.dart` — `CustomPainter` hexagonal radar chart: concentric ring guides, axis spokes, gradient-filled polygon, colored vertex dots — _Requirements: AC-004_
  - [ ] 7.2 Create `lib/widgets/weekly_bars.dart` — 7-column bar chart with gradient fill, today highlighted, day labels — _Requirements: AC-004_
  - [ ] 7.3 Create `lib/widgets/achievement_card.dart` — badge image (full/greyscale), lock overlay, name/description, progress bar for locked badges, "Unlocked" label for completed — _Requirements: AC-004, AC-013_
  - [ ] 7.4 Rebuild screen layout: `Atmosphere` → `AppHeader` → XP hero `GlassCard` (`ProgressRing` + level + stat pills) → Cognitive map card (radar + skill legend) → This week card (weekly bars) → Milestones grid (2-col achievement cards) — _Requirements: AC-004_
  - [ ] 7.5 Wire to `playerProgressProvider` for real XP, skill scores (computed from `adaptiveHistory`), daily XP breakdown, achievement unlock state — _Requirements: AC-004, AC-010_
  - [ ] 7.6 Write widget tests (radar renders, bars render, achievement states) — _Requirements: AC-004, AC-013_

- [ ] **8.** Screen: Leaderboard (leaderboard_screen.dart)
  - [ ] 8.1 Rebuild screen layout: `Atmosphere` → `AppHeader` → header (eyebrow + gradient title + rank summary) → segmented control (global/friends/local) → podium (2nd-1st-3rd with crown, avatar frames, XP, rank pedestals) → pinned "you" row → remaining player rows — _Requirements: AC-005_
  - [ ] 8.2 Wire player's own row to real XP from `playerProgressProvider`; other rows use demo data with "Coming soon" footer — _Requirements: AC-005, AC-010, AC-014_
  - [ ] 8.3 Write widget tests (podium ordering, "YOU" badge on self row, segmented control switching) — _Requirements: AC-005, AC-014_

- [ ] **9.** Screen: Settings (settings_screen.dart)
  - [ ] 9.1 Rebuild screen layout: `Atmosphere` → `AppHeader` → title → profile `GlassCard` (avatar ring, name, level, credits, edit/avatar ghost buttons) → mastery card (bronze/silver/gold tier, progress bar) → VIP `GlassCard` (gold accent, crown icon, benefits, upgrade button) → Account section (invite row, notifications toggle) → System section (sound/music/haptics toggles) → Support section (how to play, adaptive difficulty, privacy rows) → version footer — _Requirements: AC-006_
  - [ ] 9.2 Wire profile data to `playerProgressProvider`, toggle state to persisted preferences — _Requirements: AC-006, AC-010_
  - [ ] 9.3 Write widget tests (toggle interaction, profile data display, section rendering) — _Requirements: AC-006_

- [ ] **10.** Screen: Game (gameplay_screen.dart)
  - [ ] 10.1 Update game chrome: back button (circle), centered eyebrow (track name + level), 5-dot progress bar, timer pill (blue default / pink pulse when ≤4s) — _Requirements: AC-007, AC-011_
  - [ ] 10.2 Update layout: centered "Find the match" instruction → target `GlassCard` with shape row → 2×2 option grid (selected=cyan glow border) → bottom bar (hint ghost button + submit primary button) — _Requirements: AC-007_
  - [ ] 10.3 Wire to existing `gameplayViewModel` state machine — phase, timer, options, selected, hints — _Requirements: AC-007, AC-010_
  - [ ] 10.4 Write widget tests (timer color switch, option selection state, submit enabled/disabled) — _Requirements: AC-007, AC-011_

- [ ] **11.** Integration: verify everything works together
  - [ ] 11.1 Run `dart analyze` — zero warnings/errors — _Requirements: AC-001_
  - [ ] 11.2 Run `flutter test` — all tests passing (existing + new) — _Requirements: AC-001_
  - [ ] 11.3 Visual verification: launch on iOS simulator and confirm all 6 screens render correctly — _Requirements: AC-001_ `[manual]`

### 3.2 Wave Plan

**Wave 1 (parallel):** 1.1, 1.2, 2.1, 2.2, 2.3, 2.4
**Wave 2 (parallel, after Wave 1):** 1.3, 3.1, 3.2, 3.3, 3.4, 3.5, 3.6, 3.7, 3.8, 3.9
**Wave 3 (parallel, after Wave 2):** 3.10, 4.1, 4.2
**Wave 4 (parallel, after Wave 3):** 4.3, 5.1, 5.2, 5.3, 5.4, 5.5, 6.1, 6.2, 7.1, 7.2, 7.3, 7.4, 8.1, 9.1, 10.1, 10.2
**Wave 5 (parallel, after Wave 4):** 5.6, 5.7, 6.3, 6.4, 7.5, 7.6, 8.2, 8.3, 9.2, 9.3, 10.3, 10.4
**Wave 6 (sequential, after Wave 5):** 11.1, 11.2, 11.3

### 3.3 Test Plan

Test plan: `Docs/AgToosa_TestPlan-S2-01.md`
AC coverage: 14 ACs mapped to test IDs
Smoke set: 7 tests tagged @smoke (one per Must-priority AC)

---

## ✅ Spec Approved

Approved: 2026-05-14 09:30
