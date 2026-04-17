# Implementation Plan: Local Telemetry Collection v1

**Status:** Archived

**Implementation note:** This plan is archived after ship and kept only as historical execution context.

## Overview
Implement a minimal, privacy-safe telemetry foundation that records local session start/end events in Hive. This first release is internal-only: no network sync, no consent prompt, and no PII.

## Architecture Decisions
- Use a dedicated Hive box for telemetry so the data model stays separate from player progress.
- Keep telemetry write APIs behind a repository/service interface so app code never touches Hive directly.
- Limit v1 to session lifecycle events only to keep scope small and reduce privacy risk.
- Use a bounded retention policy so telemetry cannot grow without limit.

## Task List

### Phase 1: Telemetry model and storage
- [x] Task 1: Add a `TelemetryEvent` model and repository contract
  - Acceptance: telemetry events have name, timestamp, and typed properties; repository API exists for recording and reading events
  - Verify: unit tests for model serialization and contract behavior
  - Files: `lib/data/telemetry_event.dart`, `lib/data/telemetry_repository.dart`, `test/data/telemetry_event_test.dart`

- [x] Task 2: Implement Hive-backed telemetry persistence
  - Acceptance: events can be written, read back, and pruned to a bounded history
  - Verify: repository tests pass with a temporary Hive directory
  - Files: `lib/data/hive_telemetry_repository.dart`, `test/data/hive_telemetry_repository_test.dart`

### Phase 2: App lifecycle wiring
- [x] Task 3: Record session start/end from app lifecycle
  - Acceptance: the main app records a session start when the authenticated shell becomes active and a session end when the app backgrounds/exits
  - Verify: widget tests or provider tests cover the lifecycle hook behavior
  - Files: `lib/features/main_app/main_app_shell.dart`, `lib/main.dart`, related tests

### Phase 3: Verification and hardening
- [x] Task 4: Verify telemetry does not break app startup or existing flows
  - Acceptance: existing tests pass and telemetry remains optional if storage fails
  - Verify: `flutter test` and `dart analyze`
  - Files: any necessary integration test updates

## Checkpoints

### Checkpoint: After Task 2
- [x] Telemetry events persist locally and prune correctly
- [x] No app wiring yet; storage layer is green

### Checkpoint: Complete
- [x] Session lifecycle events are recorded locally
- [x] Existing gameplay and persistence tests still pass
- [x] Telemetry remains local-only and privacy-safe

## Risks and Mitigations
| Risk | Impact | Mitigation |
|------|--------|------------|
| Telemetry data grows without bound | Medium | Enforce retention cap and prune on write |
| App startup becomes fragile | High | Keep telemetry optional and fail-soft |
| Privacy scope expands accidentally | High | Limit v1 to session events only, no PII, no transport |

## Open Questions
- Whether the first version should include a hidden export/debug screen
- Whether session end should be emitted on pause, detach, or both