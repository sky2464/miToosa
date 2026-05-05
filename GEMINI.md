# GEMINI.md — miToosa

This codebase uses the **AgToosa** framework. Before beginning any task, read `Docs/AgToosa_Agent.md` for core rules, principles, and security requirements.

## Project Overview

**miToosa** is a cross-platform Flutter cognitive puzzle game (iOS, Android, macOS, Web). It features an ADHD-optimized gameplay loop with pattern recognition, memory, and math puzzles across 8 tracks × 23 levels, built on a free-first model (25 free games/day + share bonus + streak ladder).

## AgToosa Commands

Use these 5 commands for every development cycle:

| Command | Workflow File | Purpose |
|---------|--------------|---------|
| `/agtoosa-spec` | `Docs/AgToosa_Spec.md` | Research, specify, and architect |
| `/agtoosa-build` | `Docs/AgToosa_Build.md` | Implement with TDD (Red-Green-Refactor) |
| `/agtoosa-qa` | `Docs/AgToosa_QA.md` | QA planning, execution, defect triage |
| `/agtoosa-review` | `Docs/AgToosa_Review.md` | Security, architecture, and cross-platform review |
| `/agtoosa-ship` | `Docs/AgToosa_Ship.md` | Pre-ship checklist, docs sync, retro |

Sub-commands: `research` · `plan` · `quick` (spec) · `scope` · `tdd` · `test` (build) · `security` · `arch` · `debug` · `cross` (review) · `check` · `docs` · `retro` (ship).

## Key References

- `Docs/Master-Plan.md` — source of truth for project state, Epics, sprint, backlog
- `Docs/Context/` — product.md, tech-stack.md, workflow.md, product-guidelines.md
- `Docs/AgToosa_Changelog.md` — project changelog
- `docs/PRODUCT-WEDGE.md` — canonical product economy (do not modify without user approval)

## Tech Stack

- **Language:** Dart 3.11+
- **Framework:** Flutter (iOS, Android, macOS, Web)
- **State Management:** Riverpod (StateNotifier + FutureProvider) with code generation
- **Persistence:** Hive (AES-256 encrypted, local-only) + flutter_secure_storage
- **Navigation:** go_router
- **Audio:** audioplayers
- **Code Generation:** build_runner + riverpod_generator

## Architecture

Three layers — never mix concerns:

1. `lib/core/engine/` — Pure Dart game engines. No Flutter or Hive imports. Static methods, immutable state.
2. `lib/features/` — Riverpod StateNotifiers connecting engines to UI.
3. `lib/data/` — Encrypted Hive persistence, telemetry, and models.

## Building and Running

```bash
flutter pub get                                               # Install dependencies
dart pub run build_runner build --delete-conflicting-outputs  # MANDATORY before first run
flutter run                                                   # Android (default)
flutter run -d iPhone                                         # iOS simulator
flutter run -d chrome                                         # Web
flutter run -d macos                                          # macOS desktop
dart analyze                                                  # Lint & static analysis
flutter test                                                  # Run all tests
```

## Development Rules

- TDD enforced — write failing tests before implementation (Red-Green-Refactor).
- Run `dart analyze && flutter test` before every commit.
- No code file may exceed 500 lines.
- New dependencies require explicit approval before adding to pubspec.yaml.
- `share_plus` is pinned at `^12.0.2` — do NOT upgrade to 13.0.0+ without checking flutter_secure_storage compatibility.

## Key Files

| File | Purpose |
|------|---------|
| `lib/core/engine/gameplay_engine.dart` | Main game state machine |
| `lib/core/engine/progression_engine.dart` | Adaptive difficulty |
| `lib/core/engine/streak_engine.dart` | Streak continuity |
| `lib/core/engine/achievement_engine.dart` | Achievement catalog |
| `lib/data/hive_persistence_provider.dart` | Encrypted storage |
| `lib/data/models/player_progress.dart` | Central player state (schema v6) |
| `lib/features/gameplay/gameplay_view_model.dart` | Round state management |
| `test/core/engine/gameplay_engine_test.dart` | Reference test (seeded RNG pattern) |
| `docs/PRODUCT-WEDGE.md` | Product economy (canonical) |
