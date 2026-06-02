# Spec: BL-04 — Backend Leaderboard (Real-Time)

> **Story ID:** BL-04
> **Epic:** EP-03 — Retention & Monetization Expansion
> **Status:** ⬜ Backlog (gated)
> **Estimate:** L
> **Spec created:** 2026-05-16
> **Design review:** 2026-06-01 (`/plan-design-review` — §2.4–2.9, AC-013–AC-017)
> **Gate:** D1 ≥ 40% **AND** social-motivation signal from S1-04 playtest must be confirmed before `/agtoosa-build` starts. Spec authored ahead of the gate as a de-risking tech-design exercise.
> **Hard dependency:** **BL-03** (Firebase production project setup, App Check enforcement, Crashlytics, GA4) must be ✅ Done before this story enters Active Cycle. BL-04 cannot start without a provisioned Firebase project.

---

## 0. Context (Findings)

A demo leaderboard UI already exists at `lib/features/main_app/leaderboard_screen.dart` (podium + segmented control: `global` / `friends` / `local`, with a pinned `YOU` row and "XP to top 3" delta). The footer reads "_Leaderboard preview · live in v1.3_" — making this the natural live-backend hookup. The Riverpod `playerProgressProvider` already exposes `totalXP`, which is the leaderboard score source of truth. Firebase SDKs are wired (`firebase_core`, `firebase_analytics`, `firebase_app_check`) but no Firestore/RTDB integration exists yet — that's the gap BL-04 closes.

The six AgToosa forcing questions are answered in-line below from codebase + Firebase best-practice research (no live Q&A needed; this is a tech-design pass before the playtest gate clears):

**Q1 — Status quo.** Today the leaderboard displays a hard-coded demo cohort with the local player's XP slotted at rank 4. Nothing breaks if we change it: any rendering contract is internal to one file (`_Person`, `_LeaderRow`, `_Podium`). The new backend simply replaces `_demo` with a `StreamProvider<List<LeaderboardEntry>>`. The existing UI shape (top-3 podium, pinned YOU row, segmented control) is the contract we must preserve.

**Q2 — Narrowest scope (v1).** Global, weekly, top-100 by `totalXP`, plus the local player's rank-window (player ± 5 neighbours). Drop `friends` and `local` scopes from v1 (degrade gracefully to a "Coming soon" state for those tabs). Drop avatars/frames from the backend doc — the UI already hydrates them locally from the avatar id. v1 keeps the doc schema minimal: `{ playerId, displayName, score, week, updatedAt }`.

**Q3 — Urgency signal.** Gated. No player is blocked today. We pre-spec because the dependency chain (BL-03 Firebase project → BL-04 backend → marketing of social proof) is long, and the playtest gate decides whether to start in days, not months. Workaround today is the demo data, which is fine.

**Q4 — 10-star version.** Real-time deltas via Firestore snapshot listeners (✅ in v1), per-friend cohorts via the social graph (deferred — needs an identity story), seasonal/historical archives kept in `leaderboard_archives/{weekId}` for "your best-ever week" surfacing, animated rank-change toasts, anti-cheat ML scoring on score-jump anomalies. v1 ships only the snapshot listener and weekly bucketing — everything else is post-launch.

**Q5 — Top failure modes.**
  1. **Client lies about score** — anonymous-auth client posts inflated XP and tops the board (Tampering — see threat model).
  2. **Hot-key write contention / quota burn** — every level completion writes to the same doc; a viral run = a cost spike (Denial of Service / billing risk).
  3. **Personally-identifying display names** — players use real names or emails as `displayName` and leak PII to a public global board (Information Disclosure / privacy).

**Q6 — Security surface (CRITICAL).** This crosses a major trust boundary for the first time in the codebase:
  - **Anonymous-write protection:** Use **Firebase Anonymous Authentication** (free tier 50k MAU per BL-03 research) to bind every Firestore write to a server-issued UID. Security Rules enforce `request.auth.uid == resource.data.playerId` — clients cannot impersonate.
  - **Server-side score validation:** A Cloud Function (`onLeaderboardWrite`, Firestore trigger on `leaderboard_entries/{playerId}`) recomputes the legitimacy bound — score must equal `min(client_score, server_max_xp_for_playerId)` derived from an append-only `xp_audit_log/{playerId}/events/{eventId}` collection that records every XP grant. Writes that exceed the server-known bound are clamped (not rejected — clamping survives clock skew and is observable).
  - **Rate-limiting:** Security Rules enforce a `updatedAt > resource.data.updatedAt + duration.value(5, 's')` minimum-interval on writes (5 s per playerId). Cloud Function additionally tracks a sliding 60-second window per UID via `rate_limits/{uid}` and rejects bursts > 20 writes/min.
  - **App Check:** All Firestore reads + writes require App Check tokens (Play Integrity on Android, DeviceCheck/App Attest on iOS, reCAPTCHA Enterprise on Web). Enforced by BL-03; BL-04 verifies enforcement is on before going live.
  - **Display name sanitization:** `displayName` is server-generated as `Pilot_NNNN` (4-digit zero-padded from a `displayNames/{uid}` counter). v1 disallows user-chosen names entirely — pre-empts profanity, PII, and impersonation.
  - **Repudiation:** All writes are observable in `xp_audit_log` (append-only, client write disabled — only Cloud Functions can write) and in Cloud Logging for the trigger function.
  - **Information disclosure:** Read rules expose only `{ rank, displayName, score, updatedAt }` projection — `playerId` is hashed (SHA-256 of UID + project-secret pepper) before exposure to other clients; the player's own row exposes their real UID for self-identification.
  - **DoS / cost:** Daily Firestore budget alert at $5/day; if exceeded, the Cloud Function flips a Remote Config flag `leaderboard_writes_enabled=false` and clients enter read-only/cached mode.

### Backend choice (trade-off documented)

| Option | Pros | Cons | Verdict |
|--------|------|------|---------|
| **Cloud Firestore** ✅ | Existing Firebase deps (BL-03), declarative Security Rules, native snapshot listeners, free tier covers v1 traffic, `where + orderBy + limit` queries fit our access pattern, Cloud Functions triggers built-in. | Per-doc read pricing; aggregation queries (`count()`) cost extra; cold-start on Functions. | **Choose for v1.** |
| Realtime Database (RTDB) | Cheaper for high-frequency writes, lower latency for true real-time. | No native composite queries (must denormalize for `friends`/`local`), JSON-tree-only schema is brittle, rules language less expressive. | Rejected — query model doesn't fit "top-N by score this week". |
| Cloudflare Workers + D1 | Fully custom, edge-distributed, predictable pricing, OWASP-friendly. | New auth surface to build, no native client SDK for snapshot listeners (we'd poll or build SSE), 2× the platform surface to operate. | Rejected for v1 — too much net-new infra. Reconsider at scale if Firestore costs become punitive. |
| Custom backend (Cloud Run + Postgres) | Maximum flexibility. | All of CF+D1's cons plus operational overhead. | Rejected — premature. |

**Decision:** Firestore for v1. **Open question deferred to `/agtoosa-build` kickoff:** if BL-03 reveals Firestore is unavailable in target regions or App Check isn't viable on a deployment target, revisit RTDB.

---

## 1. Requirements

### 1.1 User Stories

**As a** competitive player, **I want** to see how my weekly XP ranks against all other players in real time **so that** I am motivated to play more sessions this week.

**As a** new player, **I want** to see my rank update immediately after finishing a level **so that** I feel the connection between effort and standing.

**As a** privacy-conscious player, **I want** to appear on the leaderboard under an auto-generated pseudonym **so that** I do not leak my identity by playing.

**As a** product owner, **I want** server-side validation of every score submission **so that** a single bad actor cannot poison the social-proof signal we built the entire engagement loop on.

### 1.2 Acceptance Criteria (EARS)

| ID | EARS | Priority |
|----|------|----------|
| AC-001 | WHEN the player completes a level and gains XP THE SYSTEM SHALL submit a leaderboard write within 5 seconds containing `{playerId, score=totalXP, week=ISO-week-of-now-UTC, updatedAt}` | Must |
| AC-002 | WHEN the leaderboard screen is opened THE SYSTEM SHALL subscribe to a Firestore snapshot of the top 100 entries for the current week ordered by `score` descending and stream updates to the UI | Must |
| AC-003 | WHEN the leaderboard screen renders THE SYSTEM SHALL also fetch the local player's neighbour-window (player rank ± 5) and pin a YOU row even if the player is outside the top 100 | Must |
| AC-004 | IF a client write contains a `score` exceeding the server-known XP audit-log total for that playerId THEN the Cloud Function trigger SHALL clamp the stored score to the server-known total and emit a `leaderboard_clamp` telemetry event | Must |
| AC-005 | WHEN any Firestore read or write is attempted without a valid App Check token THE SYSTEM SHALL reject the request at the Security Rules layer | Must |
| AC-006 | WHEN a client attempts to write a leaderboard entry where `request.auth.uid != resource.data.playerId` THE SYSTEM SHALL reject the write at the Security Rules layer | Must |
| AC-007 | WHILE a player is anonymous (no account) WHEN they first write to the leaderboard THE SYSTEM SHALL auto-generate a pseudonym `Pilot_NNNN` (4-digit zero-padded) and persist it as the player's `displayName` | Must |
| AC-008 | WHEN a client submits leaderboard writes faster than 1 per 5 seconds per playerId THE SYSTEM SHALL reject the burst writes at the Security Rules layer | Must |
| AC-009 | WHEN the `leaderboard_writes_enabled` Remote Config flag is `false` THE SYSTEM SHALL skip the client write call and surface the cached/last-known leaderboard from local memory | Should |
| AC-010 | WHILE the device is offline WHEN the player completes a level THE SYSTEM SHALL queue the leaderboard write via Firestore offline persistence and flush it on reconnect | Should |
| AC-011 | WHEN the segmented control is set to `friends` or `local` in v1 THE SYSTEM SHALL display a "Coming soon" empty state without crashing or making a backend call | Should |
| AC-012 | IF the player has opted out of leaderboard participation THEN WHEN a level completes THE SYSTEM SHALL NOT submit a write and SHALL omit the player from any displayed rankings | Could |
| AC-013 | WHEN the leaderboard screen is opened WHILE Firestore snapshot data has not yet arrived THE SYSTEM SHALL show in-place skeleton placeholders for the podium and at least three list rows (not a full-screen-only spinner) | Must |
| AC-014 | WHEN a Firestore read fails or App Check blocks leaderboard reads THE SYSTEM SHALL show a friendly, actionable error banner (suggest retry) consistent with `docs/Context/product-guidelines.md` error tone | Must |
| AC-015 | WHEN the neighbour-window stream resolves THE SYSTEM SHALL display the local player's current rank and "XP to top 3" delta in the header from live data (not hardcoded demo rank) | Must |
| AC-016 | WHEN `leaderboard_writes_enabled` is `false` THE SYSTEM SHALL render the last cached leaderboard AND show a subtle non-blocking "Updates paused" chip | Should |
| AC-017 | WHEN the current ISO week has fewer than three ranked players THE SYSTEM SHALL render the podium with available ranks only (no crash, no empty podium crash) | Must |

### 1.3 Out of Scope

- **`friends` and `local` scopes** — require a social graph / geolocation story (defer to BL-05+).
- **Custom display names / avatars uploaded to backend** — v1 uses server-generated `Pilot_NNNN` only; avatars are still client-side based on local `avatar` id.
- **Historical / seasonal archives** — `leaderboard_archives/{weekId}` collection is planned but not in v1 build.
- **Anti-cheat ML** — v1 ships only the deterministic XP audit-log clamp.
- **Leaderboard pagination beyond top-100 + neighbour-window** — no "load more" affordance.
- **Cross-week leaderboards (all-time)** — v1 is weekly-only, ISO week (Mon 00:00 UTC → Sun 23:59 UTC).
- **Identity migration on account linking** — when BL-XX adds Firebase Auth account linking, the anonymous UID transfer story is separately specced.
- **Modifying `PlayerProgress` schema** — v1 adds a leaderboard `OptOut` preference via a *new* Hive box (`leaderboard_prefs`), NOT a `PlayerProgress` schema bump, to avoid touching the v7 adapter.

---

## 2. Design

### 2.1 Architecture Blueprint

```
Files to create (Flutter client — lib/):
  - lib/data/models/leaderboard_entry.dart        — immutable model + fromFirestore/toFirestore
  - lib/data/leaderboard_repository.dart          — Firestore read/write, snapshot streams, offline queue
  - lib/features/leaderboard/leaderboard_provider.dart  — Riverpod StreamProvider + opt-out StateProvider

Files to change (Flutter client — lib/):
  - lib/features/main_app/leaderboard_screen.dart — replace _demo with provider.watch; preserve podium / YOU-row / segmented-control UX

Files to create (server — cloud_functions/):
  - cloud_functions/package.json                  — Functions runtime deps (firebase-functions, firebase-admin)
  - cloud_functions/src/index.ts                  — exports: onLeaderboardWrite, onXpGrantAuditAppend, weeklyResetScheduled
  - cloud_functions/src/score_validator.ts        — pure: clamp(clientScore, serverMax) → {clampedScore, didClamp}
  - cloud_functions/src/rate_limiter.ts           — pure: sliding-window check against rate_limits/{uid}
  - cloud_functions/src/display_name_minter.ts    — pure: mints next Pilot_NNNN from atomic counter

Files to create (rules — firestore/):
  - firestore/firestore.rules                     — match leaderboard_entries, xp_audit_log, rate_limits, display_names
  - firestore/firestore.indexes.json              — composite index on (week ASC, score DESC)

Files to create (tests — test/, cloud_functions/test/):
  - test/data/leaderboard_repository_test.dart    — Riverpod + fake Firestore tests
  - test/features/leaderboard/leaderboard_provider_test.dart
  - test/features/main_app/leaderboard_screen_test.dart  — golden + widget tests against StreamProvider
  - cloud_functions/test/score_validator.test.ts
  - cloud_functions/test/rate_limiter.test.ts
  - cloud_functions/test/display_name_minter.test.ts

Key interfaces:
  - LeaderboardRepository
      .submitScore(playerId: String, totalXp: int) → Future<void>
      .topNStream({week: String, limit: int}) → Stream<List<LeaderboardEntry>>
      .neighbourWindowStream({playerId, window: int}) → Stream<List<LeaderboardEntry>>
      .setOptOut(bool) → Future<void>
  - leaderboardTopNProvider = StreamProvider.family<List<LeaderboardEntry>, LeaderboardScope>
  - leaderboardNeighboursProvider = StreamProvider<List<LeaderboardEntry>>
  - leaderboardOptOutProvider = StateNotifierProvider<LeaderboardOptOutNotifier, bool>

Firestore collections:
  - leaderboard_entries/{playerId}                — doc: { displayName, score, week, updatedAt, hashedId }
  - xp_audit_log/{playerId}/events/{eventId}      — append-only, server-only-write, client-read-own
  - rate_limits/{uid}                             — sliding window tracker (server-only)
  - display_names/{uid}                           — { name: "Pilot_0042" }, server-only-write
  - leaderboard_meta/counter                      — atomic counter for Pilot_NNNN minting

File-size note: every planned file stays well under 500 LOC. `leaderboard_repository.dart` is the largest expected (~250 LOC); `leaderboard_screen.dart` net change is a delete (-50 LOC of demo data) + add (~30 LOC of provider wiring).
```

### 2.2 Data Flow

1. Player completes a level → `gameplayViewModel` calls `progressionEngine.computeReward(...)` → `PlayerProgress.totalXP` is mutated and persisted to Hive.
2. The same `gameplayViewModel` invokes `LeaderboardRepository.submitScore(playerId, totalXP)`.
3. Repository checks `leaderboardOptOutProvider`. If opted-out, return early (AC-012).
4. Repository checks `leaderboard_writes_enabled` Remote Config flag (AC-009). If false, return early.
5. Repository builds a `LeaderboardEntry` doc with `week = ISO-week-of-now-UTC`, `updatedAt = serverTimestamp()`, `score = totalXP`, and writes to `leaderboard_entries/{playerId}` (idempotent — same doc id per player).
6. Firestore Security Rules check: App Check token valid (AC-005), `request.auth.uid == request.resource.data.playerId` (AC-006), 5-second min-interval since last `updatedAt` (AC-008). On failure, the write is rejected client-side without server cost.
7. On accepted write, Cloud Function `onLeaderboardWrite` fires:
   a. Reads `xp_audit_log/{playerId}/events/*` and sums to `serverMaxXp`.
   b. `clampedScore = min(request.score, serverMaxXp)`.
   c. If `clampedScore < request.score`, overwrites the doc with `clampedScore` and emits `leaderboard_clamp` telemetry (AC-004).
   d. Updates `rate_limits/{uid}` sliding-window counter.
   e. If first-ever write for this UID, calls `display_name_minter.mint(uid)` → atomic increment on `leaderboard_meta/counter`, writes `Pilot_NNNN` to `display_names/{uid}` and back into the leaderboard doc (AC-007).
8. Leaderboard screen on open: `leaderboardTopNProvider` subscribes to a Firestore snapshot query (`where('week', '==', currentWeek).orderBy('score', 'desc').limit(100)`) — AC-002.
9. Same screen: `leaderboardNeighboursProvider` subscribes to a second query for the rank-window around the local player — AC-003.
10. Riverpod fans the streams into the existing podium / YOU-row / list rendering.
11. Offline: Firestore offline persistence queues writes from step 5; on reconnect they flush automatically (AC-010).
12. A scheduled Function (`weeklyResetScheduled`, cron `0 0 * * 1 UTC`) is **not** required for v1 — the `week` field on each doc naturally bucket-isolates rankings. A janitor function (post-v1) will move stale weeks to `leaderboard_archives`.

### 2.3 Threat Model (STRIDE)

| Threat | Category | Mitigation |
|--------|----------|------------|
| Client posts inflated `score` to top the board | Tampering | Cloud Function `onLeaderboardWrite` re-derives max-legal score from append-only `xp_audit_log` and clamps writes (AC-004). Audit log is server-only-write (Security Rules deny client writes). |
| Anonymous client impersonates another `playerId` | Spoofing | Firestore Security Rule: `request.auth.uid == request.resource.data.playerId` (AC-006). App Check (AC-005) gates every request. Anonymous Auth binds UID server-side. |
| Bot farm spams writes to burn Firestore quota | Denial of Service | Security Rule: 5 s min-interval on `updatedAt` per playerId doc (AC-008). Cloud Function sliding-window: 20 writes/min/UID hard reject. App Check rejects non-attested traffic. Daily $5 budget alert → Remote Config kill-switch (AC-009). |
| Bad actor scrapes public board to harvest UIDs / track players cross-app | Information Disclosure | `playerId` is never returned to other clients — only `hashedId = SHA256(uid + project_pepper)`. Display names are server-generated (`Pilot_NNNN`), no PII. The player's own row is the only one with their real UID exposed. |
| Player uses real name / email as displayName and leaks PII publicly | Information Disclosure | v1 disallows user-chosen names entirely — server mints `Pilot_NNNN`. AC-007. |
| Score changes happen but no one can prove who / when | Repudiation | `xp_audit_log` is append-only, server-written, includes `serverTimestamp()`. Cloud Function writes also logged in Cloud Logging with structured payloads. |
| Cloud Function bug elevates a clamped player back to inflated score | Elevation of Privilege | `score_validator.ts` is a pure function with comprehensive tests (test/score_validator.test.ts). Function deploys gated by CI test suite. Function uses `merge: false` write so it cannot accidentally re-apply client values. |
| Compromised CI secret leaks Firebase admin key | Elevation of Privilege | Functions use the default service account (no admin key in CI); deploys via Workload Identity Federation. No service-account JSON in repo. |
| Player below the fold sees zero engagement signal and churns | (out-of-STRIDE — product) | AC-003 neighbour-window keeps the player anchored regardless of absolute rank. |

### 2.4 Screen information hierarchy

**UI classifier:** APP UI (dense data surface, not a marketing landing page).

**Visual scan order (billboard test — user must understand rank in under 3 seconds):**

| Priority | Region | Content | Tokens |
|----------|--------|---------|--------|
| Primary | Header block | Eyebrow (week + reset) → gradient "Leaderboard" title → YOUR rank line (`#N` · XP to top 3) | `AP.eyebrow`, `AP.display` + ShaderMask gradient, `AP.body` / `AP.fg` for rank line |
| Secondary | Scope control | Segmented pill: Global (live) · Friends · Local | Existing `_SegmentedControl` glass pill (`AP.glassFill`, `AP.glassBorder`, `AP.gradPrimary` when active) |
| Tertiary | Body | Podium (ranks 1–3) → pinned YOU row → scrollable ranks 4–100 | `_Podium`, `_LeaderRow` |
| Footer | — | Remove demo footer `Leaderboard preview · live in v1.3`. Optional subtle meta: `Scores update as you play` (`AP.fgMuted`, 10px) | — |

**Layout (single `ListView`, matches current `leaderboard_screen.dart`):**

```
┌─────────────────────────────────────┐
│ WEEKLY · RESETS SUN 23:59 UTC       │  ← eyebrow (AC-015: week aligned to ISO UTC)
│ Leaderboard (gradient title)        │
│ You're ranked #N · X XP to top 3    │  ← dynamic from neighbour stream (AC-015)
├─────────────────────────────────────┤
│ [ GLOBAL | friends | local ]        │  ← segmented control
├─────────────────────────────────────┤
│  (optional chip: Updates paused)    │  ← AC-016 when RC kill-switch
│  (optional chip: Sync when online)  │  ← offline queue hint (AC-010)
├─────────────────────────────────────┤
│         PODIUM 2 · 1 · 3            │
├─────────────────────────────────────┤
│ ▶ YOU row (pinned, highlighted)     │
│   rank 4 … 100 rows                 │
└─────────────────────────────────────┘
```

**Data merge rules (implementer):**

1. `leaderboardTopNProvider` supplies ranks 1–100 for the current `week` (AC-002).
2. `leaderboardNeighboursProvider` supplies the local player's rank and ±5 neighbours (AC-003).
3. Header rank `#N` and `xpToTop3` MUST be computed from neighbour data (or derived rank service), never from `_demo` rank 4 (AC-015).
4. YOU row is always pinned between podium and the scroll list, even when the player is outside the top 100 (AC-003).
5. Row `displayName` comes from Firestore (`Pilot_NNNN` per AC-007). Avatar id and frame remain client-side (hash/mod of local avatar id) — no server avatar upload in v1.

### 2.5 Interaction state matrix

What the player **sees** (not backend behaviour):

| Feature | Loading | Empty | Error | Success | Partial / edge |
|---------|---------|-------|-------|---------|----------------|
| Global top-100 | Skeleton: podium blocks + 3 `_LeaderRow` placeholders (shimmer on `AP.glassFill`) | Centered: **"Be the first this week"** + primary CTA **Play** (routes to next level / home) | Top `GlassCard` banner: **"Couldn't load rankings. Check your connection and try again."** + **Retry** button | Live podium + list | <3 players: podium shows 1–2 columns only; list may be short (AC-017) |
| Neighbour / YOU | YOU row skeleton (same height as `_LeaderRow`) | If unranked (no write yet): header shows **"Play a level to join this week"**; hide XP-to-top-3 | Same error banner as global | Pinned YOU + dynamic `#N` | Outside top 100: YOU still pinned; list excludes duplicate YOU |
| Friends / Local tabs | N/A (no network) | Replace body with **Coming soon** panel (AC-011): icon + **"Friends rankings are on the way"** / **"Local rankings are on the way"** + ghost button **Back to Global** | N/A | N/A | Tab remains tappable; no Firestore call |
| Background submit | N/A | N/A | Silent fail + telemetry | Score streams in | AC-009: cached board + **Updates paused** chip (AC-016) |
| Offline (AC-010) | N/A | N/A | N/A | Normal UI when cache exists | Non-blocking chip: **"Score will sync when you're back online"** (dismisses on reconnect) |
| Opt-out (AC-012) | N/A | Full-screen within tab: **"You're off the weekly board"** + link **Privacy settings** | N/A | Participating UI as above | See §2.6 |

**Copy tone:** Encouraging, short, ADHD-friendly per `docs/Context/product-guidelines.md`. Never blame the user.

### 2.6 Leaderboard opt-out (Settings) — v1 optional

AC-012 remains **Could** for build gating; when implemented, use existing Settings patterns:

| Element | Spec |
|---------|------|
| Location | `lib/features/settings/settings_screen.dart` — new row in the preferences `GlassCard` (with Sound / Music / Haptics) |
| Control | `SettingsRow` + `ToggleSwitch` bound to `leaderboardOptOutProvider` |
| Title | **Weekly leaderboard** |
| Subtitle | **Show my score on the global board** |
| Default | Off (participating) — matches `LeaderboardPrefs.optedOut` default `false` |
| On enable opt-out | Persist to `leaderboard_prefs` Hive box; stop writes; leaderboard tab shows §2.5 opt-out empty state |

**Design decision (review 2026-06-01):** Defer Settings toggle to the same build wave as AC-012 if playtest gate delays full BL-04; UI spec is frozen here so implementers do not invent copy.

### 2.7 User journey and emotional arc

| Step | User does | Feels | UI must support |
|------|-----------|-------|-----------------|
| 1 | Opens Leaderboard tab | Curious, competitive | Skeleton → fast first paint (AC-013) |
| 2 | Scans header | Oriented | Clear `#N` and XP delta (AC-015) |
| 3 | Views podium | Social proof | Real names `Pilot_NNNN`, not demo cohort |
| 4 | Finishes a level, returns | Progress | Stream updates YOU row without manual refresh (AC-002) |
| 5 | Taps Friends / Local | Mild curiosity | Warm **Coming soon**, not error (AC-011) |
| 6 | Offline or kill-switch | Not punished | Cached board + honest chips (AC-009, AC-016, AC-010) |
| 7 | Opts out in Settings | In control | Clear off-board message (AC-012) |

**Time horizons (Norman):** Visceral = gradient title + podium motion (existing); Behavioral = rank line updates; Reflective = weekly reset eyebrow builds "this week matters" habit.

### 2.8 AI slop and design-system alignment

**Hard rules (APP UI):** Calm hierarchy, utility copy, no decorative card grid around each row. Reuse `_LeaderRow` list rhythm — do not wrap every row in a separate hero card.

**Preserve (on-brand, not slop):**

- Gradient ShaderMask on "Leaderboard" title — matches Aetheric Pulse (S2-04).
- Glass segmented control — existing component.

**Avoid:**

- Generic 3-column feature grid, centered marketing hero, purple-on-white defaults, emoji bullets, colored left-border cards.
- New one-off `Inter` styles — use `AP.eyebrow`, `AP.display`, `AP.body`, `AP.fgMeta` only (remove stray `fontFamily: 'Inter'` when touching this file).

**Component reuse map:**

| UI element | Source | Notes |
|------------|--------|-------|
| Segmented control | `_SegmentedControl` | Min 44pt touch height: `vertical: 9` padding → verify ≥44pt total; add `Semantics(selected:)` |
| Rows | `_LeaderRow` | Adapter: `LeaderboardEntry` → `_Person` (`displayName`, `score`, `rank`, `isYou`) |
| Podium | `_Podium` | Order 2nd · 1st · 3rd unchanged |
| Coming soon | New `_ComingSoonPanel` in same file OR inline | `GhostButton` for **Back to Global** |
| Error banner | `GlassCard` + `PrimaryButton` / text button Retry | Match settings error tone |
| Settings opt-out | `SettingsRow` + `ToggleSwitch` | §2.6 |

**Calibration:** `docs/Context/product-guidelines.md` (canonical). Legacy `docs/miToosa Design System/uploads/DESIGN.md` (Kinetic Obsidian) is reference-only; active theme is **Aetheric Pulse** via `AP` tokens.

### 2.9 Responsive and accessibility

| Requirement | Implementation |
|-------------|----------------|
| Touch targets | Segmented segments and Retry ≥44pt (`product-guidelines`) |
| Semantics | Podium: `"Rank 1, Pilot_0042, 24820 XP"`; YOU row: `"Your rank, …"` |
| Segmented control | Announce selected scope; Friends/Local: `"Coming soon, not available"` |
| Dynamic Type | Podium font scales down (min 12px); row names ellipsize before XP |
| Contrast | Body text on `AP.surface` ≥4.5:1; rank line uses `AP.fg` not `AP.fgMuted` for primary stat |
| Web | Same layout; no hover-only affordances |

**Eyebrow timezone (design decision):** Backend week bucket is **ISO week, Monday 00:00 UTC** (§1.3). Eyebrow copy: **`WEEKLY · RESETS SUN 23:59 UTC`** (replaces ambiguous local-only "SUN 23:59" without timezone). Optional v1.1: localize reset to device TZ with footnote.

**Display name (design decision):** Show server `Pilot_NNNN` only on the board (AC-007). Do not show local profile nicknames on the public global list — privacy and anti-impersonation.

### 2.10 Build Scope

```
✅ Ready to proceed — Scope Boundary
Files in scope      : lib/data/models/leaderboard_entry.dart, lib/data/leaderboard_repository.dart,
                      lib/features/leaderboard/leaderboard_provider.dart,
                      lib/features/main_app/leaderboard_screen.dart,
                      cloud_functions/src/index.ts, cloud_functions/src/score_validator.ts,
                      cloud_functions/src/rate_limiter.ts, cloud_functions/src/display_name_minter.ts,
                      cloud_functions/package.json,
                      firestore/firestore.rules, firestore/firestore.indexes.json,
                      test/data/leaderboard_repository_test.dart,
                      test/features/leaderboard/leaderboard_provider_test.dart,
                      test/features/main_app/leaderboard_screen_test.dart,
                      cloud_functions/test/score_validator.test.ts,
                      cloud_functions/test/rate_limiter.test.ts,
                      cloud_functions/test/display_name_minter.test.ts
Directories in scope: lib/data/models/, lib/data/, lib/features/leaderboard/, lib/features/main_app/,
                      cloud_functions/, firestore/, test/data/, test/features/leaderboard/, test/features/main_app/
Out of scope        : lib/data/player_progress.dart (no schema bump),
                      lib/core/engine/* (no engine changes),
                      lib/data/hive_persistence_provider.dart (no encryption changes),
                      friends/local scope queries, account linking, anti-cheat ML,
                      leaderboard_archives janitor function (post-v1)
```

---

## 3. Tasks

### 3.1 Task Tree

- [ ] **1.** Firestore schema + Security Rules: define wire format and enforce auth/integrity at the rules layer
  - [ ] 1.1 Author `firestore/firestore.rules` covering `leaderboard_entries`, `xp_audit_log`, `rate_limits`, `display_names` — _Requirements: AC-005, AC-006, AC-008_
  - [ ] 1.2 Author `firestore/firestore.indexes.json` with composite index `(week ASC, score DESC)` — _Requirements: AC-002_
  - [ ] 1.3 Add Firestore Rules unit tests (firebase-rules-unit-testing) for write-impersonation, missing-AppCheck, burst-write — _Requirements: AC-005, AC-006, AC-008_
- [ ] **2.** Client data model: define the immutable wire type
  - [ ] 2.1 Create `lib/data/models/leaderboard_entry.dart` with `fromFirestore` / `toFirestore` and `copyWith` — _Requirements: AC-001, AC-002_
  - [ ] 2.2 Unit-test serialization round-trip + ISO-week derivation — _Requirements: AC-001_
- [ ] **3.** Client repository: Firestore reads, writes, opt-out, kill-switch
  - [ ] 3.1 Create `lib/data/leaderboard_repository.dart` with `submitScore`, `topNStream`, `neighbourWindowStream`, `setOptOut` — _Requirements: AC-001, AC-002, AC-003, AC-009, AC-010, AC-012_
  - [ ] 3.2 Wire Firestore offline persistence enable on app boot — _Requirements: AC-010_
  - [ ] 3.3 Read `leaderboard_writes_enabled` from Remote Config; cache value and short-circuit `submitScore` when false — _Requirements: AC-009_
  - [ ] 3.4 Add a tiny `leaderboard_prefs` Hive box (NOT a `PlayerProgress` schema bump) for opt-out persistence — _Requirements: AC-012_
  - [ ] 3.5 Repository tests using fake Firestore (`fake_cloud_firestore`) — _Requirements: AC-001, AC-002, AC-003, AC-009, AC-010, AC-012_
- [ ] **4.** Riverpod providers: stream into the UI
  - [ ] 4.1 Create `lib/features/leaderboard/leaderboard_provider.dart` exposing `leaderboardTopNProvider`, `leaderboardNeighboursProvider`, `leaderboardOptOutProvider` — _Requirements: AC-002, AC-003, AC-012_
  - [ ] 4.2 Provider tests via `ProviderContainer` — _Requirements: AC-002, AC-003_
- [ ] **5.** UI wiring: replace demo data, preserve podium/YOU-row contract
  - [ ] 5.1 Modify `lib/features/main_app/leaderboard_screen.dart` to consume providers from task 4; delete `_demo`; remove preview footer; wire dynamic header rank (AC-015); use `AP` typography only — _Requirements: AC-002, AC-003, AC-011, AC-015, §2.4_
  - [ ] 5.2 Add `friends` / `local` Coming soon panel per §2.5 (icon, copy, GhostButton **Back to Global**); no backend call — _Requirements: AC-011, §2.5_
  - [ ] 5.3 Implement loading skeleton (AC-013), error retry banner (AC-014), kill-switch chip (AC-016), offline sync chip (AC-010), opt-out empty state (AC-012), podium <3 edge (AC-017) — _Requirements: AC-010, AC-012, AC-013, AC-014, AC-016, AC-017, §2.5_
  - [ ] 5.4 Widget tests: podium, YOU-row pinning, coming-soon, loading skeleton, error banner, dynamic header rank — _Requirements: AC-002, AC-003, AC-011, AC-013, AC-014, AC-015_
  - [ ] 5.5 (optional) Settings `SettingsRow` + `ToggleSwitch` for leaderboard opt-out — _Requirements: AC-012, §2.6_
- [ ] **6.** Cloud Functions: server-side validation, rate-limiting, display-name minting
  - [ ] 6.1 Scaffold `cloud_functions/` (package.json, tsconfig, eslint) and wire Firebase project — _Requirements: AC-004, AC-007, AC-008_ `[manual]` (requires gcloud auth + project linking)
  - [ ] 6.2 Implement pure `score_validator.ts` with clamp(clientScore, serverMax) — _Requirements: AC-004_
  - [ ] 6.3 Implement pure `rate_limiter.ts` sliding-window check — _Requirements: AC-008_
  - [ ] 6.4 Implement pure `display_name_minter.ts` with atomic counter — _Requirements: AC-007_
  - [ ] 6.5 Implement `onLeaderboardWrite` trigger orchestrating validator + rate-limiter + minter — _Requirements: AC-004, AC-007, AC-008_
  - [ ] 6.6 Unit tests for all three pure modules + integration test for the trigger using Functions emulator — _Requirements: AC-004, AC-007, AC-008_
- [ ] **7.** Telemetry + observability hooks
  - [ ] 7.1 Emit `leaderboard_write_submitted` / `leaderboard_write_clamped` / `leaderboard_write_throttled` / `leaderboard_opt_out_toggled` events to `telemetryRepositoryProvider` — _Requirements: AC-001, AC-004, AC-008, AC-012_
  - [ ] 7.2 Add Cloud Logging structured fields in `onLeaderboardWrite` for observability — _Requirements: AC-004_
  - [ ] 7.3 Configure $5/day Firestore budget alert + Remote Config kill-switch wiring — _Requirements: AC-009_ `[manual]` (GCP console)
- [ ] **8.** End-to-end + performance verification
  - [ ] 8.1 E2E test: complete a level → write fires → snapshot updates within 5 s — _Requirements: AC-001, AC-002_
  - [ ] 8.2 Negative E2E: opted-out player completes a level → no write fires, not on board — _Requirements: AC-012_
  - [ ] 8.3 Load test: 50 concurrent writes from same playerId → rules reject burst — _Requirements: AC-008_

### 3.2 Wave Plan

**Wave 1 (parallel, no dependencies):** 1.1, 1.2, 2.1, 6.2, 6.3, 6.4
**Wave 2 (parallel, after Wave 1):** 1.3, 2.2, 3.1, 3.4, 6.5, 7.2
**Wave 3 (parallel, after Wave 2):** 3.2, 3.3, 3.5, 4.1, 6.1, 6.6
**Wave 4 (parallel, after Wave 3):** 4.2, 5.1, 7.1
**Wave 5 (sequential, after Wave 4):** 5.2, 5.3, 5.4, 5.5, 7.3, 8.1, 8.2, 8.3

### 3.3 Test Plan

Test plan: `Docs/AgToosa_TestPlan-BL-04.md`
AC coverage: 17 ACs (12 original + AC-013–AC-017 from design review 2026-06-01); update test IDs when test plan is next touched
Smoke set: Must-priority ACs including AC-013, AC-014, AC-015

---

## 4. Design review (2026-06-01)

> `/plan-design-review` on this spec. Branch: `main`. Design completeness: **5/10 → 9/10**.

### 4.1 What already exists

| Asset | Path | Reuse |
|-------|------|-------|
| Leaderboard demo UI | `lib/features/main_app/leaderboard_screen.dart` | `_Podium`, `_LeaderRow`, `_SegmentedControl` |
| Design tokens | `lib/theme/design_tokens.dart` (`AP`) | All new copy and surfaces |
| Settings patterns | `lib/features/settings/settings_screen.dart` | `SettingsRow`, `ToggleSwitch`, `GlassCard` |
| Opt-out persistence (pre-gate) | `lib/data/leaderboard_prefs.dart` | Hive box plumbing |
| Entry model (pre-gate) | `lib/data/leaderboard_entry.dart` | Wire format |
| Product voice / a11y | `docs/Context/product-guidelines.md` | Copy and 44pt targets |

### 4.2 NOT in scope (design)

- Custom server-side avatars or display-name overrides
- Friends / local live UI (beyond Coming soon)
- Pagination, all-time tab, rank-change animations
- Marketing-style hero sections or 3-column feature grids
- Formal repo-root `DESIGN.md` (use `AP` + product-guidelines)

### 4.3 Approved visual reference

| Screen | Reference | Notes |
|--------|-----------|-------|
| Global live | §2.4 ASCII layout + existing `leaderboard_screen.dart` | gstack designer unavailable; ASCII wireframes in spec |
| Coming soon | §2.5 Friends/Local row | — |
| Loading | §2.5 skeleton description | Podium + row placeholders |

### 4.4 Design review completion summary

```
+====================================================================+
|         DESIGN PLAN REVIEW — COMPLETION SUMMARY (BL-04)              |
+====================================================================+
| Pass 1  (Info Arch)     | 4/10 → 9/10                              |
| Pass 2  (States)        | 3/10 → 9/10                              |
| Pass 3  (Journey)       | 5/10 → 8/10                              |
| Pass 4  (AI Slop)       | 6/10 → 8/10                              |
| Pass 5  (Design Sys)    | 7/10 → 9/10                              |
| Pass 6  (Responsive)    | 4/10 → 8/10                              |
| Pass 7  (Decisions)     | 5 resolved (see §2.6, §2.9)              |
+--------------------------------------------------------------------+
| New ACs                 | AC-013 … AC-017                          |
| Overall design score    | 5/10 → 9/10                              |
+====================================================================+
```

**Verdict:** Plan is design-complete for implementation waves 3–5. Run `/plan-eng-review` before `/agtoosa-build` after playtest + BL-03 gates clear. Run `/design-review` on the live screen after implementation.

## GSTACK REVIEW REPORT

| Review | Trigger | Why | Runs | Status | Findings |
|--------|---------|-----|------|--------|----------|
| CEO Review | `/plan-ceo-review` | Scope & strategy | 0 | — | — |
| Codex Review | `/codex review` | Independent 2nd opinion | 0 | — | — |
| Eng Review | `/plan-eng-review` | Architecture & tests (required) | 0 | — | — |
| Design Review | `/plan-design-review` | UI/UX gaps | 1 | CLEAR | score 5→9, +5 ACs, §2.4–2.9 |
| DX Review | `/plan-devex-review` | Developer experience gaps | 0 | — | — |

**UNRESOLVED:** 0 design decisions blocking implementation (AC-012 Settings toggle optional Could).

**VERDICT:** DESIGN REVIEW CLEARED — eng review required before ship.

---

## ✅ Spec Approved

Approved: 2026-05-16 00:00

Gate: D1 ≥ 40% + social motivation signal from S1-04 playtest must be confirmed before `/agtoosa-build` starts. Story remains in Backlog with this gate annotation; do not enroll in Active Cycle until both signals clear AND **BL-03** (Firebase project setup) is ✅ Done.
