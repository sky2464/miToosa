
# Privacy Policy — miToosa

**Last Updated:** July 27, 2026

---

## Summary

miToosa is a **local-first** puzzle game. Game progress, preferences, and anonymous session telemetry are stored on your device. When the release build is launched with `FIREBASE_ENABLED=true`, the app may send **anonymous usage analytics** to Firebase and Google Analytics unless you turn analytics off in Settings. We do not collect names, email addresses, or account credentials, and we do not use ad targeting.

---

## 1. Information We Collect

### Stored locally on your device

| Data | Purpose | Storage |
|------|---------|---------|
| Random player ID (UUID) | Identify save data on-device | Platform keychain (encrypted) |
| Game progress (XP, coins, stars, streaks, hearts, diamonds, difficulty settings, tutorial state) | Track your gameplay progress | Hive database (AES-256 encrypted) |
| Session timestamps (start/end, duration) | Local telemetry and analytics readiness | Hive database |
| Difficulty preferences | Adaptive difficulty tuning | Hive database (encrypted) |

### Sent when Firebase analytics is enabled (`FIREBASE_ENABLED=true`)

When analytics is enabled in a release or TestFlight build, Firebase and Google Analytics may receive **anonymous, non-identifying** usage events such as app launch and session activity. These events are not linked to your real name, email, or Apple/Google account. You can disable anonymous analytics anytime in **Settings → Anonymous analytics**.

### What We Do NOT Collect

- No names, emails, or real identities
- No location data
- No advertising ID (IDFA) collection for ad targeting
- No user-generated content or chat
- No cookies or web tracking pixels inside the app
- No leaderboard accounts or social graph in the v1.5 launch build

---

## 2. Data Transmission

**Default / development builds:** miToosa runs local-first. Progress stays on device and analytics uses a no-op sink unless `FIREBASE_ENABLED=true` is set at build time.

**Release builds with `FIREBASE_ENABLED=true`:** The app initializes Firebase and may transmit anonymous analytics events to Google Firebase / Google Analytics infrastructure. Game save data remains on device; analytics events do not include your puzzle answers or personal profile.

---

## 3. Data Sharing

- **Local data:** Not shared with third parties; it remains on your device until you uninstall or reset progress.
- **Analytics data (when enabled):** Processed by Google Firebase / Google Analytics under their terms. See [Google's Privacy Policy](https://policies.google.com/privacy) for how Google handles analytics data.

We do not sell personal information.

---

## 4. Data Retention

- **Game progress:** Stored on your device until you uninstall the app or clear app data.
- **Telemetry events:** Capped at 500 events locally; oldest events are automatically pruned.
- **Analytics (when enabled):** Retained per Firebase / Google Analytics project settings in the developer console.
- **Deletion:** Uninstalling the app removes on-device data. You can also reset progress in Settings or turn off anonymous analytics in Settings.

---

## 5. Children's Privacy

miToosa does not require account sign-up and does not knowingly collect personal information from children. Parents or guardians with questions may contact us using the channels in [Support](SUPPORT.md).

---

## 6. Security

Local data is protected using:

- **AES-256 encryption** for game progress (Hive encrypted box)
- **HMAC integrity hashing** to detect save data tampering
- **Platform keychain** (iOS Keychain / Android Keystore) for encryption keys

---

## 7. Changes to This Policy

We may update this Privacy Policy from time to time. Changes will be noted by updating the "Last Updated" date above. The in-repo copy at `docs/PRIVACY-POLICY.md` is the source of truth until a public URL is published for App Store Connect.

---

## 8. Contact

If you have questions about this Privacy Policy, contact us at:

**Email:** sky2464@gmail.com  
**GitHub:** [https://github.com/sky2464/miToosa](https://github.com/sky2464/miToosa)  
**Support:** [docs/SUPPORT.md](SUPPORT.md)
