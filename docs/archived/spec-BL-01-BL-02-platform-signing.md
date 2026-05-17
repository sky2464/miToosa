# Spec: BL-01 + BL-02 — Platform Release Signing Scaffolding (iOS + Android)

> **Story ID:** BL-01 + BL-02 (combined)
> **Epic:** EP-02 — Platform Release Infrastructure
> **Status:** 🟦 Todo
> **Estimate:** M
> **Spec created:** 2026-05-16

---

## Context

EP-02 ("Platform Release Infrastructure") gates the ability to ship signed release builds to the App Store and Play Store. Today:

- **iOS** (`ios/Runner.xcodeproj/project.pbxproj`): Automatic signing is enabled with `DEVELOPMENT_TEAM = TYK6BBNDW5`, `CODE_SIGN_STYLE = Automatic`, bundle id `com.chicademy.mitoosa`. There is no `PROVISIONING_PROFILE_SPECIFIER` and no Distribution profile configured for App Store release builds.
- **Android** (`android/app/build.gradle.kts` line 36): `release.signingConfig = signingConfigs.getByName("debug")` — explicitly flagged in code as "Signing with the debug keys for now; replace with release keystore before publishing." A release-grade `signingConfig` block does not exist, no `key.properties` is consumed, and `*.keystore` is not gitignored.
- **`.gitignore`** is missing `*.keystore`, `*.jks`, `key.properties`, `*.mobileprovision`, `*.p12`, `GoogleService-Info.plist`, and `*.cer` — meaning a developer could accidentally commit secrets today.

The blocker pattern is that the **human-action parts cannot be automated** (Apple Developer account login, Distribution certificate / Provisioning Profile generation in App Store Connect, `keytool` keystore generation, Play Console upload-key registration). What the agent **can** do is the **code scaffolding**: parameterize signingConfig in Gradle to consume `key.properties` via env vars, harden iOS pbxproj signing settings for App Store distribution where possible without a cert in hand, add gitignore rules, ship a `key.properties.template`, and publish a runbook documenting every human step the developer must perform.

### Inline answers to the 6 forcing questions

| # | Question | Inline finding |
|---|----------|----------------|
| Q1 | Status quo | iOS: dev signing works (team TYK6BBNDW5). Android: release builds use debug keystore — **not uploadable to Play Store**. Nothing breaks for local dev. |
| Q2 | Narrowest scope | Wire signingConfig + key.properties consumption in Gradle, harden .gitignore, ship runbook. iOS pbxproj keeps Automatic for now; manual signing is a follow-up once a Distribution cert exists. |
| Q3 | Urgency signal | Owner is blocked from any TestFlight / Play Internal Test today. Workaround: build unsigned APKs for sideload only — not viable past Sprint 2. |
| Q4 | 10-star | Fastlane match for iOS, GitHub-Actions-managed signing secrets, automated TestFlight upload, dual-key (upload + app-signing) Play App Signing. Deferred to a later spec — see "Out of Scope". |
| Q5 | Failure modes | (a) Keystore committed to git → Play upload key irrecoverable. (b) `key.properties` committed → signing password leaked. (c) Apple cert expires unnoticed → release builds break. |
| Q6 | Security surface | **YES — high**. Touches code-signing identity, secret material (keystore + passwords), platform secure-distribution channels. STRIDE focus: Tampering, Repudiation, Information Disclosure. |

---

## 1. Requirements

### 1.1 User Stories

**As a** developer preparing miToosa for App Store / Play Store release, **I want** Gradle and Xcode signing configuration parameterized via environment-supplied secrets (never hardcoded), **so that** I can produce signed release artifacts without committing keystore material to git.

**As a** project owner who will perform the human-only steps (Apple Distribution cert, App Store Connect onboarding, keytool keystore generation, Play Console upload-key registration), **I want** a step-by-step runbook with exact commands and verification checks, **so that** I can complete the manual handoff in one focused session without external research.

**As a** future contributor cloning the repo, **I want** a `key.properties.template` and clear `.gitignore` rules, **so that** I cannot accidentally commit signing secrets and the build fails loudly when secrets are missing rather than silently using debug keys.

### 1.2 Acceptance Criteria (EARS)

| ID | EARS | Priority |
|----|------|----------|
| AC-001 | WHEN a release Android build is invoked AND `android/key.properties` exists with valid `storeFile`, `storePassword`, `keyAlias`, `keyPassword` THE SYSTEM SHALL sign the APK/AAB with the release keystore (not the debug keystore). | Must |
| AC-002 | WHEN a release Android build is invoked AND `android/key.properties` is missing or any required field is blank THE SYSTEM SHALL fail the build with a clear error message naming the missing field (fail-loud, never silently fall back to debug keys for release). | Must |
| AC-003 | WHEN any contributor stages a file matching `*.keystore`, `*.jks`, `*.p12`, `*.mobileprovision`, `*.cer`, or `android/key.properties` THE SYSTEM SHALL exclude it via `.gitignore` so it never enters version control. | Must |
| AC-004 | THE SYSTEM SHALL provide `android/key.properties.template` with placeholder values and inline comments documenting every required field. | Must |
| AC-005 | THE SYSTEM SHALL publish `Docs/RELEASE-SIGNING.md` containing the full manual runbook for Apple Distribution cert, App Store Connect app record, keytool keystore generation, Play Console upload-key registration, and verification steps. | Must |
| AC-006 | WHEN `flutter build appbundle --release` is invoked with valid signing config THE SYSTEM SHALL produce a signed `.aab` whose APK Signature Scheme v2/v3 signature verifies via `apksigner verify`. | Must |
| AC-007 | WHEN `dart analyze` and `flutter test` run after the scaffolding lands THE SYSTEM SHALL report zero new errors and zero new warnings introduced by the changes. | Must |
| AC-008 | IF an `IOS_DISTRIBUTION_TEAM_ID` env var is set during an Xcode archive THEN WHEN the archive runs THE SYSTEM SHALL use that team id for distribution signing; otherwise fall back to the current development team `TYK6BBNDW5`. | Should |
| AC-009 | WHILE the keystore file path is parameterized via `storeFile=…/upload-keystore.jks` in `key.properties` WHEN a developer relocates the keystore THE SYSTEM SHALL pick up the new path without code changes. | Should |
| AC-010 | IF the developer follows the runbook end-to-end THEN WHEN they reach the verification step THE SYSTEM SHALL describe how to confirm the upload-key SHA-256 fingerprint matches the value registered in Play Console. | Should |

> **Q5 ↔ Must AC mapping:** Failure mode (a) keystore-in-git ↔ AC-003. (b) silent debug-key fallback ↔ AC-002. (c) cert expiry / missing secrets ↔ AC-002 (loud failure) + AC-005 (runbook covers cert renewal cadence).

### 1.3 Out of Scope

- Fastlane integration (iOS `match` or Android `supply`) — deferred to a future spec under EP-02.
- GitHub Actions CI signing (storing keystore secrets in `secrets.*`, triggering TestFlight/Play uploads from CI) — deferred.
- iOS manual signing (PROVISIONING_PROFILE_SPECIFIER hardcoded for Distribution) — kept on Automatic until a Distribution cert exists; runbook covers the manual UI flow in Xcode.
- App Store Connect / Play Console **account onboarding** itself — runbook documents the steps but execution requires the human and their credentials.
- Renewal automation (cert/profile expiry monitoring) — runbook notes the cadence; automation deferred.
- macOS / Web release signing — out of scope; iOS + Android only.

---

## 2. Design

### 2.1 Architecture Blueprint

**Files to create:**

```
android/key.properties.template          — placeholder properties consumed by Gradle (committed)
Docs/RELEASE-SIGNING.md                  — developer runbook (committed)
test/release/signing_config_test.dart    — Dart-level guard: verifies key.properties.template exists, .gitignore rules present, no real *.keystore tracked
```

**Files to change:**

```
android/app/build.gradle.kts             — load key.properties → real release signingConfig + fail-loud guard
.gitignore                               — add *.keystore, *.jks, *.p12, *.mobileprovision, *.cer, android/key.properties, GoogleService-Info.plist, ios/Runner/GoogleService-Info.plist
ios/Runner.xcodeproj/project.pbxproj     — (light touch) keep CODE_SIGN_STYLE=Automatic for Debug; add a comment-anchored Release section that consumes ${IOS_DISTRIBUTION_TEAM_ID:-TYK6BBNDW5}. If pbxproj parameterization risks corruption, defer to runbook instructions only — decided during 2.1 task.
```

**Files NOT touched (out of scope):**

```
lib/, test/ (other than the new signing_config_test.dart),
ios/Runner/, ios/Flutter/,
android/app/src/ (manifest/code),
pubspec.yaml, analysis_options.yaml
```

**Key Gradle interface** (`android/app/build.gradle.kts`):

```kotlin
val keystoreProperties = Properties().apply {
    val f = rootProject.file("key.properties")  // android/key.properties
    if (f.exists()) load(f.inputStream())
}

android {
    signingConfigs {
        create("release") {
            storeFile = keystoreProperties.getProperty("storeFile")?.let { file(it) }
            storePassword = keystoreProperties.getProperty("storePassword")
            keyAlias = keystoreProperties.getProperty("keyAlias")
            keyPassword = keystoreProperties.getProperty("keyPassword")
        }
    }
    buildTypes {
        release {
            val cfg = signingConfigs.getByName("release")
            if (cfg.storeFile == null) {
                // Fail-loud per AC-002 — refuse silent debug-key fallback for release builds.
                throw GradleException("Release build requires android/key.properties — see Docs/RELEASE-SIGNING.md")
            }
            signingConfig = cfg
        }
    }
}
```

### 2.2 Data Flow

1. Developer follows `Docs/RELEASE-SIGNING.md` and runs `keytool -genkey -v -keystore ~/.mitoosa/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload`.
2. Developer copies `android/key.properties.template` → `android/key.properties`, fills in `storeFile`, `storePassword`, `keyAlias`, `keyPassword`. `.gitignore` ensures the populated file is untracked.
3. Developer runs `flutter build appbundle --release`. Gradle's `release` build type loads `key.properties`; if any required field is missing, the build fails with the message from AC-002 pointing at the runbook. Otherwise, Gradle invokes `apksigner` with the supplied keystore producing a signed `.aab`.
4. Developer registers the keystore's SHA-256 fingerprint in Play Console under "App signing" (one-time, per runbook). Subsequent uploads use Play App Signing — the developer's keystore is the **upload key** only.
5. (iOS) Developer opens `ios/Runner.xcworkspace` in Xcode, signs in to Apple Developer account, ensures team `TYK6BBNDW5` is selected, lets Xcode auto-generate the Distribution provisioning profile during Archive → Distribute App → App Store Connect upload. Runbook documents the exact menu path and verification.
6. Developer uses TestFlight / Play Internal Test to install on a physical device and confirms install succeeds (proves signing chain).

### 2.3 Threat Model (STRIDE)

| Threat | Category | Mitigation |
|--------|----------|------------|
| Keystore (`*.jks`, `*.keystore`) committed to git → leaked private key → **irrecoverable** loss of Play Store upload identity (Google does not re-issue upload keys for the same app) | Information Disclosure | `.gitignore` excludes `*.keystore`, `*.jks`, `*.p12` (AC-003). `signing_config_test.dart` asserts no `*.keystore`/`*.jks` files are tracked. Runbook explicitly highlights this as the single most dangerous mistake. |
| `key.properties` committed with plaintext keystore + key passwords | Information Disclosure | `.gitignore` excludes `android/key.properties` (AC-003); only `key.properties.template` (placeholder values) is committed (AC-004). |
| Build silently falls back to debug keystore for a release artifact → Play Store rejects on upload OR (worse) developer uploads an unsigned-for-distribution artifact | Tampering / Spoofing | AC-002 fail-loud guard: missing `key.properties` aborts the Gradle release build with a clear runbook pointer. |
| Apple Distribution certificate or App Store provisioning profile leaks (e.g., shared `.p12` over email/chat) → attacker can sign and publish updates impersonating miToosa | Spoofing / Tampering | `.gitignore` excludes `*.mobileprovision`, `*.p12`, `*.cer` (AC-003). Runbook mandates: cert stays in macOS Keychain only; `.p12` exports go straight into a password manager (1Password / Keychain), never into the repo or chat. |
| Attacker substitutes a malicious APK in transit between developer's machine and Play Console (MITM) | Tampering | Play Console requires HTTPS upload; signed AAB integrity verified by `apksigner verify` (AC-006). Runbook adds a `apksigner verify --print-certs` step to confirm fingerprint before upload. |
| Developer denies having uploaded a malicious build (repudiation) | Repudiation | Apple + Google sign every uploaded build with the team's distribution identity; uploads are logged in App Store Connect / Play Console with timestamp + uploader Apple ID / Google account. No additional in-repo mitigation needed. |
| `GoogleService-Info.plist` / `google-services.json` (Firebase configs) committed publicly → API keys exposed | Information Disclosure | `.gitignore` excludes both (paired chore since Firebase Analytics is already wired in `pubspec.yaml`). |

### 2.4 Build Scope

```
✅ Ready to proceed — Scope Boundary
Files in scope      : android/app/build.gradle.kts, android/key.properties.template, .gitignore, Docs/RELEASE-SIGNING.md, test/release/signing_config_test.dart, ios/Runner.xcodeproj/project.pbxproj (light touch only — may be runbook-only if pbxproj edit is fragile)
Directories in scope: android/, Docs/, test/release/, ios/Runner.xcodeproj/
Out of scope        : lib/, test/core/, test/widgets/, ios/Runner/, ios/Flutter/, pubspec.yaml, analysis_options.yaml, .github/workflows/
```

---

## 3. Tasks

### 3.1 Task Tree

- [ ] **1.** Android signing config — parameterize Gradle to consume `key.properties` and fail loud when missing
  - [ ] 1.1 Add `Properties` loader + `signingConfigs.create("release")` block in `android/app/build.gradle.kts` reading from `android/key.properties` — _Requirements: AC-001, AC-009_
  - [ ] 1.2 Replace `release.signingConfig = signingConfigs.getByName("debug")` with the real release config + fail-loud guard per AC-002 — _Requirements: AC-001, AC-002_
  - [ ] 1.3 Create `android/key.properties.template` with placeholder values and field-by-field comments — _Requirements: AC-004_
- [ ] **2.** Secret hygiene — gitignore + guard test
  - [ ] 2.1 Append `*.keystore`, `*.jks`, `*.p12`, `*.mobileprovision`, `*.cer`, `android/key.properties`, `**/GoogleService-Info.plist`, `**/google-services.json` to `.gitignore` — _Requirements: AC-003_
  - [ ] 2.2 Write `test/release/signing_config_test.dart` — asserts: (a) `android/key.properties.template` exists; (b) `.gitignore` contains each required rule; (c) `git ls-files` returns no `*.keystore`/`*.jks`/`key.properties` (excluding `.template`) — _Requirements: AC-003, AC-004, AC-007_
- [ ] **3.** iOS signing — light pbxproj touch (or runbook-only if fragile)
  - [ ] 3.1 Inspect `ios/Runner.xcodeproj/project.pbxproj` for safe `DEVELOPMENT_TEAM` parameterization; if Xcode's build-settings UI exposes an env override path, document it in 3.2 instead of editing pbxproj. Decision recorded inline. — _Requirements: AC-008_
  - [ ] 3.2 **[manual]** Open `ios/Runner.xcworkspace` in Xcode, log into Apple Developer account, confirm team `TYK6BBNDW5` is signed in, let Automatic Signing provision Debug + Release. Verify via Product → Archive that an archive can be created without error. — _Requirements: AC-008_ `[manual]`
- [ ] **4.** Developer runbook
  - [ ] 4.1 Author `Docs/RELEASE-SIGNING.md` per outline in spec (iOS section, Android section, verification, troubleshooting, secret-rotation cadence). Cross-link to AC IDs and threat-model entries. — _Requirements: AC-005, AC-010_
- [ ] **5.** Manual human-only execution gates (cannot be agent-automated)
  - [ ] 5.1 **[manual]** Generate Android upload keystore via `keytool -genkey ...` per runbook; store in `~/.mitoosa/upload-keystore.jks` (or password-manager-controlled path); populate `android/key.properties` locally. — _Requirements: AC-001, AC-006_ `[manual]`
  - [ ] 5.2 **[manual]** Apple Developer Program: log in, generate iOS Distribution certificate, install in macOS Keychain. Create App Store Connect app record for bundle id `com.chicademy.mitoosa`. — _Requirements: AC-005, AC-008_ `[manual]`
  - [ ] 5.3 **[manual]** Google Play Console: create app record for `com.chicademy.mitoosa`, register upload key SHA-256 fingerprint (from `keytool -list -v -keystore upload-keystore.jks`), enable Play App Signing. — _Requirements: AC-005, AC-010_ `[manual]`
  - [ ] 5.4 **[manual]** End-to-end verification: run `flutter build appbundle --release`, run `apksigner verify --print-certs build/app/outputs/bundle/release/app-release.aab`, upload to Play Internal Test track, install on a physical Android device, confirm app launches. Repeat the analog for iOS via Xcode Archive → TestFlight. — _Requirements: AC-006_ `[manual]`
- [ ] **6.** Verification gates
  - [ ] 6.1 Run `dart analyze` and `flutter test`; confirm zero new errors / warnings — _Requirements: AC-007_

### 3.2 Wave Plan

**Wave 1 (parallel — all automatable, no shared state):** 1.1, 1.3, 2.1, 3.1, 4.1

**Wave 2 (sequential after Wave 1):** 1.2 (depends on 1.1), 2.2 (depends on 2.1 + 1.3)

**Wave 3 (sequential after Wave 2):** 6.1 (depends on all code changes landing)

**Wave 4 (manual — human-gated, runs after Wave 3 ships):** 3.2, 5.1, 5.2, 5.3, 5.4

### 3.3 Test Plan

Test plan: `Docs/AgToosa_TestPlan-BL-01-BL-02.md`
AC coverage: 10 ACs (7 Must · 3 Should) mapped to test IDs T-001 … T-009
Smoke set: 4 tests tagged `@smoke` (one per critical Must AC)

---

## ✅ Spec Approved

Approved: 2026-05-16 00:00
