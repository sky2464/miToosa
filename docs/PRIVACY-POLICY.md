<!-- HUMAN-ACTION-REQUIRED: Replace contact info placeholders before publication -->

# Privacy Policy — miToosa

**Last Updated:** April 17, 2026

---

## Summary

miToosa is an offline puzzle game. **All data stays on your device.** We do not collect, transmit, or share any personal information.

---

## 1. Information We Collect

miToosa does **not** collect personal information. The app stores the following data locally on your device only:

| Data | Purpose | Storage |
|------|---------|---------|
| Random player ID (UUID) | Identify save data on-device | Platform keychain (encrypted) |
| Game progress (XP, coins, stars, streaks, hearts, diamonds, difficulty settings, tutorial state) | Track your gameplay progress | Hive database (AES-256 encrypted) |
| Session timestamps (start/end, duration) | Local telemetry for future analytics readiness | Hive database (unencrypted, no PII) |
| Difficulty preferences | Adaptive difficulty tuning | Hive database (encrypted) |

### What We Do NOT Collect

- No names, emails, or real identities
- No location data
- No device identifiers (IDFA, GAID, etc.)
- No crash reports (not yet integrated)
- No analytics sent to any server
- No advertising data
- No cookies or tracking pixels

---

## 2. Data Transmission

**None.** miToosa does not make any network requests. All data is processed and stored locally on your device.

---

## 3. Data Sharing

We do not share data with any third parties because we do not collect any data from your device.

---

## 4. Data Retention

- **Game progress**: Stored indefinitely on your device until you uninstall the app or clear app data.
- **Telemetry events**: Capped at 500 events; oldest events are automatically pruned.
- **Deletion**: Uninstalling the app removes all stored data. You can also reset your progress within the app's settings.

---

## 5. Children's Privacy

miToosa does not collect any personal information from anyone, including children under 13. The app is suitable for all ages.

---

## 6. Security

Local data is protected using:
- **AES-256 encryption** for game progress (Hive encrypted box)
- **HMAC integrity hashing** to detect save data tampering
- **Platform keychain** (iOS Keychain / Android Keystore) for encryption keys

---

## 7. Changes to This Policy

We may update this Privacy Policy from time to time. Changes will be noted by updating the "Last Updated" date above.

---

## 8. Contact

If you have questions about this Privacy Policy, contact us at:

**Email:** [TODO: Add contact email]  
**GitHub:** [TODO: Add repository URL]
