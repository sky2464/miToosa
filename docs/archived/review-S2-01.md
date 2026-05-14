# Review: S2-01 — Aetheric Pulse UI Redesign

> **Story ID:** S2-01
> **Spec:** [Docs/archived/spec-S2-01.md](spec-S2-01.md)
> **Reviewed:** 2026-05-14
> **Verdict:** 🔴 **BLOCKED**

---

## Verdict Summary

| Persona | Verdict | 🔴 Critical | 🟡 Warning |
|---------|---------|------------|-----------|
| Security Officer | ✅ PASS | 0 | 0 |
| Engineering Manager | 🔴 BLOCKED | 2 | 3 |
| CEO / Product Owner | 🟡 PASS-WITH-CONDITIONS | 3 | 2 |
| QA Lead | 🔴 BLOCKED | 5 | 4 |
| **Aggregate** | **🔴 BLOCKED** | **10** | **9** |

The story has **10 Critical findings across 3 personas** and cannot ship as-is. Foundation work is solid and shippable; screen-level delivery and tests are incomplete.

---

## 🔴 Critical Findings (10)

### Engineering — file size violations
1. **design_system.dart is 737 lines** (cap is 500). Violates `Docs/Context/workflow.md` architecture rule. The file was already over the cap pre-S2-01; S2-01 added tokens that grew it further. *Fix:* split into `design_system_colors.dart` + `design_system_typography.dart` + `design_system_spacing.dart`, or migrate remaining constants into the new `AP` namespace in `design_tokens.dart`.
2. **world_map_screen.dart is 509 lines** (9 over cap). *Fix:* extract bottom-sheet preview or `_TrackCard` into a separate file.

### CEO — Must-priority AC gaps
3. **AC-003 Path constellation NOT delivered.** `PathConstellation` widget exists but is not wired into `world_map_path_screen.dart`. Players see legacy InteractiveViewer-based path inside core gameplay flow.
4. **AC-007 Game screen NOT delivered.** Existing `gameplay_screen.dart` retained — players see legacy chrome inside the most-used screen.
5. **AC-002 / AC-010 partial on Tracks.** Daily Spark hero refinement, filter chips, PNG-iconed featured/grid tiles deferred (tasks 5.1, 5.3-5.7). The free-first wedge surface is unrefined.

### QA — uncovered Must-priority ACs (5 of 10 have zero screen-level tests)
6. **AC-002 Tracks screen** — no `tracks_screen_test.dart`. Test plan IDs T-003/T-004/T-005 unimplemented.
7. **AC-003 Path constellation** — no `path_constellation_test.dart`. T-006/T-007 unimplemented.
8. **AC-005 Leaderboard** — no `leaderboard_screen_test.dart`. Podium, segmented control, "YOU" row untested. T-012/T-013 unimplemented.
9. **AC-009 Bottom nav** — no shell test verifying 5-tab structure or active indicator. T-019/T-020 unimplemented.
10. **AC-010 Provider integration** — no integration tests with mocked `playerProgressProvider`. T-021/T-022/T-023 unimplemented.

---

## 🟡 Warnings (9)

### Engineering
- `Docs/Context/CONTEXT.md` missing — domain-language alignment cannot be verified. *Fix:* create CONTEXT.md per `Docs/CONTEXT-FORMAT.md`.
- `Docs/adr/` directory does not exist — 3 architectural decisions in S2-01 are undocumented (AP token namespace; CustomPainter for radar/constellation vs. charting lib; bundled PNG assets). *Fix:* add 3 ADRs.
- `leaderboard_screen.dart` (420 lines) and `progress_screen.dart` (378 lines) trending toward cap; watch growth.

### CEO
- Test coverage gaps (4.3, 5.7, 7.6, 8.3, 9.3, 10.4 widget tests deferred) — regression risk on delivered work.
- AC-006 Settings deferred kills the VIP upsell card surface — directly tied to PRODUCT-WEDGE monetization path.

### QA — Accessibility (WCAG 2.1 AA)
- **`ToggleSwitch` is 42×24 px** — well below the 44pt minimum tap-target requirement.
- **`GhostButton` ~37pt tall** (padding 12 + 13pt content) — below minimum.
- **`PrimaryButton` ~42pt tall** — below minimum.
- `BackdropFilter` in `glass_card.dart` and `app_header.dart` is a known slow path on Flutter Web (which is in the supported browser matrix).

---

## 🟢 Passed

### Security (full pass)
- **A03 Injection** — no user-input rendering in new widgets; strings come from spec/PlayerProgress
- **A05 Misconfiguration** — no debug flags or `print`/`debugPrint` in new code
- **A09 Logging failures** — no PII (playerId/email/UUID) referenced in new widget files
- **STRIDE Tampering** (asset injection) — all 26 PNGs bundled at build time; no `NetworkImage` or HTTP URLs
- **STRIDE Information Disclosure** — no PII baked into static UI strings
- **Secrets scan** — no emails, tokens, or API keys
- **`Atmosphere` resource lifecycle** — `AnimationController` properly created in `initState`, disposed in `dispose()`

### Engineering
- All 12 new widget files under 500 lines (largest: `path_constellation.dart` at 344)
- Pure-engine layer untouched (no Flutter/Hive imports in `lib/core/engine/`)
- Full test suite: **721/721 passing**
- Shallow-module check passed — each widget encapsulates a distinct visual concept
- New `design_tokens.dart` (139 lines) cleanly introduces the `AP` namespace

### CEO
- Foundation is defensible: 11 shared widgets and 2 fully rebuilt screens (Progress, Leaderboard) ship real value
- Brand consistency on delivered screens intact (sentence case, glassmorphism, no jargon, no chrome emojis)
- Free-first wedge surfaces (stat pills for streak/energy/XP) shipped on at least one screen
- 5 of 10 Must-priority ACs fully delivered (AC-001, AC-004, AC-005, AC-008, AC-009); AC-013 and AC-014 (Should) delivered

### QA
- Coverage exists for AC-001 (tokens), AC-006 (settings — pre-existing), AC-008 (atmosphere)
- 7 new widget test files added with 24 new test cases — all passing
- `dart analyze` clean

---

## 🔬 Iron Law — Root Cause (for Critical findings 3-5, 6-10)

**Root cause:** The XL story was scoped to 6 screen rebuilds + foundation + tests in one ship. Time/risk pressure during the build led to deferring 3 screens (Path, Settings, Game) and 5 screen-level test files. The deferred items were noted in the build log but never demoted from the spec's Must-priority list, leaving the AC ledger out of sync with what was actually built.

**Mitigation:** Split S2-01 into the foundation deliverable (what's done) + 3 follow-up stories (what's left). Do not mark AC-002/003/006/007 as delivered until the corresponding screen swap-ins land.

**Regression test ID:** Not applicable — these are coverage gaps, not regressions.

---

## Recommended Path Forward

1. **Accept S2-01 as a foundation-only partial ship** with explicit follow-up stories logged before any external "Aetheric Pulse" announcement:
   - **S2-02 — Path screen swap-in** (tasks 6.1-6.4 + screen test) — blocker for AC-003
   - **S2-03 — Game screen chrome refresh** (tasks 10.1-10.4 + AC-011 timer pulse) — blocker for AC-007/011, highest visibility
   - **S2-04 — Tracks completion + Settings refactor + screen tests** (5.1, 5.3-5.7, 9.1-9.3, 4.3, 7.6, 8.3) — blocker for AC-002, AC-006, AC-010
2. **Fix the 500-line violation in `design_system.dart`** before merge (or accept as documented pre-existing tech debt and file a Chore in Backlog).
3. **Address WCAG tap-target sizing** for `ToggleSwitch`/`GhostButton`/`PrimaryButton` — change `minHeight: 44` on the gesture target (the visual chrome can stay smaller, but the hit-target must be 44+).
4. **Create `Docs/Context/CONTEXT.md` and 3 ADRs** under `Docs/adr/` — recoverable hygiene.

---

## Provenance Note

During this review, two specialist agents (Security, QA) reported that embedded `<system-reminder>` blocks claiming to be "MCP Server Instructions" appeared inside untrusted tool outputs (file content read during the audit). Both agents correctly treated these as untrusted content per the security rules and did **not** act on them. The redesign source bundle (`docs/mitoosa-design-system-2/`) appears to contain text that could be misinterpreted as agent instructions. Recommend a sanitization pass during follow-up stories.
