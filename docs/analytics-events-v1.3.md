# Analytics Events — v2.0 Wedge Metrics

All events extend the existing `TelemetryEvent` model in `lib/data/telemetry_event.dart`.
Events are stored locally via Hive and can be exported to a remote backend when one is added.

## Event Catalog

| Event Name | Trigger | Key Properties |
|---|---|---|
| `level_complete` | Player finishes a puzzle level | `track_id`, `level_index`, `stars`, `coin_reward` |
| `streak_update` | Daily streak check runs | `streak_count`, `result` (continued/frozen/broken) |
| `achievement_unlocked` | Player earns a new achievement | `achievement_id`, `coin_reward` |
| `daily_reward_claimed` | Player claims daily reward | `day` (1–7), `coins` |
| `session_start` | App foreground (existing) | `session_id`, `source` |
| `session_end` | App background (existing) | `session_id`, `source`, `duration_ms` |

## Usage

```dart
// Level complete
TelemetryEvent.levelComplete(
  trackId: 'track_1',
  levelIndex: 3,
  stars: 4,
  coinReward: 30,
);

// Streak update
TelemetryEvent.streakUpdate(
  streakCount: 7,
  result: 'continued',
);

// Achievement
TelemetryEvent.achievementUnlocked(
  achievementId: 'streak_week',
  coinReward: 50,
);

// Daily reward
TelemetryEvent.dailyRewardClaimed(day: 3, coins: 20);
```

## Integration Points

1. **Gameplay screen** (`_saveProgress`) — emit `level_complete` after saving
2. **App startup / daily check** — emit `streak_update` when streak is evaluated
3. **Achievement evaluation** — emit `achievement_unlocked` for each newly unlocked
4. **Daily reward modal** — emit `daily_reward_claimed` on claim tap

## Storage

Events are persisted in the `telemetry_event_box` Hive box via `HiveTelemetryRepository`.
The repository is accessed through `telemetryRepositoryProvider` (Riverpod).

## v2.0 Wedge Events

| Event Name | Trigger | Key Properties |
|---|---|---|
| `allowance_check` | Game start when daily allowance is checked | `remaining`, `daily_limit`, `has_bonus_today` |
| `allowance_depleted` | Player uses last free game of the day | `daily_limit` |
| `share_attempt` | Player taps share button | `result` (success/dismissed/failed) |
| `share_bonus_granted` | Successful share awards bonus games | `bonus_games` |
| `upgrade_shown` | VIP/upgrade prompt displayed | `placement` |
| `upgrade_tapped` | Player taps upgrade CTA | `placement` |

### Emit locations

| Event | Code location |
|---|---|
| `allowance_check` | Gameplay screen, before round starts |
| `allowance_depleted` | Gameplay screen, after last allowance used |
| `share_attempt` | `WorldMapScreen._shareForHeart` (to be renamed `_shareForBonus`) |
| `share_bonus_granted` | Persistence layer, after share bonus is recorded |
| `upgrade_shown` | Wherever upgrade CTA is rendered |
| `upgrade_tapped` | Upgrade CTA onTap handler |

## Success Metrics (KPIs)

| Metric | Definition | Target |
|---|---|---|
| **D1 retention** | % of new users who return the next day | ≥ 30% |
| **D7 retention** | % of new users who return within 7 days | ≥ 15% |
| **First-session completion** | % of new users who finish at least 1 round | ≥ 80% |
| **Daily share rate** | % of active daily users who share | ≥ 10% |
| **Allowance depletion rate** | % of daily users who hit 0 remaining games | ≥ 20% |
| **Upgrade interest** | % of users shown upgrade who tap | ≥ 5% |
| **Session frequency** | Average sessions per user per week | ≥ 3 |

### How to compute each metric from events

- **D1 retention**: Count distinct users with `session_start` on day N+1 / distinct users with first `session_start` on day N.
- **D7 retention**: Count distinct users with `session_start` within days N+1..N+7 / distinct users with first `session_start` on day N.
- **First-session completion**: Count users with `level_complete` in first session / users with `session_start` (no prior sessions).
- **Daily share rate**: Count distinct users with `share_attempt` where result=success on day D / distinct users with `session_start` on day D.
- **Allowance depletion rate**: Count distinct users with `allowance_depleted` on day D / distinct users with `session_start` on day D.
- **Upgrade interest**: Count `upgrade_tapped` events / `upgrade_shown` events (per placement).
- **Session frequency**: Count `session_start` events per user per 7-day window.
