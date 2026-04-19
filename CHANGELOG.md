# Changelog

All notable changes to miToosa will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.4.0] — 2025-07-25

### Added
- **Difficulty tiers** — easy, medium, hard, challenge modes with puzzle timers and XP multipliers
- **Session-based gameplay** — 5-puzzle sessions with cumulative XP tracking and session-complete overlay
- **Game over overlay** — shows puzzles solved and XP earned when hearts run out mid-session
- **XP progression gate** — tracks lock until player earns enough per-level XP (7 XP threshold)
- **Difficulty selection sheet** — bottom sheet for choosing difficulty tier before starting a level
- **Run timer overlay** — gradient progress bar with time-label during timed puzzle runs
- **Per-level tracking** — levelXP, levelBestTime, levelBestDifficulty stored per level
- **Daily XP tracking** — dailyXP counter resets each calendar day
- **XP chip** — real-time XP badge in gameplay header during sessions

### Changed
- **Hive schema v6** — added dailyXP, dailyXPDate, levelXP, levelBestTime, levelBestDifficulty fields with backward-compatible migration
- **Integrity hash** — HMAC payload now covers all v6 fields (dailyXP, dailyXPDate, levelXP, levelBestTime, levelBestDifficulty)
- **Hash payload refactored** — list-based assembly for auditability
- **gameplay_screen.dart simplified** — extracted GameOverOverlay, SessionCompleteOverlay, SessionStat, and ShapeRenderer into dedicated files (1298 → 960 lines)
- **_saveProgress race fix** — save now awaited before navigation transition

### Fixed
- `recordLevelDifficulty` now asserts on unknown tier names in debug mode

## [1.3.0] — 2025-07-24

### Added
- **Streak engine** — daily login streak tracking with freeze support and milestone rewards (7, 14, 30, 60, 90, 120, 180, 365 days)
- **Achievement system** — 9 achievements across 5 categories with progress tracking and coin rewards
- **Daily rewards** — 7-day reward cycle (10–100 coins) with claim validation
- **Streak calendar** — visual calendar showing play history, streak count, best streak, and freeze inventory
- **Settings screen** — toggles for haptic feedback, background music, and sound effects
- **Haptics integration** — tactile feedback on correct/wrong answers during gameplay
- **Music lifecycle** — background music pause/resume with app lifecycle and proper cleanup
- **Coin rewards** — earn coins on first-clear of levels via ProgressionEngine
- **Level expansion** — 17 tracks expanded from 10 to 15 levels each
- **Analytics events** — telemetry factories for level_complete, streak_update, achievement_unlocked, daily_reward_claimed
- **Navigation integration** — achievements, daily rewards, and streak calendar accessible from progress screen; streak card tap navigates to calendar from world map

### Changed
- **Hive schema v4** — added streakFreezeCount, streakMilestones, achievementProgress, dailyRewardDay, lastDailyRewardClaim, playHistory fields with backward-compatible defaults
- **Integrity hash** — HMAC payload now covers all v4 fields (unlockedAchievements, achievementProgress, lastDailyRewardClaim, playHistory)
- **Streak logic** — `recordLogin()` now delegates to StreakEngine for consistent freeze handling

### Fixed
- Coin exploit where `isFirstClear` was always true due to save-before-load ordering

## [1.2.0] — 2026-04-17

### Added
- **Onboarding flow** — 3-page guided introduction for new players
- **Progress tracking** — XP, hearts, diamonds, streaks, and levels completed
- **Track selection** — browse levels by category before playing
- **Bottom navigation** — quick access to Tracks, Progress, and Leaderboard tabs
- **Training mode** — easier levels 0–2 for new players
- **Meaningful hints** — tailored to each puzzle rule
- **Hint elimination** — grey out one wrong option per hint
- **Adaptive difficulty** — adjusts to player performance over recent levels
- **Engagement loop** — hearts, diamonds, streak bonuses, and share-to-refuel
- **Local telemetry** — privacy-safe on-device session start/end logging via Hive
- **Encrypted persistence** — AES-256 encrypted Hive box with HMAC integrity

### Fixed
- 5-star rating footer display
- XP display alignment in header
- Timer display in gameplay overlay
- Debug yellow artifact removed

### Changed
- Color palette updated with dopamine-driven aesthetics
- Level bounds validation prevents out-of-range access
- Categories added to `worlds.json` for track grouping

### Technical
- 264 unit and widget tests passing
- Dart analysis: zero errors
- Flutter 3.5.0+, Dart ≥3.5
- iOS 12.0+ · Android 5.0+ · Web (Chrome, Edge, Safari)

### Known Limitations
- Leaderboard is a placeholder (planned for v1.3)
- App Store share URL uses a placeholder until store approval
- Telemetry is local-only; cloud analytics deferred to v1.3

## [1.0.0] — 2026-03-01

### Added
- Initial release of miToosa IQ puzzle game
- Core gameplay engine with multiple puzzle rules
- World and level content system (JSON-driven)
- Basic player progress persistence
