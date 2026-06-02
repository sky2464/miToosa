# Workflow Configuration

<!-- Last updated: 2026-06-01 — BL-21 DX expansion (verify-pr.sh) -->

## TDD
tdd: true
# Red-Green-Refactor enforced in /agtoosa-build.
# For bugs: write a failing test first (Prove-It pattern), then fix.
# Engine tests use seeded RNG for determinism.

## Coverage
coverage_threshold: 80
# Minimum test coverage % required by /agtoosa-review QA Lead and /agtoosa-qa

## Branch Naming
branch_naming: "feat/ISSUE-ID-SHORT-DESC"
# e.g., feat/DEV-123-add-share-bonus

## Commit Strategy
commit_strategy: "conventional"
# Format: type(scope): description
# Types: feat, fix, chore, docs, test, refactor, perf
# Never mix formatting changes with behavior changes in one commit.

## Linting
linter: "dart analyze"
lint_config: "analysis_options.yaml"

## Verification Gates
verification_gates:
  - "bash scripts/verify-pr.sh   # local mirror of pr-validation.yml (preferred before PR)"
  - "dart format --output=none --set-exit-if-changed .  # included in verify-pr"
  - "dart analyze          # lint + type check"
  - "flutter test          # full test suite"
  - "flutter pub get       # dependency resolution"
  - "dart pub run build_runner build --delete-conflicting-outputs  # when lib/ or pubspec changed (verify-pr runs conditionally)"
# Run all gates before every commit or push.

## Code Generation
code_gen_command: "dart pub run build_runner build --delete-conflicting-outputs"
# Run after: adding/modifying Riverpod providers, adding Hive models

## Architecture Rules
architecture_rules:
  - "Pure Dart engines (lib/core/engine/) must have NO Flutter or Hive imports"
  - "All engine methods must be static and return immutable state via copyWith()"
  - "No code file may exceed 500 lines"
  - "New dependencies require explicit approval before adding to pubspec.yaml"
  - "Schema migrations require a migration test covering upgrade from previous schema version"

## Notes
# - Documentation sync pass required after /build, /test, /review, /code-simplify
# - Completed specs must be archived to docs/archived/ during /agtoosa-ship
# - Master-Plan.md must be updated after every phase transition
