# BL-01+02 — Manual release signing guides

Step-by-step runbooks for the five **deferred human tasks** on story **BL-01+02** (Platform Release Signing). Code scaffolding is already on `main`; these guides complete the handoff so you can ship to **TestFlight** and **Play Internal testing**.

| Task | Guide | What you get when done |
|------|--------|-------------------------|
| **3.2** | [Xcode automatic signing](BL-01-02-3.2-xcode-automatic-signing.md) | Debug + Release profiles; Archive builds without signing errors |
| **5.1** | [Android keystore (`keytool`)](BL-01-02-5.1-android-keystore-keytool.md) | Upload keystore + populated `android/key.properties` |
| **5.2** | [Apple Distribution + App Store Connect](BL-01-02-5.2-apple-distribution-app-store-connect.md) | Distribution identity in Keychain; app record for `dev.atoosa.mitoosa` |
| **5.3** | [Play Console upload key](BL-01-02-5.3-play-console-upload-key.md) | SHA-256 registered; Play App Signing enabled |
| **5.4** | [E2E TestFlight + Play Internal](BL-01-02-5.4-e2e-testflight-play-internal.md) | Installable builds on physical devices from both stores |

**Overview runbook (shorter):** [docs/RELEASE-SIGNING.md](../RELEASE-SIGNING.md)  
**Spec / ACs:** [docs/archived/spec-BL-01-BL-02-platform-signing.md](../archived/spec-BL-01-BL-02-platform-signing.md)  
**Test checkpoints:** [docs/AgToosa_TestPlan-BL-01-BL-02.md](../AgToosa_TestPlan-BL-01-BL-02.md) (T-007, T-008, T-009)

---

## Recommended order

You can parallelize **5.1** and **5.2** if two people (or two accounts) are available. Otherwise:

1. **5.1** — Android upload keystore (blocks **5.3** and Android half of **5.4**)
2. **5.2** — Apple Distribution cert + App Store Connect app (blocks **3.2** iOS Archive and iOS half of **5.4**)
3. **3.2** — Xcode automatic signing (needs Apple Developer access from **5.2**)
4. **5.3** — Register upload-key fingerprint in Play Console (needs **5.1**)
5. **5.4** — Upload and install from TestFlight + Play Internal Test (needs all above)

---

## Prerequisites (all tasks)

| Requirement | iOS | Android |
|-------------|-----|---------|
| Paid developer account | [Apple Developer Program](https://developer.apple.com/programs/) (team `TYK6BBNDW5` or your fork’s team) | [Google Play Console](https://play.google.com/console) developer account |
| Hardware / OS | macOS with Xcode (latest stable) | Any OS with JDK (`keytool` ships with JDK) |
| App identifiers | Bundle ID `dev.atoosa.mitoosa` | Application ID `com.chicademy.mitoosa` (same as `android/app/build.gradle.kts`; Android launch is deferred) |
| Repo state | `flutter pub get` · `cd ios && pod install` | `android/key.properties.template` present; **do not** commit real `android/key.properties` |

---

## When BL-01+02 is complete

Check off in [docs/Master-Plan.md](../Master-Plan.md) tasks **3.2**, **5.1**, **5.2**, **5.3**, **5.4**, and move story **BL-01+02** from **Awaiting Manual** to **Done** after **5.4** passes on real devices.

---

## Security reminders

- Never commit `*.jks`, `*.keystore`, `android/key.properties`, `*.p12`, or `*.mobileprovision`.
- The Android **upload key is permanent** — back up the keystore and passwords in a password manager and offline storage.
- Apple Distribution certificates expire yearly; renew before the next release season.
