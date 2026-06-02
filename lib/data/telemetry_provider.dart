import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

import '../core/analytics/analytics_sink.dart';
import '../core/analytics/firebase_analytics_sink.dart';
import 'forwarding_telemetry_repository.dart';
import 'hive_telemetry_repository.dart';
import 'telemetry_repository.dart';
import 'telemetry_session_controller.dart';

const kFirebaseEnabled = bool.fromEnvironment(
  'FIREBASE_ENABLED',
  defaultValue: false,
);

final analyticsSinkProvider = Provider<AnalyticsSink>((ref) {
  if (kFirebaseEnabled) {
    return FirebaseAnalyticsSink(FirebaseAnalytics.instance);
  }
  return const NoOpAnalyticsSink();
});

final telemetryRepositoryProvider = Provider<TelemetryRepository>((ref) {
  final sink = ref.watch(analyticsSinkProvider);
  return ForwardingTelemetryRepository(HiveTelemetryRepository(), sink);
});

final telemetrySessionControllerProvider = Provider<TelemetrySessionController>(
  (ref) {
    return TelemetrySessionController(ref.watch(telemetryRepositoryProvider));
  },
);
