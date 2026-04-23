import 'package:flutter_test/flutter_test.dart';
import 'package:mitoosa/core/analytics/analytics_sink.dart';
import 'package:mitoosa/data/forwarding_telemetry_repository.dart';
import 'package:mitoosa/data/telemetry_event.dart';
import 'package:mitoosa/data/telemetry_repository.dart';

// Minimal in-memory repository for testing.
class _MemoryRepository implements TelemetryRepository {
  final List<TelemetryEvent> events = [];
  bool initCalled = false;

  @override
  Future<void> init() async {
    initCalled = true;
  }

  @override
  Future<void> record(TelemetryEvent event) async => events.add(event);

  @override
  Future<List<TelemetryEvent>> readAll() async => List.unmodifiable(events);

  @override
  Future<void> clear() async => events.clear();
}

// Sink that records every tracked event for assertion.
class _CapturingSink implements AnalyticsSink {
  final List<TelemetryEvent> captured = [];

  @override
  Future<void> track(TelemetryEvent event) async => captured.add(event);
}

// Sink that always throws — used to test fault-tolerance.
class _ThrowingSink implements AnalyticsSink {
  @override
  Future<void> track(TelemetryEvent event) async =>
      throw Exception('sink unavailable');
}

void main() {
  group('NoOpAnalyticsSink', () {
    test('track completes without error', () async {
      const sink = NoOpAnalyticsSink();
      final event = TelemetryEvent.sessionStart(sessionId: 'test-id');
      await expectLater(sink.track(event), completes);
    });

    test('is a const constructor — two instances are identical', () {
      const a = NoOpAnalyticsSink();
      const b = NoOpAnalyticsSink();
      expect(identical(a, b), isTrue);
    });
  });

  group('ForwardingTelemetryRepository', () {
    late _MemoryRepository inner;
    late _CapturingSink sink;
    late ForwardingTelemetryRepository repo;

    setUp(() {
      inner = _MemoryRepository();
      sink = _CapturingSink();
      repo = ForwardingTelemetryRepository(inner, sink);
    });

    test('record persists event to inner repository', () async {
      final event = TelemetryEvent.sessionStart(sessionId: 'abc');
      await repo.record(event);

      expect(inner.events, hasLength(1));
      expect(inner.events.first.name, equals('session_start'));
    });

    test('record forwards event to analytics sink', () async {
      final event = TelemetryEvent.sessionStart(sessionId: 'abc');
      await repo.record(event);

      expect(sink.captured, hasLength(1));
      expect(sink.captured.first.name, equals('session_start'));
    });

    test('record forwards same event instance to both inner and sink', () async {
      final event = TelemetryEvent.levelComplete(
        trackId: 'track-1',
        levelIndex: 3,
        stars: 4,
        coinReward: 50,
      );
      await repo.record(event);

      expect(inner.events.first, equals(sink.captured.first));
    });

    test('readAll delegates to inner repository', () async {
      final event = TelemetryEvent.streakUpdate(
        streakCount: 7,
        result: 'continued',
      );
      await repo.record(event);

      final all = await repo.readAll();
      expect(all, hasLength(1));
      expect(all.first.name, equals('streak_update'));
    });

    test('clear delegates to inner repository', () async {
      await repo.record(TelemetryEvent.sessionStart(sessionId: 'x'));
      await repo.clear();

      expect(inner.events, isEmpty);
    });

    test('init delegates to inner repository', () async {
      expect(inner.initCalled, isFalse);
      await repo.init();
      expect(inner.initCalled, isTrue);
    });

    test('sink failure is caught — inner record still succeeds', () async {
      // A flaky or misconfigured backend must not interrupt Hive writes.
      final throwingSink = _ThrowingSink();
      final faultTolerantRepo = ForwardingTelemetryRepository(inner, throwingSink);

      final event = TelemetryEvent.sessionStart(sessionId: 'y');
      await expectLater(faultTolerantRepo.record(event), completes);

      // Event is durably stored even though the sink threw.
      expect(inner.events, hasLength(1));
      expect(inner.events.first.name, equals('session_start'));
    });

    test('multiple events are forwarded in order', () async {
      final e1 = TelemetryEvent.sessionStart(sessionId: 's1');
      final e2 = TelemetryEvent.levelComplete(
        trackId: 't1',
        levelIndex: 1,
        stars: 3,
        coinReward: 10,
      );
      await repo.record(e1);
      await repo.record(e2);

      expect(sink.captured.map((e) => e.name).toList(),
          equals(['session_start', 'level_complete']));
    });
  });
}
