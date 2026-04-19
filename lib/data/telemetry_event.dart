class TelemetryEvent {
  final String name;
  final DateTime timestamp;
  final Map<String, Object?> properties;

  const TelemetryEvent({
    required this.name,
    required this.timestamp,
    this.properties = const {},
  });

  factory TelemetryEvent.sessionStart({
    required String sessionId,
    DateTime? timestamp,
    String source = 'main_app_shell',
  }) {
    return TelemetryEvent(
      name: 'session_start',
      timestamp: (timestamp ?? DateTime.now()).toUtc(),
      properties: {
        'session_id': sessionId,
        'source': source,
      },
    );
  }

  factory TelemetryEvent.sessionEnd({
    required String sessionId,
    required Duration duration,
    DateTime? timestamp,
    String source = 'main_app_shell',
  }) {
    return TelemetryEvent(
      name: 'session_end',
      timestamp: (timestamp ?? DateTime.now()).toUtc(),
      properties: {
        'session_id': sessionId,
        'source': source,
        'duration_ms': duration.inMilliseconds,
      },
    );
  }

  Map<String, Object?> toJson() {
    return {
      'name': name,
      'timestamp': timestamp.toUtc().toIso8601String(),
      'properties': properties,
    };
  }

  factory TelemetryEvent.fromJson(Map<dynamic, dynamic> json) {
    final name = json['name'];
    final timestamp = json['timestamp'];
    final properties = json['properties'];

    if (name is! String) {
      throw const FormatException('TelemetryEvent.name must be a string');
    }
    if (timestamp is! String) {
      throw const FormatException('TelemetryEvent.timestamp must be a string');
    }
    if (properties is! Map) {
      throw const FormatException('TelemetryEvent.properties must be a map');
    }

    return TelemetryEvent(
      name: name,
      timestamp: DateTime.parse(timestamp).toUtc(),
      properties: Map<String, Object?>.from(properties),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TelemetryEvent &&
        other.name == name &&
        other.timestamp == timestamp &&
        _mapsEqual(other.properties, properties);
  }

  @override
  int get hashCode => Object.hash(name, timestamp, _mapHash(properties));

  // ─── v1.3 engagement events ────────────────────────────────

  factory TelemetryEvent.levelComplete({
    required String trackId,
    required int levelIndex,
    required int stars,
    required int coinReward,
    DateTime? timestamp,
  }) {
    return TelemetryEvent(
      name: 'level_complete',
      timestamp: (timestamp ?? DateTime.now()).toUtc(),
      properties: {
        'track_id': trackId,
        'level_index': levelIndex,
        'stars': stars,
        'coin_reward': coinReward,
      },
    );
  }

  factory TelemetryEvent.streakUpdate({
    required int streakCount,
    required String result, // continued, frozen, broken
    DateTime? timestamp,
  }) {
    return TelemetryEvent(
      name: 'streak_update',
      timestamp: (timestamp ?? DateTime.now()).toUtc(),
      properties: {
        'streak_count': streakCount,
        'result': result,
      },
    );
  }

  factory TelemetryEvent.achievementUnlocked({
    required String achievementId,
    required int coinReward,
    DateTime? timestamp,
  }) {
    return TelemetryEvent(
      name: 'achievement_unlocked',
      timestamp: (timestamp ?? DateTime.now()).toUtc(),
      properties: {
        'achievement_id': achievementId,
        'coin_reward': coinReward,
      },
    );
  }

  factory TelemetryEvent.dailyRewardClaimed({
    required int day,
    required int coins,
    DateTime? timestamp,
  }) {
    return TelemetryEvent(
      name: 'daily_reward_claimed',
      timestamp: (timestamp ?? DateTime.now()).toUtc(),
      properties: {
        'day': day,
        'coins': coins,
      },
    );
  }

  // ─── v2.0 wedge events ─────────────────────────────────────

  factory TelemetryEvent.allowanceCheck({
    required int remaining,
    required int dailyLimit,
    required bool hasBonusToday,
    DateTime? timestamp,
  }) {
    return TelemetryEvent(
      name: 'allowance_check',
      timestamp: (timestamp ?? DateTime.now()).toUtc(),
      properties: {
        'remaining': remaining,
        'daily_limit': dailyLimit,
        'has_bonus_today': hasBonusToday,
      },
    );
  }

  factory TelemetryEvent.allowanceDepleted({
    required int dailyLimit,
    DateTime? timestamp,
  }) {
    return TelemetryEvent(
      name: 'allowance_depleted',
      timestamp: (timestamp ?? DateTime.now()).toUtc(),
      properties: {
        'daily_limit': dailyLimit,
      },
    );
  }

  factory TelemetryEvent.shareAttempt({
    required String result, // success, dismissed, failed
    DateTime? timestamp,
  }) {
    return TelemetryEvent(
      name: 'share_attempt',
      timestamp: (timestamp ?? DateTime.now()).toUtc(),
      properties: {
        'result': result,
      },
    );
  }

  factory TelemetryEvent.shareBonusGranted({
    required int bonusGames,
    DateTime? timestamp,
  }) {
    return TelemetryEvent(
      name: 'share_bonus_granted',
      timestamp: (timestamp ?? DateTime.now()).toUtc(),
      properties: {
        'bonus_games': bonusGames,
      },
    );
  }

  factory TelemetryEvent.upgradeShown({
    required String placement, // allowance_depleted, settings, streak_screen
    DateTime? timestamp,
  }) {
    return TelemetryEvent(
      name: 'upgrade_shown',
      timestamp: (timestamp ?? DateTime.now()).toUtc(),
      properties: {
        'placement': placement,
      },
    );
  }

  factory TelemetryEvent.upgradeTapped({
    required String placement,
    DateTime? timestamp,
  }) {
    return TelemetryEvent(
      name: 'upgrade_tapped',
      timestamp: (timestamp ?? DateTime.now()).toUtc(),
      properties: {
        'placement': placement,
      },
    );
  }
}

bool _mapsEqual(Map<String, Object?> left, Map<String, Object?> right) {
  if (left.length != right.length) return false;
  for (final entry in left.entries) {
    if (!right.containsKey(entry.key)) return false;
    if (right[entry.key] != entry.value) return false;
  }
  return true;
}

int _mapHash(Map<String, Object?> map) {
  final keys = map.keys.toList()..sort();
  return Object.hashAll([
    for (final key in keys) key,
    for (final key in keys) map[key],
  ]);
}