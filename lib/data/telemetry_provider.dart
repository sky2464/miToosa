import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/analytics/analytics_sink.dart';
import 'forwarding_telemetry_repository.dart';
import 'hive_telemetry_repository.dart';
import 'telemetry_repository.dart';
import 'telemetry_session_controller.dart';

/// Replace with a real [AnalyticsSink] once a backend is selected.
/// Example: `FirebaseAnalyticsSink()` or `AmplitudeAnalyticsSink()`.
final analyticsSinkProvider = Provider<AnalyticsSink>((ref) {
  return const NoOpAnalyticsSink();
});

final telemetryRepositoryProvider = Provider<TelemetryRepository>((ref) {
  final sink = ref.watch(analyticsSinkProvider);
  return ForwardingTelemetryRepository(HiveTelemetryRepository(), sink);
});

final telemetrySessionControllerProvider =
    Provider<TelemetrySessionController>((ref) {
  return TelemetrySessionController(ref.watch(telemetryRepositoryProvider));
});