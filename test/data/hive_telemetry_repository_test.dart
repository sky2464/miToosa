import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mitoosa/data/hive_telemetry_repository.dart';
import 'package:mitoosa/data/telemetry_event.dart';

void main() {
  late Directory tempDir;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('mitoosa_telemetry_test_');
    Hive.init(tempDir.path);
  });

  tearDownAll(() async {
    await Hive.deleteBoxFromDisk(HiveTelemetryRepository.defaultBoxName);
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('records events and reads them back in order', () async {
    final repo = HiveTelemetryRepository(maxEvents: 10);
    await repo.init();

    final start = TelemetryEvent(
      name: 'session_start',
      timestamp: DateTime.utc(2026, 4, 17, 12, 0),
      properties: const {'session_id': 's1'},
    );
    final end = TelemetryEvent(
      name: 'session_end',
      timestamp: DateTime.utc(2026, 4, 17, 12, 5),
      properties: const {'session_id': 's1', 'duration_seconds': 300},
    );

    await repo.record(start);
    await repo.record(end);

    final events = await repo.readAll();
    expect(events, [start, end]);
  });

  test('prunes oldest events when maxEvents is exceeded', () async {
    final repo = HiveTelemetryRepository(maxEvents: 3);
    await repo.init();
    await repo.clear();

    for (var i = 0; i < 5; i++) {
      await repo.record(
        TelemetryEvent(
          name: 'session_start',
          timestamp: DateTime.utc(2026, 4, 17, 12, i),
          properties: {'session_id': 's$i'},
        ),
      );
    }

    final events = await repo.readAll();
    expect(events.length, 3);
    expect(events.map((e) => e.properties['session_id']), ['s2', 's3', 's4']);
  });
}
