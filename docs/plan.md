## Plan: miToosa Sleek iOS Redesign — Aetheric Pulse

**TL;DR**
Introduce a sleek iOS 2026 look by layering an **Aetheric Pulse** palette (soft blue `#597AFA` and pink pastel gradients) on top of the existing **Kinetic Obsidian** dark theme. Add an **Aetheric Pulse Dark** variant (Inter font, brand blue `#3B82F6` + purple `#A855F7`) for the primary dark experience. Glassmorphism and `BackdropFilter` are already in use via `GlassCard`; this plan extends them rather than introducing them. Fluid spring animations and a dopamine feedback toast (+N XP "IQ +1!") are tuned for ADHD flow.

**Baseline truths (what already exists)**
- Theme system (`lib/theme/design_system.dart`) ships with `KineticObsidian` dark tokens. Aetheric Pulse Light and Dark classes now live alongside it; none replace each other.
- Glassmorphism is already in production via `lib/widgets/glass_card.dart` (50% surfaceContainer fill, 16 px `BackdropFilter`, lit top/left edges) and the top-bar / nav bar (24 px blur).
- Haptics are wired via `lib/core/haptics_service.dart` (native `HapticFeedback`). No external haptics package needed.
- `flutter_riverpod` state is used throughout; `ref.listen` is the hook we now use to fire the per-puzzle dopamine toast.
- Font stack: Orbitron (display) + Exo 2 (body) bundled locally. Inter is bundled for the Aetheric Pulse Dark typography scale. `google_fonts` has been removed from the dependency list so no font is fetched from a CDN at runtime.

**Mockup links**
- Project ID: `8116825045928899731`
- Dashboard Map: Screen ID `cb2f8947555041b6b1d0a2af0114e940`
- Progress / Streak: Screen ID `2db3a9c3f7934ca6ab0497d5adf30351`
- Leaderboard: Screen ID `0ba2fc556ebd4b0aa60b551f6330781d`

**Steps (as implemented)**
1. **Theme**: Add Aetheric Pulse tokens to `lib/theme/design_system.dart` alongside Kinetic Obsidian. New radii `radiusPillow = 25`, `radiusPillowLg = 32`, `radiusHero = 40`. New `aethericGradient` (soft blue → pink). Add `AethericPulseLight.lightTheme` and `AethericPulseDark.themeData` for `ThemeMode.system`.
2. **Shell**: Rebuild `lib/features/main_app/main_app_shell.dart` as a floating frosted pill nav (24 px blur, 32 px radius, 16 px inset, respects `SafeArea`). Add a new **Path** tab pointing at `WorldMapPathScreen`. Every nav item wrapped in `Semantics` + a 44×44 `ConstrainedBox`.
3. **Path map**: New `lib/features/navigation/world_map_path_screen.dart`. Supports both vertical and horizontal layouts (toggle + `MediaQuery.orientation`). `InteractiveViewer` + `TransformationController` zoom the current (highest unlocked) level to fill the viewport on entry via a `Matrix4Tween` animation (500 ms `easeOutCubic`). Unlocked nodes pulse via `ScaleTransition`. Path line uses `AethericPulseLight.gradient`.
4. **Dopamine feedback**: New `lib/widgets/feedback_toast.dart`. Shown on `PhaseCompleted` edge via `ref.listen(gameplayViewModelProvider(level))` in `gameplay_screen.dart`. 280 ms `easeOutBack` scale+fade. Complements — does not replace — `SessionCompleteOverlay`. Haptic already fires in `_handleOptionTap` via the existing `HapticsService`.
5. **Login polish**: `lib/features/auth/login_screen.dart` CTA wrapped in `Semantics` + 44×44 constraint; keeps float/pulse ambient animations.
6. **Accessibility sweep**: All interactive surfaces across the nav, world map, and settings wrap `GestureDetector` in `Semantics(button: true, label: ...)` + `ConstrainedBox(minWidth: 44, minHeight: 44)`.
7. **Settings**: Add an Appearance row with a three-way System/Light/Dark selector bound to new `PlayerProgress.themeModeOverride` (schema v7). Mask the raw UUID with a `Semantics` label that explicitly describes anonymity.
8. **Platform dependencies**: Bundle `Orbitron-Variable.ttf`, `Exo2-Variable.ttf`, `Exo2-Italic-Variable.ttf`, and `Inter[slnt,wght].ttf` in `assets/fonts/`. Remove `google_fonts`. Add `flutter_animate: ^4.5.0`.

**Relevant files**
- `lib/theme/design_system.dart` — `KineticObsidian`, `AethericPulseLight`, `AethericPulseDark` (do not remove any; they coexist).
- `lib/main.dart` — `ThemeMode.system`, respects `PlayerProgress.themeModeOverride`.
- `lib/features/main_app/main_app_shell.dart` — floating frosted pill nav with Path tab.
- `lib/features/navigation/world_map_path_screen.dart` — new, dual-orientation path with zoom-to-current.
- `lib/features/navigation/world_map_screen.dart` — existing Daily Training dashboard (untouched except for a11y wrappers).
- `lib/widgets/feedback_toast.dart` — per-puzzle dopamine toast.
- `lib/features/gameplay/gameplay_screen.dart` — `ref.listen` wiring for the toast.
- `lib/features/auth/login_screen.dart` — Semantics + 44×44 on CTA.
- `lib/features/settings/settings_screen.dart` — Appearance selector; masked ID Semantics.
- `lib/data/player_progress.dart` — schema v7, nullable `themeModeOverride`.
- `pubspec.yaml` — bundled Orbitron / Exo 2 / Inter fonts; `flutter_animate` added; `google_fonts` removed.

**Verification**
1. `flutter pub get`.
2. `flutter pub run build_runner build --delete-conflicting-outputs` after any Riverpod or Hive-adapter change.
3. `dart analyze` — zero warnings across modified files.
4. `flutter test` — existing 86 `PlayerProgress` tests pass; new tests cover feedback toast entry/exit and `themeModeOverride` Hive round-trip for pre-v7 saves.
5. `flutter run -d "iPhone 15 Pro" --no-tree-shake-icons`:
   - Every nav item and CTA is at least 44×44 points (check with iOS Accessibility Inspector).
   - VoiceOver reads every nav item, CTA, and the masked pilot ID correctly.
   - Dynamic Type at Accessibility sizes renders without clipping.
   - Rotating the device switches the Path screen between vertical ↔ horizontal and re-centers on the current level.
   - Completing a puzzle shows a single dopamine toast, haptic fires once, no frame drops (DevTools Performance).
   - Toggling the iOS light/dark system setting flips themes when the Appearance selector is on System.
6. Web smoke (`flutter run -d chrome`): glass/backdrop renders; be aware that `flutter_secure_storage` falls back to **plaintext localStorage** on web. If web is a shipping target, document this caveat and plan a server-side key sync before launch.

**Decisions**
- *Coexistence over replacement*: Aetheric Pulse is additive. Kinetic Obsidian stays for screens that rely on neon cyan/purple identity. This avoids a half-migrated look during rollout.
- *Animation budget 180–500 ms*: ADHD flow — hover / press transitions stay under 300 ms; celebratory beats (session complete) get up to 500 ms. The existing 500 ms elastic "Correct!" animation sits right at the edge and is preserved.
- *No new haptics dependency*: `HapticsService` already covers light/medium/heavy and selection click.
- *Local fonts*: bundling removed CDN reach-out at runtime; strengthens the offline-first claim.

**Further Considerations**
1. **Dark-only today → `ThemeMode.system` plus override**: the app now supports Light, Dark, and System. Next step is to audit screens that hard-code dark colors (the `KineticBackground` particle layer, for instance) so they render correctly in Light.
2. **Web secure storage**: `flutter_secure_storage` degrades to plaintext `localStorage` on web. Not a regression from this plan, but worth surfacing before any marketing push that emphasizes security.
3. **Share flow**: `share_plus` stays pinned at `^12.0.2` due to the Windows `flutter_secure_storage` incompatibility. Any redesigned share UI should not force an upgrade.
