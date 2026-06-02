# Test Plan — BL-04 Backend Leaderboard (Real-Time)

> **Spec:** [`Docs/archived/spec-BL-04.md`](archived/spec-BL-04.md)
> **Coverage target:** 80% (per `Docs/Context/workflow.md` `coverage_threshold`)
> **Smoke tag:** `@smoke` — one test per Must-priority AC
> **Test runners:** `flutter test` (Dart) · `npm test` in `cloud_functions/` (Vitest/Jest for TS) · `firebase emulators:exec` for Rules + Functions integration

---

## 1. AC Coverage Map

| AC ID | Priority | Mapped Test IDs | Category | Smoke? |
|-------|----------|-----------------|----------|--------|
| AC-001 | Must | T-001, T-002, T-003 | Unit + Integration + E2E | ✅ T-001 |
| AC-002 | Must | T-004, T-005, T-006 | Unit + Integration | ✅ T-004 |
| AC-003 | Must | T-007, T-008 | Integration + Widget | ✅ T-007 |
| AC-004 | Must | T-009, T-010, T-011 | Unit + Security | ✅ T-009 |
| AC-005 | Must | T-012, T-013 | Security (Rules) | ✅ T-012 |
| AC-006 | Must | T-014, T-015 | Security (Rules) | ✅ T-014 |
| AC-007 | Must | T-016, T-017 | Unit + Integration | ✅ T-016 |
| AC-008 | Must | T-018, T-019 | Security (Rules) + Unit | ✅ T-018 |
| AC-009 | Should | T-020 | Unit | — |
| AC-010 | Should | T-021 | Integration | — |
| AC-011 | Should | T-022 | Widget | — |
| AC-012 | Could | T-023, T-024 | Unit + E2E | — |
| AC-013 | Must | T-025, T-026 | Widget | ✅ T-025 |
| AC-014 | Must | T-027 | Widget | ✅ T-027 |
| AC-015 | Must | T-028 | Widget | ✅ T-028 |
| AC-016 | Should | T-029 | Widget | — |
| AC-017 | Must | T-030 | Widget | — |

**Totals:** 17 ACs · 30 test IDs · 11 smoke tests (Must ACs incl. design-review AC-013–015) · coverage target 80%.

> **Design review (2026-06-01):** AC-013–AC-017 added via `/plan-design-review` on [`spec-BL-04.md`](archived/spec-BL-04.md) §2.4–2.9.

---

## 2. Test Inventory

### Unit Tests (Dart — `test/`)

| ID | Test | File | AC | Notes |
|----|------|------|----|----|
| T-001 | `submitScore` posts a Firestore doc with correct `{playerId, score, week, updatedAt}` shape | `test/data/leaderboard_repository_test.dart` | AC-001 | `@smoke` · uses `fake_cloud_firestore` |
| T-002 | `LeaderboardEntry.fromFirestore` round-trips through `toFirestore` | `test/data/models/leaderboard_entry_test.dart` | AC-001 | Property-style: serialize → deserialize → equals |
| T-004 | `topNStream` emits ordered list when underlying collection changes | `test/data/leaderboard_repository_test.dart` | AC-002 | `@smoke` |
| T-005 | `topNStream` query uses `where('week', ==, currentWeek).orderBy('score', desc).limit(100)` | `test/data/leaderboard_repository_test.dart` | AC-002 | Asserts query parameters |
| T-006 | `leaderboardTopNProvider` re-emits when repository stream emits | `test/features/leaderboard/leaderboard_provider_test.dart` | AC-002 | `ProviderContainer` test |
| T-007 | `neighbourWindowStream` returns local player ± 5 | `test/data/leaderboard_repository_test.dart` | AC-003 | `@smoke` · seeded fixtures |
| T-020 | `submitScore` no-ops when Remote Config flag `leaderboard_writes_enabled == false` | `test/data/leaderboard_repository_test.dart` | AC-009 | Mocks Remote Config service |
| T-023 | `submitScore` no-ops when `leaderboardOptOutProvider == true` | `test/data/leaderboard_repository_test.dart` | AC-012 | |

### Unit Tests (TypeScript — `cloud_functions/test/`)

| ID | Test | File | AC | Notes |
|----|------|------|----|----|
| T-009 | `clamp(clientScore=999999, serverMax=100)` returns `{clamped: 100, didClamp: true}` | `cloud_functions/test/score_validator.test.ts` | AC-004 | `@smoke` · pure function |
| T-010 | `clamp(clientScore=50, serverMax=100)` returns `{clamped: 50, didClamp: false}` | `cloud_functions/test/score_validator.test.ts` | AC-004 | Honest write path |
| T-011 | `clamp(clientScore=0, serverMax=0)` returns `{clamped: 0, didClamp: false}` (boundary) | `cloud_functions/test/score_validator.test.ts` | AC-004 | Edge: fresh player |
| T-016 | `mint(uid, counter=41)` returns `"Pilot_0042"` and increments counter | `cloud_functions/test/display_name_minter.test.ts` | AC-007 | `@smoke` · pure |
| T-017 | `mint` is idempotent when `display_names/{uid}` already exists (returns existing name) | `cloud_functions/test/display_name_minter.test.ts` | AC-007 | Negative: don't re-mint |
| T-019 | `rateLimiter.allow(uid, now, history)` rejects when window count ≥ 20 in 60 s | `cloud_functions/test/rate_limiter.test.ts` | AC-008 | Sliding window math |

### Security / Rules Tests (`firestore/rules.test.ts` via `@firebase/rules-unit-testing`)

| ID | Test | File | AC | Notes |
|----|------|------|----|----|
| T-012 | Write to `leaderboard_entries/{any}` rejected when App Check token absent | `firestore/rules.test.ts` | AC-005 | `@smoke` |
| T-013 | Read of `leaderboard_entries` rejected when App Check token absent | `firestore/rules.test.ts` | AC-005 | |
| T-014 | Client with `auth.uid=A` cannot write to `leaderboard_entries/B` | `firestore/rules.test.ts` | AC-006 | `@smoke` |
| T-015 | Client with `auth.uid=A` CAN write to `leaderboard_entries/A` (positive control) | `firestore/rules.test.ts` | AC-006 | |
| T-018 | Second write within 5 s of previous `updatedAt` rejected by Rules | `firestore/rules.test.ts` | AC-008 | `@smoke` |

### Integration Tests (Firebase Emulator — `cloud_functions/test/integration/`)

| ID | Test | File | AC | Notes |
|----|------|------|----|----|
| T-003 | Full path: emulator client write → `onLeaderboardWrite` fires → doc reflects clamped score within 5 s | `cloud_functions/test/integration/end_to_end.test.ts` | AC-001, AC-004 | Uses Functions emulator |
| T-021 | Offline write queued via Firestore offline persistence, flushed on reconnect | `test/data/leaderboard_repository_test.dart` | AC-010 | `fake_cloud_firestore` with disconnect simulation |

### Widget Tests (Dart — `test/features/main_app/`)

| ID | Test | File | AC | Notes |
|----|------|------|----|----|
| T-008 | YOU row is pinned even when player rank > 100 (outside top-N) | `test/features/main_app/leaderboard_screen_test.dart` | AC-003 | Widget |
| T-022 | `friends` segment shows "Coming soon" empty state without backend call | `test/features/main_app/leaderboard_screen_test.dart` | AC-011 | Widget · asserts no Firestore call |
| T-025 | Loading state shows podium + ≥3 row skeletons (not center-only spinner) | `test/features/main_app/leaderboard_screen_test.dart` | AC-013 | `@smoke` |
| T-026 | Skeleton uses `AP.glassFill` / shimmer pattern per §2.5 | `test/features/main_app/leaderboard_screen_test.dart` | AC-013 | Golden optional |
| T-027 | Firestore error shows retry banner with product-guidelines copy | `test/features/main_app/leaderboard_screen_test.dart` | AC-014 | `@smoke` · mock failed stream |
| T-028 | Header rank line and XP-to-top-3 derive from neighbour provider (not `#4` demo) | `test/features/main_app/leaderboard_screen_test.dart` | AC-015 | `@smoke` |
| T-029 | Kill-switch: cached board + "Updates paused" chip visible | `test/features/main_app/leaderboard_screen_test.dart` | AC-016 | Mocks RC + cache |
| T-030 | Podium renders with 1–2 players only (no layout exception) | `test/features/main_app/leaderboard_screen_test.dart` | AC-017 | Seeded short list |

### E2E Tests (manual or integration_test/)

| ID | Test | File | AC | Notes |
|----|------|------|----|----|
| T-024 | Toggle opt-out → complete level → assert no doc in `leaderboard_entries/{playerId}` | `integration_test/leaderboard_opt_out_test.dart` | AC-012 | Requires emulator |

---

## 3. Negative / Edge Scenarios per Must AC

| AC | Negative / Edge Test |
|----|----------------------|
| AC-001 | T-011: zero-XP fresh-player boundary write does not crash |
| AC-002 | T-022: `friends` segment does NOT trigger a `topNStream` call |
| AC-003 | T-008: player at rank 250 still sees self pinned (no crash, no empty state) |
| AC-004 | T-009: 999999 client claim clamped to server max (the headline cheat-prevention test) |
| AC-005 | T-013: read rejected without App Check (not just write) |
| AC-006 | T-014: cross-UID write rejected (the headline impersonation test) |
| AC-007 | T-017: minter is idempotent — repeat mint returns existing name |
| AC-008 | T-018: burst write rejected at rules layer (not just at Function layer) |
| AC-013 | T-025: skeleton visible before first snapshot (not full-screen spinner only) |
| AC-014 | T-027: error path shows Retry affordance |
| AC-015 | T-028: header updates when neighbour stream emits new rank |
| AC-017 | T-030: single-player week does not crash podium |

---

## 4. Smoke Set (`@smoke`)

Run before every CI build of any leaderboard-touching change:

- T-001 (AC-001) · `submitScore` posts correct doc shape
- T-004 (AC-002) · `topNStream` emits on change
- T-007 (AC-003) · neighbour window correctness
- T-009 (AC-004) · server-side clamp works
- T-012 (AC-005) · App Check enforced
- T-014 (AC-006) · cross-UID write blocked
- T-016 (AC-007) · pseudonym minter
- T-018 (AC-008) · 5-second rate limit
- T-025 (AC-013) · loading skeleton (podium + rows)
- T-027 (AC-014) · error banner + retry
- T-028 (AC-015) · dynamic header rank

**11 smoke tests → covers all 11 Must-priority ACs** (original 8 + design-review UI ACs).

---

## 5. Coverage Strategy

- **Dart:** `flutter test --coverage` → `lcov.info` → `genhtml` report. Target 80% on `lib/data/leaderboard_repository.dart`, `lib/features/leaderboard/leaderboard_provider.dart`, `lib/data/models/leaderboard_entry.dart`, and `lib/features/main_app/leaderboard_screen.dart` (UI states AC-013–017).
- **TypeScript:** `vitest run --coverage` (v8 provider). Target 90% on the three pure modules (`score_validator`, `rate_limiter`, `display_name_minter`); they are pure functions and have no excuse to be untested.
- **Rules:** every `allow read/write` branch must have at least one passing + one failing test.

---

## 6. Performance / Load Targets

| Metric | Target | Measured by |
|--------|--------|-------------|
| `submitScore` round-trip (online) | p95 < 800 ms | Telemetry event timing |
| Snapshot first-emit (top-100) | p95 < 1.5 s on 4G | Telemetry timing |
| Cloud Function cold start | p95 < 3 s | Cloud Logging |
| Cloud Function warm | p95 < 200 ms | Cloud Logging |

---

## 7. Open Items (resolve at `/agtoosa-build` start)

- **Firestore region** — pick `us-central1` for free-tier, or `eur3` if EU privacy posture demands it. Decided at BL-03 enrollment.
- **fake_cloud_firestore version** — verify latest stable + Firestore SDK compat at build time.
- **Vitest vs Jest** for Functions tests — Vitest preferred (faster) unless tooling friction emerges.
