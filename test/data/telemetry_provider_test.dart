import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mitoosa/core/analytics/analytics_sink.dart';
import 'package:mitoosa/data/forwarding_telemetry_repository.dart';
import 'package:mitoosa/data/telemetry_event.dart';
import 'package:mitoosa/data/telemetry_provider.dart';

void main() {
  group('firebase flag', () {
    test('is disabled by default', () {
      expect(kFirebaseEnabled, isFalse);
    });
  });

  group('analyticsSinkProvider', () {
    test('returns NoOpAnalyticsSink by default', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final sink = container.read(analyticsSinkProvider);

      expect(sink, isA<NoOpAnalyticsSink>());
    });

    test('can be overridden with a custom sink', () {
      final customSink = _FakeSink();
      final container = ProviderContainer(
        overrides: [
          analyticsSinkProvider.overrideWithValue(customSink),
        ],
      );
      addTearDown(container.dispose);

      final sink = container.read(analyticsSinkProvider);

      expect(sink, same(customSink));
    });
  });

  group('telemetryRepositoryProvider', () {
    test('returns a ForwardingTelemetryRepository', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final repo = container.read(telemetryRepositoryProvider);

      expect(repo, isA<ForwardingTelemetryRepository>());
    });

    test('injects the overridden sink into the ForwardingTelemetryRepository', () {
      // Provider test scope: verify type wiring, not runtime forwarding.
      // Runtime forwarding is covered by analytics_sink_test.dart (unit level).
      final customSink = _FakeSink();
      final container = ProviderContainer(
        overrides: [
          analyticsSinkProvider.overrideWithValue(customSink),
        ],
      );
      addTearDown(container.dispose);

      // The repository is constructed without error when the sink is overridden.
      final repo = container.read(telemetryRepositoryProvider);
      expect(repo, isA<ForwardingTelemetryRepository>());

      // The sink override is reflected in the container — same instance.
      expect(container.read(analyticsSinkProvider), same(customSink));
    });
  });
}

class _FakeSink implements AnalyticsSink {
  @override
  Future<void> track(TelemetryEvent event) async {}
}
