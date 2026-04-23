import 'dart:developer' as developer;

import '../core/analytics/analytics_sink.dart';
import 'telemetry_event.dart';
import 'telemetry_repository.dart';

/// Wraps a [TelemetryRepository] and forwards every recorded event to an
/// [AnalyticsSink]. All read operations delegate to the inner repository.
///
/// Sink failures are caught and logged — they never interrupt the inner write.
/// This ensures a misconfigured or unavailable analytics backend cannot
/// prevent events from reaching local Hive storage.
class ForwardingTelemetryRepository implements TelemetryRepository {
  final TelemetryRepository _inner;
  final AnalyticsSink _sink;

  const ForwardingTelemetryRepository(this._inner, this._sink);

  @override
  Future<void> init() => _inner.init();

  @override
  Future<void> record(TelemetryEvent event) async {
    await _inner.record(event);
    try {
      await _sink.track(event);
    } catch (error, stackTrace) {
      developer.log(
        'Analytics sink failed for event "${event.name}": $error',
        name: 'telemetry.forwarding_repository',
        level: 900,
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<List<TelemetryEvent>> readAll() => _inner.readAll();

  @override
  Future<void> clear() => _inner.clear();
}
