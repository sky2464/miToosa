# Tech Stack

<!-- Last updated: 2026-06-01 — BL-21 DX expansion -->

## Language
language: "Dart 3.x"

## Frameworks
framework: "Flutter (iOS, Android, macOS, Web)"
state_management: "Riverpod (StateNotifier + FutureProvider)"
key_packages:
  - "flutter_riverpod — reactive state management"
  - "hive / hive_flutter — local AES-encrypted key-value storage"
  - "flutter_secure_storage — platform Keychain/Keystore for encryption key"
  - "share_plus: ^12.0.2 — native share sheet (PINNED: ^12, NOT 13.0.0+, due to flutter_secure_storage compat)"
  - "uuid — UUID v4 anonymous player ID"
  - "crypto / pointycastle — HMAC-SHA256 integrity checks on Hive records"

## Database
database: "Hive (AES-256 encrypted, local-only). Schema version 6 (PlayerProgress). Integrity: HMAC-SHA256 per record. Fail-secure: corrupted records deleted."
notes: "No remote database in v1. One-time migration from plaintext to encrypted boxes on app update. Analytics backend TBD after Sprint 1 playtest."

## Deployment
deployment: "iOS App Store · Google Play Store · Web (GCP Cloud Run optional) · macOS"
build_notes: |
  - Some flutter run invocations require --no-tree-shake-icons (see docs/BUILD.md)
  - MANDATORY before first run: dart pub run build_runner build --delete-conflicting-outputs
codebase_structure:
  - "lib/core/engine/ — Pure Dart game engines (no Flutter/Hive imports)"
  - "lib/features/ — Riverpod providers and view models"
  - "lib/data/ — Hive persistence and models"
  - "lib/widgets/ — Flutter UI components"
  - "test/core/engine/ — Reference: gameplay_engine_test.dart (seeded RNG pattern)"

## Test Framework
test_framework: "flutter test (Dart built-in test runner)"
tdd: true
test_patterns:
  - "Seeded RNG for deterministic engine tests (GameplayEngine, ProgressionEngine, etc.)"
  - "ProviderContainer for Riverpod provider isolation tests"
  - "Real Hive boxes in temp directory for integration tests (no mocking)"
  - "Reference test: test/core/engine/gameplay_engine_test.dart"
current_test_count: "887 passing (as of BL-23 ship, 2026-06-20)"

## Browser / Device Matrix
browser_matrix:
  - "iOS Safari (latest)"
  - "Android Chrome (latest)"
  - "macOS Safari / Chrome (latest)"
  - "Web: Chrome latest, Edge latest"

## Infrastructure-as-Code
iac_tool: "N/A — no cloud infrastructure in v1"

## CI/CD
ci_platform: "GitHub Actions"
workflows:
  - ".github/workflows/pr-validation.yml — PRs to main + workflow_dispatch; cached Flutter; dart format, dart analyze, flutter test; conditional build_runner, docs archival, prompt injection guard"
local_ci_mirror: "scripts/verify-pr.sh — same gates locally (diff vs origin/main by default)"
weekly_health: ".github/workflows/weekly-health.yml — Mondays 06:00 UTC, flutter test on main (workflow_dispatch supported)"
dependency_health_local: "scripts/dependency_health.sh — on-demand replacement for deleted dependency-maintenance.yml (see docs/OPERATIONS-dependency-maintenance.md)"

## Notes
<!-- Agent configs may say Docs/ — on-disk path is lowercase docs/ -->
<!-- CRITICAL: share_plus is PINNED at ^12.0.2 — do NOT upgrade to 13.0.0+ without checking flutter_secure_storage compatibility -->
<!-- Verification gates (run before every PR): bash scripts/verify-pr.sh -->
<!-- Code gen (run after adding Riverpod providers or Hive models): dart pub run build_runner build --delete-conflicting-outputs -->
<!-- Linter: dart analyze with analysis_options.yaml -->
