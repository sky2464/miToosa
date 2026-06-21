# iPhone Launch Readiness

**Launch focus:** iPhone/iOS only  
**Bundle ID:** `dev.atoosa.mitoosa`  
**App Store name:** `miToosa`  
**Analytics decision:** Firebase + Google Analytics enabled for release  
**Backend scope:** Analytics only. Leaderboard, server sync, IAP, referral tiers, and VIP remain deferred until separately approved.

This checklist captures what the repo can prepare and what the owner must do in external systems before App Store launch.

## Repo-prepared items

- [x] iOS Runner bundle identifier locked to `dev.atoosa.mitoosa`.
- [x] Release signing runbooks point iOS App Store work at `dev.atoosa.mitoosa`.
- [x] Firebase setup runbook documents the launch decision to enable Firebase + Google Analytics.
- [x] App Store metadata draft exists in `docs/APP-STORE-METADATA.md`.
- [x] Company registration readiness checklist exists in `docs/COMPANY-REGISTRATION-READINESS.md`.
- [x] Replace placeholder `lib/firebase_options.dart` by running `flutterfire configure` after the Firebase iOS app is created.
- [ ] Publish privacy and support URLs, then replace placeholders in App Store metadata.

## Manual owner checklist

### Company registration

- [ ] Register the legal entity.
- [ ] Decide whether `miToosa` needs a DBA/trade-name filing.
- [ ] Choose registered agent and principal business address.
- [ ] Get EIN after formation.
- [ ] Open business bank/accounting/password-manager structure.
- [ ] Store IP and asset ownership records for source code, app name, domains, designs, fonts, and signing credentials.

### Apple Developer and App Store Connect

- [ ] Register App ID `dev.atoosa.mitoosa`.
- [ ] Create Apple Distribution certificate or let Xcode create it.
- [ ] In Xcode, select the correct Apple Team and enable automatic signing.
- [ ] Create App Store Connect app record:
  - Platform: iOS
  - Name: `miToosa`
  - Bundle ID: `dev.atoosa.mitoosa`
  - SKU: `mitoosa-ios`
- [ ] Complete Age Rating questionnaire.
- [ ] Complete Export Compliance questionnaire.
- [ ] Complete App Privacy questionnaire.
- [ ] Upload screenshots and metadata.
- [ ] Archive, validate, upload, and submit build.

### Firebase + Google Analytics

- [x] Create Firebase project (`mitoosa-2121b`).
- [ ] Enable Google Analytics in the Firebase project.
- [x] Register iOS app with bundle ID `dev.atoosa.mitoosa`.
- [x] From repo root, run:

```bash
flutterfire configure --project=mitoosa-2121b --platforms=ios --ios-bundle-id=dev.atoosa.mitoosa
```

- [x] Confirm generated config replaces `lib/firebase_options.dart`.
- [x] Confirm `ios/Runner/GoogleService-Info.plist` exists locally and is not committed if it contains project credentials.
- [ ] Decide Google Analytics data-sharing settings in Firebase/Google admin.
- [ ] For release verification, run with:

```bash
flutter run --dart-define=FIREBASE_ENABLED=true
```

- [ ] Verify at least one launch/session event in Firebase Analytics DebugView.

### Public web/contact requirements

- [ ] Publish Privacy Policy URL.
- [ ] Publish Support URL.
- [ ] Decide legal/privacy/support email addresses.
- [ ] Optional: publish marketing/product page.

### Physical iPhone QA

- [ ] TestFlight install on a real iPhone.
- [ ] Cold launch.
- [ ] Onboarding.
- [ ] Full gameplay session.
- [ ] Settings.
- [ ] Share flow.
- [ ] Persistence after force quit/restart.
- [ ] Offline behavior.
- [ ] VoiceOver smoke test.
- [ ] Dynamic Type check.
- [ ] Confirm no broken links, placeholder URLs, layout overflows, or App Review metadata mismatches.

## Verification gates

Run before submitting the TestFlight/App Store build:

```bash
dart analyze
flutter test
flutter pub get
```

Run code generation only if providers, generated models, or `pubspec.yaml` changed:

```bash
dart pub run build_runner build --delete-conflicting-outputs
```

Final App Store gate:

- [ ] Xcode Archive succeeds for `dev.atoosa.mitoosa`.
- [ ] Xcode Organizer **Validate App** passes.
- [ ] Build uploads to TestFlight.
- [ ] TestFlight install on a real iPhone passes.
- [ ] App Privacy questionnaire matches Firebase + Google Analytics behavior and current data collection.

