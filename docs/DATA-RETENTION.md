# Data Retention Policy — miToosa

**Last Updated:** April 17, 2026

---

## Overview

miToosa is an offline-only application. All user data is stored locally on the device. No data is transmitted to any server. This document describes what data is stored, where, how long it is retained, and how to delete it.

---

## Data Inventory

### Encrypted Stores (AES-256 via platform keychain)

| Hive Box | Contents | Retention | Max Size |
|----------|----------|-----------|----------|
| `player_progress_box` | XP, coins, streaks, stars, hearts, diamonds, difficulty mode, adaptive history, tutorial state, share date | Indefinite (until app uninstall or user reset) | 1 record per player |

### Unencrypted Stores

| Hive Box | Contents | Retention | Max Size |
|----------|----------|-----------|----------|
| `telemetry_event_box` | Session start/end events with timestamps and duration | Rolling window: oldest events pruned when count exceeds 500 | 500 events |

### Platform Keychain (iOS Keychain / Android Keystore)

| Key | Contents | Retention |
|-----|----------|-----------|
| `mitoosa_active_player_id` | Random UUID v4 (not personally identifiable) | Until app uninstall or user-initiated reset |
| `hive_encryption_key_v1` | AES-256 encryption key for Hive | Until app uninstall |
| `hive_integrity_key_v1` | HMAC-SHA256 key for save integrity | Until app uninstall |

---

## Deletion

### Automatic
- **Telemetry events**: Oldest events are automatically deleted when the 500-event cap is reached (`HiveTelemetryRepository._pruneIfNeeded()`).

### User-Initiated
- **In-app reset**: The settings screen allows resetting player progress, which regenerates the player ID and clears progress data.
- **App uninstall**: Removes all local Hive databases, shared preferences, and (on most platforms) keychain entries.
- **Clear app data**: Via device Settings → Apps → miToosa → Clear Data.

### No Server-Side Data
There is no server-side data to delete. No GDPR data subject access requests (DSARs) apply because no personal data leaves the device.

---

## GDPR Compliance Notes

| GDPR Requirement | miToosa Status |
|------------------|----------------|
| Lawful basis for processing | Not applicable — no personal data is collected or processed remotely |
| Right to access | All data is already on the user's device |
| Right to erasure | Uninstall or clear app data; no remote records exist |
| Right to portability | Not applicable — no remote data to export |
| Data Protection Officer | Not required — no systematic processing of personal data |
| Data breach notification | Not applicable — no data transmitted or stored remotely |

---

## Future Considerations

If cloud analytics or crash reporting is added in a future version (v1.3+):
1. This policy must be updated before the feature ships
2. A consent mechanism (opt-in or opt-out) will be required
3. A server-side data retention schedule must be defined
4. Privacy policy version will be bumped and users notified
