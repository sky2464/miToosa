# miToosa Copilot instructions

Use these instructions for all Copilot work in this repository. Keep them concise, practical, and grounded in the actual Flutter/Dart workflow.

## Project and architecture

- `miToosa` is a Flutter/Dart cognitive puzzle game that targets iOS, Android, Web, and macOS.
- Core gameplay logic lives in `lib/core/engine`.
- Feature UI and state wiring live in `lib/features/gameplay`.
- Persistence and repositories live in `lib/data`.
- Design tokens and visual system code live in `lib/theme`.
- Tests live in `test/`, and helper scripts live in `scripts/`.

## Working location

- If you opened the project through `CoachToosa.code-workspace`, this repository is still the real codebase root.
- Keep repository customizations in this repo’s `.github/` folder, not in the `CoachToosa` wrapper folder.

## Implementation discipline

- Work in small, verifiable slices.
- Prefer spec → plan → build → test → review → ship.
- Use TDD when the change touches core logic or fixes a bug.
- For bugs, follow the prove-it pattern: create or identify a failing test first, then fix the bug.
- Do not mix unrelated cleanup with the requested change.
- Do not invent Node/npm workflows for this repo. This is a Flutter/Dart project.

## Validation commands

- Run `flutter pub get` after a fresh clone or whenever dependencies change.
- Run `dart run build_runner build --delete-conflicting-outputs` after changing Riverpod generator inputs, annotated models, or other generated-code inputs.
- Run `dart format lib test` after code changes.
- Run `dart analyze` before considering the change ready.
- Run `flutter test` for broad validation.
- Use `flutter test test/core/engine/gameplay_engine_test.dart` for fast gameplay-engine smoke coverage when the change is scoped there.

## Copilot workflow assets

- Repository-wide always-on guidance lives in this file.
- Reusable slash commands live in `.github/prompts/`.
- Domain skills live in `.github/skills/`.
- Specialized agents live in `.github/agents/`.

Prefer the prompt files for repeatable workflows:

- `/spec` — define scope and acceptance criteria before coding
- `/plan` — break work into small, testable slices
- `/build` — implement the next approved slice
- `/test` — design or run the right tests
- `/review` — perform a multi-axis review before merge
- `/code-simplify` — remove unnecessary complexity without changing behavior
- `/ship` — run the release checklist and prepare the final handoff

## Agents and skills

- Use `code-reviewer` for quality reviews.
- Use `test-engineer` for test design, failing-test reproduction, and coverage analysis.
- Use `security-auditor` for security-focused reviews.
- Reuse the existing skill files instead of rewriting their guidance inside every prompt.

## Documentation and hygiene

- Keep README and workflow docs aligned with the real commands that work.
- When you change developer workflow, update the corresponding prompt, instruction, or README section in the same change.
- Never commit secrets, generated junk, or local-only machine state.
