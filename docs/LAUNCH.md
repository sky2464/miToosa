# miToosa iPhone Launch Plan

**Release target:** v1.5.1 iPhone App Store launch  
**Current focus:** 100% iPhone/iOS until App Store readiness is complete  
**Bundle ID:** `dev.atoosa.mitoosa`  
**App Store name:** `miToosa`  
**Analytics:** Firebase + Google Analytics enabled for release  

Android, macOS, and Web release work is deferred. Existing cross-platform code stays intact, but launch execution now routes through the iPhone-specific readiness files.

## Source files

- `docs/IPHONE-LAUNCH-READINESS.md` — owner checklist for App Store, Firebase, company, public URLs, and physical iPhone QA.
- `docs/APP-STORE-METADATA.md` — App Store product-page draft, screenshot checklist, and questionnaire guide.
- `docs/PRIVACY-POLICY.md` — public privacy policy source (Firebase + GA when `FIREBASE_ENABLED=true`).
- `docs/SUPPORT.md` — public support page source for App Store Support URL.
- `docs/USER-GUIDE.md` — in-app help and gameplay reference linked from Support.
- `docs/COMPANY-REGISTRATION-READINESS.md` — company formation and App Store seller-readiness checklist.
- `docs/ANALYTICS-SETUP.md` — Firebase + Google Analytics activation runbook.
- `docs/RELEASE-SIGNING.md` — signing, archive, TestFlight, and troubleshooting runbook.

## Code readiness

- [x] iOS Runner bundle identifier is `dev.atoosa.mitoosa`.
- [x] Firebase Analytics scaffolding exists behind `FIREBASE_ENABLED`.
- [x] Placeholder `lib/firebase_options.dart` fails closed until FlutterFire config is generated.
- [x] Release signing runbooks exist.
- [x] Privacy and data-retention docs exist ([PRIVACY-POLICY.md](PRIVACY-POLICY.md), [SUPPORT.md](SUPPORT.md)).
- [x] Generated Firebase config added after external Firebase project/app setup (BL-23).
- [ ] Publish public privacy/support URLs and paste finals into App Store metadata `[manual-deferred: 2026-07-11]` — see [APP-STORE-METADATA.md](APP-STORE-METADATA.md).
- [ ] Capture and upload iPhone screenshots per metadata checklist `[manual-deferred: 2026-07-11]`.

## Manual external gates

### Company

- [ ] Register company.
- [ ] Decide DBA/trade-name posture for `miToosa`.
- [ ] Get EIN.
- [ ] Set up bank/accounting/password vault.
- [ ] Record IP and asset ownership.

### Apple

- [ ] Register App ID `dev.atoosa.mitoosa`.
- [ ] Create Apple Distribution certificate or let Xcode create it.
- [ ] Enable Xcode automatic signing.
- [ ] Create App Store Connect app record.
- [ ] Complete App Privacy, Age Rating, and Export Compliance.
- [ ] Upload screenshots and metadata.
- [ ] Archive, validate, upload to TestFlight, and submit for review.

### Firebase + Google Analytics

- [x] Create Firebase project with Google Analytics enabled (`mitoosa-2121b`).
- [x] Register iOS app `dev.atoosa.mitoosa`.
- [x] Run `flutterfire configure --project=mitoosa-2121b --platforms=ios --ios-bundle-id=dev.atoosa.mitoosa`.
- [ ] Verify Firebase DebugView with `FIREBASE_ENABLED=true`.
- [ ] Ensure App Store privacy answers declare the release analytics behavior.

### Physical iPhone QA

- [ ] Install from TestFlight on a real iPhone.
- [ ] Verify cold launch, onboarding, full gameplay session, settings, share flow, restart persistence, offline behavior, VoiceOver, Dynamic Type, and no broken links/placeholders.

## Verification gates

```bash
dart analyze
flutter test
flutter pub get
```

Run code generation only if providers/generated files or `pubspec.yaml` change:

```bash
dart pub run build_runner build --delete-conflicting-outputs
```

Final release validation happens in Xcode Organizer and TestFlight:

- [ ] Archive succeeds for `dev.atoosa.mitoosa`.
- [ ] Validate App passes.
- [ ] TestFlight build processes.
- [ ] TestFlight install on a real iPhone passes.

