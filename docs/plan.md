## Plan: miToosa Sleek iOS Redesign — Aetheric Pulse

**Status:** SHIPPED — 2026-04-24  
**TL;DR**
Introduced a sleek iOS 2026 look by layering an **Aetheric Pulse** palette (soft blue `#597AFA` and pink pastel gradients) on top of the existing **Kinetic Obsidian** dark theme. Added an **Aetheric Pulse Dark** variant (Inter font, brand blue `#3B82F6` + purple `#A855F7`) for the primary dark experience. Glassmorphism and `BackdropFilter` extended via `GlassCard`. Fluid spring animations and a dopamine feedback toast (+N XP "IQ +1!") tuned for ADHD flow.

**Mockup links**
- Project ID: `8116825045928899731`
- Dashboard Map: Screen ID `cb2f8947555041b6b1d0a2af0114e940`
- Progress / Streak: Screen ID `2db3a9c3f7934ca6ab0497d5adf30351`
- Leaderboard: Screen ID `0ba2fc556ebd4b0aa60b551f6330781d`

**Relevant files**
- `lib/theme/design_system.dart` — `KineticObsidian`, `AethericPulseLight`, `AethericPulseDark` (coexist)
- `lib/main.dart` — `ThemeMode.system`, respects `PlayerProgress.themeModeOverride`
- `lib/features/main_app/main_app_shell.dart` — floating frosted pill nav with Path tab
- `lib/features/navigation/world_map_path_screen.dart` — dual-orientation path with zoom-to-current
- `lib/features/navigation/world_map_screen.dart` — Daily Training dashboard (a11y wrappers added)
- `lib/widgets/feedback_toast.dart` — per-puzzle dopamine toast
- `lib/features/gameplay/gameplay_screen.dart` — `ref.listen` wiring for the toast
- `lib/features/auth/login_screen.dart` — Semantics + 44×44 on CTA
- `lib/features/settings/settings_screen.dart` — Appearance selector; masked ID Semantics
- `lib/data/player_progress.dart` — schema v7, nullable `themeModeOverride`
- `pubspec.yaml` — bundled Orbitron / Exo 2 / Inter fonts; `google_fonts` removed

**Completed items (2026-04-22 → 2026-04-24)**
- P1: Light-mode rendering — `KineticBackground`, `KineticText`, `ProgressRing` adapted to `ThemeMode.system`
- P2: Gameplay option cards — `Semantics(button:true)` wrappers added to `_buildListOption()` and `_buildOptionCard()`
- P3: `recordLevelTime` wired in `_saveProgress()` in `gameplay_screen.dart`
- P4: Leaderboard live player XP via `ref.watch(playerProgressProvider).totalXP`
- P5: `flutter_animate` removed from `pubspec.yaml` (was imported nowhere)
- P6: Dynamic Type migration — `textTheme.*` adopted across login, shell, path screen, toast
- P7: `WorldMapPathScreen` 6-test suite added (portrait, landscape, semantics, orientation, zoom, highlight)
- P8: World map path screen token cleanup — `KineticObsidian` refs replaced with `AethericPulse*` tokens
- All 507 tests pass

**Decisions**
- *Coexistence over replacement*: Aetheric Pulse is additive. Kinetic Obsidian stays for screens relying on neon cyan/purple identity.
- *Animation budget 180–500 ms*: ADHD flow — hover/press under 300 ms; celebratory beats up to 500 ms.
- *No new haptics dependency*: `HapticsService` already covers light/medium/heavy and selection click.
- *Local fonts*: bundling removed CDN reach-out at runtime; strengthens offline-first claim.

---

## Sprint 1 — Post-Redesign: Close the Wedge, Ship to Staging, Run the Playtest

**Status:** Active  
**Date:** 2026-04-22  
**Sprint goal:** Prove the coded wedge works with real users before building anything new.

### Gap Analysis: Redesign vs. Reality

| Task | Claimed | Reality |
|------|---------|---------|
| Task 1 — Source of truth | ✅ Done | ✅ Confirmed. `PRODUCT-WEDGE.md` authoritative. |
| Task 2 — KPI taxonomy | ✅ Done | ✅ Confirmed. Telemetry events in Hive. |
| Task 3 — First-session friction | ✅ Code done | ⚠️ Manual verification never ran. |
| Task 4 — Free-games allowance | ✅ Code + persistence tests | ⚠️ Manual check skipped. |
| Task 5 — Share bonus | ✅ Code done | ⚠️ Manual verification never ran. |
| Task 6 — Streak reward ladder | ✅ Persistence tests | ⚠️ Manual check skipped. |
| Task 11 — Release gates | ✅ Documented | ❌ Staging URL missing. Gate never exercised. |
| Task 7 — Referral tiers | DEFERRED | ✅ Correctly deferred (needs backend). |
| Task 8 — VIP/IAP | DEFERRED | ✅ Correctly deferred (needs playtest data). |
| Task 9 — Landing page | DEFERRED | ✅ Correctly deferred (needs external infra). |
| Task 10 — Playtest | DEFERRED | ❌ Zero demand signal. Product is pre-product. |

### Problem Statement

The wedge features (Tasks 3–6) are coded and pass automated tests, but no human has verified the product works as described. The release gate (Task 11) has never been exercised. The product has not been playtested. Without closing these gaps, any further feature investment (backend leaderboard, referral tiers, VIP) is building on an unproven foundation.

### Goals

1. **G1 — Wedge verified:** Human walks the full product loop (first session → game → share → streak) in under 10 minutes with no economy confusion.
2. **G2 — Staging operational:** Public web staging URL exists, `/qa`-reviewed, recorded as the release gate target.
3. **G3 — Analytics backend selected:** Team agrees on KPI data destination so playtest data is capturable.
4. **G4 — Playtest launched:** 15–20 testers recruited, survey live, first responses captured within sprint.
5. **G5 — No new features start until G1–G4 are green.**

### Non-Goals

1. **Backend leaderboard** — No validated retention yet. Revisit after playtest data.
2. **Referral tiers (Task 7)** — Needs server-side attribution. Local Hive architecture cannot verify referred play.
3. **VIP / IAP (Task 8)** — Needs playtest validation + StoreKit/Google Play Billing integration.
4. **iOS/Android App Store submissions** — Provisioning/keystore are human-action blockers; tracked separately.
5. **Web platform hardening beyond staging** — localStorage crypto caveat is a known decision; product decision needed before public launch, not this sprint.

### Requirements

#### Must-Have (P0)

**M1 — Manual wedge QA walkthrough**
Run full product loop: fresh install → onboarding → first game → share → streak day 1 → return next day.
- Acceptance: Written walkthrough confirms each manual-check checkbox in `update.md` is green, or raises a bug ticket per failure.

**M2 — Staging deployment target selected and live**
Pick web host (Vercel, Firebase Hosting, Netlify), deploy web build, record URL in `CLAUDE.md` and `docs/RELEASE-GATES.md`.
- Acceptance: URL loads app, passes `/qa` review, is recorded as official staging target.

**M3 — Analytics backend decision**
Agree on analytics destination, integrate SDK, confirm at least one event (session start) appears in dashboard.
- Acceptance: One real event visible in analytics dashboard from a manual test session.

**M4 — Playtest recruitment opens**
15–20 testers identified. Survey drafted, reviewed, linked from staging URL.
- Acceptance: ≥5 responses captured by end of sprint.

**M5 — `docs/RELEASE-GATES.md` created and operational**
Documents: staging URL, `/qa` process, branch → review → staging → qa → merge sequence. Gate exercised on this sprint's staging deployment.
- Acceptance: One full gate sequence run and logged before sprint closes.

#### Nice-to-Have (P1)

**P1.1 — Web platform crypto decision documented**
Write decision note: accept localStorage plaintext on web for now, or scope a web-specific encryption shim.

**P1.2 — Playtest findings memo template ready**
Template prepared so synthesis can start immediately when responses arrive.

**P1.3 — Streak reward messaging manual review**
Confirm streak milestone notifications surface correctly at 3-day and 7-day thresholds.

#### Future Considerations (P2 — design around, don't build)

**P2.1 — Backend leaderboard**
If playtest shows strong social motivation: lightweight serverless leaderboard (Supabase/Firebase RTDB/Cloudflare Workers+KV). No schema changes needed in `PlayerProgress`.

**P2.2 — Referral attribution server**
Thin server accepting anonymous player IDs, emitting "referral completed" webhook when referred ID plays first game.

**P2.3 — VIP / IAP product definition**
One-page VIP definition before implementation: ad-free, +10 daily games, streak freeze, early access. Only after playtest willingness-to-pay signal.

**P2.4 — iOS/Android release signing**
Apple Developer account provisioning, Android keystore creation. Unblock in parallel with playtest for Sprint 2 TestFlight/internal track.

### Success Metrics

| Metric | Target | Timeframe |
|--------|--------|-----------|
| Manual QA P0 bugs | Zero | Sprint |
| Staging uptime | URL responds | Sprint |
| Analytics events firing | ≥1 confirmed | Sprint |
| Playtest responses | ≥5 by sprint end | Sprint |
| First-session time to gameplay | <60 seconds | Sprint |
| D1 return rate | ≥40% | 1 week post-playtest |
| Session completion rate | ≥70% | 1 week post-playtest |
| Share rate (day 1) | ≥20% of sessions | 1 week post-playtest |
| "Would you pay for VIP?" | ≥30% yes/maybe | Playtest survey |

### Open Questions

| Question | Owner | Blocking? |
|----------|-------|-----------|
| Which analytics backend? Firebase vs. Amplitude vs. Posthog | Engineering + product | Yes — blocks M3 |
| Which web host for staging? | Engineering | Yes — blocks M2 |
| Session-only heart/diamond mechanic — needs first-session UX explanation? | Design | No |
| Where do playtest findings live? `docs/playtests/` or external? | Product | No |
| Should streak freeze be surfaced as VIP benefit or earnable? | Product | No — affects P2.3 |

### Timeline

```
Week 1
├── Day 1-2:  Select web host, deploy staging build, run /qa
├── Day 2-3:  Manual wedge QA walkthrough (Tasks 3-6)
├── Day 3:    Select analytics backend, confirm one event fires
└── Day 4-5:  Playtest survey drafted, recruitment opens

Week 2
├── Day 1-3:  Playtest sessions running, first responses captured
├── Day 3-4:  RELEASE-GATES.md finalized with real staging URL
└── Day 5:    Sprint retro — go/no-go on Sprint 2 feature set
```

**Hard gate:** No Sprint 2 features scoped until playtest has ≥5 responses and manual wedge QA is green.

### What to Build Next (summary)

| Feature | Decision | Rationale |
|---------|----------|-----------|
| Backend leaderboard | Not yet | No retention signal yet |
| Web platform hardening | Staging only | Need URL for playtest; full hardening after demand proof |
| Referral tiers | Not yet | Needs server; scope in Sprint 2 if playtest positive |
| VIP / IAP | Not yet | Needs playtest willingness-to-pay signal |
| Playtest | This sprint | Highest leverage; unblocks every subsequent decision |
| Streak reward polish | This sprint (P1) | Low effort, visible during playtest window |
| Analytics backend | This sprint (P0) | Can't measure the wedge without it |

### Sprint 2 Preview (conditional on playtest data)

- **If D1 ≥40% and share rate ≥20%:** Streak reward ladder polish + lightweight backend foundation for leaderboard/referral + TestFlight beta.
- **If <40% D1 or economy confusion:** First-session redesign, economy copy overhaul, second playtest round.

No Sprint 2 scope locked until Sprint 1 closes with real data.
