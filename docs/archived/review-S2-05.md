# Review: S2-05 — Tracks UI Fixes

> **Story ID:** S2-05  
> **Review date:** 2026-06-11  
> **Verdict:** PASS  
> **Critical findings:** 0  

## Goal Contract Alignment

| Field | Status |
|-------|--------|
| Spec Goal Contract | Not present in `docs/AgToosa_Spec-S2-05-tracks-ui-fixes.md` (see 🟡 Warning) |
| Story intent | Fix light-mode Tracks washout, Start session CTA artifact, wire header menus |
| User outcome | Tracks screen readable in both themes; header taps open profile/credits sheets |
| Proof | Widget tests for glass/button/header; `tracks_screen_test.dart` for hero; full suite green |

## Findings

| Severity | Persona | Finding | Evidence | Disposition |
|----------|---------|---------|----------|-------------|
| 🟢 Passed | Security | No new secrets, network calls, or persistence changes. Menu sheets read local `PlayerProgress` only. | `profile_menu_sheet.dart`, `credits_menu_sheet.dart`, `main_app_shell.dart` wiring | No action required. |
| 🟢 Passed | Security | STRIDE from spec satisfied — UI-only change; no auth boundary changes. | Spec build scope is presentation layer | No action required. |
| 🟢 Passed | Engineering | `APTheme` centralizes theme-aware tokens; `GlassCard` uses context theme instead of hard-coded dark palette. | `design_tokens.dart`, `glass_card.dart` | No action required. |
| 🟢 Passed | Engineering | All S2-05 scope files under 500 lines except `world_map_screen.dart` (534, pre-existing shell). | `wc -l` on build-scope files | Monitor in future EP-04 refactors. |
| 🟢 Passed | Product | AC-001–AC-005 implemented per spec; header menus wired in `_SafeAppHeader`. | Code + widget tests | Ship when warnings accepted. |
| 🟢 Passed | QA | `dart analyze` clean; full `flutter test` 882/882 passing. | Terminal run 2026-06-11 | No action required. |
| 🟢 Passed | QA | AC-001 covered by `glass_card_test.dart` (light/dark fill + shadows). | `test/widgets/glass_card_test.dart` | No action required. |
| 🟢 Passed | QA | AC-003 covered by `primary_button_test.dart` (blurRadius > 0); hero CTA uses `glow: false`. | `world_map_screen.dart:322`, `primary_button_test.dart` | No action required. |
| 🟡 Warning | Engineering | `lib/widgets/track_tile.dart` has uncommitted theme-aware edits but is **not** listed in spec build scope. | `git diff HEAD -- track_tile.dart` | Include in ship commit or split to follow-up task. |
| 🟡 Warning | Engineering | `world_map_screen.dart` exceeds 500-line guideline (534 lines). | Line count | Defer extract to EP-04; not introduced by this story alone. |
| 🟡 Warning | Engineering | `docs/Context/CONTEXT.md` is CI/CD-focused; game economy terms (games vs credits vs sessions) not centralized for UI copy review. | `docs/Context/CONTEXT.md` | Consider `/agtoosa-spec` domain-language pass later. |
| 🟡 Warning | Product | Profile sheet headline shows raw `playerId` (UUID) — poor player-facing identity. | `profile_menu_sheet.dart:66` | Replace with display name or "Pilot" before App Store if no account system. |
| 🟡 Warning | Product | Credits sheet copy uses "sessions" and "+40 bonus sessions"; canonical wedge uses **games** (`docs/PRODUCT-WEDGE.md`). | `credits_menu_sheet.dart:68-75` | Align copy with wedge terminology in a follow-up (do not edit wedge doc without owner approval). |
| 🟡 Warning | QA | AC-002 (light-mode readability) has no light-theme widget test on `WorldMapScreen`; `tracks_screen_test.dart` runs dark theme only. | `test/features/main_app/tracks_screen_test.dart` | Add light-theme pump test before ship or accept manual QA on device. |
| 🟡 Warning | QA | AC-004/AC-005: tests assert `onProfileTap` / `onCreditsTap` fire on `AppHeader`, but no test opens `showProfileMenuSheet` / `showCreditsMenuSheet` and asserts sheet content. | `shared_components_test.dart`; no matches in `test/` for sheet helpers | Optional widget test for sheet smoke; not blocking given callback + shell wiring. |
| 🟡 Warning | QA | Flake re-run: `flutter test --repeat` unavailable on this Flutter SDK; scoped widget tests run once successfully (45 tests). | `flutter test` scoped run | Re-run manually if flakes appear in CI. |

## Verification Evidence

| Command | Exit | Result |
|---------|------|--------|
| `dart analyze` | 0 | No issues found |
| `flutter test` | 0 | 882/882 passing |
| `flutter test test/widgets/glass_card_test.dart test/widgets/primary_button_test.dart test/widgets/shared_components_test.dart` | 0 | 45/45 passing |

## Code Simplification Notes

- `APTheme.of(context)` pattern is consistent across new/changed widgets; no shallow pass-through layers added.
- Menu sheets share nearly identical container decoration — acceptable duplication at ~100 lines each; extract shared `_MenuSheetShell` only if a third sheet appears.

## Review Gate

No unresolved 🔴 Critical findings. S2-05 may proceed to `/agtoosa-ship check`.

**Suggested release:** PATCH on app version track (UI fix story); coordinate with v1.5.0 launch milestone in `docs/LAUNCH.md`.

**Pre-ship recommendations (non-blocking):** light-theme Tracks test; profile display label; credits copy vs wedge; commit or drop `track_tile.dart` drift.
