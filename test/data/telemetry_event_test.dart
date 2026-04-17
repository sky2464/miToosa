import 'package:flutter_test/flutter_test.dart';
import 'package:mitoosa/data/telemetry_event.dart';

void main() {
  test('TelemetryEvent serializes and deserializes round-trip', () {
    final event = TelemetryEvent(
      name: 'session_start',
      timestamp: DateTime.utc(2026, 4, 17, 12, 30),
      properties: const {
        'session_id': 'abc-123',
        'source': 'main_app_shell',
      },
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
}
