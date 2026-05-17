# Test Plan — BL-01 + BL-02 (Platform Release Signing Scaffolding)

> **Spec:** [Docs/archived/spec-BL-01-BL-02-platform-signing.md](archived/spec-BL-01-BL-02-platform-signing.md)
> **Coverage target:** 80% (per `Docs/Context/workflow.md` → `coverage_threshold`)
> **Generated:** 2026-05-16 (Part 4 of `/agtoosa-spec`)

---

## Scope & Strategy

This work is primarily **configuration + documentation**, not Dart code. Test strategy reflects that:

- **Dart-level tests** (`flutter test`) cover guardrails: file existence, `.gitignore` rules, no-tracked-secrets invariants. These run in CI every PR.
- **Build-system verification** (Gradle / Xcode) is performed via manual commands documented in the runbook and asserted by the developer at Wave 4 (per AC-006). We do not run a real release build in CI for this spec — that requires real signing material, which is the human handoff itself.
- **Manual end-to-end** verification (sign + upload + install) is the gating check for closing BL-01 / BL-02 and is captured as test IDs T-007 / T-008 / T-009 with explicit acceptance checkpoints in the runbook.

---

## AC Coverage Matrix

| AC ID | EARS summary | Priority | Test IDs | Category | Negative / edge | Smoke |
|-------|--------------|----------|----------|----------|-----------------|-------|
| AC-001 | Release Android build signs with release keystore when `key.properties` valid | Must | T-001, T-007 | Build / Manual | T-002 (missing field) | T-007 `@smoke` |
| AC-002 | Build fails loud when `key.properties` missing or incomplete | Must | T-002 | Build | inherent (negative path) | T-002 `@smoke` |
| AC-003 | `.gitignore` excludes all signing-secret patterns | Must | T-003, T-004 | Unit (Dart) | T-004 (no tracked secrets) | T-003 `@smoke` |
| AC-004 | `key.properties.template` exists with placeholders + comments | Must | T-005 | Unit (Dart) | — | — |
| AC-005 | `Docs/RELEASE-SIGNING.md` published with full runbook | Must | T-006 | Unit (Dart) | — | — |
| AC-006 | `apksigner verify` passes on the produced AAB | Must | T-007 | Manual / Build | T-002 (no AAB if missing keys) | T-007 `@smoke` |
| AC-007 | `dart analyze` + `flutter test` clean after scaffolding | Must | T-009 | Verification | — | T-009 `@smoke` |
| AC-008 | iOS distribution team id honored via env var override | Should | T-008 | Manual | — | — |
| AC-009 | Keystore path is relocatable via `storeFile=...` | Should | T-001 (covered) | Build | — | — |
| AC-010 | Runbook documents SHA-256 fingerprint verification | Should | T-006 (covered) | Doc | — | — |

**Totals:** 9 test IDs · 7 Must ACs covered · 3 Should ACs covered · 4 smoke tests.

---

## Test Catalog

### T-001 — Release build with valid `key.properties` produces signed AAB
- **Category:** Manual / Build verification
- **AC:** AC-001, AC-009
- **Preconditions:** Wave 4 tasks 5.1 complete (developer has a real keystore + populated `android/key.properties`).
- **Steps:** Run `flutter build appbundle --release`. Locate `build/app/outputs/bundle/release/app-release.aab`.
- **Pass:** Build succeeds; `apksigner verify build/app/outputs/bundle/release/app-release.aab` exits 0.

### T-002 — Missing `key.properties` aborts release build with runbook pointer `@smoke`
- **Category:** Build verification (negative path)
- **AC:** AC-002
- **Preconditions:** `android/key.properties` absent OR `storeFile=` field blank.
- **Steps:** Run `flutter build appbundle --release`.
- **Pass:** Gradle exits non-zero; stderr contains the AC-002 error message naming `android/key.properties` and pointing at `Docs/RELEASE-SIGNING.md`. **Never** silently produces a debug-signed release artifact.

### T-003 — `.gitignore` contains required exclusions `@smoke`
- **Category:** Unit (Dart, `test/release/signing_config_test.dart`)
- **AC:** AC-003
- **Steps:** Read `.gitignore`; assert it contains each of: `*.keystore`, `*.jks`, `*.p12`, `*.mobileprovision`, `*.cer`, `android/key.properties`, `**/GoogleService-Info.plist`, `**/google-services.json`.
- **Pass:** All patterns present. (Fail message lists missing patterns.)

### T-004 — No signing secrets are tracked in git
- **Category:** Unit (Dart, `test/release/signing_config_test.dart`)
- **AC:** AC-003
- **Steps:** Shell out to `git ls-files`; assert the result contains zero files matching `*.keystore`, `*.jks`, `*.p12`, `*.mobileprovision`, `*.cer`. Allow `android/key.properties.template` (the placeholder); reject `android/key.properties` (the real file).
- **Pass:** Zero matches in the forbidden set.

### T-005 — `key.properties.template` exists with required fields
- **Category:** Unit (Dart, `test/release/signing_config_test.dart`)
- **AC:** AC-004
- **Steps:** Read `android/key.properties.template`; assert it defines (placeholder values OK) `storeFile=`, `storePassword=`, `keyAlias=`, `keyPassword=` and includes a comment block referencing `Docs/RELEASE-SIGNING.md`.
- **Pass:** All four keys present; comment block present.

### T-006 — `Docs/RELEASE-SIGNING.md` published with required sections
- **Category:** Unit (Dart, `test/release/signing_config_test.dart`)
- **AC:** AC-005, AC-010
- **Steps:** Read `Docs/RELEASE-SIGNING.md`; assert top-level headings include: `## iOS`, `## Android`, `## Verification`, `## Secret rotation`, `## Troubleshooting`; assert body contains the string `keytool -genkey` and the string `apksigner verify`.
- **Pass:** All headings + both verification commands present.

### T-007 — End-to-end Android: signed AAB uploads to Play Internal Test `@smoke`
- **Category:** Manual / E2E
- **AC:** AC-001, AC-006
- **Preconditions:** Wave 4 tasks 5.1 + 5.3 complete.
- **Steps:** Run `flutter build appbundle --release`; verify with `apksigner verify --print-certs`; upload to Play Console Internal Test track; install on a physical Android device via the Play Store internal-test link.
- **Pass:** App installs and launches on device.

### T-008 — End-to-end iOS: archived build uploads to TestFlight
- **Category:** Manual / E2E
- **AC:** AC-008
- **Preconditions:** Wave 4 tasks 3.2 + 5.2 complete.
- **Steps:** Open `ios/Runner.xcworkspace` in Xcode; Product → Archive; Distribute App → App Store Connect → Upload. Wait for TestFlight processing; install on a physical iOS device via TestFlight.
- **Pass:** Build appears in TestFlight; installs and launches on device.

### T-009 — Verification gates clean `@smoke`
- **Category:** Verification (CI-runnable)
- **AC:** AC-007
- **Steps:** Run `dart analyze` and `flutter test` after Wave 2 lands.
- **Pass:** Zero new errors, zero new warnings vs. baseline; full suite passes including the new `signing_config_test.dart`.

---

## Smoke Set

The smoke set runs in CI on every PR and gates the close of BL-01 / BL-02 Wave 3:

- **T-002** — fail-loud guard
- **T-003** — gitignore protection
- **T-007** — Android end-to-end (manual, gated to Wave 4)
- **T-009** — analyze + test clean

T-007 is `@smoke` because it is the single most load-bearing assertion — a signed AAB that actually installs on a Play-distributed device.
