# Product Context

<!-- Last updated: 2026-05-04 — /agtoosa-init -->

## App Type
app_type: "Cross-platform Mobile & Web Game (iOS, Android, macOS, Web)"

## Target Users
target_users: "Mobile puzzle / brain-game players who play short sessions (3–5 minutes). ADHD-optimized gameplay loop. B2C casual mobile audience."

## Core Problem
core_problem: "Cognitive engagement through pattern recognition and memory puzzles. Most brain-training apps feel like chores; miToosa creates a habit loop through dopamine-optimized short sessions and a free-first promise — no sign-up paywall, no forced ads."

## Core Features
core_features:
  - "Core gameplay loop: 8 puzzle tracks × 23 levels — pattern recognition, memory, math, physics puzzles"
  - "Adaptive difficulty via ProgressionEngine (rolling 5-level window, 0.75–1.50 multiplier)"
  - "Daily streak system with 8 milestone thresholds (3, 7, 14, 30, 60, 90, 180, 365 days)"
  - "Achievement framework: 9 achievements across progress, skill, and exploration categories"
  - "Free-games allowance: 25 free games/day, resets daily"
  - "Share bonus: +40 games per daily share (anti-abuse, once per day)"
  - "Hearts (❤) and diamonds (💎) as internal session-level mechanics"
  - "Encrypted Hive local storage (AES-256 + platform Keychain/Keystore)"
  - "Anonymous local-first auth (UUID v4 — no sign-up required)"
  - "Local telemetry (Hive-based event tracking aligned to product KPIs)"
  - "Cross-platform: iOS, Android, macOS, Web (verified builds)"
  - "WCAG 2.1 AA accessibility compliance (44pt touch targets, semantic labels, Dynamic Type)"

## Non-Goals
non_goals:
  - "No forced paywall before value — free-first is non-negotiable"
  - "No backend leaderboard until playtest validates D1 ≥40% and social motivation signal"
  - "No referral tier system until free-games wedge is proven"
  - "No VIP/IAP until retention is proven via playtest"
  - "No server-side sync in v1 — local-first only"
  - "No real-time multiplayer"

## Current Milestone
current_milestone: "v1.5.0 — iPhone App Store launch (EP-01); UX polish in flight (EP-04); playtest deferred until TestFlight"

## Success Metrics
success_metrics:
  - "D1 retention ≥ 40% (very likely to return next day)"
  - "Session completion rate: ≥ 70% complete a full 3-round session"
  - "Free-games model comprehension: ≥ 80% of playtesters understand it"
  - "Share prompt positive/neutral reaction: ≥ 60%"
  - "Would-pay-for-VIP signal: ≥ 30% yes/maybe"
  - "Time-to-first-game: ≥ 80% under 60 seconds from cold launch"

## Notes
<!-- Canonical economy reference: docs/PRODUCT-WEDGE.md -->
<!-- Product story: 25 free games/day + 40-game share bonus + optional VIP convenience layer -->
<!-- No backend yet — all data is local (Hive). Analytics backend decision pending Sprint 1 playtest. -->
