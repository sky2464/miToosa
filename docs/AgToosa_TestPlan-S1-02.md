# AgToosa Test Plan — S1-02 Analytics Backend Integration

Spec reference: `docs/AgToosa_Spec-S1-02.md`
Coverage target: 80% (from `docs/Context/workflow.md`)

## AC Coverage Table

| AC | Test ID | Category | Smoke | Scenario | Expected Result |
|----|---------|----------|-------|----------|-----------------|
| AC-001 | T-001 | Integration | @smoke | Run app/build with default `FIREBASE_ENABLED=false` | App boots and build succeeds with `NoOpAnalyticsSink`; no Firebase init crash |
| AC-002 | T-002 | Unit | @smoke | Analyze imports and package wiring after dependency add | `FirebaseAnalyticsSink` compiles; analyzer has zero errors |
| AC-003 | T-003 | Unit | @smoke | Emit a telemetry event through forwarding repository | Active sink receives `track()` call with event name and properties |
| AC-004 | T-004 | Security | @smoke | Enable `FIREBASE_ENABLED=true` with placeholder options file | Build fails with explicit `flutterfire configure` guidance |
| AC-005 | T-005 | Integration |  | Enable Firebase with real generated options | `Firebase.initializeApp()` completes and app reaches first frame |
| AC-006 | T-006 | Integration |  | Fire `session_start` in debug-enabled run | Event appears in Firebase Analytics DebugView within 60 seconds |
| AC-007 | T-007 | Integration | @smoke | Run baseline test suite after changes | Existing test suite passes with zero regressions |

## Negative/Edge Scenarios

- T-004: Guardrail for missing `flutterfire configure` output prevents silent misconfiguration.
- T-001: Default-flag path protects non-Firebase environments from runtime failures.
- T-006: Verify DebugView timing window and retry behavior when event batching delays visibility.

## Environment Requirements

- Flutter SDK and Dart toolchain
- Access to Firebase project for gated tests (AC-005, AC-006)
- FlutterFire CLI (`dart pub global activate flutterfire_cli`)
- Optional Android device/emulator for DebugView property command
