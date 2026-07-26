# Spec: BL-37 — Privacy-Respecting Crash Resilience

> **Story ID:** BL-37
> **Epic:** EP-02 Platform Release Infrastructure
> **Status:** ⬜ Backlog
> **Estimate:** M
> **Clarity:** ready
> **Spec created:** 2026-07-14

## 1. Requirements

### 1.1 Goal Contract

| Field | Value |
|-------|-------|
| Goal | Add Firebase Crashlytics with a testable global error boundary, nonfatal reporting path, and privacy-respecting collection control. |
| User outcome | Release crashes and sanctioned nonfatal failures are diagnosable without exposing player progress or collecting diagnostics after the player opts out. |
| Success condition | Firebase-enabled builds configure Crashlytics through one adapter; Flutter framework and asynchronous errors reach it; controlled nonfatal errors are reportable; diagnostics collection follows the BL-32 preference; policy/disclosure and test evidence are updated. |
| Proof / evidence | Reporter adapter tests, bootstrap error-handler tests, nonfatal smoke through a fake, Firebase configuration/build checks, dart analyze, flutter test, and manual Firebase Console receipt check. |
| Non-goals | Remote logging, custom user identifiers, network tracing, performance monitoring, automated test crashes in production UI, or changes to docs/PRODUCT-WEDGE.md. |
| Assumptions | BL-32 is implemented first and supplies the privacy preference/consent boundary; Firebase project configuration exists from BL-23. |
| Risks | Static global error handlers are hard to restore in tests; error details can contain sensitive state; a Crashlytics setup can be incomplete without platform configuration. |
| Unresolved questions | None. The user selected Firebase Crashlytics with privacy/disclosure coverage and a nonfatal smoke test. |

### 1.2 Brownfield Baseline

| Area | Current state | Intended delta |
|------|---------------|----------------|
| Error boundary | main.dart initializes Firebase but does not set FlutterError or PlatformDispatcher handlers. | Install handlers through a testable bootstrap boundary. |
| Reporting | No firebase_crashlytics dependency or nonfatal service exists. | Add dependency, configuration, adapter, and safe report API. |
| Privacy | Analytics has a future opt-out design in BL-32. | Diagnostics collection follows the same anonymous diagnostics preference; disclosures explain this extension. |
| Recovery | Startup errors can terminate without a user-facing recovery state. | Report sanitized failure and preserve existing recovery UI where feasible. |

### 1.3 User Stories

**As a** player, **I want** the game to recover or fail gracefully when something goes wrong **so that** a crash does not silently lose trust.

**As a** maintainer, **I want** actionable crash and nonfatal reports that respect the player's privacy choice **so that** release defects can be fixed responsibly.

### 1.4 Acceptance Criteria (EARS)

| ID | EARS | Priority |
|----|------|----------|
| AC-001 | WHEN a Firebase-enabled build bootstraps with diagnostics enabled THE SYSTEM SHALL initialize Firebase Crashlytics through one reporter adapter. | Must |
| AC-002 | WHEN Flutter framework or uncaught asynchronous errors occur THE SYSTEM SHALL report sanitized fatal errors through the reporter and preserve the platform handler contract. | Must |
| AC-003 | WHEN approved application code reports a nonfatal failure THE SYSTEM SHALL record a sanitized nonfatal error with a bounded context key set. | Must |
| AC-004 | WHEN the player disables anonymous diagnostics through the BL-32 privacy preference THE SYSTEM SHALL disable Crashlytics collection and SHALL not send new reports. | Must |
| AC-005 | WHEN Crashlytics is added THE SYSTEM SHALL update Firebase/platform configuration, privacy policy, Settings disclosure, and App Store data documentation consistently. | Must |
| AC-006 | WHEN the nonfatal smoke path runs in test or a controlled Firebase-enabled device build THE SYSTEM SHALL produce a report attempt without exposing a developer-only crash button in release UI. | Must |

### 1.5 Out of Scope

- Adding user IDs, emails, puzzle answers, raw Hive data, remote logs, traces, or performance monitoring.
- Reporting errors when the player has disabled anonymous diagnostics.
- Introducing a visible test-crash control in production Settings.
- Backend alerting/on-call workflows or a separate logging provider.

### 1.6 Failure Modes

| AC | Failure mode | Mitigation |
|----|--------------|------------|
| AC-001 | Firebase service exists but native Crashlytics config is omitted. | Follow official FlutterFire configuration and verify platform build/plugins. |
| AC-002 | Handler recurses or swallows platform behavior. | Preserve handler return contract; capture prior handler in tests where appropriate. |
| AC-003 | Error context includes player ID/progress or arbitrary exception payload. | Whitelist static error category/context keys and sanitize messages. |
| AC-004 | Opt-out disables analytics but leaves Crashlytics active. | One diagnostics preference mapping with unit tests for both services. |
| AC-006 | Smoke test requires a production UI control or sends a real crash. | Use injectable reporter fake in automated tests; device smoke calls a debug-only bounded nonfatal path. |

## 2. Design

### 2.1 Architecture Blueprint

Files to create:

- lib/core/crash_reporter.dart — interface, Firebase implementation, no-op implementation, and sanitization contract.
- lib/core/error_boundary.dart — bootstrap wiring for FlutterError, PlatformDispatcher, and optional zone handling.
- focused tests under test/core/.

Files to change:

- pubspec.yaml and platform Firebase configuration generated/verified through FlutterFire tools as required.
- lib/main.dart — initialize reporter after BL-32 diagnostics preference is available and install handlers before runApp.
- lib/data/privacy_preferences_repository.dart and Settings disclosure from BL-32 — extend wording/behavior to anonymous diagnostics.
- Docs/PRIVACY-POLICY.md, docs/APP-STORE-METADATA.md, and launch checks — describe Crashlytics truthfully.
- Docs/AgToosa_TestPlan-BL-37.md — test evidence.

The reporter is a core boundary. Feature/data code may report a named sanctioned nonfatal condition but never imports Firebase Crashlytics directly.

### 2.2 Data Flow

1. BL-32 bootstrap resolves anonymous diagnostics preference.
2. Firebase-enabled bootstrap creates FirebaseCrashReporter or NoopCrashReporter and sets collection enabled from that preference.
3. ErrorBoundary routes FlutterError and PlatformDispatcher errors through the reporter with fatal=true.
4. Approved code calls reportNonfatal with a static category and a sanitized Error/StackTrace.
5. The reporter strips/limits context and records through Crashlytics only when collection is enabled.
6. Docs and Settings describe anonymous diagnostics; an injected fake proves the smoke path in automated tests.

### 2.3 Threat Model (STRIDE)

| Threat | Category | Mitigation |
|--------|----------|------------|
| Exceptions carry private player data to Crashlytics. | Information Disclosure | Sanitize messages, forbid PlayerProgress/UUID/context dumps, whitelist static keys. |
| Opt-out is bypassed by a direct Firebase call. | Elevation of Privilege | One reporter boundary plus source scan and fake tests. |
| Error handler recurses and freezes startup. | Denial of Service | Guard reporting errors and preserve platform handler return semantics. |
| A nonfatal report is forged with arbitrary content. | Tampering | Restrict public API to typed/static categories and bounded context. |
| Console receipt cannot prove release configuration. | Repudiation | Device smoke records timestamp/category with no PII and manual Console evidence. |

### 2.4 External Reference

Firebase documents Flutter setup, FlutterError.onError, PlatformDispatcher.instance.onError, and test reporting in its [Crashlytics for Flutter guide](https://firebase.google.com/docs/crashlytics/flutter/get-started).

### 2.5 Build Scope

✅ Ready to proceed — Scope Boundary
Files in scope      : firebase_crashlytics dependency/configuration, crash reporter/error boundary, main.dart bootstrap, BL-32 privacy preference/disclosure integration, privacy/App Store docs, focused tests, Docs/AgToosa_TestPlan-BL-37.md, Docs/Master-Plan.md
Directories in scope: lib/core/, lib/data/, lib/features/settings/, ios/, android/, test/core/, Docs/
Out of scope        : custom identifiers, remote logging/tracing/performance, production test-crash UI, new backend, active-cycle enrollment

## 3. Tasks

### 3.1 Task Tree

- [ ] **1. Reporting contract tests:** Define RED privacy/error behavior before Firebase wiring.
  - [ ] 1.1 Add fake reporter tests for fatal, nonfatal, sanitization, and disabled collection. — _Requirements: AC-002, AC-003, AC-004_
  - [ ] 1.2 Add bootstrap handler and controlled nonfatal smoke tests. — _Requirements: AC-001, AC-002, AC-006_
- [ ] **2. Crash reporter boundary:** Add dependency/configuration and narrow interfaces.
  - [ ] 2.1 Add firebase_crashlytics and run/update FlutterFire platform configuration as needed. — _Requirements: AC-001, AC-005_
  - [ ] 2.2 Implement Firebase/Noop reporter and sanitization policy. — _Requirements: AC-001, AC-003, AC-004_
  - [ ] 2.3 Install framework/asynchronous error handlers through ErrorBoundary. — _Requirements: AC-002_
- [ ] **3. Privacy/documentation integration:** Reuse the approved opt-out boundary.
  - [ ] 3.1 Make diagnostics collection follow BL-32 preference and update Settings wording. — _Requirements: AC-004, AC-005_
  - [ ] 3.2 Update policy, App Store documentation, and launch checklist. — _Requirements: AC-005_
- [ ] **4. Verification:** Prove report attempts without production crash UI.
  - [ ] 4.1 Run focused tests, dart analyze, flutter test, and Firebase/iOS config checks. — _Requirements: AC-001 through AC-006_
  - [ ] 4.2 Run controlled nonfatal device smoke and verify Console receipt. — _Requirements: AC-006_ [manual]

### 3.2 Wave Plan

**Wave 1 (parallel):** 1.1, 1.2
**Wave 2 (sequential after Wave 1):** 2.1, 2.2
**Wave 3 (sequential after Wave 2):** 2.3, 3.1
**Wave 4 (sequential after Wave 3):** 3.2, 4.1, 4.2

### 3.3 Test Plan

Test plan: Docs/AgToosa_TestPlan-BL-37.md
AC coverage: 6 ACs mapped to 7 test IDs
Smoke set: T-001, T-002, T-003, T-004, T-006

### 3.4 Work Package DAG

| package_id | wave | depends_on | owned_files | inputs | outputs | merge_order | verification |
|------------|------|------------|-------------|--------|---------|-------------|--------------|
| PKG-1.1 | 1 | — | reporter/error tests | BL-32 privacy interface | RED privacy/report tests | 1 | focused flutter test |
| PKG-1.2 | 1 | — | bootstrap smoke tests | fake reporter | RED handler/smoke tests | 2 | focused flutter test |
| PKG-2.1 | 2 | PKG-1.1 | pubspec/platform Firebase config | official guide | plugin configuration | 3 | flutter pub get |
| PKG-2.2 | 2 | PKG-2.1 | reporter/error boundary | Firebase plugin | safe reporter implementation | 4 | focused flutter test |
| PKG-3.1 | 3 | PKG-2.2 | main.dart/privacy/Settings | reporter + consent | opt-out linkage | 5 | focused flutter test |
| PKG-4.1 | 4 | PKG-3.1 | docs/tests/test plan | integrated reports | GREEN evidence | 6 | dart analyze lib test && flutter test |

### 3.5 Story Skill Opportunity Synthesis

No new project skill is proposed. Crash reporting is a narrow platform integration covered by existing Firebase, privacy, and iphone-launch-gate processes.

### 3.6 Spec Quality Analyzer

| Check | Result |
|-------|--------|
| Crash collection follows the declared privacy boundary. | Pass |
| Error handlers and nonfatal path are testable without production crash UI. | Pass |
| PII/context minimization is explicit. | Pass |
| All Must ACs map to tests. | Pass |
