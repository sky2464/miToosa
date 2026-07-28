# Spec: BL-32 — Privacy, Consent, and iOS Release Configuration

> **Story ID:** BL-32
> **Epic:** EP-02 Platform Release Infrastructure
> **Status:** 🏁 Shipped (2026-07-27)
> **Estimate:** M
> **Clarity:** ready
> **Spec created:** 2026-07-14

## ✅ Spec Approved

Approved 2026-07-27. Enrolled in Active Cycle for implementation.

## 1. Requirements

### 1.1 Goal Contract

| Field | Value |
|-------|-------|
| Goal | Make anonymous analytics default-on but clearly disclosed, independently controllable, and permanently separated from advertising consent in the iPhone release configuration. |
| User outcome | Players can understand and turn off anonymous analytics, while the app never grants ad storage, ad user data, or ad personalization consent. |
| Success condition | Bootstrap loads persisted analytics preference before enabling collection; Settings has a clear opt-out; every applied Firebase consent set denies ad-related categories; iOS release metadata, portrait orientation, local-network declaration, and privacy manifest match the shipped feature set. |
| Proof / evidence | Preferences/service tests, Firebase adapter tests, Settings widget tests, plist and privacy-manifest lint/build checks, dart analyze, flutter test, and iPhone opt-out smoke. |
| Non-goals | Crashlytics implementation, ATT prompts, ad SDKs, user accounts, backend telemetry, or edits to docs/PRODUCT-WEDGE.md. |
| Assumptions | Analytics remains anonymous and Firebase-enabled only for builds using FIREBASE_ENABLED; shared_preferences can safely store the local opt-out without a Hive schema bump. |
| Risks | Native auto-collection can occur before Dart preferences load; invalid privacy-manifest keys can block App Store submission; a new platform service can drift from disclosure copy. |
| Unresolved questions | None. The user selected analytics enabled by default with disclosure/opt-out and all ad consent denied. |

### 1.2 Brownfield Baseline

| Area | Current state | Intended delta |
|------|---------------|----------------|
| Consent | main.dart unconditionally grants analytics, ad storage, ad user data, and ad personalization. | Apply persisted analytics preference and deny all ad-related categories every time. |
| Persistence | shared_preferences is available but privacy choice has no owner. | Add a narrow privacy preferences repository with a default-enabled value. |
| Settings | No analytics disclosure/opt-out exists. | Add accessible disclosure and opt-out UI with a plain-language effect. |
| iOS metadata | Display name and supported orientations are stale/broad; local-network description conflicts with hidden POC. | Set miToosa naming, portrait iPhone contract, and remove non-applicable local-network declaration. |
| Privacy manifest | Runner has no app PrivacyInfo.xcprivacy. | Add a valid, target-bundled manifest after an API/data audit. |

### 1.3 User Stories

**As a** player, **I want** to know whether anonymous analytics is enabled and turn it off **so that** I control optional data collection.

**As a** player, **I want** the iPhone app's permissions and privacy information to match what I can actually use **so that** I am not misled.

### 1.4 Acceptance Criteria (EARS)

| ID | EARS | Priority |
|----|------|----------|
| AC-001 | WHEN a Firebase-enabled build starts THE SYSTEM SHALL load the persisted analytics choice before enabling analytics collection. | Must |
| AC-002 | WHEN analytics is enabled by default or re-enabled THE SYSTEM SHALL grant analytics storage only and SHALL deny ad storage, ad user data, and ad personalization consent. | Must |
| AC-003 | WHEN a player disables anonymous analytics in Settings THE SYSTEM SHALL persist the choice, disable collection, and preserve the choice after relaunch. | Must |
| AC-004 | WHEN a player views the analytics control THE SYSTEM SHALL show plain-language disclosure, opt-out effect, and a link or route to the current privacy policy. | Must |
| AC-005 | WHEN the iOS release target is built THE SYSTEM SHALL use miToosa display naming, portrait orientation on iPhone, no unused local-network description, and a valid target-bundled PrivacyInfo.xcprivacy. | Must |
| AC-006 | WHEN privacy policy or App Store metadata is reviewed THE SYSTEM SHALL accurately describe anonymous analytics, opt-out, local-only game data, and absence of ad targeting. | Must |

### 1.5 Out of Scope

- Firebase Crashlytics, which is BL-37.
- Advertisements, ATT, IDFA, personalization, or marketing consent.
- A legal opinion or App Store Connect submission.
- Local multiplayer implementation; BL-31 hides the POC from release navigation.
- Hive schema changes for privacy choice.

### 1.6 Failure Modes

| AC | Failure mode | Mitigation |
|----|--------------|------------|
| AC-001 | Native Firebase collects before Dart applies opt-out. | Disable automatic collection in iOS config; explicitly enable only after preferences load. |
| AC-002 | A future edit accidentally grants an ad category. | Centralize consent in one adapter and assert all ad flags false in unit tests. |
| AC-003 | Toggle updates UI but not native collection or persistence. | Test service call order and cold-relaunch readback. |
| AC-004 | Disclosure makes an overbroad data claim. | Reuse reviewed policy text and forbid personal/profile data claims. |
| AC-005 | Manifest is syntactically valid but not bundled. | Lint with plutil and inspect/archive target membership in an iOS build. |
| AC-006 | Policy drifts from shipped configuration. | Cross-check test and review checklist against source settings. |

## 2. Design

### 2.1 Architecture Blueprint

Files to create:

- lib/data/privacy_preferences_repository.dart — default-enabled local choice with a narrow interface and fake.
- lib/core/analytics_consent_service.dart — applies Firebase collection and consent from one value; no UI dependency.
- ios/Runner/PrivacyInfo.xcprivacy — valid app privacy manifest, added to the Runner target using the xcode-project-setup workflow.
- focused tests under test/data/, test/core/, and test/features/settings/.

Files to change:

- lib/main.dart — load/apply preferences before Firebase collection.
- lib/features/settings/settings_screen.dart — anonymous analytics disclosure and switch.
- ios/Runner/Info.plist and ios/Runner.xcodeproj/project.pbxproj — release naming, iPhone orientation, analytics auto-collection default, and target membership.
- Docs/PRIVACY-POLICY.md, docs/APP-STORE-METADATA.md, and associated launch checklist — align public disclosures.
- Docs/AgToosa_TestPlan-BL-32.md — test evidence.

The data layer stores the player choice. The analytics adapter has the only FirebaseAnalytics consent calls. Widgets never call Firebase directly.

### 2.2 Data Flow

1. Bootstrap initializes local preferences before Firebase analytics collection is enabled.
2. PrivacyPreferencesRepository returns default true only when no choice exists.
3. AnalyticsConsentService applies analytics storage equal to the choice, all ad values false, and collection equal to the choice.
4. Settings displays the current value and explanatory privacy copy.
5. A toggle updates local storage first, then applies the adapter; failures restore the visible value and show recovery feedback.
6. iOS target metadata and privacy manifest document the actual resulting behavior.

### 2.3 Threat Model (STRIDE)

| Threat | Category | Mitigation |
|--------|----------|------------|
| A default configuration sends analytics before opt-out is read. | Information Disclosure | Disable native auto-collection and explicitly enable after preference loading. |
| Future code enables advertising consent. | Elevation of Privilege | One adapter always writes false ad flags with unit tests. |
| Stale policy underreports actual data flow. | Repudiation | Source-to-policy checklist and launch review evidence. |
| Malformed privacy manifest blocks submission. | Denial of Service | Plist lint plus archive/build verification and target membership check. |
| Toggle state is spoofed by a stale widget. | Tampering | Repository-backed state, serialized updates, and relaunch test. |

### 2.4 External References

- Firebase Analytics exposes setAnalyticsCollectionEnabled and setConsent in its [Flutter API](https://pub.dev/documentation/firebase_analytics/latest/firebase_analytics/FirebaseAnalytics-class.html).
- Apple requires a valid [PrivacyInfo.xcprivacy manifest](https://developer.apple.com/documentation/bundleresources/privacy-manifest-files) for appropriate app/SDK data practices and expects it to be target-bundled.
- Apple documents [NSLocalNetworkUsageDescription](https://developer.apple.com/documentation/BundleResources/Information-Property-List/NSLocalNetworkUsageDescription) for apps that actually use the local network.

### 2.5 Build Scope

✅ Ready to proceed — Scope Boundary
Files in scope      : privacy preferences/consent service, main.dart, Settings privacy UI, iOS Info.plist and target membership, PrivacyInfo.xcprivacy, privacy/App Store documentation, focused tests, Docs/AgToosa_TestPlan-BL-32.md, Docs/Master-Plan.md
Directories in scope: lib/data/, lib/core/, lib/features/settings/, ios/Runner/, ios/Runner.xcodeproj/, test/, Docs/
Out of scope        : Crashlytics, ads/ATT/IDFA, local multiplayer, Hive schema fields, active-cycle enrollment

## 3. Tasks

### 3.1 Task Tree

- [ ] **1. Privacy contract tests:** Capture consent ordering, defaults, and disclosure behavior.
  - [ ] 1.1 Add RED repository/adapter tests for default, opt-out, opt-in, and all ad flags false. — _Requirements: AC-001, AC-002, AC-003_
  - [ ] 1.2 Add RED Settings disclosure and privacy-policy-route tests. — _Requirements: AC-004_
  - [ ] 1.3 Add RED static tests for iOS metadata and privacy-manifest presence. — _Requirements: AC-005, AC-006_
- [ ] **2. Consent architecture:** Implement local preferences and one Firebase boundary.
  - [ ] 2.1 Add privacy preferences repository and test fake. — _Requirements: AC-001, AC-003_
  - [ ] 2.2 Add AnalyticsConsentService and move all consent/collection calls into it. — _Requirements: AC-001, AC-002, AC-003_
  - [ ] 2.3 Update bootstrap ordering and Settings control. — _Requirements: AC-001, AC-003, AC-004_
- [ ] **3. iOS release truth:** Align native metadata and public disclosure.
  - [ ] 3.1 Update Info.plist display name, orientation, local-network declaration, and auto-collection default. — _Requirements: AC-005_
  - [ ] 3.2 Add/target PrivacyInfo.xcprivacy through xcode-project-setup and lint it. — _Requirements: AC-005_
  - [ ] 3.3 Align privacy policy, App Store metadata, and release checklist. — _Requirements: AC-004, AC-006_
- [ ] **4. Verification:** Prove settings, plist, and release behavior.
  - [ ] 4.1 Run focused tests, dart analyze, flutter test, plutil lint, and iOS config build. — _Requirements: AC-001 through AC-006_
  - [ ] 4.2 Run iPhone enable/disable/relaunch disclosure smoke. — _Requirements: AC-003, AC-004, AC-005_ [manual]

### 3.2 Wave Plan

**Wave 1 (parallel):** 1.1, 1.2, 1.3
**Wave 2 (parallel after Wave 1):** 2.1, 3.1
**Wave 3 (sequential after Wave 2):** 2.2, 2.3, 3.2
**Wave 4 (sequential after Wave 3):** 3.3, 4.1, 4.2

### 3.3 Test Plan

Test plan: Docs/AgToosa_TestPlan-BL-32.md
AC coverage: 6 ACs mapped to 7 test IDs
Smoke set: T-001, T-002, T-003, T-005, T-006

### 3.4 Work Package DAG

| package_id | wave | depends_on | owned_files | inputs | outputs | merge_order | verification |
|------------|------|------------|-------------|--------|---------|-------------|--------------|
| PKG-1.1 | 1 | — | privacy/Settings tests | current Firebase bootstrap | RED behavior tests | 1 | focused flutter test |
| PKG-1.2 | 1 | — | iOS static tests | Info.plist baseline | RED release-metadata tests | 2 | focused flutter test |
| PKG-2.1 | 2 | PKG-1.1 | privacy repository/service | shared_preferences, Firebase API | single consent boundary | 3 | focused flutter test |
| PKG-2.2 | 2 | PKG-1.2 | iOS plist/manifest/project | Apple contract | target-bundled manifest | 4 | plutil -lint ios/Runner/PrivacyInfo.xcprivacy |
| PKG-3.1 | 3 | PKG-2.1, PKG-2.2 | main.dart and Settings | consent service | live disclosure/opt-out | 5 | focused flutter test |
| PKG-4.1 | 4 | PKG-3.1 | docs/tests/test plan | integrated behavior | GREEN evidence | 6 | dart analyze lib test && flutter test |

### 3.5 Story Skill Opportunity Synthesis

No new project skill is proposed. Existing iphone-launch-gate applies at build/ship, and the implementation is bounded by standard Flutter plus Xcode project setup practices.

### 3.6 Spec Quality Analyzer

| Check | Result |
|-------|--------|
| Default-on analytics and opt-out decision are explicit. | Pass |
| Ad-related consent is unambiguously denied. | Pass |
| Privacy manifest and App Store disclosure have testable artifacts. | Pass |
| Crash reporting is deliberately isolated to BL-37. | Pass |
