import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

import '../../data/telemetry_event.dart';
import 'analytics_sink.dart';

class FirebaseAnalyticsSink implements AnalyticsSink {
  final FirebaseAnalytics _analytics;

  const FirebaseAnalyticsSink(this._analytics);

  @override
  Future<void> track(TelemetryEvent event) {
    final parameters = sanitizeParameters(event.properties);

    return _analytics.logEvent(
      name: event.name,
      parameters: parameters,
    );
  }

  @visibleForTesting
  static Map<String, Object>? sanitizeParameters(
    Map<String, Object?> properties,
  ) {
    final parameters = <String, Object>{};

    for (final entry in properties.entries) {
      final value = entry.value;
      if (value == null) {
        continue;
      }

      if (value is String || value is num || value is bool) {
        parameters[entry.key] = value;
        continue;
      }

      if (value is DateTime) {
        parameters[entry.key] = value.toUtc().toIso8601String();
        continue;
      }

      if (value is Duration) {
        parameters[entry.key] = value.inMilliseconds;
        continue;
      }

      parameters[entry.key] = value.toString();
    }

    return parameters.isEmpty ? null : parameters;
  }
}