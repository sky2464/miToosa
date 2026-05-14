# Spec: S2-02 — Aetheric Pulse Path Screen Swap-In

> **Story ID:** S2-02
> **Epic:** EP-04 — User Experience Polish
> **Parent:** S2-01 (Aetheric Pulse UI Redesign — foundation shipped 2026-05-14)
> **Status:** 🟦 Todo
> **Estimate:** M (2–3 d)
> **Spec created:** 2026-05-14

---

## 1. Requirements

### 1.1 User Stories

**As a** player, **I want** the Path tab to use the constellation-style level path **so that** my journey through a track feels immersive and matches the redesigned screens (Tracks / Progress / Leaderboard).

### 1.2 Acceptance Criteria (EARS)

| ID | EARS | Priority |
|----|------|----------|
| AC-001 | WHEN the player taps the Path tab THE SYSTEM SHALL render the new `PathConstellation` widget (S-curve nodes, dashed full path, solid completed segment with blue glow) | Must |
| AC-002 | WHEN the constellation renders THE SYSTEM SHALL display done nodes (green check), the current node (blue with pulse + "YOU ARE HERE" pill), locked nodes (muted with lock icon), and boss nodes (gold with crown) — states derived from real per-track level progress | Must |
| AC-003 | WHEN the player has multiple tracks THE SYSTEM SHALL allow switching the active track view (preserves existing UX of `world_map_path_screen.dart`) and re-renders the constellation against that track's data | Must |
| AC-004 | WHEN the constellation renders for the first time THE SYSTEM SHALL scroll to bring the current node into view | Should |
| AC-005 | WHEN the screen renders THE SYSTEM SHALL include the existing hero band (track name, level X of Y, tier progress bar, 3D PNG track icon) above the constellation | Should |

### 1.3 Out of Scope

- Adding new path animations beyond the existing `_PulseRing` on the current node
- Touch interactions on individual nodes (tap-to-replay/preview) — separate story
- Boss-level reward modals or special unlock animations

---

## 2. Design

### 2.1 Architecture Blueprint

**Files to modify:**
- `lib/features/navigation/world_map_path_screen.dart` — replace the InteractiveViewer-based node rendering with `PathConstellation`. Keep: track switching, hero band, scroll-to-current logic. Replace: per-track loop body and old node painter.

**Files referenced (no changes):**
- `lib/widgets/path_constellation.dart` — already built in S2-01
- `lib/data/player_progress.dart` — `levelStars[trackId_index]` source of truth

### 2.2 Data Flow

1. Player taps Path tab → `WorldMapPathScreen` builds.
2. Reads active track from existing selection state (preserve from current screen).
3. For each level index `i` in `track.targetLevelCount`:
   - If `levelStars["${track.id}_$i"] > 0` → `PathNodeState.done`
   - Else if `i` is the lowest unstarred index → `PathNodeState.current`
   - Else → `PathNodeState.locked`
   - If `i % 5 == 4` → `PathNodeType.boss`
4. Build `List<PathLevel>` and pass to `PathConstellation(levels: ...)`.
5. On first frame, scroll the SingleChildScrollView so the current node is centered.

### 2.3 Threat Model (STRIDE)

| Threat | Category | Mitigation |
|--------|----------|------------|
| Track switching while constellation is animating leaks pulse controller | DoS | `_PulseRing` already disposes its `AnimationController`; verify in a unit test |
| Empty track (0 levels) breaks the painter's S-curve math | DoS | Guard with `if (track.targetLevelCount == 0) return EmptyState()` |

### 2.4 Build Scope

```
✅ Ready to proceed — Scope Boundary
Files in scope      : lib/features/navigation/world_map_path_screen.dart
Directories in scope: lib/features/navigation/
Out of scope        : lib/widgets/path_constellation.dart (built in S2-01),
                      lib/core/engine/ (engines unchanged), lib/data/ (no schema changes)
```

---

## 3. Tasks

### 3.1 Task Tree

- [ ] **1.** Swap path renderer
  - [ ] 1.1 Replace InteractiveViewer node loop in `world_map_path_screen.dart` with `PathConstellation` widget call — _Requirements: AC-001, AC-002_
  - [ ] 1.2 Map per-track level progress (`levelStars`) into `List<PathLevel>` with correct state/type — _Requirements: AC-002_
  - [ ] 1.3 Preserve track switching UX from existing screen — _Requirements: AC-003_
  - [ ] 1.4 Scroll the current node into view on first frame — _Requirements: AC-004_
  - [ ] 1.5 Guard against empty-track edge case — _Requirements: AC-002_
- [ ] **2.** Tests
  - [ ] 2.1 Widget test: constellation renders done/current/locked node states from mocked progress — _Requirements: AC-001, AC-002_
  - [ ] 2.2 Widget test: track switching re-renders constellation — _Requirements: AC-003_
  - [ ] 2.3 Verify `dart analyze` clean and `flutter test` passes — _Requirements: AC-001_

### 3.2 Wave Plan

**Wave 1 (sequential):** 1.1, 1.2 (must replace render path before mapping data)
**Wave 2 (parallel):** 1.3, 1.4, 1.5
**Wave 3 (parallel):** 2.1, 2.2
**Wave 4 (sequential):** 2.3

### 3.3 Test Plan

Coverage target: 80%. Add 2 widget tests + verify existing path tests still pass.

---

## ✅ Spec Approved

Approved: 2026-05-14 12:00
