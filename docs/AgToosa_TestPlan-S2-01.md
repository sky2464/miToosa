# Test Plan: S2-01 — Aetheric Pulse UI Redesign

> **Spec reference:** [Docs/archived/spec-S2-01.md](archived/spec-S2-01.md)
> **Coverage target:** 80% (from `Docs/Context/workflow.md`)

---

## AC Coverage Table

| AC | Description | Test IDs | Category |
|----|-------------|----------|----------|
| AC-001 | Aetheric Pulse tokens render correctly | T-001, T-002 | Unit |
| AC-002 | Tracks screen renders all sections | T-003, T-004, T-005 | Unit, Integration |
| AC-003 | Path constellation renders with correct node states | T-006, T-007 | Unit |
| AC-004 | Progress screen renders XP hero, radar, weekly bars, achievements | T-008, T-009, T-010, T-011 | Unit |
| AC-005 | Leaderboard renders podium + segmented control + rows | T-012, T-013 | Unit |
| AC-006 | Settings screen renders all sections with working toggles | T-014, T-015 | Unit |
| AC-007 | Game screen renders chrome, timer, options, hint/submit | T-016, T-017 | Unit |
| AC-008 | Atmosphere renders animated glow blobs | T-018 | Unit |
| AC-009 | Bottom nav renders 5 tabs with active state | T-019, T-020 | Unit, Integration |
| AC-010 | Screens display real player data from providers | T-021, T-022, T-023 | Integration |
| AC-011 | Timer switches to pink pulse when ≤4s | T-024 | Unit |
| AC-012 | Stat pills support horizontal scroll | T-025 | Unit |
| AC-013 | Locked achievements show greyscale + lock + progress | T-026 | Unit |
| AC-014 | Player's own leaderboard row highlighted with "YOU" badge | T-027 | Unit |

---

## Test Details

### Unit Tests

| ID | Test Name | AC | @smoke |
|----|-----------|-----|--------|
| T-001 | `design_tokens_match_prototype` — verify hex values for surface, brand colors, gradients | AC-001 | @smoke |
| T-002 | `glass_card_uses_aetheric_pulse_recipe` — fill opacity 0.045, blur 24px, border 0.08 | AC-001 | |
| T-003 | `tracks_screen_renders_daily_spark_hero` — finds ProgressRing, "Start session" button, stat pills | AC-002 | @smoke |
| T-004 | `tracks_screen_renders_featured_track` — finds track name, progress bar, play button | AC-002 | |
| T-005 | `tracks_screen_renders_track_grid` — finds 7 TrackTile widgets (8 tracks - 1 featured) | AC-002 | |
| T-006 | `path_constellation_renders_nodes` — done nodes green, current node blue with pulse, locked muted | AC-003 | @smoke |
| T-007 | `path_constellation_boss_node_gold` — boss nodes show gold border and "Boss" label | AC-003 | |
| T-008 | `progress_screen_renders_xp_hero` — finds ProgressRing with XP value, level display | AC-004 | @smoke |
| T-009 | `skill_radar_renders_polygon` — 6-point polygon visible with correct vertex count | AC-004 | |
| T-010 | `weekly_bars_renders_7_days` — 7 bar columns rendered, today highlighted | AC-004 | |
| T-011 | `achievement_card_locked_state` — greyscale filter, lock icon, progress bar visible | AC-004, AC-013 | |
| T-012 | `leaderboard_renders_podium` — top 3 players in 2-1-3 layout with crown on first | AC-005 | @smoke |
| T-013 | `leaderboard_segmented_control` — 3 segments (global/friends/local), tap switches active | AC-005 | |
| T-014 | `settings_screen_renders_profile` — avatar, player name, level, credits visible | AC-006 | @smoke |
| T-015 | `settings_toggle_interaction` — tapping toggle changes state, visual updates | AC-006 | |
| T-016 | `game_screen_renders_chrome` — back button, level indicator, progress dots, timer | AC-007 | @smoke |
| T-017 | `game_screen_option_selection` — tapping option highlights it with cyan border | AC-007 | |
| T-018 | `atmosphere_renders_glow_blobs` — widget tree contains 3 positioned gradient containers | AC-008 | |
| T-019 | `bottom_nav_renders_5_tabs` — Tracks, Path, Progress, Leaders, Settings labels visible | AC-009 | |
| T-020 | `bottom_nav_active_tab_indicator` — selected tab shows blue glow indicator | AC-009 | |
| T-024 | `game_timer_pink_at_4s` — timer container uses pink tint when value ≤ 4 | AC-011 | |
| T-025 | `stat_pills_scrollable` — horizontal scroll view contains stat pill children | AC-012 | |
| T-026 | `achievement_card_locked_with_progress` — progress bar shows X/Y fraction, lock icon overlay | AC-013 | |
| T-027 | `leaderboard_you_row_highlighted` — player row has blue background, "YOU" badge visible | AC-014 | |

### Integration Tests

| ID | Test Name | AC | @smoke |
|----|-----------|-----|--------|
| T-021 | `tracks_screen_reads_player_progress` — with mocked provider, screen shows real XP/streak/energy values | AC-010 | |
| T-022 | `progress_screen_reads_skill_scores` — radar chart polygon shaped by adaptive history data | AC-010 | |
| T-023 | `path_screen_reads_level_progress` — node states (done/current/locked) derived from real level data | AC-010 | |

---

## Negative / Edge Scenarios

| ID | Test Name | AC | Description |
|----|-----------|-----|-------------|
| T-028 | `tracks_screen_zero_progress` | AC-002, AC-013 | Fresh player: 0 streak, 25/25 energy, 0 XP, no track progress — graceful zero states |
| T-029 | `path_screen_level_1` | AC-003 | Only first node is "current", rest are locked — no done nodes |
| T-030 | `progress_screen_no_achievements` | AC-004, AC-013 | No achievements unlocked — all cards show locked state |
| T-031 | `leaderboard_player_not_ranked` | AC-005 | Player XP is 0 — "you" row still renders at bottom |
| T-032 | `game_timer_zero` | AC-007, AC-011 | Timer reaches 0 — timer pill shows 0 without crash |
| T-033 | `missing_track_icon_fallback` | AC-002 | PNG not found — `errorBuilder` renders fallback without crash |

---

## Smoke Set Summary

7 tests tagged `@smoke` — one per Must-priority AC:
- T-001: Tokens (AC-001)
- T-003: Tracks screen (AC-002)
- T-006: Path constellation (AC-003)
- T-008: Progress XP hero (AC-004)
- T-012: Leaderboard podium (AC-005)
- T-014: Settings profile (AC-006)
- T-016: Game chrome (AC-007)
