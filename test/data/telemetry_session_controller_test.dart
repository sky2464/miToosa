import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mitoosa/data/telemetry_event.dart';
import 'package:mitoosa/data/telemetry_repository.dart';
import 'package:mitoosa/data/telemetry_session_controller.dart';

class FakeTelemetryRepository implements TelemetryRepository {
  final List<TelemetryEvent> recorded = [];

  @override
  Future<void> init() async {}

  @override
  Future<void> record(TelemetryEvent event) async {
    recorded.add(event);
  }

  @override
  Future<List<TelemetryEvent>> readAll() async => List.unmodifiable(recorded);

  @override
  Future<void> clear() async {
    recorded.clear();
  }
}

void main() {
  test('records a single session start/end pair', () async {
    final repo = FakeTelemetryRepository();
    final controller = TelemetrySessionController(repo);

    await controller.startSession();
    await controller.startSession();
    await controller.endSession();
    await controller.endSession();

    expect(repo.recorded.length, 2);
    expect(repo.recorded.map((e) => e.name), ['session_start', 'session_end']);
    expect(repo.recorded.first.properties['session_id'], isNotNull);
    expect(repo.recorded.last.properties['duration_ms'], isA<int>());
  });

  test('maps lifecycle pause/resume to session end/start', () async {
    final repo = FakeTelemetryRepository();
    final controller = TelemetrySessionController(repo);

    await controller.handleLifecycleState(AppLifecycleState.resumed);
    await controller.handleLifecycleState(AppLifecycleState.inactive);
    await controller.handleLifecycleState(AppLifecycleState.paused);
    await controller.handleLifecycleState(AppLifecycleState.resumed);

    expect(repo.recorded.map((e) => e.name), [
      'session_start',
      'session_end',
      'session_start',
    ]);
  });
}
