# Changelog

All notable changes to miToosa will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
