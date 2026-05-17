# `firebase/` — Templates & Configuration (Pre-Deploy)

This directory holds Firebase configuration artifacts authored **ahead
of the live Firebase project**. Nothing here is deployed today. It is
the output of the BL-04 spec's threat-modelling pass and exists to
de-risk the BL-04 Backend Leaderboard story so that the Wave-1 work
can be skipped entirely when the playtest gate clears and BL-03
(Firebase production project setup) is ✅ Done.

## Files

### `firestore.rules.template`

The Firestore Security Rules that will govern the
`leaderboard_entries`, `xp_audit_log`, `rate_limits`,
`display_names`, and `leaderboard_meta` collections defined in
[spec-BL-04 §2.1](../docs/archived/spec-BL-04.md).

Enforces:

- **AC-005** — App Check token required on every read/write.
- **AC-006** — Writer's `auth.uid` must equal the document's
  `playerId` (and equal the doc id).
- **AC-008** — 5-second min-interval throttle per `playerId`.
- **AC-007** — Clients cannot set `displayName`; server-side Cloud
  Function mints `Pilot_NNNN` on first write.
- **Hard ceiling** — `score` must be in `[0, 120000]` (kept in sync
  with `kMaxLeaderboardScore` in
  [`lib/data/leaderboard_entry.dart`](../lib/data/leaderboard_entry.dart)).

Hard ceiling rationale: the per-player legitimate ceiling is derived
from the append-only `xp_audit_log` by the Cloud Function (AC-004) —
Security Rules cannot atomically aggregate a subcollection, so the
ceiling here is the project-wide hard cap. The Function is the source
of truth for the per-player clamp.

## Deploy process (when BL-03 lands)

This is the runbook for the engineer (or `cloudflare:wrangler`-style
agent) promoting these templates to live deploy:

1. **Prerequisites:**
   - BL-03 ✅ Done (Firebase production project provisioned, App Check
     enforcement on, Crashlytics + GA4 linked, `firebase` CLI auth'd
     with appropriate service account).
   - `flutter pub get` deps include `cloud_firestore`,
     `firebase_auth`, `firebase_app_check` (added by BL-03 or by
     BL-04 Wave 3).

2. **Promote rules:**
   ```bash
   cp firebase/firestore.rules.template firebase/firestore.rules
   ```
   Review the diff against any existing rules in the Firebase project
   (`firebase deploy --dry-run --only firestore:rules`).

3. **Test locally with the Firestore Emulator:**
   ```bash
   firebase emulators:start --only firestore
   # In a separate shell, run the rules unit tests (added in
   # BL-04 Wave 1, task 1.3) against the emulator.
   ```
   The rules unit tests (firebase-rules-unit-testing) cover the
   write-impersonation, missing-AppCheck, burst-write scenarios called
   out in the spec's STRIDE table.

4. **Deploy:**
   ```bash
   firebase deploy --only firestore:rules --project <prod-project-id>
   ```

5. **Verify in production:**
   - Use the Firebase Console > Firestore > Rules > Playground to
     simulate the three negative cases.
   - Check Cloud Logging for `permission-denied` events during the
     first hour of traffic — expect a small baseline from legitimate
     throttle hits.

6. **Add `firestore.indexes.json`** alongside `firestore.rules` —
   composite index on `(week ASC, score DESC)` is required by the
   top-N query (AC-002). This file is **not** in the pre-gate
   foundation; ship it during Wave 1 of the BL-04 build (task 1.2).

## Status — pre-gate

| Artifact | Status |
|---|---|
| `firestore.rules.template` | ✅ Authored (this commit) |
| `firestore.rules` (live) | ⏸️ Blocked on BL-03 |
| `firestore.indexes.json` | ⏸️ Wave-1 task 1.2 of BL-04 build |
| Cloud Functions source | ⏸️ Wave-1+ tasks 6.2/6.3/6.4 of BL-04 build |
| Rules unit tests | ⏸️ Wave-2 task 1.3 of BL-04 build |
