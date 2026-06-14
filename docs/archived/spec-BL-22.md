# Spec: BL-22 — iPhone Launch Readiness Prep

> **Story ID:** BL-22  
> **Epic:** EP-01 Launch Readiness & Validation  
> **Status:** 🏁 Shipped  
> **Estimate:** S  
> **Spec created:** 2026-06-03  

## 1. Requirements

### 1.1 User Stories

**As a** project owner preparing miToosa for App Store registration, **I want** the iOS app identity locked to the final launch bundle ID **so that** Apple, Firebase, signing, and App Store Connect all use one consistent identifier.

**As a** launch operator, **I want** iPhone-only launch, Firebase/Google Analytics, App Store metadata, company readiness, and manual external steps documented **so that** I can execute the non-automatable launch work without rediscovering requirements.

### 1.2 Acceptance Criteria (EARS)

| ID | EARS | Priority |
|----|------|----------|
| AC-001 | WHEN the iOS project is inspected THE SYSTEM SHALL use `dev.atoosa.mitoosa` for Runner and `dev.atoosa.mitoosa.RunnerTests` for tests. | Must |
| AC-002 | WHEN launch documentation is inspected THE SYSTEM SHALL identify the v1 launch focus as iPhone/iOS only. | Must |
| AC-003 | WHEN analytics documentation is inspected THE SYSTEM SHALL state Firebase + Google Analytics are approved for release analytics and require `FIREBASE_ENABLED=true` plus generated Firebase options. | Must |
| AC-004 | WHEN App Store preparation docs are inspected THE SYSTEM SHALL provide metadata, privacy, age rating, export compliance, and screenshot capture guidance. | Must |
| AC-005 | WHEN company-readiness docs are inspected THE SYSTEM SHALL list formation, public contact, admin, and IP/asset ownership steps. | Must |
| AC-006 | WHEN release docs are inspected THE SYSTEM SHALL list manual external gates for Apple App ID, Firebase iOS app, public URLs, Xcode Archive/TestFlight, and physical iPhone QA. | Must |
| AC-007 | WHEN active launch docs and iOS config are scanned THE SYSTEM SHALL reject stale active bundle IDs `com.mitoosa.app` and `com.chicademy.mitoosa` for iOS launch instructions. | Must |
| AC-008 | WHEN the placeholder Firebase options file is used THE SYSTEM SHALL fail closed with `flutterfire configure --platforms=ios` guidance for `dev.atoosa.mitoosa`. | Should |

### 1.3 Out of Scope

- Do not create Apple Developer, App Store Connect, Firebase, Google Analytics, bank, EIN, or company accounts.
- Do not submit an App Store build or run TestFlight on behalf of the owner.
- Do not enable leaderboard, server sync, VIP, referrals, IAP, Android launch, macOS launch, or Web launch.
- Do not modify `docs/PRODUCT-WEDGE.md`.
- Do not modify unrelated S2-05 work, including `docs/AgToosa_Spec-S2-05-tracks-ui-fixes.md`.

## 2. Design

### 2.1 Architecture Blueprint

Files changed or created:

- `ios/Runner.xcodeproj/project.pbxproj` — set iOS Runner and RunnerTests bundle identifiers to `dev.atoosa.mitoosa`.
- `docs/LAUNCH.md`, `docs/IPHONE-LAUNCH-READINESS.md`, `docs/APP-STORE-METADATA.md`, `docs/COMPANY-REGISTRATION-READINESS.md`, `docs/ANALYTICS-SETUP.md`, `docs/RELEASE-SIGNING.md`, `docs/release/BL-01-02-*.md` — iPhone-first launch, Firebase/GA, App Store, company, and signing handoff docs.
- `lib/firebase_options.dart` — placeholder error message points to iOS FlutterFire configuration for `dev.atoosa.mitoosa`.
- `test/release/signing_config_test.dart`, `test/release/iphone_launch_readiness_test.dart` — regression guards for bundle ID and launch-readiness docs.
- `pubspec.lock` — refreshed by `flutter pub get` under the active Flutter SDK resolver.

### 2.2 Data Flow

1. Owner registers Apple/Firebase resources using `dev.atoosa.mitoosa`.
2. Owner runs `flutterfire configure --project=<id> --platforms=ios`, replacing placeholder Firebase options.
3. Release build is run with `--dart-define=FIREBASE_ENABLED=true` when analytics should be active.
4. App Store Connect metadata, privacy, age rating, export compliance, screenshots, and support/privacy URLs are filled from the readiness docs.
5. Xcode Archive validates/uploads to TestFlight, then a physical iPhone install confirms launch readiness.

### 2.3 Threat Model (STRIDE)

| Threat | Category | Mitigation |
|--------|----------|------------|
| Stale bundle ID registered in Apple or Firebase, producing signing/config mismatch | Tampering / Denial of Service | Tests and docs pin `dev.atoosa.mitoosa`; stale active IDs are rejected in launch docs/config. |
| Firebase config committed before owner review | Information Disclosure | Placeholder remains fail-closed; docs require generated config after external setup and note local `GoogleService-Info.plist` handling. |
| App Store privacy answers omit Firebase + Google Analytics | Information Disclosure / Repudiation | App Store metadata and readiness docs require App Privacy answers to match release analytics behavior. |
| Signing material shared through repo/chat | Spoofing / Tampering | Existing signing runbooks keep certs/profiles out of source control and route private material to local Keychain/password manager. |
| Manual external gates mistaken for automated completion | Repudiation | Manual tasks are explicitly deferred in spec/test plan and readiness checklist. |

### 2.4 Build Scope

✅ Ready to proceed — Scope Boundary  
Files in scope      : `ios/Runner.xcodeproj/project.pbxproj`, `lib/firebase_options.dart`, `pubspec.lock`, `test/release/signing_config_test.dart`, `test/release/iphone_launch_readiness_test.dart`, BL-22 launch/signing/analytics docs, BL-22 spec/test/review artifacts  
Directories in scope: `docs/`, `docs/release/`, `docs/archived/`, `test/release/`, `ios/Runner.xcodeproj/`, `lib/`  
Out of scope        : `docs/PRODUCT-WEDGE.md`, unrelated S2-05 spec/work, account creation, App Store submission, Firebase console execution, physical-device QA execution  

## 3. Tasks

### 3.1 Task Tree

- [x] **1.** iOS identity: lock launch bundle ID
  - [x] 1.1 Set Runner bundle ID to `dev.atoosa.mitoosa` and RunnerTests to `dev.atoosa.mitoosa.RunnerTests` — _Requirements: AC-001_
  - [x] 1.2 Add regression assertions rejecting stale iOS launch bundle IDs — _Requirements: AC-001, AC-007_
- [x] **2.** Launch docs: make iPhone-first readiness explicit
  - [x] 2.1 Replace stale multi-platform launch plan with iPhone-first launch plan — _Requirements: AC-002, AC-006_
  - [x] 2.2 Add iPhone launch readiness checklist with manual external gates — _Requirements: AC-002, AC-006_
  - [x] 2.3 Add App Store metadata draft — _Requirements: AC-004_
  - [x] 2.4 Add company registration readiness checklist — _Requirements: AC-005_
- [x] **3.** Firebase/GA docs: document approved analytics path
  - [x] 3.1 Update analytics runbook for Firebase + Google Analytics launch decision — _Requirements: AC-003_
  - [x] 3.2 Update Firebase placeholder guidance for iOS FlutterFire configuration — _Requirements: AC-003, AC-008_
- [x] **4.** Release runbooks: align App Store handoff
  - [x] 4.1 Update iOS signing and App Store Connect runbooks to `dev.atoosa.mitoosa` — _Requirements: AC-006, AC-007_
  - [x] 4.2 Keep Android launch identity deferred and separate from iPhone launch — _Requirements: AC-002_
- [x] **5.** Workflow artifacts and verification
  - [x] 5.1 Backfill BL-22 spec, test plan, review, changelog, and Master-Plan tracking — _Requirements: AC-001–AC-008_
  - [x] 5.2 Run format, analyze, pub get, and full test suite — _Requirements: AC-001–AC-008_
- [ ] **6.** Manual external gates
  - [ ] 6.1 Register Apple App ID `dev.atoosa.mitoosa` — _Requirements: AC-006_ `[manual-deferred: 2026-06-03]`
  - [ ] 6.2 Create Firebase project/iOS app and run FlutterFire configure — _Requirements: AC-003, AC-008_ `[manual-deferred: 2026-06-03]`
  - [ ] 6.3 Publish privacy/support URLs and update App Store metadata — _Requirements: AC-004, AC-006_ `[manual-deferred: 2026-06-03]`
  - [ ] 6.4 Archive/upload to TestFlight and install on real iPhone — _Requirements: AC-006_ `[manual-deferred: 2026-06-03]`
  - [ ] 6.5 Complete physical iPhone QA and App Privacy review — _Requirements: AC-004, AC-006_ `[manual-deferred: 2026-06-03]`

### 3.2 Wave Plan

**Wave 1 (parallel):** 1.1, 2.1, 2.2, 2.3, 2.4  
**Wave 2 (sequential after Wave 1):** 1.2, 3.1, 3.2, 4.1, 4.2  
**Wave 3 (sequential):** 5.1, 5.2  
**Manual/deferred:** 6.1, 6.2, 6.3, 6.4, 6.5  

### 3.3 Test Plan

See `docs/AgToosa_TestPlan-BL-22.md`.

## ✅ Spec Approved

Approved: 2026-06-03 00:00
