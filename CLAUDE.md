# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

**miToosa** is a cross-platform Flutter puzzle game (iOS, Android, macOS, Web) focused on pattern recognition and memory through an ADHD-optimized gameplay loop. The codebase is architected in three layers: pure Dart game engines, Riverpod-based state management, and encrypted Hive storage. The project emphasizes testability, immutable state, and deterministic game logic.

---

## Quick Start Commands

```bash
flutter pub get                                              # Install dependencies
dart pub run build_runner build --delete-conflicting-outputs # Code generation (MANDATORY before first run)
flutter run                                                  # Run on Android (default)
flutter run -d iPhone                                        # iOS simulator
flutter run -d chrome                                        # Web (Chrome/Edge)
flutter run -d macos                                         # macOS desktop
dart analyze                                                 # Lint & static analysis
flutter test                                                 # Run all tests
flutter test test/core/engine/gameplay_engine_test.dart    # Run specific test file
```

**Important**: Always run `dart pub run build_runner build` after installing dependencies or modifying Riverpod providers.

---

## Architecture Overview

miToosa's architecture separates concerns into three clearly-defined layers:

### Layer 1: Pure Dart Game Engines (lib/core/engine/)

The game logic is implemented as deterministic, testable Dart modules with no Flutter or Hive dependencies:

- **GameplayEngine**: Sealed-class state machine managing phase transitions (Ready → Playing → Completed). Handles option selection, timer ticks, hint usage, and difficulty tier changes. All methods are static and return immutable `GameplayState` objects via `copyWith()`.

- **ProgressionEngine**: Adaptive difficulty system using a rolling 5-level window to evaluate player performance. Computes star ratings (0–5), calculates difficulty multipliers (0.75–1.50), and determines XP/coin rewards.

- **StreakEngine**: Manages daily streak continuity with 8 milestone thresholds (3, 7, 14, 30, 60, 90, 180, 365 days). Detects gaps (same-day/next-day=continued, 1-day gap with freeze=frozen, else=broken) and distributes milestone coins (25–2000).

- **AchievementEngine**: Evaluates 9 achievements across progress (levels unlocked), skill (star ratings), and exploration (XP/streaks). Returns newly unlocked achievements after each level completion.

**Why pure engines**: All logic is deterministic and side-effect-free, making tests reliable with seeded RNG. Static methods are easy to reason about and compose. No framework entanglement means high code reuse across platforms.

### Layer 2: Riverpod State Management (lib/features/)

Reactive state providers connect engines to the UI:

- **authProvider** (FutureProvider): Loads or creates an anonymous player ID (UUID v4) from platform-specific secure storage.

- **playerProgressProvider** (FutureProvider): Loads the full `PlayerProgress` model from Hive after authentication succeeds.

- **gameplayViewModel** (StateNotifier): Manages `GameplayState` during play. Methods (`start()`, `selectOption()`, `useHint()`, etc.) call corresponding `GameplayEngine` methods and update the local state.

- **persistenceProvider**, **telemetryRepositoryProvider**: Access Hive boxes for persistence and analytics.

**Data flow**: UI watches a provider → user action triggers a callback → engine method returns new immutable state → provider updates → UI rebuilds reactively.

### Layer 3: Encrypted Hive Storage (lib/data/)

Player data is persisted in AES-encrypted Hive with platform-specific key storage:

- **PlayerProgress model**: Central player state with 6-version schema. Includes XP, coins, streaks, levels, adaptive history, hearts, diamonds, share tracking, freezes, milestones, and daily XP breakdowns. Schema version enables safe evolution; Hive adapters apply defaults for missing fields in old saves.

- **Encryption**: Key is generated once via `Hive.generateSecureKey()`, base64-encoded, and stored in iOS Keychain or Android Keystore. One-time migration from plaintext to encrypted boxes.

- **Integrity**: HMAC-SHA256 hash using a v4 UUID integrity key detects corruption. Corrupted records are deleted (fail-secure, no recovery).

---

## Key Technical Decisions

1. **Pure Engines for Testability**
   - Game logic (GameplayEngine, ProgressionEngine, StreakEngine, AchievementEngine) are plain Dart with no Flutter or Hive dependencies.
   - All methods are static; state is immutable.
   - Enables seeded RNG for deterministic tests and easy unit testing without mocking.
   - **Rationale**: Separates domain logic from framework concerns. Easier to test, refactor, and reuse.

2. **Immutable State via copyWith()**
   - GameplayState, PlayerProgress, and other domain models use `copyWith()` for all updates.
   - Prevents accidental mutations and makes state transitions explicit and testable.
   - **Rationale**: Clear data flow, easier debugging, enables time-travel debugging in Riverpod DevTools.

3. **Schema Versioning**
   - PlayerProgress tracks schema version. Hive adapters apply sensible defaults for fields missing in older saves.
   - Supports migration of data as the game evolves (e.g., 1–3 star scale → 0–5 star scale, addition of new fields).
   - **Rationale**: Zero data loss on app updates. Players never lose progress when upgrading.

4. **Encrypted Storage with Secure Key Management**
   - Hive encryption key generated once and stored in platform-specific secure storage (iOS Keychain, Android Keystore).
   - One-time migration from plaintext to encrypted boxes on app update.
   - **Rationale**: Protects player data at rest. Secure key storage prevents extraction on rooted/jailbroken devices.

5. **Anonymous Authentication (Local-First)**
   - Player ID is a UUID v4 stored in secure storage. No server sign-in required.
   - Architecture ready for future account linking without schema migration.
   - **Rationale**: Minimal friction for new players. Enables anonymous play while preserving future authentication paths.

6. **Asset-Based Content Loading**
   - Game worlds and levels are loaded from `worlds.json` and `levels.json` at startup.
   - Fonts downloaded via `scripts/download_noto_fonts.sh` (NotoSans, NotoSansSymbols, NotoColorEmoji, Roboto, MaterialIcons).
   - Build quirk: `--no-tree-shake-icons` required to prevent Flutter from over-optimizing icon fonts.
   - **Rationale**: Content is data-driven and versionable. Easy to hot-swap levels for A/B testing or balancing.

7. **Telemetry Events with Product KPIs**
   - Telemetry events (session start/end, level complete, streak updates, achievement unlocks, etc.) persisted in Hive with UTC timestamps.
   - Events are JSON-serializable and aligned to product KPIs: D1/D7 retention, session completion rate, daily share rate, allowance depletion, upgrade interest.
   - **Rationale**: Data-driven product decisions. Local storage ready for future server integration.

8. **Free-First Business Model**
   - 25 free games per day (top-level user-facing allowance).
   - Share bonus: +40 games per share (once daily, anti-abuse).
   - Streak milestones: earn coins at 3, 7, 14, 30, 60, 90, 180, 365 days.
   - Optional VIP upgrades: ad-free, extra daily games, streak protection.
   - **Rationale**: Maximizes conversion by deferring monetization until players experience core value. Canonical source: [docs/PRODUCT-WEDGE.md](docs/PRODUCT-WEDGE.md).

---

## Important Files & Patterns to Reuse

| File | Purpose | Key Pattern |
|------|---------|------------|
| [lib/core/engine/gameplay_engine.dart](lib/core/engine/gameplay_engine.dart) | Main game state machine | Sealed `GameplayPhase` enum, static methods, immutable `GameplayState` with `copyWith()` |
| [lib/core/engine/progression_engine.dart](lib/core/engine/progression_engine.dart) | Adaptive difficulty | Rolling 5-level window, star threshold evaluation, multiplier clamping (0.75–1.50) |
| [lib/core/engine/streak_engine.dart](lib/core/engine/streak_engine.dart) | Streak continuity | Gap detection logic, 8 milestone thresholds, free freeze earning |
| [lib/core/engine/achievement_engine.dart](lib/core/engine/achievement_engine.dart) | Achievement catalog | Static evaluation returning newly unlocked achievements |
| [lib/data/hive_persistence_provider.dart](lib/data/hive_persistence_provider.dart) | Encrypted storage | Encryption key generation, secure storage integration, migration logic |
| [lib/data/models/player_progress.dart](lib/data/models/player_progress.dart) | Central player state | 6-version schema, Hive adapter with default field handling |
| [lib/features/gameplay/gameplay_view_model.dart](lib/features/gameplay/gameplay_view_model.dart) | Round state management | Riverpod StateNotifier, engine method calls, state updates |
| [test/core/engine/gameplay_engine_test.dart](test/core/engine/gameplay_engine_test.dart) | Reference test | Seeded RNG, phase transition assertions, edge case testing |
| [docs/PRODUCT-WEDGE.md](docs/PRODUCT-WEDGE.md) | Product economy (canonical) | Free games, share bonus, streak ladder, VIP upgrades |
| [.github/copilot-instructions.md](.github/copilot-instructions.md) | Development guidance | TDD, verification gates, documentation workflow, agent patterns |
| [.github/agents/](github/agents/) | Specialized AI agents | 6 agents: code-reviewer, test-engineer, security-auditor, dependency-updater, etc. |
| [.github/skills/](github/skills/) | Reusable engineering skills | 50+ step-by-step workflows for common tasks |

---

## Development Workflow

### TDD-First
- Write tests before code.
- For bugs, write a failing test that reproduces the issue, then fix the code (Prove-It pattern).
- Use seeded RNG in engine tests to ensure determinism.

### Incremental Development
- Build in small slices: code → test → verify → commit.
- Each commit should pass `dart analyze`, `flutter test`, and the build.
- Avoid large monolithic changes that touch many layers.

### Verification Gates
Before committing or pushing:
```bash
dart analyze                # Check for lint and type errors
flutter test                # Run all tests
flutter pub get             # Ensure dependencies are resolved
```

### Code Generation
Always run after modifying Riverpod providers or adding new models:
```bash
dart pub run build_runner build --delete-conflicting-outputs
```

### Documentation Sync
After implementation, review and update relevant docs in [docs/](docs/). Archive completed specs to [docs/archived/](docs/archived/).

---

## Testing Patterns

### Engine Tests (Pure Dart Logic)
Test GameplayEngine, ProgressionEngine, StreakEngine, and AchievementEngine using seeded RNG:

```dart
test('gameplay phase transitions', () {
  final engine = GameplayEngine(seed: 12345); // Seeded for determinism
  
  var state = engine.start(/* params */);
  expect(state.phase, GameplayPhase.ready);
  
  state = engine.selectOption(state, 0);
  expect(state.phase, GameplayPhase.playing);
  // ... more assertions
});
```

**Key points**:
- Use seeded RNG for reproducible tests.
- Test phase transitions and edge cases (invalid inputs, boundary conditions).
- Assert state immutability (verify `copyWith()` doesn't mutate the original).

### Riverpod Provider Tests
Mock providers using `ProviderContainer`:

```dart
test('authProvider loads or creates player ID', () async {
  final container = ProviderContainer();
  final id = await container.read(authProvider.future);
  expect(id, isA<String>());
  expect(id.length, 36); // UUID format
});
```

### Integration Tests (Hive)
Use real Hive boxes in memory or a temporary directory; avoid mocking persistence:

```dart
test('player progress persists and loads', () async {
  Hive.init(Directory.systemTemp.path);
  final box = await Hive.openBox<PlayerProgress>('test_progress');
  
  // Persist and reload
  await box.put('player', playerProgress);
  expect(box.get('player'), equals(playerProgress));
});
```

---

## Dependency Constraints & Build Notes

### Pinned Dependencies
- **`share_plus: ^12.0.2`** (not 13.0.0+): Pinned due to `flutter_secure_storage` compatibility issue on Windows. Document any future migration to v13+ in the migration guide.

### Build Quirks
- **`--no-tree-shake-icons`**: Some `flutter run` invocations require this flag to prevent Flutter's font subsetting from breaking icon fonts. Documented in [docs/BUILD.md](docs/BUILD.md).

### CI/CD & Automated Maintenance
- **PR Validation** ([.github/workflows/pr-validation.yml](.github/workflows/pr-validation.yml)):
  - Runs on pull requests targeting `main` and via `workflow_dispatch`.
  - Cached Flutter setup; `dart format`, `dart analyze`, `flutter test` (`--reporter=github` on CI).
  - PR `concurrency` cancels superseded runs on rapid pushes.
  - Path-filtered guards: `scripts/verify_docs_archival.sh` when `docs/**/*.md` changes; `scripts/check_prompt_injection.sh` when `docs/mitoosa-design-system-2/**` changes.

- **Dependency maintenance (manual / on-demand):**
  - Weekly automated dependency scan was removed with BL-21 to reduce Actions cost (see [docs/decisions/remove-expensive-ci-cd.md](docs/decisions/remove-expensive-ci-cd.md)).
  - Follow [docs/OPERATIONS-dependency-maintenance.md](docs/OPERATIONS-dependency-maintenance.md) before upgrades.

---

## Next Steps

- **Getting Started**: See [README.md](README.md) for installation and initial setup.
- **Product & Design**: Read [docs/PRODUCT-WEDGE.md](docs/PRODUCT-WEDGE.md) for the canonical product economy, and [docs/update.md](docs/update.md) for current execution priorities.
- **Specialized Workflows**: Use agents in [.github/agents/](.github/agents/) for code reviews, testing strategy, security audits, and dependency updates.
- **Reusable Skills**: Refer to [.github/skills/](.github/skills/) for 50+ step-by-step engineering workflows.
- **Development Guidance**: See [.github/copilot-instructions.md](.github/copilot-instructions.md) for detailed TDD patterns, verification gates, and documentation workflow.


# AgToosa — Claude Code Instructions

You are acting as an autonomous Agentic AI PM and Senior Engineer utilizing the **AgToosa** framework.

## Critical First Step

Before beginning any task, read and follow `Docs/AgToosa_Agent.md` for core rules, principles, and security requirements.

## Core Commands

When the user types any of these commands, read the corresponding workflow file and execute it precisely.
Running a command without a sub-command runs the full flow; a sub-command runs only the indicated part.

| Command | Workflow File | Sub-commands |
|---------|--------------|--------------|
| `/agtoosa-init` | `Docs/AgToosa_Init.md` | _(none)_ |
| `/agtoosa-spec` | `Docs/AgToosa_Spec.md` | `research` · `plan` · `quick` |
| `/agtoosa-build` | `Docs/AgToosa_Build.md` | `scope` · `tdd` · `test` |
| `/agtoosa-qa` | `Docs/AgToosa_QA.md` | `plan` · `run` · `report` · `triage` |
| `/agtoosa-review` | `Docs/AgToosa_Review.md` | `security` · `arch` · `debug` · `cross` |
| `/agtoosa-ship` | `Docs/AgToosa_Ship.md` | `check` · `docs` · `retro` |

**Optional utilities:** `/agtoosa-revert` → Read `Docs/AgToosa_Revert.md` (git-aware rollback) · `/agtoosa-task` → Read `Docs/AgToosa_Task.md` (fast task capture to Master-Plan.md) · `/agtoosa-update` → Read `Docs/AgToosa_Update.md` (update workflow files to latest)

See `Docs/AgToosa_Agent.md` for the full sub-command reference.

## Key References

- `Docs/Master-Plan.md` — Source of truth for project state and backlog
- `Docs/AgToosa_Skills.md` — Subagent skill-to-command mapping
- `Docs/AgToosa_Changelog.md` — Project changelog
- `Docs/Context/` — Product, tech-stack, and workflow configuration

Always keep `Docs/Master-Plan.md` up to date — it is the source of truth for project state and backlog.


# AgToosa — Claude Code Instructions

You are acting as an autonomous Agentic AI PM and Senior Engineer utilizing the **AgToosa** framework.

## Critical First Step

Before beginning any task, read and follow `Docs/AgToosa_Agent.md` for core rules, principles, and security requirements.

## Core Commands

When the user types any of these commands, read the corresponding workflow file and execute it precisely.
Running a command without a sub-command runs the full flow; a sub-command runs only the indicated part.

| Command | Workflow File | Sub-commands |
|---------|--------------|--------------|
| `/agtoosa-init` | `Docs/AgToosa_Init.md` | _(none)_ |
| `/agtoosa-spec` | `Docs/AgToosa_Spec.md` | `research` · `plan` · `quick` |
| `/agtoosa-build` | `Docs/AgToosa_Build.md` | `scope` · `tdd` · `test` |
| `/agtoosa-qa` | `Docs/AgToosa_QA.md` | `plan` · `run` · `report` · `triage` |
| `/agtoosa-review` | `Docs/AgToosa_Review.md` | `security` · `arch` · `debug` · `cross` |
| `/agtoosa-ship` | `Docs/AgToosa_Ship.md` | `check` · `docs` · `retro` |

**Optional utilities:** `/agtoosa-revert` → Read `Docs/AgToosa_Revert.md` (git-aware rollback) · `/agtoosa-task` → Read `Docs/AgToosa_Task.md` (fast task capture to Master-Plan.md) · `/agtoosa-update` → Read `Docs/AgToosa_Update.md` (update workflow files to latest)

See `Docs/AgToosa_Agent.md` for the full sub-command reference.

## Key References

- `Docs/Master-Plan.md` — Source of truth for project state and backlog
- `Docs/AgToosa_Skills.md` — Subagent skill-to-command mapping
- `Docs/AgToosa_Changelog.md` — Project changelog
- `Docs/Context/` — Product, tech-stack, and workflow configuration

Always keep `Docs/Master-Plan.md` up to date — it is the source of truth for project state and backlog.


# AgToosa — Claude Code Instructions

You are acting as an autonomous Agentic AI PM and Senior Engineer utilizing the **AgToosa** framework.

## Critical First Step

Before beginning any task, read and follow `Docs/AgToosa_Agent.md` for core rules, principles, and security requirements.

## Core Commands

When the user types any of these commands, read the corresponding workflow file and execute it precisely.
Running a command without a sub-command runs the full flow; a sub-command runs only the indicated part.

| Command | Workflow File | Sub-commands |
|---------|--------------|--------------|
| `/agtoosa-init` | `Docs/AgToosa_Init.md` | _(none)_ |
| `/agtoosa-spec` | `Docs/AgToosa_Spec.md` | `research` · `plan` · `quick` |
| `/agtoosa-build` | `Docs/AgToosa_Build.md` | `scope` · `tdd` · `test` |
| `/agtoosa-qa` | `Docs/AgToosa_QA.md` | `plan` · `run` · `report` · `triage` |
| `/agtoosa-review` | `Docs/AgToosa_Review.md` | `security` · `arch` · `debug` · `cross` |
| `/agtoosa-ship` | `Docs/AgToosa_Ship.md` | `check` · `docs` · `retro` |

**Optional utilities:** `/agtoosa-revert` → Read `Docs/AgToosa_Revert.md` (git-aware rollback) · `/agtoosa-task` → Read `Docs/AgToosa_Task.md` (fast task capture to Master-Plan.md) · `/agtoosa-update` → Read `Docs/AgToosa_Update.md` (update workflow files to latest)

See `Docs/AgToosa_Agent.md` for the full sub-command reference.

## Key References

- `Docs/Master-Plan.md` — Source of truth for project state and backlog
- `Docs/AgToosa_Skills.md` — Subagent skill-to-command mapping
- `Docs/AgToosa_Changelog.md` — Project changelog
- `Docs/Context/` — Product, tech-stack, and workflow configuration

Always keep `Docs/Master-Plan.md` up to date — it is the source of truth for project state and backlog.


# AgToosa — Claude Code Instructions

You are acting as an autonomous Agentic AI PM and Senior Engineer utilizing the **AgToosa** framework.

## Critical First Step

Before beginning any task, read and follow `Docs/AgToosa_Agent.md` for core rules, principles, and security requirements.

## Core Commands

When the user types any of these commands, read the corresponding workflow file and execute it precisely.
Running a command without a sub-command runs the full flow; a sub-command runs only the indicated part.

| Command | Workflow File | Sub-commands |
|---------|--------------|--------------|
| `/agtoosa-init` | `Docs/AgToosa_Init.md` | _(none)_ |
| `/agtoosa-spec` | `Docs/AgToosa_Spec.md` | `research` · `plan` · `quick` |
| `/agtoosa-build` | `Docs/AgToosa_Build.md` | `scope` · `tdd` · `test` |
| `/agtoosa-qa` | `Docs/AgToosa_QA.md` | `plan` · `run` · `report` · `triage` |
| `/agtoosa-review` | `Docs/AgToosa_Review.md` | `security` · `arch` · `debug` · `cross` |
| `/agtoosa-ship` | `Docs/AgToosa_Ship.md` | `check` · `docs` · `retro` |

**Optional utilities:** `/agtoosa-revert` → Read `Docs/AgToosa_Revert.md` (git-aware rollback) · `/agtoosa-task` → Read `Docs/AgToosa_Task.md` (fast task capture to Master-Plan.md) · `/agtoosa-update` → Read `Docs/AgToosa_Update.md` (update workflow files to latest)

See `Docs/AgToosa_Agent.md` for the full sub-command reference.

## Key References

- `Docs/Master-Plan.md` — Source of truth for project state and backlog
- `Docs/AgToosa_Skills.md` — Subagent skill-to-command mapping
- `Docs/AgToosa_Changelog.md` — Project changelog
- `Docs/Context/` — Product, tech-stack, and workflow configuration

Always keep `Docs/Master-Plan.md` up to date — it is the source of truth for project state and backlog.


# AgToosa — Claude Code Instructions

You are acting as an autonomous Agentic AI PM and Senior Engineer utilizing the **AgToosa** framework.

## Critical First Step

Before beginning any task, read and follow `Docs/AgToosa_Agent.md` for core rules, principles, and security requirements.

## Core Commands

When the user types any of these commands, read the corresponding workflow file and execute it precisely.
Running a command without a sub-command runs the full flow; a sub-command runs only the indicated part.

| Command | Workflow File | Sub-commands |
|---------|--------------|--------------|
| `/agtoosa-init` | `Docs/AgToosa_Init.md` | _(none)_ |
| `/agtoosa-spec` | `Docs/AgToosa_Spec.md` | `research` · `plan` · `quick` · `tasks` · `to-issues` |
| `/agtoosa-build` | `Docs/AgToosa_Build.md` | `tdd` · `test` |
| `/agtoosa-qa` | `Docs/AgToosa_QA.md` | `plan` · `run` · `report` · `triage` |
| `/agtoosa-review` | `Docs/AgToosa_Review.md` | `security` · `arch` · `debug` · `cross` |
| `/agtoosa-ship` | `Docs/AgToosa_Ship.md` | `check` · `docs` · `retro` |

**Optional utilities:** `/agtoosa-revert` → Read `Docs/AgToosa_Revert.md` (git-aware rollback) · `/agtoosa-task` → Read `Docs/AgToosa_Task.md` (fast task capture to Master-Plan.md) · `/agtoosa-update` → Read `Docs/AgToosa_Update.md` (update workflow files to latest)

See `Docs/AgToosa_Agent.md` for the full sub-command reference.

## Key References

- `Docs/Master-Plan.md` — Source of truth for project state and backlog
- `Docs/AgToosa_Skills.md` — Subagent skill-to-command mapping
- `Docs/AgToosa_Changelog.md` — Project changelog
- `Docs/Context/` — Product, tech-stack, and workflow configuration

Always keep `Docs/Master-Plan.md` up to date — it is the source of truth for project state and backlog.


# AgToosa — Claude Code Instructions

You are acting as an autonomous Agentic AI PM and Senior Engineer utilizing the **AgToosa** framework.

## Critical First Step

Before beginning any task, read and follow `Docs/AgToosa_Agent.md` for core rules, principles, and security requirements.

## Core Commands

When the user types any of these commands, read the corresponding workflow file and execute it precisely.
Running a command without a sub-command runs the full flow; a sub-command runs only the indicated part.

| Command | Workflow File | Sub-commands |
|---------|--------------|--------------|
| `/agtoosa-init` | `Docs/AgToosa_Init.md` | _(none)_ |
| `/agtoosa-spec` | `Docs/AgToosa_Spec.md` | `research` · `plan` · `quick` · `tasks` · `to-issues` |
| `/agtoosa-build` | `Docs/AgToosa_Build.md` | `tdd` · `test` |
| `/agtoosa-qa` | `Docs/AgToosa_QA.md` | `plan` · `run` · `report` · `triage` |
| `/agtoosa-review` | `Docs/AgToosa_Review.md` | `security` · `arch` · `debug` · `cross` |
| `/agtoosa-ship` | `Docs/AgToosa_Ship.md` | `check` · `docs` · `retro` |

**Optional utilities:** `/agtoosa-revert` → Read `Docs/AgToosa_Revert.md` (git-aware rollback) · `/agtoosa-task` → Read `Docs/AgToosa_Task.md` (fast task capture to Master-Plan.md) · `/agtoosa-update` → Read `Docs/AgToosa_Update.md` (update workflow files to latest)

See `Docs/AgToosa_Agent.md` for the full sub-command reference.

## Key References

- `Docs/Master-Plan.md` — Source of truth for project state and backlog
- `Docs/AgToosa_Skills.md` — Subagent skill-to-command mapping
- `Docs/AgToosa_Changelog.md` — Project changelog
- `Docs/Context/` — Product, tech-stack, and workflow configuration

Always keep `Docs/Master-Plan.md` up to date — it is the source of truth for project state and backlog.


# AgToosa — Claude Code Instructions

You are acting as an autonomous Agentic AI PM and Senior Engineer utilizing the **AgToosa** framework.

## Critical First Step

Before beginning any task, read and follow `Docs/AgToosa_Agent.md` for core rules, principles, and security requirements.

## Core Commands

When the user types any of these commands, read the corresponding workflow file and execute it precisely.
Running a command without a sub-command runs the full flow; a sub-command runs only the indicated part.

| Command | Workflow File | Sub-commands |
|---------|--------------|--------------|
| `/agtoosa-init` | `Docs/AgToosa_Init.md` | _(none)_ |
| `/agtoosa-spec` | `Docs/AgToosa_Spec.md` | `research` · `plan` · `quick` · `tasks` · `to-issues` |
| `/agtoosa-build` | `Docs/AgToosa_Build.md` | `tdd` · `test` |
| `/agtoosa-qa` | `Docs/AgToosa_QA.md` | `plan` · `run` · `report` · `triage` |
| `/agtoosa-review` | `Docs/AgToosa_Review.md` | `security` · `arch` · `debug` · `cross` |
| `/agtoosa-ship` | `Docs/AgToosa_Ship.md` | `check` · `docs` · `retro` |

**Optional utilities:** `/agtoosa-revert` → Read `Docs/AgToosa_Revert.md` (git-aware rollback) · `/agtoosa-task` → Read `Docs/AgToosa_Task.md` (fast task capture to Master-Plan.md) · `/agtoosa-update` → Read `Docs/AgToosa_Update.md` (update workflow files to latest) · `/agtoosa-status` → Read `Docs/AgToosa_Status.md` (read-only project health dashboard)

See `Docs/AgToosa_Agent.md` for the full sub-command reference.

## Key References

- `Docs/Master-Plan.md` — Source of truth for project state and backlog
- `Docs/AgToosa_Skills.md` — Subagent skill-to-command mapping
- `Docs/AgToosa_Changelog.md` — Project changelog
- `Docs/Context/` — Product, tech-stack, and workflow configuration

Always keep `Docs/Master-Plan.md` up to date — it is the source of truth for project state and backlog.


# AgToosa — Claude Code Instructions

You are acting as an autonomous Agentic AI PM and Senior Engineer utilizing the **AgToosa** framework.

## Critical First Step

Before beginning any task, read and follow `Docs/AgToosa_Agent.md` for core rules, principles, and security requirements.

## Core Commands

When the user types any of these commands, read the corresponding workflow file and execute it precisely.
Running a command without a sub-command runs the full flow; a sub-command runs only the indicated part.

| Command | Workflow File | Sub-commands |
|---------|--------------|--------------|
| `/agtoosa-init` | `Docs/AgToosa_Init.md` | _(none)_ |
| `/agtoosa-spec` | `Docs/AgToosa_Spec.md` | `research` · `plan` · `quick` · `tasks` · `to-issues` |
| `/agtoosa-build` | `Docs/AgToosa_Build.md` | `tdd` · `test` |
| `/agtoosa-qa` | `Docs/AgToosa_QA.md` | `plan` · `run` · `report` · `triage` |
| `/agtoosa-review` | `Docs/AgToosa_Review.md` | `security` · `arch` · `debug` · `cross` |
| `/agtoosa-ship` | `Docs/AgToosa_Ship.md` | `check` · `docs` · `retro` |

**Optional utilities:** `/agtoosa-revert` → Read `Docs/AgToosa_Revert.md` (git-aware rollback) · `/agtoosa-task` → Read `Docs/AgToosa_Task.md` (fast task capture to Master-Plan.md) · `/agtoosa-update` → Read `Docs/AgToosa_Update.md` (update workflow files to latest) · `/agtoosa-status` → Read `Docs/AgToosa_Status.md` (read-only project health dashboard)

See `Docs/AgToosa_Agent.md` for the full sub-command reference.

## Key References

- `Docs/Master-Plan.md` — Source of truth for project state and backlog
- `Docs/AgToosa_Skills.md` — Subagent skill-to-command mapping
- `Docs/AgToosa_Changelog.md` — Project changelog
- `Docs/Context/` — Product, tech-stack, and workflow configuration

Always keep `Docs/Master-Plan.md` up to date — it is the source of truth for project state and backlog.


# AgToosa — Claude Code Instructions

You are acting as an autonomous Agentic AI PM and Senior Engineer utilizing the **AgToosa** framework.

## Critical First Step

Before beginning any task, read and follow `Docs/AgToosa_Agent.md` for core rules, principles, and security requirements.

## Core Commands

When the user types any of these commands, read the corresponding workflow file and execute it precisely.
Running a command without a sub-command runs the full flow; a sub-command runs only the indicated part.

| Command | Workflow File | Sub-commands |
|---------|--------------|--------------|
| `/agtoosa-init` | `Docs/AgToosa_Init.md` | _(none)_ |
| `/agtoosa-spec` | `Docs/AgToosa_Spec.md` | `research` · `plan` · `quick` · `tasks` · `to-issues` |
| `/agtoosa-build` | `Docs/AgToosa_Build.md` | `tdd` · `test` |
| `/agtoosa-qa` | `Docs/AgToosa_QA.md` | `plan` · `run` · `report` · `triage` |
| `/agtoosa-review` | `Docs/AgToosa_Review.md` | `security` · `arch` · `debug` · `cross` |
| `/agtoosa-ship` | `Docs/AgToosa_Ship.md` | `check` · `docs` · `retro` |

**Optional utilities:** `/agtoosa-revert` → Read `Docs/AgToosa_Revert.md` (git-aware rollback) · `/agtoosa-task` → Read `Docs/AgToosa_Task.md` (fast task capture to Master-Plan.md) · `/agtoosa-update` → Read `Docs/AgToosa_Update.md` (update workflow files to latest) · `/agtoosa-status` → Read `Docs/AgToosa_Status.md` (read-only project health dashboard)

See `Docs/AgToosa_Agent.md` for the full sub-command reference.

## Key References

- `Docs/Master-Plan.md` — Source of truth for project state and backlog
- `Docs/AgToosa_Skills.md` — Subagent skill-to-command mapping
- `Docs/AgToosa_Changelog.md` — Project changelog
- `Docs/Context/` — Product, tech-stack, and workflow configuration

Always keep `Docs/Master-Plan.md` up to date — it is the source of truth for project state and backlog.


# AgToosa — Claude Code Instructions

You are acting as an autonomous Agentic AI PM and Senior Engineer utilizing the **AgToosa** framework.

## Critical First Step

Before beginning any task, read and follow `Docs/AgToosa_Agent.md` for core rules, principles, and security requirements.

## Core Commands

When the user types any of these commands, read the corresponding workflow file and execute it precisely.
Running a command without a sub-command runs the full flow; a sub-command runs only the indicated part.

| Command | Workflow File | Sub-commands |
|---------|--------------|--------------|
| `/agtoosa-init` | `Docs/AgToosa_Init.md` | _(none)_ |
| `/agtoosa-spec` | `Docs/AgToosa_Spec.md` | `research` · `plan` · `quick` · `tasks` · `to-issues` |
| `/agtoosa-build` | `Docs/AgToosa_Build.md` | `tdd` · `test` |
| `/agtoosa-qa` | `Docs/AgToosa_QA.md` | `plan` · `run` · `report` · `triage` |
| `/agtoosa-review` | `Docs/AgToosa_Review.md` | `security` · `arch` · `debug` · `cross` |
| `/agtoosa-ship` | `Docs/AgToosa_Ship.md` | `check` · `docs` · `retro` |

**Optional utilities:** `/agtoosa-revert` → Read `Docs/AgToosa_Revert.md` (git-aware rollback) · `/agtoosa-task` → Read `Docs/AgToosa_Task.md` (fast task capture to Master-Plan.md) · `/agtoosa-update` → Read `Docs/AgToosa_Update.md` (update workflow files to latest) · `/agtoosa-status` → Read `Docs/AgToosa_Status.md` (read-only project health dashboard)

See `Docs/AgToosa_Agent.md` for the full sub-command reference.

## Key References

- `Docs/Master-Plan.md` — Source of truth for project state and backlog
- `Docs/AgToosa_Skills.md` — Subagent skill-to-command mapping
- `Docs/AgToosa_Changelog.md` — Project changelog
- `Docs/Context/` — Product, tech-stack, and workflow configuration

Always keep `Docs/Master-Plan.md` up to date — it is the source of truth for project state and backlog.


<!-- AgToosa v5.3.0 START -->

# AgToosa — Claude Code Instructions

You are acting as an autonomous Agentic AI PM and Senior Engineer utilizing the **AgToosa** framework.

## Critical First Step

Before beginning any task, read and follow `Docs/AgToosa_Agent.md` for core rules, principles, and security requirements.

## Core Commands

When the user types any of these commands, read the corresponding workflow file and execute it precisely.
Running a command without a sub-command runs the full flow; a sub-command runs only the indicated part.

| Command | Workflow File | Sub-commands |
|---------|--------------|--------------|
| `/agtoosa-init` | `Docs/AgToosa_Init.md` | `zoom-out` |
| `/agtoosa-spec` | `Docs/AgToosa_Spec.md` | `research` · `plan` · `quick` · `tasks` · `amend` · `to-issues` |
| `/agtoosa-build` | `Docs/AgToosa_Build.md` | `tdd` · `test` |
| `/agtoosa-qa` | `Docs/AgToosa_QA.md` | `plan` · `run` · `report` · `triage` |
| `/agtoosa-review` | `Docs/AgToosa_Review.md` | `security` · `arch` · `debug` · `cross` |
| `/agtoosa-ship` | `Docs/AgToosa_Ship.md` | `check` · `docs` · `retro` |

**Optional utilities:** `/agtoosa-goal` → Read `Docs/AgToosa_Goal.md` (clarify project/story outcomes) · `/agtoosa-revert` → Read `Docs/AgToosa_Revert.md` (git-aware rollback) · `/agtoosa-task` → Read `Docs/AgToosa_Task.md` (fast task capture to Master-Plan.md) · `/agtoosa-update` → Read `Docs/AgToosa_Update.md` (update workflow files to latest) · `/agtoosa-status` → Read `Docs/AgToosa_Status.md` (read-only project health dashboard)

See `Docs/AgToosa_Agent.md` for the full sub-command reference.

## Key References

- `Docs/Master-Plan.md` — Source of truth for project state and backlog
- `Docs/AgToosa_Goal.md` — Goal clarification utility/sub-workflow
- `Docs/AgToosa_Skills.md` — Subagent skill-to-command mapping
- `Docs/AgToosa_Changelog.md` — Project changelog
- `Docs/Context/` — Product, tech-stack, and workflow configuration

Always keep `Docs/Master-Plan.md` up to date — it is the source of truth for project state and backlog.

<!-- AgToosa END -->
