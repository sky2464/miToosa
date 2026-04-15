# GEMINI.md — miToosa Cognitive Puzzle Game

## 🧠 Project Overview
**miToosa** is a Flutter-based cognitive excellence puzzle game designed for sharpening pattern recognition, memory, and IQ. It features a "2026-native" aesthetic (Aetheric Pulse design system) with short, high-impact gameplay loops.

The project follows a **Domain-Driven Design (DDD)** architecture with a strict separation between core logic, data persistence, and the UI layer.

## 🛠 Tech Stack
- **Framework:** [Flutter](https://flutter.dev) (>= 3.5.0)
- **State Management:** [Riverpod](https://riverpod.dev) + [Riverpod Generator](https://pub.dev/packages/riverpod_generator)
- **Persistence:** [Hive](https://pub.dev/packages/hive) + [flutter_secure_storage](https://pub.dev/packages/flutter_secure_storage)
- **Navigation:** [Go Router](https://pub.dev/packages/go_router)
- **Audio:** [Audioplayers](https://pub.dev/packages/audioplayers)
- **Code Generation:** [build_runner](https://pub.dev/packages/build_runner)

## 🏗 Core Architecture
miToosa is organized into three primary layers:

1.  **Domain Layer (`lib/core/`):** Pure Dart logic. Platform-agnostic. Contains the game engine, puzzle generation, and models. **MUST NOT** depend on Flutter, Riverpod, or Hive.
2.  **Data Layer (`lib/data/`):** Handles persistence and repositories. Uses Hive for local storage and `flutter_secure_storage` for encryption keys.
3.  **UI Layer (`lib/features/`):** Flutter widgets and Riverpod ViewModels (StateNotifiers).

### Key Components
- **`GameplayEngine` (`lib/core/engine/gameplay_engine.dart`):** Manages puzzle states (Ready → Playing → Completed). Uses a functional/static approach for state transitions.
- **`ContentProvider` (`lib/core/content_provider.dart`):** Loads track definitions from JSON and procedurally builds levels using `PuzzleGenerator`.
- **`GameplayViewModel` (`lib/features/gameplay/gameplay_view_model.dart`):** A Riverpod family provider that manages the UI state for a specific gameplay level.

## 🚀 Building and Running

### Prerequisites
- Flutter SDK (>= 3.5.0)
- JDK 21
- Xcode (for iOS/macOS)

### Commands
- **Install dependencies:** `flutter pub get`
- **Code generation (MANDATORY):** `dart pub run build_runner build --delete-conflicting-outputs`
- **Run the app:** `flutter run`
- **Run tests:** `flutter test`
- **Static analysis:** `dart analyze`

## 📏 Development Conventions
- **Pure Dart in Core:** Keep `lib/core/` free of any Flutter or external framework dependencies.
- **Immutability:** Use immutable state classes (e.g., `GameplayState`) and update them using `copyWith`.
- **Functional Style Engine:** The `GameplayEngine` provides static methods that return a new state based on an existing one.
- **Dependency Inversion:** Use abstract interfaces for persistence (`IPersistenceProvider`) to allow for easy mocking in tests.
- **Linting:** Adheres to the rules in `analysis_options.yaml` (based on `flutter_lints`).

## 📁 Key Files and Directories
- `lib/core/engine/`: Core game logic and puzzle generation.
- `lib/core/models/`: Domain models (Puzzles, Levels).
- `lib/data/`: Hive adapters and persistence implementations.
- `lib/features/`: Feature-based UI modules (gameplay, auth, navigation).
- `lib/theme/`: Design system tokens and styles (Aetheric Pulse).
- `assets/content/`: JSON definitions for worlds and levels.
- `.claude/`: Detailed architectural documentation and design guides.

## ⚠️ Important Notes
- **Code Generation:** Many files (providers, Hive adapters) depend on `build_runner`. Always run the build command after modifying model or provider files.
- **Out-of-Sync Docs:** Some files in `.claude/` (e.g., `ARCHITECTURE.md`) may mention `Freezed` for `PlayerProgress` or class-based methods for `GameplayEngine`, while the current implementation uses standard classes and static methods. Refer to the actual code in `lib/` as the source of truth.
- **Assets:** Ensure Noto Sans fonts and audio files are present in the `assets/` directory for the UI to render correctly.
