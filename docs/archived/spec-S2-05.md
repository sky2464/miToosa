# Spec: S2-05 — Tracks UI Fixes

> **Story ID:** S2-05  
> **Epic:** EP-04 User Experience Polish  
> **Status:** 🏁 Shipped  
> **Estimate:** M  
> **Spec created:** 2026-06-02  
> **Shipped:** 2026-06-11  

## 1. Requirements

### 1.1 Goal Contract

| Field | Value |
|-------|-------|
| User outcome | Tracks screen is readable in light and dark mode; header taps open profile and credits menus without visual artifacts on the hero CTA |
| Success condition | All AC-001–AC-005 pass widget tests; review PASS with 0 critical findings; `flutter test` green |
| Proof / evidence | `docs/archived/review-S2-05.md`; `test/widgets/glass_card_test.dart`, `primary_button_test.dart`, `shared_components_test.dart`; full suite 882/882 (2026-06-11) |
| Non-goals | Backend profile sync; IAP wiring; full `world_map_screen.dart` refactor |

### 1.2 User Stories

**As a** player using light mode, **I want** the Tracks screen glass and typography to match the active theme **so that** content is not washed out or gray.

**As a** player, **I want** header avatar and credits pill to open menus **so that** I can see profile and allowance context without leaving Tracks.

### 1.3 Acceptance Criteria (EARS)

| ID | EARS | Priority |
|----|------|----------|
| AC-001 | WHEN the app theme is light or dark THE SYSTEM SHALL render `GlassCard` with theme-appropriate glass tokens via `APTheme`. | Must |
| AC-002 | WHEN the Tracks hero is shown THE SYSTEM SHALL render headline and progress dots with readable contrast in both themes. | Must |
| AC-003 | WHEN the Start session primary button is shown THE SYSTEM SHALL not display a harsh horizontal line artifact (softened shadow/shine; hero CTA `glow: false`). | Must |
| AC-004 | WHEN the user taps the header avatar/brand THE SYSTEM SHALL open the profile menu sheet. | Must |
| AC-005 | WHEN the user taps the credits pill THE SYSTEM SHALL open the credits menu sheet. | Must |

### 1.4 Out of Scope

- `track_tile.dart` theme polish (landed in working tree; not blocking S2-05)
- Light-theme golden test on full `WorldMapScreen` (deferred warning from review)
- Credits copy alignment with PRODUCT-WEDGE “games” terminology (follow-up)

## 2. Build Scope

- `lib/theme/design_tokens.dart` — `APTheme` helper
- `lib/widgets/glass_card.dart`, `app_header.dart`, `primary_button.dart`
- `lib/widgets/profile_menu_sheet.dart`, `credits_menu_sheet.dart` (new)
- `lib/features/main_app/main_app_shell.dart`
- `lib/features/navigation/world_map_screen.dart`
- `lib/widgets/featured_track.dart`, `kinetic_progress_bar.dart`
- `test/widgets/glass_card_test.dart`, `shared_components_test.dart`, `primary_button_test.dart`

## 3. Tasks

- [x] 1.1 APTheme helper + theme-aware GlassCard
- [x] 1.2 Theme-aware typography on Tracks screen + FeaturedTrack + KineticProgressBar
- [x] 1.3 Soften PrimaryButton shadow/shine; glow:false on hero CTA
- [x] 1.4 ProfileMenuSheet + credits menu + AppHeader/shell wiring
- [x] 1.5 Widget tests for all ACs
- [x] 5.1 `/agtoosa-review` — PASS (`docs/archived/review-S2-05.md`)
- [x] 5.2 `/agtoosa-ship` — archived 2026-06-11

## ✅ Spec Approved

Date: 2026-06-02
