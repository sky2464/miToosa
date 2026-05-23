# Release Signing

This runbook covers release signing for both target stores — Google Play (Android) and the App Store / TestFlight (iOS). Signing material is platform-managed and never lives in source control. See also: spec `docs/archived/spec-BL-01-BL-02-platform-signing.md` (AC-001 through AC-010).

## Step-by-step manuals (BL-01+02 deferred tasks)

For numbered click-by-click procedures (tasks **3.2**, **5.1**, **5.2**, **5.3**, **5.4**), use the dedicated guides under **`docs/release/`**:

| Task | Guide |
|------|--------|
| Index + recommended order | [docs/release/BL-01-02-README.md](release/BL-01-02-README.md) |
| 3.2 Xcode automatic signing | [docs/release/BL-01-02-3.2-xcode-automatic-signing.md](release/BL-01-02-3.2-xcode-automatic-signing.md) |
| 5.1 Android keystore (`keytool`) | [docs/release/BL-01-02-5.1-android-keystore-keytool.md](release/BL-01-02-5.1-android-keystore-keytool.md) |
| 5.2 Apple Distribution + ASC app | [docs/release/BL-01-02-5.2-apple-distribution-app-store-connect.md](release/BL-01-02-5.2-apple-distribution-app-store-connect.md) |
| 5.3 Play upload-key SHA-256 | [docs/release/BL-01-02-5.3-play-console-upload-key.md](release/BL-01-02-5.3-play-console-upload-key.md) |
| 5.4 TestFlight + Play Internal | [docs/release/BL-01-02-5.4-e2e-testflight-play-internal.md](release/BL-01-02-5.4-e2e-testflight-play-internal.md) |

The sections below remain a concise reference; follow the manuals when executing the manual gates for the first time.

# Android Release Signing

This project requires a secure keystore for Android release builds. The signing configuration is loaded from `android/key.properties`, which must be excluded from source control.

## Setup

1. Copy the signing template:
   ```bash
   cp android/key.properties.template android/key.properties
   ```
2. Fill in your values:
   - `storeFile` — path to the release keystore file.
   - `storePassword` — keystore password.
   - `keyAlias` — key alias inside the keystore.
   - `keyPassword` — key password.

3. Ensure the file is ignored by Git. The `.gitignore` file now excludes `android/key.properties` and common keystore artifacts.

## Build

Use the normal Gradle release build command:

```bash
cd android
./gradlew assembleRelease
```

If the file is missing or fields are empty, the build will fail with a clear error message.

## Security

- Never commit `android/key.properties` or keystore binaries to version control.
- Store release credentials securely, such as in a secrets manager or CI secret store.

# iOS

iOS release signing is managed through Xcode + Apple Developer Program. Unlike Android, no checked-in config file controls signing — credentials live entirely in your local Keychain and the Apple Developer portal. Pbxproj parameterization was evaluated (spec task 3.1) and **deferred to runbook-only** because Xcode rewrites `ios/Runner.xcodeproj/project.pbxproj` on most edits, which makes programmatic patches fragile. The team ID currently embedded in pbxproj (`TYK6BBNDW5`) is acceptable; per-developer overrides happen through Xcode's UI (see _Switching teams locally_ below).

## Prerequisites

- An **Apple Developer Program** membership (paid, USD $99/year) under team `TYK6BBNDW5` (or your fork's team).
- macOS host with the latest stable Xcode installed.
- Bundle identifier `com.chicademy.mitoosa` registered in App Store Connect.

## Setup

1. Open the workspace (never the `.xcodeproj` directly):

   ```bash
   open ios/Runner.xcworkspace
   ```

2. In Xcode, select the **Runner** target → **Signing & Capabilities** tab.

3. Pick a signing mode:
   - **Automatic** (recommended): tick **Automatically manage signing**, then select your Apple Developer team from the dropdown. Xcode will provision Debug + Release profiles for you.
   - **Manual**: untick automatic signing and import a Distribution certificate (`.p12`) into your Keychain, then attach a downloaded Provisioning Profile per build configuration.

4. Confirm the **Bundle Identifier** reads `com.chicademy.mitoosa` for Release.

5. In **App Store Connect** (https://appstoreconnect.apple.com), create the app record:
   - **My Apps → +** → **New App** → platform iOS → bundle id `com.chicademy.mitoosa`.
   - Fill metadata (name, SKU, primary language).

## Switching teams locally

If you fork the repo and need to ship under a different team, change `DEVELOPMENT_TEAM` directly in Xcode's Signing & Capabilities tab — do not hand-edit `ios/Runner.xcodeproj/project.pbxproj`. Xcode persists the change correctly; a manual edit is likely to be clobbered.

## Archive & Upload

1. In Xcode, set the active scheme to **Runner** and the destination to **Any iOS Device (arm64)**.
2. **Product → Archive**. Wait for the archive to build (3–10 min).
3. When the **Organizer** window appears: select the new archive → **Distribute App** → **App Store Connect** → **Upload** → keep defaults → **Upload**.
4. The build appears in **App Store Connect → TestFlight** within ~15 min for processing. Once processed, add it to an Internal Test group to validate it installs on a real device.

# Verification

After producing a signed build, verify the signature before promoting it to a public track.

## Android

```bash
# Locate the build artifact:
ls build/app/outputs/bundle/release/app-release.aab

# Inspect the signing certificate baked into the bundle:
apksigner verify --print-certs build/app/outputs/bundle/release/app-release.aab
```

The certificate SHA-256 fingerprint reported by `apksigner` MUST match the upload key fingerprint registered in **Play Console → Setup → App integrity → App signing**. After upload, open **Play Console → Release → Bundle Explorer**, select the uploaded version, and confirm the **App bundle** signed-by fingerprint matches.

## iOS

1. In Xcode **Organizer**: select the archive → **Validate App**. Validation runs Apple's pre-flight checks (entitlements, missing assets, signing).
2. After upload, **App Store Connect → TestFlight → Builds**: verify the build appears with status **Ready to Test** (processing took ~15 min). If status reads **Invalid Binary** or **Missing Compliance**, click in for the diagnostic.
3. Install the build on a physical device through TestFlight and confirm cold launch.

# Secret rotation

| Asset | Cadence | Action on rotation |
|-------|---------|--------------------|
| Apple **Distribution Certificate** (`.p12`) | Annual — Apple certs expire after 1 year | Re-generate in Apple Developer portal, install in Keychain, re-issue Provisioning Profile. Old certs continue to validate already-published builds but cannot sign new ones. |
| Apple **Provisioning Profile** | Auto-managed when using Automatic Signing; manual users rebuild when cert renews | Download fresh `.mobileprovision` from Apple Developer portal; double-click to install. |
| Android **Upload key** (`upload-keystore.jks`) | **Permanent — never rotate.** | If lost, you MUST contact Google Play support to reset it. Treat this asset as irreplaceable. |
| Android **Play App Signing key** | Managed by Google — opaque to publishers | Nothing to do. Google holds and rotates this for you. |
| `android/key.properties` (passwords) | Rotate if compromised or contributor changes | Update passwords in the keystore via `keytool -storepasswd` / `keytool -keypasswd`; sync `android/key.properties` locally + in CI secret store; never check the file in. |

## Storage recommendations

- Store the Android `upload-keystore.jks` and `android/key.properties` in a password manager (1Password, Bitwarden) AND back up to a second offline location (encrypted USB or printed BIP-39 of the password). The upload key is permanent — losing it is a multi-week recovery process.
- Store the Apple Distribution `.p12` export in the same password manager. Re-issuance is fast (~10 min via Apple Developer portal) so backup is less critical, but exporting from Keychain on cert generation day still saves you a re-issue.

# Troubleshooting

## Android

- **Gradle: `> Property 'storeFile' not found` / `Missing: storeFile`** — `android/key.properties` is missing or fields are blank. Re-copy `android/key.properties.template`, fill in values, ensure path to keystore resolves from the project root.
- **Play Console: `Your Android App Bundle is signed with the wrong key. … Your app bundle is expected to be signed with the certificate with fingerprint: SHA1: …`** — the upload key registered in Play does not match the key in your AAB. Verify with `apksigner verify --print-certs <aab>` and compare to **Play Console → Setup → App integrity → Upload key certificate**. If you have the wrong keystore locally, restore the correct `upload-keystore.jks` from backup. If the keystore is truly lost, request a Play upload-key reset via Play Console help.
- **Play Console: `Signature does not match the previously installed version`** — only happens when sideloading; not relevant to Play distribution. For sideload testing, fully uninstall the prior version first.
- **`./gradlew assembleRelease` fails on CI but works locally** — confirm CI populates `android/key.properties` from a secret store before the Gradle invocation; CI must NOT rely on a checked-in file (the template is not a valid key file).

## iOS

- **Xcode: `No profiles for 'com.chicademy.mitoosa' were found`** — sign in to the right Apple Developer account in Xcode (Settings → Accounts), confirm the team is selected in Signing & Capabilities, then click **Try Again**. If you switched teams, also bump the bundle id or claim it under the new team in the Developer portal.
- **App Store Connect: `Invalid Binary` after upload** — open the email Apple sends for the specific reason. Common causes: missing `NSPhotoLibraryUsageDescription` in `Info.plist`, ITMS-90683 missing usage strings, attempting to upload a Debug-signed archive (re-archive in Release).
- **Archive succeeds but `Distribute App` is greyed out** — the archive was built for the iOS Simulator, not a device. Reset destination to **Any iOS Device (arm64)** and re-archive.
- **`Code Signing Error: Provisioning profile … doesn't include the currently selected device`** — only affects Debug builds on physical devices; not relevant to App Store distribution. Either add the device UDID via Apple Developer portal or switch to a simulator.
