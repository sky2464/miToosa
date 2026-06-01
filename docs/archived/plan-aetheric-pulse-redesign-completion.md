# Plan: miToosa Sleek iOS Redesign — Aetheric Pulse

**Status:** Archived
**Archived:** 2026-04-24

**TL;DR**
Introduced a sleek iOS 2026 look by layering an **Aetheric Pulse** palette (soft blue `#597AFA` and pink pastel gradients) on top of the existing **Kinetic Obsidian** dark theme. Added an **Aetheric Pulse Dark** variant (Inter font, brand blue `#3B82F6` + purple `#A855F7`) for the primary dark experience. Glassmorphism and `BackdropFilter` extended via `GlassCard`. Fluid spring animations and a dopamine feedback toast (+N XP "IQ +1!") tuned for ADHD flow.

**Mockup links**
- Project ID: `8116825045928899731`
- Dashboard Map: Screen ID `cb2f8947555041b6b1d0a2af0114e940`
- Progress / Streak: Screen ID `2db3a9c3f7934ca6ab0497d5adf30351`
- Leaderboard: Screen ID `0ba2fc556ebd4b0aa60b551f6330781d`

**Relevant files**
- `lib/theme/design_system.dart` — `KineticObsidian`, `AethericPulseLight`, `AethericPulseDark` (coexist)
- `lib/main.dart` — `ThemeMode.system`, respects `PlayerProgress.themeModeOverride`
- `lib/features/main_app/main_app_shell.dart` — floating frosted pill nav with Path tab
- `lib/features/navigation/world_map_path_screen.dart` — dual-orientation path with zoom-to-current
- `lib/features/navigation/world_map_screen.dart` — Daily Training dashboard (a11y wrappers added)
- `lib/widgets/feedback_toast.dart` — per-puzzle dopamine toast
- `lib/features/gameplay/gameplay_screen.dart` — `ref.listen` wiring for the toast
- `lib/features/auth/login_screen.dart` — Semantics + 44×44 on CTA
- `lib/features/settings/settings_screen.dart` — Appearance selector; masked ID Semantics
- `lib/data/player_progress.dart` — schema v7, nullable `themeModeOverride`
- `pubspec.yaml` — bundled Orbitron / Exo 2 / Inter fonts; `google_fonts` removed

**Completed items (2026-04-22 → 2026-04-24)**
- P1: Light-mode rendering — `KineticBackground`, `KineticText`, `ProgressRing` adapted to `ThemeMode.system`
- P2: Gameplay option cards — `Semantics(button:true)` wrappers added to `_buildListOption()` and `_buildOptionCard()`
- P3: `recordLevelTime` wired in `_saveProgress()` in `gameplay_screen.dart`
- P4: Leaderboard live player XP via `ref.watch(playerProgressProvider).totalXP`
- P5: `flutter_animate` removed from `pubspec.yaml` (was imported nowhere)
- P6: Dynamic Type migration — `textTheme.*` adopted across login, shell, path screen, toast
- P7: `WorldMapPathScreen` 6-test suite added (portrait, landscape, semantics, orientation, zoom, highlight)
- P8: World map path screen token cleanup — `KineticObsidian` refs replaced with `AethericPulse*` tokens
- All 637 tests pass

**Decisions**
- *Coexistence over replacement*: Aetheric Pulse is additive. Kinetic Obsidian stays for screens relying on neon cyan/purple identity.
- *Animation budget 180–500 ms*: ADHD flow — hover/press under 300 ms; celebratory beats up to 500 ms.
- *No new haptics dependency*: `HapticsService` already covers light/medium/heavy and selection click.
- *Local fonts*: bundling removed CDN reach-out at runtime; strengthens offline-first claim.

**Archived:** 2026-04-24
