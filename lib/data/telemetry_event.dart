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