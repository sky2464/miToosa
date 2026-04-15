# Full Story — []

Status: Draft

This document is the authoritative "full story" for the mobile puzzle game currently implemented in this repository. The app name is left as a placeholder `[]` so this document can be reused for a product rename and a cross-platform port. This file explains the product, how it works, internal architecture, domain API, data model, puzzle generation, engineering & migration plan, security requirements, feature tasks, and a developer checklist with file references.

> Goals

- Capture the entire technical story and domain API so engineers can port or extend the product.
- Provide an actionable migration plan and developer task list for multi-stack ports (Flutter, .NET MAUI, Unity, React Native).
- Keep platform-specific details generalized; include mapping guidelines and example pseudocode.

---

## Overview

[] is a single-player, local-first puzzle game focused on small, fast mini-levels that exercise pattern recognition, counting, sequencing, and elementary reasoning. Players progress through themed "worlds" of levels, gain XP, earn stars, unlock rewards, and collect achievements. The current implementation uses a pure-domain approach (game logic separated from UI and persistence) making it straightforward to port the core engine to another stack.

### Core gameplay pillars

- Short mini-levels (one puzzle per mini-level) designed for quick completion and reinforcement.
- Deterministic domain engine with randomized puzzle generation via a `PuzzleGenerator` and level templates.
- Local persistence for player progress, achievements, and settings.

### Primary user flows

- World Map → Level Select → Mini-Level (Gameplay) → Level Complete → Progression

### Primary value props

- Educational and cognitive skill-building puzzles.
- Lightweight sessions for quick play and repeated practice.

---

## How It Works (Runtime Flow)

1. Startup loads the content catalog (WorldCatalog) and local player progress from the persistence layer.
2. Player selects a world and level; the app resolves a `LevelDefinition` and converts it to a runtime `GameplayLevel`.
3. `GameplayEngine` is created with the `GameplayLevel` and controls the round lifecycle (`start()`, `selectOption(id:)`, `restart()`).
4. UI layer (ViewModel + SwiftUI views in this codebase) binds to engine state and renders puzzle prompt, target shapes, and options.
5. Player selects an option; engine validates via `Puzzle.validateAnswer(optionId:)`, updates `score` and `feedback` and transitions phase.
6. On level completion, `ProgressionEngine` computes stars, XP, next level unlocks, and the app persists `PlayerProgress`.

Sequence summary (components to inspect)

- Gameplay engine: the domain layer that manages a single round/mini-level lifecycle, scoring, attempts, and feedback. Look for an `Engine` concept exposing `start()`, `selectOption(...)`, and `restart()` semantics.
- Puzzle generator: component(s) that build `Puzzle` objects from a `PuzzleRule` and `DifficultyParameters`. Should support deterministic RNG injection for tests.
- Progression engine: rules that compute stars/XP, decide unlocks, and produce completion summaries.
- Persistence layer: API that saves and restores `PlayerProgress`, content catalogs, and player settings.
- UI adapters: thin view/ViewModel or controller layers that bind to engine state and call domain APIs.

---

## Architecture

High-level components

- Core / Domain (language-agnostic): models, engines, puzzle generation, progression logic.
  - Files: [iToosa/Game/Models](iToosa/Game/Models), [iToosa/Game/Engine](iToosa/Game/Engine)
- Content: world/level definitions and assets. Currently implemented as a Swift catalog (`WorldCatalog`). Export to JSON for cross-platform reuse.
  - File: [iToosa/Game/Content/WorldCatalog.swift](iToosa/Game/Content/WorldCatalog.swift)
- Persistence: local storage and player models (SwiftData in iOS). Define an interface `IPersistenceProvider` when porting.
  - Files: [iToosa/Data/PersistenceProvider.swift](iToosa/Data/PersistenceProvider.swift), [iToosa/Data/PlayerProgress.swift](iToosa/Data/PlayerProgress.swift)
- UI: platform-specific views and viewmodels. Keep thin controllers/adapters calling into Domain APIs.
  - Files: [iToosa/Features](iToosa/Features)
- Services & Platform Adapters: analytics, remote sync (optional), purchases, notifications — keep them behind interfaces.

### Design principles

- Domain-first: keep game rules entirely in Core so that ports only need to reimplement UI & persistence.
- Content decoupling: export `WorldCatalog` to a content JSON file consumed by any platform.
- Interface-based platform services: define minimal service interfaces (persistence, telemetry) and implement per-platform.

### Concurrency and thread-safety

- The Swift code marks many structs as `Sendable`. When porting, ensure engine state updates are single-threaded or protected by the target runtime's concurrency primitives.

---

## Domain API Reference (canonical, language-agnostic)

This section describes the minimal, canonical domain API that any port should reproduce. The focus is on behavior, invariants, and data shapes rather than language or file locations. The pseudocode below is intentionally explicit so it can be ported to any language.

GameplayEngine (detailed pseudocode)

The `GameplayEngine` runs a single mini-level. It is deterministic, side-effect-free (no direct persistence or UI), and exposes a tiny API for the UI layer.

```pseudocode
class GameplayEngine {
 // constructor injects a GameplayLevel and an RNG for deterministic generation/testing
 constructor(level: GameplayLevel, rng: RNG = defaultRNG)

 // state
 property level: GameplayLevel
 property phase: enum { Ready, Playing, Completed } = Ready
 property score: int = 0
 property incorrectAttempts: int = 0
 property selectedOptionId: ID? = null
 property feedback: Feedback? = null

 // start playing the round
 method start(): void
  if phase == Playing: return
  phase = Playing
  selectedOptionId = null
  feedback = null

 // select an option (by ID). Updates score/phase/feedback deterministically
 method selectOption(optionId: ID): void
  if phase != Playing: return
  if not level.puzzle.hasOption(optionId):
   feedback = Feedback(Warning, "invalid option")
   return
  selectedOptionId = optionId
  if level.puzzle.validateAnswer(optionId):
   score = level.calculateScore(incorrectAttempts)
   feedback = Feedback(Success, level.successMessage)
   phase = Completed
  else:
   incorrectAttempts += 1
   feedback = Feedback(Hint, level.retryMessage)

 // reset engine to initial state
 method restart(): void
  phase = Ready
  score = 0
  incorrectAttempts = 0
  selectedOptionId = null
  feedback = null
}
```

Design notes:

- Keep `GameplayEngine` small and deterministic. Side-effects (persisting progress, analytics) should be handled by callers after the engine reports completion.
- `calculateScore` is a function on the `GameplayLevel` or a separate scoring policy to allow 3-star vs 5-star or fractional scoring schemes.

Puzzle (canonical)

```pseudocode
class Puzzle {
 property id: ID
 property prompt: string
 property rule: PuzzleRule
 property targetData: Any  // structured, rule-specific data (shapes, numbers, grid)
 property options: List<Option>
 property correctOptionId: ID

 method hasOption(id: ID): bool
 method validateAnswer(id: ID): bool
}
```

GameplayLevel (canonical)

```pseudocode
class GameplayLevel {
 property id: string
 property title: string
 property puzzle: Puzzle
 property hint: string?
 property successMessage: string?
 property retryMessage: string?
 property perfectScore: int
 property starThresholds: List<int>  // e.g., [80, 60, 40]

 method calculateScore(incorrectAttempts: int): int
  // example policy: perfectScore minus penalty per incorrect attempt
  return max(0, perfectScore - incorrectAttempts * penalty)
}
```

PuzzleGenerator (interface + example)

```pseudocode
interface PuzzleGenerator {
 method generate(rule: PuzzleRule, difficulty: DifficultyParameters, rng: RNG): Puzzle
}

// Example generator: matchIdentical
function generateMatchIdentical(difficulty, rng): Puzzle
 shapeCount = difficulty.shapeCount
 availableShapes = chooseShapes(difficulty.shapePalette, rng)
 target = rng.sample(availableShapes, shapeCount)
 correctOption = Option(id: rng.uuid(), data: target)
 wrongOptions = []
 for i in 1..(difficulty.choiceCount - 1):
  mutated = mutateOneElement(target, availableShapes, rng)
  wrongOptions.append(Option(id: rng.uuid(), data: mutated))
 options = rng.shuffle([correctOption] + wrongOptions)
 return Puzzle(id: rng.uuid(), prompt: "Pick the identical", rule: MatchIdentical, targetData: target, options: options, correctOptionId: correctOption.id)
```

Determinism for tests:

- Always pass an injectable `RNG` with a fixed seed when running unit tests so generators produce repeatable puzzles.

ProgressionEngine (canonical)

```pseudocode
class ProgressionEngine {
 method completeLevel(level: GameplayLevel, score: int): LevelResult
  stars = computeStars(score, level.starThresholds)
  xp = computeXP(score, level)
  unlocked = evaluateUnlocks(level.id, stars)
  return LevelResult(stars: stars, xp: xp, unlocked: unlocked)
}
```

Core enums and types: `GameplayPhase`, `FeedbackStyle`, `PuzzleRule`, `DifficultyParameters`, `Option`, `LevelResult` — implement as idiomatic enums/records in your target language.

---

## PuzzleGeneration — rules and algorithms

`PuzzleGenerator` implements a family of generators. When porting, keep the same rule names and the same semantics of `targetShapes`, `options`, and `correctOptionId`.

Rule list (as implemented)

- `matchIdentical`, `countShapes`, `findMissing`, `sequenceNext`, `rotationMatch`, `colorPattern`, `oddOneOut`, `ruleDiscovery`, `analogyComplete`, `arithmeticBalance`, `numberGrid`, `fractionVisual`, `numberSequence`, `algebraicThinking`, `trajectoryPredict`, `forceBalance`, `wavePattern`, `gravitySequence`, `momentumChain`, `pendulumSwing`.

Example: generateMatchIdentical (algorithm summary)

- Select `shapeCount` from difficulty.
- Build `targetShapes` as a list of `shapeCount` random shapes drawn from `availableShapes`.
- The correct option uses `targetShapes`. Wrong options are created by copying `targetShapes` and mutating one or more elements.
- Return a `Puzzle` where options are shuffled and `correctOptionId` is the correct option's id.

Pseudo-code (matchIdentical):

```pseudocode
func generateMatchIdentical(difficulty):
 shapeCount = difficulty.shapeCount
 availableShapes = selectShapes(difficulty.colorCount)
 targetShapes = randomList(availableShapes, shapeCount)
 correctOption = PuzzleOption(shapes: targetShapes)
 wrongOptions = []
 for i in 0..(difficulty.choiceCount-1):
  w = mutateOneElement(targetShapes, availableShapes)
  wrongOptions.append(PuzzleOption(shapes: w))
 return Puzzle(prompt: ..., rule: matchIdentical, targetShapes, options: shuffle([correct] + wrongOptions), correctOptionId: correctOption.id)
```

Determinism for tests

- To make generator deterministic for unit tests, instrument a seeded RNG interface in the port.

---

## Data Model & Persistence (canonical)

The player runtime model and persistence strategy should be simple, typed, and portable. Below is a canonical `PlayerProgress` shape, migration guidance, and export/import pseudocode that can be adapted to any stack.

Canonical `PlayerProgress` (pseudocode / schema)

```pseudocode
record PlayerProgress {
  playerId: string
  completedLevels: Map<levelId, { stars: int, score: int, completedAt: ISO8601 }>
  totalXP: int
  coins: int
  unlockedAchievements: List<string>
  activeThemeId: string?
  streakCount: int
  bestStreak: int
  totalPuzzlesSolved: int
  firstAttemptSuccessCount: int
  powerUpsUsed: int
  daysPlayed: List<ISO8601>
}
```

Notes & migration guidance

- Prefer typed collections (maps, lists) over JSON-encoded strings so consumers can query and migrate easily.
- Provide an import utility that accepts older exports (JSON strings, legacy blobs) and converts them into the canonical `PlayerProgress` record.

Migration pseudocode

```pseudocode
function importLegacyProgress(legacyExport: JSON): PlayerProgress
  progress = PlayerProgress()
  progress.playerId = legacyExport.playerId or generateNewId()
  // example: legacy `levelStars` -> completedLevels map
  for (levelId, stars) in legacyExport.levelStars:
    progress.completedLevels[levelId] = { stars: stars, score: legacyExport.scores[levelId] or 0, completedAt: legacyExport.completedAt[levelId] or now() }
  progress.totalXP = legacyExport.totalXP or 0
  progress.coins = legacyExport.coins or 0
  progress.unlockedAchievements = legacyExport.unlockedAchievements or []
  return progress
```

Canonical content exports (recommended JSON shapes)

- `worlds.json`: array of `WorldDefinition` with fields: `id`, `name`, `subtitle`, `iconName`, `levelIds`, `unlockRequirement`, `difficultyMultiplier`.
- `levels.json`: map of `levelId -> LevelDefinition` with fields: `id`, `worldId`, `index`, `puzzleRules[]`, `difficulty`, `starThresholds[]`, `hint`, `perfectScore`.

Example `PlayerProgress` JSON (generic)

```json
{
  "playerId": "user-1234",
  "completedLevels": {
    "w1-l0": { "stars": 3, "score": 120, "completedAt": "2026-03-28T12:34:56Z" }
  },
  "totalXP": 420,
  "coins": 30,
  "unlockedAchievements": ["first_win"],
  "streakCount": 5
}
```

Persistence adapter patterns by target stack

- Relational DB (SQLite): store `players`, `level_stars`, `achievements` tables; map `PlayerProgress` fields to typed columns.
- Document store / blob store (Hive/Realm/JSON): store typed records keyed by `playerId` and provide migration utilities.
- For Unity/low-volume clients: JSON files on disk with optional lightweight SQLite for queryable state.

Encryption & privacy

- Treat gameplay data as non-PII by default. If you include identifiers for cloud sync, use GUIDs and document retention and opt-outs.
- Use platform secure storage for any tokens/secrets; encrypt at rest if required by policy.

---

## UI Mapping (patterns and pseudocode)

Keep UI thin: views/rendering and animations should have no domain logic. Use a small ViewModel/Controller adapter that binds to the domain `GameplayEngine`.

Canonical ViewModel (pseudocode)

```pseudocode
class GameplayViewModel {
 property engine: GameplayEngine
 property uiState: UIState  // derived snapshot of engine state (phase, score, options, feedback)

 constructor(level, persistence, rng):
  engine = new GameplayEngine(level, rng)
  uiState = snapshot(engine)

 method start():
  engine.start()
  uiState = snapshot(engine)

 method selectOption(optionId):
  engine.selectOption(optionId)
  uiState = snapshot(engine)
  if engine.phase == Completed:
   result = ProgressionEngine.completeLevel(engine.level, engine.score)
   persistence.saveProgress(result)

 method restart():
  engine.restart()
  uiState = snapshot(engine)
}

function snapshot(engine: GameplayEngine): UIState
 return {
  phase: engine.phase,
  score: engine.score,
  options: engine.level.puzzle.options,
  feedback: engine.feedback
 }
```

Platform mapping guidance (general)

- Declarative UI frameworks (Flutter, SwiftUI, React): use a `View` that observes `GameplayViewModel.uiState` and renders options, prompt, and feedback.
- Imperative UI (Unity): create a thin controller that subscribes to `GameplayViewModel` events and updates UI elements.
- Bindings/Databinding frameworks (.NET MAUI, Xamarin): implement `INotifyPropertyChanged`-style notifications from the ViewModel and bind `phase`, `score`, and option lists to UI controls.

Responsibilities summary

- Views: rendering, animations, and accessibility labels only.
- ViewModels/Controllers: adapt domain state for the UI, call domain APIs, and delegate persistence/telemetry to platform services.

Accessibility & localization

- Expose accessibility labels and hints from the view layer. Keep localization keys and string catalog separate from the ViewModel.

---

## Migration Plan (step-by-step)

Objective: port Core domain to the chosen stack and deliver a minimal playable version that matches the current game experience.

Phase 0 — Preparation (0.5–1 day)

- Export `WorldCatalog` and `LevelDefinition` data to canonical JSON (`content/worlds.json`, `content/levels.json`).
- Export a sample `PlayerProgress` record for round-trip tests.

Phase 1 — Domain port & tests (2–4 days)

- Reimplement domain classes: `Puzzle`, `PuzzleOption`, `GameplayLevel`, `GameplayEngine`, `PuzzleGenerator`, `ProgressionEngine` in the chosen language.
- Port unit tests: at minimum `GameplayEngineTests`, `PuzzleTests`, and `ProgressionEngine` behaviors.
- Ensure test parity by seeding generator RNG in tests.

Phase 2 — Persistence adapter (1–2 days)

- Define `IPersistenceProvider` interface and implement local provider (SQLite/Hive/Realm) for `PlayerProgress`.
- Implement migration utility that can import the canonical JSON exported in Phase 0.

Phase 3 — UI scaffold & integration (3–6 days)

- Implement World Map, Level Select, Gameplay screen, Level Complete screens.
- Integrate ViewModels with domain and persistence.

Phase 4 — QA & CI (1–3 days)

- Add unit/test runner to CI. Add app smoke tests or widget tests.
- Performance profiling and memory checks on low-end devices.

Phase 5 — Polish & store readiness (2–4 days)

- Implement analytics, privacy opt-out, remote config (optional), and platform polishing.

Estimated total: 9–20 developer-days depending on team experience and chosen stack.

Stack selection guidance

- Choose Flutter for fastest cross-platform mobile parity with high UI fidelity.
- Choose Unity if you plan to add complex animations/physics or extend into multi-platform entertainment experiences.
- Choose .NET MAUI if you have strong C# expertise or plan to target desktop platforms alongside mobile.

---

## Engineering Tasks & Feature Breakdown (developer checklist)

Epic A — Prepare content & exports

- Task A1: Add a small export tool (e.g., `tools/export_worldcatalog`) that serializes the in-repo content catalog into `content/worlds.json` and `content/levels.json`. Acceptance: JSON matches canonical schema and imports into a minimal domain importer.

Epic B — Domain port

- Task B1: Implement `Core.Domain.GameplayEngine` in the target language and port unit tests that exercise its lifecycle (start/select/restart, scoring, edge cases).
- Task B2: Implement `Core.Domain.PuzzleGenerator` and unit tests for a representative set of rules (`matchIdentical`, `countShapes`, `findMissing`).

Epic C — Persistence

- Task C1: Implement `IPersistenceProvider` and local provider. Acceptance: Round-trip save/load of `PlayerProgress` sample JSON.

Epic D — UI skeleton and integration

- Task D1: Implement `WorldMap`, `LevelSelect`, `GameplayScreen`, `LevelComplete` with data binding.

Epic E — CI & test infra

- Task E1: Add unit test job to GitHub Actions, configure matrix for platform-specific needs.

Each task should include:

- Target files to create/update (e.g., `core/gameplay_engine.dart`, `lib/views/gameplay_screen.dart` for Flutter),
- Unit test files, and
- Acceptance criteria (behavior parity tests passing + UI smoke test).

---

## Security & Privacy

Local data

- `PlayerProgress` is gameplay-only; avoid storing PII. If storing user identifiers for cloud sync, store minimal hashed or GUID IDs and provide privacy documentation.
- Encrypt sensitive data (if any) using OS-provided secure storage (Keychain/Keystore) for secrets, and SQLite encryption or file-level encryption for persistent data if required by policy.

Networking (optional future)

- Use TLS 1.2+ with certificate validation. Prefer token-based auth; store tokens in secure storage.

Telemetry

- Collect non-PII telemetry only. Provide user opt-out and document events (names, payloads, retention).

Secrets

- Keep API keys and secrets out of repo. Use CI secrets to inject at build time.

Compliance

- If targeting children/education audiences, confirm COPPA / local regulations and implement parental consent flows as required.

---

## Testing Strategy

Unit tests

- Port the core engine unit tests to the target stack. Focus on `GameplayEngine` behavior tests, `Puzzle` validation tests, and `ProgressionEngine` calculations.

Integration tests

- Persistence round-trip tests, content import tests.

UI tests

- Smoke test for the main flow: open world map → select level → start mini-level → answer correctly → complete and persist `PlayerProgress`.

CI

- Add a GitHub Actions workflow with jobs:
  - `unit-tests` (runs language-native unit tests)
  - `build` (try a debug build / package generation)
  - `ui-smoke` (optional: run integration or widget tests)

Example iOS test command (template):

```bash
# Replace <workspace> and <scheme> with your project values
xcodebuild -workspace <workspace>.xcworkspace -scheme <scheme> -destination 'platform=iOS Simulator,name=iPhone 15' test
```

---

## Roadmap & Next Features (prioritized)

1. Content expansion: add new worlds and level templates.
2. Adaptive difficulty: tie `AdaptiveDifficultyEngine` parameters to player performance.
3. Daily challenges & scheduler (already present as an engine skeleton `DailyChallengeScheduler`).
4. Social & share features (optional, privacy-first).
5. Monetization hooks (consumable power-ups) behind feature flags.

---

## Developer Handoff (what I changed/added)

- Created this document: `Docs/full-story.md` (this file).
- Created a tracked TODO (project tasks) using the repository TODO list.

If you want, I can now:

- Export the `WorldCatalog` to canonical JSON and add it to `content/` (recommended next step).
- Start a port spike of `GameplayEngine` to Flutter or C# (pick a stack).

## Conductor Plans & Project Tracks

This repository uses the Conductor tracks workflow to manage medium-to-large work (see `conductor/plan_master.md`). Below is a concise summary of the current plan state and an explicit, actionable setup checklist so a new setup or a port spike can start with confidence.

**High-level status (source: `conductor/plan_master.md`)**

- Phase 2 tracks (game/world/puzzle expansion, persistence, and rewards) are complete and archived.
- Phase 3 (quality, assets, CI, onboarding) contains the next set of work (Tracks 10-15) — important items: `code_quality_refactor` and `ci_cd_pipeline`.
- Phase 4 lists UX & polish tasks (Tracks 16-22) that are ready to pick up in parallel groups once Phase 3 priorities are handled.

### Where to inspect history & examples

- Read the Plan Master: `conductor/plan_master.md`.
- Archived track examples (how tracks were structured and committed):

- Read the Plan Master: `conductor/plan_master.md`.
- Review archived tracks in `conductor/archive/`. For each archived track, open `spec.md`, `plan.md`, `metadata.json`, and `index.md` to learn the structure and accepted tasks.

How to reuse an archived track pattern (do XYZ):

1. Identify a completed track under `conductor/archive/` whose scope or structure is similar to your new work.
2. Copy the archived track folder as a starting template, or create a new directory under `conductor/tracks/` with a shortname and date suffix (e.g., `my-feature_20260328`).
3. Update `metadata.json` fields (`track_id`, `type`, `status`, `created_at`, `description`) to reflect the new track.
4. Edit `spec.md` to define the new feature/bug/chore (Overview, Functional Requirements, Acceptance Criteria, Out of Scope).
5. Edit `plan.md` to list phases and tasks using the project's workflow pattern (e.g., Preparation → Implement → Test → QA → Release). Include a Conductor verification meta-task at each phase end.
6. Register and run the track using the `newTrack` / `implement` flows (or follow the `commands/conductor/*` agents) so the track is tracked and executed consistently.

Best practices when duplicating templates:

- Keep `spec.md` concise and focused on acceptance criteria.
- Structure `plan.md` in small, testable tasks and prefer committing per task per the workflow.
- Preserve traceability by recording timestamps, initial `metadata.json` values, and the first commit SHA in the plan.
- Avoid copying historical audit/issue data into the new spec; use the archived plan as a template only.

If `conductor/archive/` is empty or unavailable, use the `newTrack` template (see `commands/conductor/newTrack.toml`) to scaffold `spec.md` and `plan.md`.

Actionable setup checklist (minimum steps to prepare a new environment or port)

- **1) Ensure Conductor environment is initialized**
  - Confirm `conductor/index.md`, `conductor/plan_master.md`, and `conductor/workflow.md` exist. If not, run the setup flow described by `commands/conductor/setup.toml` (or run the `Conductor` setup agent).

- **2) Run repository health tasks (pre-port)**
  - Run any repository health or project-file cleanup scripts (e.g., deduplicate IDE project entries) to ensure a clean build.
  - Add missing assets referenced by tracks: place audio files under your app's resource/audio folder and ensure locales are present in your localization catalog.

- **3) Add CI (Track 13)**
  - Add `.github/workflows/ci.yml` per `conductor/tracks/ci_cd_pipeline_20260329/plan.md`: macOS runner, select Xcode 26.3, build + test steps, and test-report publishing.

- **4) Prepare content exports for ports**
  - Ensure `content/worlds.json` and `content/levels.json` exist (these canonical exports are the recommended single source of level/content data for ports).
  - If not present, export `WorldCatalog` (tools/export_worldcatalog.swift) and add files to `content/`.

- **5) Create a new Conductor Track for the port spike**
  - Use the `newTrack` Conductor flow (see `commands/conductor/newTrack.toml`). Suggested description: "Port Core Domain → target-stack (port spike)".
  - Draft `spec.md` that states acceptance criteria (engine parity tests pass) and `plan.md` with these minimal phases:
    1. Domain port & tests (seeded RNG, parity unit tests)
    2. Persistence adapter + migration utility
    3. Minimal UI scaffold & integration test (World Map → Level Select → Gameplay)

- **6) Implement port using Conductor implement flow**
  - Use `commands/conductor/implement.toml` once the new track files are created. Implement tasks one-by-one, run tests, commit frequently per the workflow.

- **7) Synchronize docs & archive completed track**
  - When the track finishes, run the review flow and archive the completed track under `conductor/archive/` (see `commands/conductor/review.toml` for the review protocol and cleanup steps).

Quick suggested new-track skeleton (copy into the Conductor new-track dialog)

- Title: Port Core Domain — target-stack
- Type: feature
- Scope (spec highlights): Re-implement `GameplayEngine`, `Puzzle`, `GameplayLevel`, `PuzzleGenerator`, and `ProgressionEngine` in target-stack. Import `content/levels.json` as fixtures. Provide unit tests that exercise engine lifecycle, puzzle validation, and progression calculations.
- Minimal acceptance criteria: Engine unit tests pass, `content` imported successfully, and a smoke UI can start a level and complete it.

If you want, I can now:

- Run `conductor:setup` checks and generate the missing conductor docs if any are absent.
- Create the new Conductor Track scaffolding for a port spike (tell me which target stack).

---

## Appendix — Implementation pointers

Use these pointers to find the canonical places in this document that describe each implementation area. They are intentionally language-agnostic and reference the pseudocode and schemas above.

- Gameplay engine: See **Domain API Reference** → `GameplayEngine (detailed pseudocode)` for lifecycle, state, and scoring invariants.
- Puzzle generator: See **Domain API Reference** → `PuzzleGenerator (interface + example)` for generator contract, seeded RNG usage, and example `matchIdentical` algorithm.
- Gameplay level & puzzle models: See **Domain API Reference** → `GameplayLevel` and `Puzzle` for the canonical data shapes and `calculateScore` policy.
- Progression: See **Domain API Reference** → `ProgressionEngine` for how to compute stars, XP, and unlocking rules.
- Persistence & exports: See **Data Model & Persistence (canonical)** for `PlayerProgress` schema, migration pseudocode, and recommended `worlds.json` / `levels.json` shapes.
- UI adapters: See **UI Mapping (patterns and pseudocode)** for the `GameplayViewModel` example and responsibilities split between view, viewmodel, and domain.

If you want, I can now:

- Export the in-repo content catalog into `content/worlds.json` and `content/levels.json` using a small export tool.
- Scaffold a new, generic Conductor Track using the suggested skeleton for a port spike — tell me the target stack.
