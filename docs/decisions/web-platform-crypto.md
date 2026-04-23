# Decision: Web Platform Encryption Storage

**Status:** Decided — Accept for v1, revisit before web public launch  
**Date:** 2026-04-22  
**Decider:** Product + Engineering

---

## Context

miToosa uses [Hive](https://pub.dev/packages/hive) with AES encryption for all player data at rest. The encryption key is generated once and stored in platform-specific secure storage via `flutter_secure_storage`:

| Platform | Key storage |
|----------|-------------|
| iOS | iOS Keychain |
| Android | Android Keystore |
| **Web** | **`localStorage` (plaintext)** |

On web, `flutter_secure_storage` has no access to a hardware-backed keystore. It falls back to writing the encryption key in plaintext to browser `localStorage`. This means:

- The Hive encryption key is readable by any JavaScript running on the same origin.
- XSS attacks could exfiltrate the key, making the "encrypted" Hive box readable.
- The data is not encrypted at rest in any meaningful sense on web.

This is not a regression introduced by any recent change — it is a documented limitation of `flutter_secure_storage` on web and is acknowledged in the Aetheric Pulse redesign plan (`docs/plan.md`, "Web secure storage" further considerations).

---

## Options Considered

### Option A — Accept for v1; document the caveat (chosen)

Web is not a primary shipping target for v1. The playtest uses the web build for convenience (no install friction), but the player data at risk is:
- Anonymous UUID player ID
- Local game progress (XP, streaks, stars)
- No PII, no payment data, no authentication tokens

The risk profile is low: there is no attacker motivation to extract puzzle game progress from a local browser session. The caveat is documented here and must be re-evaluated before any web public launch that markets the product as "secure" or "private."

**Acceptance criteria:**
- [ ] This decision doc exists and is linked from `RELEASE-GATES.md`.
- [ ] No marketing copy claims data is "encrypted" or "secure" for the web platform.
- [ ] The web build's privacy/terms (when added) omits encryption claims.

### Option B — Web-specific encryption shim (deferred)

Implement a server-side key endpoint: on web, the app fetches the Hive encryption key from a secure HTTPS endpoint (authenticated by the anonymous player UUID) rather than reading it from `localStorage`. The key is never stored client-side.

**Why deferred:** Requires backend infrastructure (does not exist yet), adds a network dependency to app startup, and is disproportionate to the current risk profile. Scope after the backend service (referral attribution, leaderboard) is built.

### Option C — Disable encryption on web only

Detect `kIsWeb` at initialization and skip Hive encryption entirely, storing data in plaintext.

**Why rejected:** Functionally equivalent to Option A but loses the abstraction. If encryption is added to web later, data migration is needed. Option A is cleaner — it maintains the same code path, just with a weaker key storage backing.

---

## Decision

**Option A: accept the current behavior for v1.**

The web build is used for playtest access only, not as a production-grade secure storage environment. No marketing copy should claim encryption for the web platform. Before any public web launch that targets retention or monetization, revisit Option B.

---

## Revisit Trigger

Re-open this decision when **any** of the following are true:

- Web becomes a primary supported platform (alongside iOS/Android).
- The app stores PII, payment data, or any credential beyond the anonymous UUID.
- Marketing copy describes the product as "secure" or "private" without platform qualification.
- A backend service exists that can serve as a key endpoint (makes Option B low-cost).

---

## References

- `lib/data/hive_persistence_provider.dart` — encryption key generation and storage
- `docs/plan.md` — Aetheric Pulse redesign, "Web secure storage" further consideration
- `flutter_secure_storage` pub.dev: web platform limitations section
