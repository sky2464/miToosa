# Spec: S2-04 — Aetheric Pulse Tracks Completion + Settings Refactor + Screen Tests

> **Story ID:** S2-04
> **Epic:** EP-04 — User Experience Polish
> **Parent:** S2-01 (Aetheric Pulse UI Redesign — foundation shipped 2026-05-14)
> **Status:** 🟦 Todo
> **Estimate:** L (4–5 d)
> **Spec created:** 2026-05-14

---

## 1. Requirements

### 1.1 User Stories

**As a** player, **I want** the Tracks tab to show a polished Daily Spark hero, filter chips, and PNG-iconed track tiles **so that** the entry screen feels as premium as the rebuilt Progress + Leaderboard tabs.

**As a** player, **I want** the Settings screen to follow the redesigned visual system **so that** every tab has consistent chrome and toggles.

**As an** engineering team, **we want** screen-level widget tests for the four rebuilt screens (Tracks / Path / Progress / Leaderboard) and the navigation shell **so that** the AC ledger is honest and regressions surface in CI.

### 1.2 Acceptance Criteria (EARS)

| ID | EARS | Priority |
|----|------|----------|
| AC-001 | WHEN the player opens the Tracks tab THE SYSTEM SHALL render the Daily Spark hero `GlassCard` with eyebrow timer, headline ("Today's session"), `ProgressRing` showing N/5 games complete, 5-dot skill sequence row, and a `PrimaryButton` "Start session" CTA — wired to real `playerProgressProvider` data | Must |
| AC-002 | WHEN the Tracks tab renders THE SYSTEM SHALL display filter chips (`all / memory / logic / speed / spatial`) with active state showing blue background + glow | Must |
| AC-003 | WHEN the Tracks tab renders THE SYSTEM SHALL display a featured track tile (full-width, 3D PNG icon in nested well, progress bar, play button) and a 2-column grid of secondary track tiles (each with 3D PNG icon, name, skill, level count) | Must |
| AC-004 | WHEN the Settings tab renders THE SYSTEM SHALL use the new `SettingsRow` + `ToggleSwitch` widgets for all toggleable rows (sound, music, haptics, notifications) — preserving existing `AudioService` / `MusicService` / `HapticsService` wiring | Must |
| AC-005 | WHEN screen-level widget tests run THE SYSTEM SHALL have at least one test per: Tracks screen (T-003/T-004/T-005), Path screen (T-006/T-007), Progress screen (T-008/T-009/T-010), Leaderboard screen (T-012/T-013), MainAppShell nav (T-019/T-020), and one integration test with a mocked `playerProgressProvider` (T-021..T-023) | Must |
| AC-006 | IF a screen reads from `playerProgressProvider` and the provider returns `error` THE SYSTEM SHALL render an empty state, never crash | Should |

### 1.3 Out of Scope

- New track content or rules (worlds.json untouched)
- Backend leaderboard wiring (still demo data for non-self rows — covered by EP-03)
- VIP purchase flow implementation (Settings VIP card stays UI-only)
- Avatar selection/editing (separate story)

---

## 2. Design

### 2.1 Architecture Blueprint

**Files to modify:**
- `lib/features/navigation/world_map_screen.dart` — finalize Daily Spark hero (already has the base), add filter chips row, replace track grid with `FeaturedTrack` + `TrackTile` widgets using PNG icons. Reuse `StatPill` strip already added in S2-01.
- `lib/features/settings/settings_screen.dart` — replace `_SettingRow` with `SettingsRow` and `_KineticToggle` with `ToggleSwitch`. Keep audio/music/haptics service wiring intact.

**Files to create:**
- `lib/widgets/featured_track.dart` — full-width featured track tile (extracted from S2-01 prototype `screen-tracks.jsx`)
- `lib/widgets/track_tile.dart` — 2-column grid tile
- `test/features/main_app/tracks_screen_test.dart`
- `test/features/main_app/leaderboard_screen_test.dart`
- `test/features/main_app/progress_screen_test.dart`
- `test/features/navigation/world_map_path_screen_test.dart` (or update existing if present)
- `test/features/main_app/main_app_shell_nav_test.dart`
- `test/features/integration/progress_provider_integration_test.dart`

**Files referenced (no changes):**
- `lib/theme/design_tokens.dart` (`AP` namespace)
- `lib/widgets/{stat_pill,primary_button,ghost_button,progress_ring,glass_card,settings_row,toggle_switch}.dart`

### 2.2 Data Flow

1. Tracks tab → `WorldMapScreen` reads `playerProgressProvider`.
2. Daily Spark hero shows `gamesPlayedToday / 5` via `freeGamesRemaining` and `dailyXP`.
3. Filter chips update local `_filter` state; track grid filters by `skill` tag.
4. Featured track = first track with `levelStars` showing in-progress (most recent unstarred level); else first track.
5. `TrackTile` reads `track.targetLevelCount` and computes per-track completed levels from `levelStars`.
6. Settings: tap → toggle local state → existing service call → persist via existing wiring.

### 2.3 Threat Model (STRIDE)

| Threat | Category | Mitigation |
|--------|----------|------------|
| Filter chip selection persists across track navigation, confusing players | Repudiation | Reset filter on screen rebuild; document expected behaviour in test |
| Track PNG fails to load on web build | DoS | All `Image.asset` calls have `errorBuilder` fallback to an icon |
| Settings service swap leaves toggle UI desynced from actual `AudioService.enabled` | Tampering | Initialize toggle state from service on mount; service is single source of truth |

### 2.4 Build Scope

```
✅ Ready to proceed — Scope Boundary
Files in scope      : lib/features/navigation/world_map_screen.dart,
                       lib/features/settings/settings_screen.dart,
                       lib/widgets/featured_track.dart (new),
                       lib/widgets/track_tile.dart (new),
                       test/features/main_app/, test/features/navigation/,
                       test/features/integration/
Directories in scope: lib/features/{navigation,settings,main_app}/, lib/widgets/, test/
Out of scope        : lib/core/engine/, lib/data/, gameplay_screen.dart (covered by S2-03),
                      world_map_path_screen.dart (covered by S2-02)
```

---

## 3. Tasks

### 3.1 Task Tree

- [ ] **1.** Tracks polish
  - [ ] 1.1 Refine Daily Spark hero: eyebrow timer, "Today's session" headline, ProgressRing N/5, skill sequence dots, Start session PrimaryButton — _Requirements: AC-001_
  - [ ] 1.2 Add filter chip row (all/memory/logic/speed/spatial) with active blue glow — _Requirements: AC-002_
  - [ ] 1.3 Create `lib/widgets/featured_track.dart` and `lib/widgets/track_tile.dart` — _Requirements: AC-003_
  - [ ] 1.4 Replace existing track cards with FeaturedTrack + 2-col TrackTile grid; wire PNG icons via `AP.trackIcon(id)` — _Requirements: AC-003_
- [ ] **2.** Settings refactor
  - [ ] 2.1 Swap `_SettingRow` → `SettingsRow` and `_KineticToggle` → `ToggleSwitch` in `settings_screen.dart`, preserving service wiring — _Requirements: AC-004_
- [ ] **3.** Screen-level tests
  - [ ] 3.1 `tracks_screen_test.dart` — Daily Spark hero, filter chips, featured + grid (3 tests) — _Requirements: AC-005_
  - [ ] 3.2 `progress_screen_test.dart` — XP hero, radar, weekly bars, achievement grid (3 tests) — _Requirements: AC-005_
  - [ ] 3.3 `leaderboard_screen_test.dart` — podium, segmented control, YOU row (3 tests) — _Requirements: AC-005_
  - [ ] 3.4 `world_map_path_screen_test.dart` — constellation renders, track switch (2 tests) — _Requirements: AC-005_
  - [ ] 3.5 `main_app_shell_nav_test.dart` — 5-tab nav, active indicator (2 tests) — _Requirements: AC-005_
  - [ ] 3.6 `progress_provider_integration_test.dart` — mocked provider, screens show real values (3 tests) — _Requirements: AC-005, AC-006_
- [ ] **4.** Verification
  - [ ] 4.1 `dart analyze` clean — _Requirements: AC-001_
  - [ ] 4.2 `flutter test` all passing — _Requirements: AC-001_
  - [ ] 4.3 Visual verification on simulator — _Requirements: AC-001_ `[manual]`

### 3.2 Wave Plan

**Wave 1 (parallel):** 1.1, 1.2, 1.3 (independent widget work)
**Wave 2 (sequential after Wave 1):** 1.4
**Wave 3 (parallel):** 2.1, 3.1, 3.2, 3.3, 3.4, 3.5, 3.6
**Wave 4 (sequential):** 4.1, 4.2
**Wave 5 (manual):** 4.3

### 3.3 Test Plan

Test plan: this spec (sub-section 3.3 above) — 16 new screen-level tests added across 6 new test files. Coverage target 80%; expect total test count to land near 740+.

---

## ✅ Spec Approved

Approved: 2026-05-14 12:00
