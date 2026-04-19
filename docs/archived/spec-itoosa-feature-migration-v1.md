# Spec: iToosa → miToosa Feature Migration v1

**Status:** Archived (originally shipped v1.3.0, 2025-07-24)  
**Date:** 2026-04-16  
**Source:** Analysis of `temp-research/iToosa/` (Swift/iOS) vs current miToosa (Flutter) v1.2.0

---

## Objective

Port the best features from the iToosa iOS prototype into miToosa, a cross-platform Flutter app. The goal is to deepen player engagement, add monetization infrastructure, and expand content — all while preserving miToosa's existing architecture (Riverpod, Hive, pure-Dart engine).

---

## Assumptions

```
1. miToosa v1.2.0 is the baseline (256 tests passing, zero lint errors)
2. All new features must work on iOS, Android, and Web
3. Hive remains the persistence layer (schema v3 → v4+)
4. Riverpod 3 remains the state management solution
5. No backend server — all features are client-side for now
6. Monetization (IAP, subscriptions) will use platform-native APIs
7. Game Center / Google Play Games integration is deferred unless marked
8. We keep miToosa's 23 puzzle rules (superset of iToosa's 20)
→ Correct me now or I'll proceed with these.
```

---

## Gap Analysis: iToosa Features vs miToosa Current State

### Legend
- ✅ = miToosa already has it
- 🔶 = miToosa has partial / different implementation
- ❌ = miToosa is completely missing it

| # | Feature | iToosa | miToosa | Gap |
|---|---------|--------|---------|-----|
| 1 | Core puzzle engine | 20 rules | 23 rules | ✅ miToosa is ahead |
| 2 | Hearts system | 3 hearts | 5 hearts + 3 refuel paths | ✅ miToosa is ahead |
| 3 | Hint system | Hint tokens (purchasable) | 1-heart cost, star-capped | ✅ Different but complete |
| 4 | Star rating | 5-star (3 thresholds) | 5-star (adaptive) | ✅ Comparable |
| 5 | XP & player levels | XP + level scaling | XP system | ✅ Comparable |
| 6 | Streak tracking | Streaks + freeze + milestones | Streaks (current/best) | 🔶 Missing freeze & milestones |
| 7 | Coins/currency | Coins from levels + purchases | Diamonds (earned) | 🔶 Different currency model |
| 8 | Adaptive difficulty | Per-rule performance tracking | History-based scaling | 🔶 iToosa more granular |
| 9 | Content volume | 8 worlds × 15 levels = 120 | 6 tracks × 10 levels = 60 | 🔶 Need more content |
| 10 | World unlock system | Linear (complete to unlock) | All tracks accessible | 🔶 No gating currently |
| 11 | **Game modes** | 4 extra modes | Run mode only | ❌ Missing |
| 12 | **Achievements** | 50+ across 5 categories | Achievement set (data only) | ❌ Missing UI + logic |
| 13 | **Daily rewards** | 7-day login cycle | None | ❌ Missing |
| 14 | **Missions/quests** | Daily (3) + Weekly (1) | None | ❌ Missing |
| 15 | **Skill radar** | 6-axis chart | None | ❌ Missing |
| 16 | **Leaderboard** | Game Center integration | Placeholder screen | ❌ Missing |
| 17 | **Store / IAP** | Consumables + cosmetics + subs | None | ❌ Missing |
| 18 | **Season pass** | 30-tier free/premium tracks | None | ❌ Missing |
| 19 | **Cosmetics** | Themes + effects + icons + rarity | None | ❌ Missing |
| 20 | **Power-ups** | 4 types (hint, 50/50, freeze, 2nd chance) | None | ❌ Missing |
| 21 | **Streak calendar** | 30-day visual history | None | ❌ Missing |
| 22 | **Streak freeze** | Skip missed day item | None | ❌ Missing |
| 23 | **Haptics** | Impact/notification/custom patterns | None | ❌ Missing |
| 24 | **Background music** | Ambient + fade in/out | SFX only (music reserved v1.3) | ❌ Missing |
| 25 | **Settings screen** | Audio, music, haptics, dev mode | Partial/stub | ❌ Missing full UI |
| 26 | **Analytics** | Protocol-based service | None | ❌ Missing |
| 27 | **Notifications** | Local reminders | None | ❌ Missing |
| 28 | **Daily challenge** | Single daily puzzle | None | ❌ Missing |
| 29 | **Endless mode** | Infinite puzzles | None | ❌ Missing |
| 30 | **Timed sprint** | Speed challenge mode | None | ❌ Missing |
| 31 | **Practice mode** | Per-rule skill practice | None | ❌ Missing |
| 32 | **Profile screen** | Player profile with cosmetics | None | ❌ Missing |
| 33 | Onboarding | Splash + setup | 3-page onboarding | ✅ miToosa has it |
| 34 | How-to-play | N/A | Per-world tutorial modal | ✅ miToosa is ahead |
| 35 | Share refuel | N/A | +1 heart per share/day | ✅ miToosa unique |
| 36 | Run timer + diamond bonus | N/A | Run countdown + 💎 bonus | ✅ miToosa unique |
| 37 | Cross-platform | iOS only | iOS + Android + Web | ✅ miToosa is ahead |
| 38 | Encrypted persistence | SwiftData | AES-encrypted Hive | ✅ miToosa is ahead |
| 39 | Test coverage | Basic unit tests | 256 tests, zero lint | ✅ miToosa is ahead |

---

## Feature Migration Priorities

### Tier 1 — High Impact, Medium Effort (v1.3)
Core engagement features that directly improve retention and session depth.

| Priority | Feature | Why | Effort |
|----------|---------|-----|--------|
| P1 | **Achievements system** | Visible long-term goals; iToosa has 50+ | M |
| P2 | **Daily rewards (7-day cycle)** | #1 retention driver; login incentive | S |
| P3 | **Streak freeze + milestones** | Protects streaks; milestone rewards | S |
| P4 | **Haptics service** | Instant feel improvement; low risk | S |
| P5 | **Background music** | Audio completeness; already reserved | S |
| P6 | **Settings screen (full)** | Audio, haptics, music toggles | S |
| P7 | **Streak calendar UI** | Visual streak history; motivational | S |

### Tier 2 — High Impact, Higher Effort (v1.4)
Game modes and progression depth.

| Priority | Feature | Why | Effort |
|----------|---------|-----|--------|
| P8 | **Daily challenge mode** | Daily engagement hook; shareable | M |
| P9 | **Practice mode (per-rule)** | Targeted skill building | M |
| P10 | **Skill radar (6-axis)** | Performance visualization; motivational | M |
| P11 | **Power-ups (4 types)** | Strategic depth; monetization base | M |
| P12 | **Missions (daily + weekly)** | Directed short-term goals | M |
| P13 | **More content (8 tracks × 15)** | Double level count to 120 | M |
| P14 | **World unlock gating** | Progression feels earned | S |
| P15 | **Adaptive difficulty per-rule** | Enhance existing system | S |

### Tier 3 — Monetization & Social (v1.5+)
Revenue and community features requiring careful design.

| Priority | Feature | Why | Effort |
|----------|---------|-----|--------|
| P16 | **Cosmetics system** | Themes, effects, icons, rarity | L |
| P17 | **Store / IAP** | Revenue stream; platform APIs | L |
| P18 | **Season pass (30-tier)** | Recurring engagement + revenue | L |
| P19 | **Leaderboard** | Social competition | M |
| P20 | **Endless mode** | Session extender | M |
| P21 | **Timed sprint mode** | Competitive challenge | M |
| P22 | **Profile screen** | Identity + cosmetic showcase | M |
| P23 | **Analytics service** | Data-driven iteration | M |
| P24 | **Local notifications** | Re-engagement | S |

**Effort key:** S = 1–2 days, M = 3–5 days, L = 1–2 weeks

---

## Data Model Additions (Hive Schema v4+)

New fields required on `PlayerProgress`:

```dart
// === v1.3 Engagement (schema v4) ===
int field17_streakFreezeCount;         // Available freeze items
List<String> field18_streakMilestones; // Achieved milestones (3,7,14,30,60,90,180,365)
Set<String> field19_unlockedAchievements; // Achievement IDs
Map<String, int> field20_achievementProgress; // Partial progress counters
int field21_dailyRewardDay;            // Current day in 7-day cycle (0-6)
DateTime? field22_lastDailyRewardClaim; // Last claim timestamp

// === v1.4 Game Modes (schema v5) ===
Map<String, double> field23_skillRadarScores; // 6 axes (0.0-1.0)
int field24_skillRadarAttempts;        // Total attempts for EMA
Map<String, dynamic> field25_dailyChallengeData; // Today's challenge state
Set<String> field26_completedMissions; // Mission IDs
Map<String, int> field27_missionProgress; // Partial progress
int field28_powerUpHint;               // Available hint power-ups
int field29_powerUpEliminator;         // Available 50/50 power-ups
int field30_powerUpTimeFreeze;         // Available time freeze power-ups
int field31_powerUpSecondChance;       // Available second chance power-ups

// === v1.5 Cosmetics & Store (schema v6) ===
String field32_activeTheme;            // Current theme ID
String field33_activeCelebration;      // Current celebration effect
String field34_activeProfileIcon;      // Current profile icon
Set<String> field35_ownedCosmetics;    // All owned cosmetic IDs
int field36_seasonPassTier;            // Current season tier
int field37_seasonPassXP;              // Season XP accumulated
bool field38_seasonPassPremium;        // Premium purchased?
Set<String> field39_claimedSeasonRewards; // Claimed tier reward IDs
```

---

## Architecture Approach

### What stays the same
- **Pure-Dart engine** — All game logic remains UI-free and testable
- **Riverpod 3** — State management via code-gen providers
- **Hive + AES** — Persistence with encrypted storage
- **Feature folders** — `lib/features/{feature_name}/`

### New patterns to adopt from iToosa
| Pattern | Where | Why |
|---------|-------|-----|
| **Protocol-driven services** | Haptics, Analytics, Notifications | Testable via mocks |
| **EMA smoothing** | Skill radar scores | Stable performance metrics |
| **Domain engine per feature** | Achievements, Missions, Season Pass | Isolated logic, easy to test |
| **Cosmetic rarity system** | Store/Cosmetics | Perceived value hierarchy |

### New feature folder structure
```
lib/features/
  achievements/        # Achievement engine + UI
  daily_rewards/       # 7-day cycle logic + modal
  daily_challenge/     # Daily puzzle mode
  missions/            # Daily/weekly quest system
  practice/            # Per-rule practice mode
  skill_radar/         # 6-axis chart + engine
  power_ups/           # 4 power-up types
  cosmetics/           # Theme/effect/icon system
  store/               # IAP integration
  season_pass/         # 30-tier progression
  streak_calendar/     # Visual streak history
  settings/            # Full settings screen (expand existing)
  profile/             # Player profile
  leaderboard/         # Expand existing placeholder
lib/core/
  haptics_service.dart
  music_service.dart
  analytics_service.dart
  notification_service.dart
```

---

## Testing Strategy

Each feature migration follows the project's TDD workflow:
1. Write failing tests for the new engine/domain logic
2. Implement pure-Dart engine
3. Write widget tests for new UI
4. Implement UI
5. Integration test the feature end-to-end

**Target:** Maintain 100% test pass rate; add ~50 tests per tier.

---

## Boundaries

### Always do
- Run `flutter test` before every commit
- Write engine logic in pure Dart (no Flutter imports)
- Migrate Hive schema with backward compatibility
- Validate all user input at system boundaries

### Ask first
- Adding new pub.dev dependencies
- Hive schema version bumps
- Platform-specific API integrations (IAP, Game Center, haptics)
- Content structure changes (worlds.json, levels.json)

### Never do
- Break existing 256 tests
- Remove or skip failing tests
- Hardcode secrets or API keys
- Mix formatting changes with behavior changes

---

## What miToosa Already Has That's Better

These miToosa features should be **preserved, not overwritten** by iToosa patterns:

| Feature | miToosa Advantage |
|---------|-------------------|
| 23 puzzle rules | 3 more than iToosa (CS/security + geometry categories) |
| 5-heart system with 3 refuel paths | More generous than iToosa's 3-heart system |
| Share-based heart refuel | Unique viral mechanic |
| Run timer + diamond bonus | Unique session-length incentive |
| Per-world how-to-play tutorial | Better onboarding per track |
| AES-encrypted Hive | Stronger persistence security |
| Cross-platform (iOS + Android + Web) | iToosa is iOS-only |
| 256 tests, zero lint | Superior test coverage |

---

## Open Questions

1. **Currency model:** iToosa uses coins + hints separately. miToosa uses diamonds. Should we add coins alongside diamonds, or keep diamonds as the single currency?
2. **Heart count:** iToosa has 3 hearts, miToosa has 5. Keep 5?
3. **Content expansion:** Add 2 new tracks to reach 8, or add levels to existing 6 tracks to reach 15 each?
4. **Monetization timeline:** Is IAP/Store a v1.5 goal or later?
5. **Leaderboard backend:** Client-only (local) or cloud-based?
6. **Analytics provider:** Firebase, Mixpanel, or custom?
7. **Season pass cadence:** Monthly? Quarterly?

---

## Implementation Roadmap

```
v1.3 (Tier 1)          v1.4 (Tier 2)            v1.5 (Tier 3)
┌──────────────┐      ┌──────────────┐         ┌──────────────┐
│ Achievements │      │ Daily Chall. │         │ Cosmetics    │
│ Daily Rewards│      │ Practice Mode│         │ Store / IAP  │
│ Streak Freeze│      │ Skill Radar  │         │ Season Pass  │
│ Haptics      │      │ Power-Ups    │         │ Leaderboard  │
│ Music        │      │ Missions     │         │ Endless Mode │
│ Settings     │      │ More Content │         │ Timed Sprint │
│ Streak Cal.  │      │ World Gating │         │ Profile      │
│              │      │ Adaptive Diff│         │ Analytics    │
│              │      │              │         │ Notifications│
└──────────────┘      └──────────────┘         └──────────────┘
 ~7 features            ~8 features              ~9 features
 Schema v4              Schema v5                Schema v6
 ~2 weeks               ~3 weeks                 ~4 weeks
```

---

## Next Steps

1. **Human reviews this spec** — Answer open questions, adjust priorities
2. `/plan` — Break Tier 1 into atomic, ordered implementation tasks
3. `/build` — Implement incrementally (one feature at a time, TDD)
4. `/test` — Validate each feature before moving to next
5. `/review` — Code review before merging each tier
