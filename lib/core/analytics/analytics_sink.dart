import '../../data/telemetry_event.dart';

/// Forwards telemetry events to an external analytics backend.
///
/// Implement this to integrate Firebase, Amplitude, Posthog, or any other
/// backend. The default provider is [NoOpAnalyticsSink], which drops all
/// events silently until a real backend is wired in.
abstract class AnalyticsSink {
  Future<void> track(TelemetryEvent event);
}

/// No-op sink used until a real analytics backend is selected.
class NoOpAnalyticsSink implements AnalyticsSink {
  const NoOpAnalyticsSink();

  @override
  Future<void> track(TelemetryEvent event) async {}
}
