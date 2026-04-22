# Implementation Plan: Aetheric Pulse Visual Redesign

**Spec:** [`docs/spec-aetheric-pulse-redesign.md`](spec-aetheric-pulse-redesign.md)  
**Status:** Archived

---

## Architecture Decisions

1. **Inter font** — bundle TTF locally (`assets/fonts/Inter[slnt,wght].ttf`), consistent with Orbitron/Exo 2 pattern. No `google_fonts` package.
2. **AethericPulse rename** — existing `AethericPulse` class → `AethericPulseLight`. Callers updated atomically in Task 2 (`main.dart:39`, `world_map_path_screen.dart:289,337,352`).
3. **darkTheme cutover** — `MiToosaTheme.darkTheme` and `main.dart darkTheme` switch to `AethericPulseDark.themeData` immediately after tokens task. No feature flag.
4. **GameplayScreen** — deferred to a follow-up pass. Not in this plan.
5. **Asset path correction** — icons already exist at `assets/images/icons/`, badges at `assets/images/badges/`; both declared in `pubspec.yaml`. No copying needed. Spec's `assets/icons/` path was incorrect — use `assets/images/icons/` everywhere.

---

## Dependency Graph

```
t1-font
  └─ t2-tokens (AethericPulseDark class + rename)
       ├─ t3-theme-switch
       ├─ t4-background ──────────┬─ t8-shell
       │                          ├─ t9-login
       │                          ├─ t12-leaderboard
       │                          └─ t13-settings
       ├─ t5-glass-card ──────────┬─ t8-shell
       │                          ├─ t9-login
       │                          ├─ t10-world-map
       │                          ├─ t11-progress
       │                          ├─ t12-leaderboard
       │                          └─ t13-settings
       ├─ t6-chip ────────────────┬─ t10-world-map
       │                          └─ t11-progress
       └─ t7-progress-bar ────────┬─ t10-world-map
                                  └─ t11-progress
```

---

## Task List

### Phase 1 — Foundation

#### Task 1: Download Inter variable font; declare in `pubspec.yaml`

**Description:** Download `Inter[slnt,wght].ttf` from Google Fonts (or rsms.me/inter) and place at `assets/fonts/Inter[slnt,wght].ttf`. Add Inter font family declaration to `pubspec.yaml` under `flutter.fonts`. Run `flutter pub get`.

**Acceptance criteria:**
- [ ] `assets/fonts/Inter[slnt,wght].ttf` exists
- [ ] `pubspec.yaml` declares `family: Inter` with TTF asset
- [ ] `flutter pub get` succeeds

**Verification:** `dart analyze` (zero errors)

**Dependencies:** None

**Files:** `pubspec.yaml`, `assets/fonts/Inter[slnt,wght].ttf`

**Scope:** Small (1-2 files)

---

#### Task 2: Add `AethericPulseDark` to `design_system.dart`; rename `AethericPulse` → `AethericPulseLight`

**Description:** Create the `AethericPulseDark` class with the full token set from the spec (colors, gradients, typography, spacing, radii, shadows, font constant). Rename the existing `AethericPulse` class to `AethericPulseLight` and update both callers.

**Acceptance criteria:**
- [ ] `AethericPulseDark` class exists with all 18 color tokens
- [ ] `AethericPulseDark.gradPrimary` (135° blue→purple), `gradMemory`, `heroGlow` defined
- [ ] `AethericPulseDark.fontBody = 'Inter'` constant exists
- [ ] `AethericPulseDark.cardOuter`, `cardInner`, `blueGlow`, `energyGlow` BoxShadow lists defined
- [ ] `AethericPulseDark.themeData` ThemeData getter returns dark Inter-based theme
- [ ] `AethericPulse` renamed to `AethericPulseLight` everywhere
- [ ] `lib/main.dart` compiles (`AethericPulseLight.lightTheme`)
- [ ] `lib/features/navigation/world_map_path_screen.dart` compiles (`AethericPulseLight.*`)

**Verification:** `dart analyze` zero errors; `flutter test` passes

**Dependencies:** Task 1 (Inter font family name must match pubspec)

**Files:** `lib/theme/design_system.dart`, `lib/main.dart`, `lib/features/navigation/world_map_path_screen.dart`

**Scope:** Medium (3 files)

---

#### Task 3: Switch `darkTheme` to `AethericPulseDark.themeData`

**Description:** Update `MiToosaTheme.darkTheme` getter and `main.dart` MaterialApp `darkTheme` param to use `AethericPulseDark.themeData`.

**Acceptance criteria:**
- [ ] `MiToosaTheme.darkTheme` returns `AethericPulseDark.themeData`
- [ ] `main.dart` `darkTheme: AethericPulseDark.themeData`

**Verification:** `dart analyze` + `flutter test`

**Dependencies:** Task 2

**Files:** `lib/theme/design_system.dart`, `lib/main.dart`

**Scope:** Small

---

**✅ Checkpoint 1:** `dart analyze` zero errors, `flutter test` all pass

---

### Phase 2 — Core Primitives

#### Task 4: Update `KineticBackground` — surface `#0a0d17`, top-center blue glow

**Description:** Replace the 2-blob corner glow pattern with a single top-center radial blue glow on an `#0a0d17` surface.

**Acceptance criteria:**
- [ ] `ColoredBox` uses `AethericPulseDark.surface` (`#0a0d17`)
- [ ] Single `Positioned` top-center `RadialGradient(colors: [Color(0x593B82F6), Colors.transparent], radius: 0.7, center: Alignment.topCenter)`, height 600, top offset -200
- [ ] No purple/cyan corner blobs

**Verification:** `dart analyze`; visual check in Chrome

**Dependencies:** Task 2

**Files:** `lib/widgets/kinetic_background.dart`

**Scope:** Small

---

#### Task 5: Update `GlassCard` — 24px blur/radius, uniform border, shadow pair

**Description:** Upgrade the glass card to the Aetheric Pulse recipe.

**Acceptance criteria:**
- [ ] `BackdropFilter` sigma 24 (was 16)
- [ ] Default `borderRadius` = `AethericPulseDark.radiusCard` (24) (was 8)
- [ ] Fill = `Color(0x14FFFFFF)` (was dynamic surface)
- [ ] Border = `Border.all(color: Color(0x1FFFFFFF), width: 1)` (uniform; was asymmetric)
- [ ] Default `boxShadow` = `[AethericPulseDark.cardOuter, AethericPulseDark.cardInner]`
- [ ] `neonGlow` param preserved for backward compat

**Verification:** `dart analyze` + `flutter test`

**Dependencies:** Task 2

**Files:** `lib/widgets/glass_card.dart`

**Scope:** Small

---

#### Task 6: Create `KineticChip` widget

**Description:** New reusable pill chip for stat pills and category labels.

**Acceptance criteria:**
- [ ] `lib/widgets/kinetic_chip.dart` exists
- [ ] Props: `label` (String), optional `leading` (Widget?), optional `color` (Color?)
- [ ] Fill: `Color(0x33A855F7)` (purple 20%), border: `Color(0x4DA855F7)`, radius: 999
- [ ] Label: Inter 500 12sp, `AethericPulseDark.brandPurple`

**Verification:** `dart analyze`

**Dependencies:** Task 2

**Files:** `lib/widgets/kinetic_chip.dart`

**Scope:** Small

---

#### Task 7: Create `KineticProgressBar` widget

**Description:** Thin 4px gradient progress bar with glow for XP and track progress.

**Acceptance criteria:**
- [ ] `lib/widgets/kinetic_progress_bar.dart` exists
- [ ] Props: `value` (double 0.0–1.0), optional `gradient` (defaults to `gradPrimary`)
- [ ] 4px height track; `Color(0x14FFFFFF)` background; `BorderRadius.circular(999)`
- [ ] Fill: `FractionallySizedBox` with `LinearGradient` 135° blue→purple
- [ ] Glow: `BoxShadow(color: Color(0x4022D3EE), blurRadius: 8)`

**Verification:** `dart analyze`

**Dependencies:** Task 2

**Files:** `lib/widgets/kinetic_progress_bar.dart`

**Scope:** Small

---

**✅ Checkpoint 2:** `dart analyze` zero errors, `flutter test` all pass

---

### Phase 3 — Shell & Auth

#### Task 8: Update `MainAppShell` — Inter top bar; 2px top-edge nav indicator

**Description:** Update the top app bar to use Aetheric Pulse tokens and replace the rounded active-pill nav item with a 2px top-edge indicator.

**Acceptance criteria:**
- [ ] Top bar background: `AethericPulseDark.glassFill` + border bottom
- [ ] Wordmark: Inter 700, `AethericPulseDark.brandBlue` gradient via ShaderMask
- [ ] Bottom nav background: `AethericPulseDark.glassFill`, border top
- [ ] Active tab: 2px `Container` at top using `gradPrimary` + `blueGlow` BoxShadow
- [ ] Active icon/label: `AethericPulseDark.brandBlue`; inactive: `AethericPulseDark.onSurfaceMuted`

**Verification:** `dart analyze` + `flutter test`

**Dependencies:** Tasks 4, 5

**Files:** `lib/features/main_app/main_app_shell.dart`

**Scope:** Medium

---

#### Task 9: Update `LoginScreen` — AethericBackground, Inter wordmark, gradPrimary CTA

**Description:** Apply Aetheric Pulse visual treatment to the login screen.

**Acceptance criteria:**
- [ ] `KineticBackground` wraps screen (already uses updated widget from Task 4)
- [ ] Wordmark: Inter 800 40sp, `AethericPulseDark.onSurface`
- [ ] Blue glow below wordmark: `primaryGlow` radial pulse, 600ms entrance
- [ ] Primary CTA: `gradPrimary` pill button (borderRadius 999), Inter 600 label
- [ ] No hardcoded KineticObsidian hex values

**Verification:** `dart analyze`

**Dependencies:** Tasks 4, 5

**Files:** `lib/features/auth/login_screen.dart`

**Scope:** Medium

---

### Phase 4 — Content Screens

#### Task 10: Update `WorldMapScreen` — stat pills row; PNG icon in nested well

**Description:** Add horizontal stat pills row and replace emoji icons with 3D PNG images in nested square wells.

**Acceptance criteria:**
- [ ] Horizontal `SingleChildScrollView` stat pills row at top (XP, Streak, Energy, Credits) using `KineticChip`
- [ ] Track card uses `GlassCard` (24px radius)
- [ ] Each card has a 56×56 square `Container` (fill `AethericPulseDark.nestedWell`, radius 16) with `Image.asset('assets/images/icons/track_<id>.png')`
- [ ] Track name: Inter 600 18sp, `AethericPulseDark.onSurface`
- [ ] Track progress: `KineticProgressBar`
- [ ] Locked track: `Opacity(opacity: 0.4)` overlay + `onSurfaceMuted` label
- [ ] No emoji as primary icon

**Verification:** `dart analyze` + `flutter test`

**Dependencies:** Tasks 5, 6, 7

**Files:** `lib/features/navigation/world_map_screen.dart`

**Scope:** Medium (3-5 files)

---

#### Task 11: Update `ProgressScreen` — Inter 900 hero, stat grid, badge PNGs

**Description:** Apply hero numeral treatment, GlassCard stat grid, and badge PNGs.

**Acceptance criteria:**
- [ ] XP numeral: Inter 900 64sp, `ShaderMask(gradPrimary)`
- [ ] "Level X" eyebrow: Inter 600 13sp ALL CAPS, `AethericPulseDark.onSurfaceMeta`
- [ ] Stat grid cells: `GlassCard` (24px radius), accent values (`accentAmber`/`accentOrange`)
- [ ] XP progress: `KineticProgressBar` full-width
- [ ] Badges: `Image.asset('assets/images/badges/<name>.png')` — locked = `Opacity(0.3)`

**Verification:** `dart analyze` + `flutter test`

**Dependencies:** Tasks 5, 6, 7

**Files:** `lib/features/main_app/progress_screen.dart`

**Scope:** Medium

---

#### Task 12: Update `LeaderboardScreen` — AP tokens, avatars, alternating rows

**Description:** Apply Aetheric Pulse tokens throughout the leaderboard.

**Acceptance criteria:**
- [ ] Background: `AethericPulseDark.surface`
- [ ] Rows: alternating `Color(0x14FFFFFF)` / transparent
- [ ] Rank 1-3: `AethericPulseDark.accentAmber` crown badge
- [ ] Player row: 40px circular `Image.asset('assets/images/avatars/avatar_N.png')`, Inter 500 16sp, `onSurfaceSecondary` XP
- [ ] Own row: 3px left border `AethericPulseDark.activeBorder`

**Verification:** `dart analyze`

**Dependencies:** Tasks 4, 5

**Files:** `lib/features/main_app/leaderboard_screen.dart`

**Scope:** Medium

---

#### Task 13: Update `SettingsScreen` — AP tokens, VIP card

**Description:** Apply Aetheric Pulse tokens to settings.

**Acceptance criteria:**
- [ ] Section headers: Inter 600 13sp ALL CAPS, `AethericPulseDark.onSurfaceMeta`
- [ ] Setting rows: `GlassCard` background, `onSurface` label, `Switch(activeColor: brandBlue)`
- [ ] VIP card: `GlassCard` with `gradPrimary` ShaderMask title, `accentAmber` chip

**Verification:** `dart analyze` + `flutter test`

**Dependencies:** Tasks 4, 5

**Files:** `lib/features/settings/settings_screen.dart`

**Scope:** Medium

---

**✅ Checkpoint 3 (FINAL):** `dart analyze` zero errors, `flutter test` zero regressions, visual match to spec

---

## Risks and Mitigations

| Risk | Impact | Mitigation |
|---|---|---|
| Inter TTF file size | Low | Variable font single file ~300KB — acceptable |
| AethericPulse rename breaks callers | Med | Only 2 files; update atomically in Task 2 |
| GlassCard radius 8→24 clips content | Med | Verify each screen after Task 5 |
| `darkTheme` cutover visible regression | Low | No tests directly exercise darkTheme |

---

## Out of Scope (deferred)

- **GameplayScreen** and its overlays — follow-up pass
- `AethericPulseLight` deletion — keep until light-mode feature is planned
- `world_map_path_screen.dart` visual redesign — uses AethericPulseLight gradient, defer to path-screen pass
