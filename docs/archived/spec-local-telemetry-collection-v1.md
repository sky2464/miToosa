# Spec: Local Telemetry Collection v1

**Status:** Archived

**Implementation note:** This spec is archived after ship and retained as historical context for the local telemetry foundation.

## Objective
Build a privacy-safe, on-device telemetry system for miToosa that records only app session start/end events in v1.

The goal is to preserve a lightweight usage trail for future product analysis without sending any telemetry off-device, collecting personal data, or introducing a consent prompt. This feature is a future-release foundation, not a user-facing analytics dashboard.

## Tech Stack
- Flutter 3.x / Dart 3.x
- Riverpod for app wiring
- Hive for local persistence
- Existing anonymous player identity remains unchanged, but telemetry must not depend on it for v1
- No new dependencies required for v1

## Commands
- Fetch dependencies: `flutter pub get`
- Run tests: `flutter test`
- Run analysis: `dart analyze`
- Build app: `flutter build apk` / `flutter build ios` / `flutter build web`

## Project Structure
- `lib/data/` — telemetry repository and persistence integration
- `lib/features/` — lifecycle hooks that emit session events
- `lib/main.dart` — app bootstrap and top-level wiring
- `test/` — unit and widget tests for telemetry behavior
- `docs/` — spec, plan, and future telemetry notes

## Code Style
Keep telemetry small and explicit.

```dart
class TelemetryEvent {
  final String name;
  final DateTime timestamp;
  final Map<String, Object?> properties;

  const TelemetryEvent({
    required this.name,
    required this.timestamp,
    this.properties = const {},
  });
}
```

Conventions:
- Event names are lowercase snake_case or dot-separated domain names
- Payloads are typed and bounded
- No freeform text from users
- No PII, no network transmission, no hidden background sync

## Testing Strategy
- Unit tests for event creation, serialization, pruning, and repository behavior
- Widget/integration tests for session start and session end wiring
- Tests must verify telemetry failures do not crash the app

## Boundaries
- Always: validate event shape, cap event history, keep payloads small, write tests first
- Ask first: exporting telemetry off-device, adding consent flows, collecting new categories of sensitive data
- Never: collect PII, log secrets, send telemetry to a server in v1, couple telemetry to gameplay logic

## Success Criteria
- The app records a local session start event when the main app becomes active
- The app records a local session end event when the app leaves the foreground or exits
- Telemetry persists across app restarts using Hive
- Stored telemetry remains bounded and prunable
- No telemetry is transmitted off-device
- Existing gameplay and persistence behavior remains unchanged if telemetry is unavailable

## Open Questions
- Should v1 expose a hidden debug export screen, or keep telemetry internal only?
- Should session boundaries be defined by foreground/background transitions, app exit, or both?
- If additional event types are needed later, they should be added in a follow-up phase.