import 'package:flutter_test/flutter_test.dart';
import 'package:mitoosa/data/telemetry_event.dart';

void main() {
  test('TelemetryEvent serializes and deserializes round-trip', () {
    final event = TelemetryEvent(
      name: 'session_start',
      timestamp: DateTime.utc(2026, 4, 17, 12, 30),
      properties: const {'session_id': 'abc-123', 'source': 'main_app_shell'},
    );

    final encoded = event.toJson();
    final decoded = TelemetryEvent.fromJson(encoded);

    expect(decoded.name, event.name);
    expect(decoded.timestamp, event.timestamp);
    expect(decoded.properties, event.properties);
  });

  test('TelemetryEvent rejects invalid payload shapes', () {
    expect(
      () => TelemetryEvent.fromJson({
        'name': 'session_start',
        'timestamp': 'not-a-date',
        'properties': const {},
      }),
      throwsA(isA<FormatException>()),
    );
  });

  // ─── v2.0 wedge event tests ────────────────────────────────

  test('allowanceCheck round-trips correctly', () {
    final event = TelemetryEvent.allowanceCheck(
      remaining: 20,
      dailyLimit: 25,
      hasBonusToday: false,
      timestamp: DateTime.utc(2026, 4, 18),
    );
    final decoded = TelemetryEvent.fromJson(event.toJson());
    expect(decoded.name, 'allowance_check');
    expect(decoded.properties['remaining'], 20);
    expect(decoded.properties['daily_limit'], 25);
    expect(decoded.properties['has_bonus_today'], false);
  });

  test('allowanceDepleted round-trips correctly', () {
    final event = TelemetryEvent.allowanceDepleted(
      dailyLimit: 25,
      timestamp: DateTime.utc(2026, 4, 18),
    );
    final decoded = TelemetryEvent.fromJson(event.toJson());
    expect(decoded.name, 'allowance_depleted');
    expect(decoded.properties['daily_limit'], 25);
  });

  test('shareAttempt round-trips correctly', () {
    final event = TelemetryEvent.shareAttempt(
      result: 'success',
      timestamp: DateTime.utc(2026, 4, 18),
    );
    final decoded = TelemetryEvent.fromJson(event.toJson());
    expect(decoded.name, 'share_attempt');
    expect(decoded.properties['result'], 'success');
  });

  test('shareBonusGranted round-trips correctly', () {
    final event = TelemetryEvent.shareBonusGranted(
      bonusGames: 40,
      timestamp: DateTime.utc(2026, 4, 18),
    );
    final decoded = TelemetryEvent.fromJson(event.toJson());
    expect(decoded.name, 'share_bonus_granted');
    expect(decoded.properties['bonus_games'], 40);
  });

  test('upgradeShown round-trips correctly', () {
    final event = TelemetryEvent.upgradeShown(
      placement: 'allowance_depleted',
      timestamp: DateTime.utc(2026, 4, 18),
    );
    final decoded = TelemetryEvent.fromJson(event.toJson());
    expect(decoded.name, 'upgrade_shown');
    expect(decoded.properties['placement'], 'allowance_depleted');
  });

  test('upgradeTapped round-trips correctly', () {
    final event = TelemetryEvent.upgradeTapped(
      placement: 'settings',
      timestamp: DateTime.utc(2026, 4, 18),
    );
    final decoded = TelemetryEvent.fromJson(event.toJson());
    expect(decoded.name, 'upgrade_tapped');
    expect(decoded.properties['placement'], 'settings');
  });
}
