import 'package:firebase_analytics/firebase_analytics.dart';

import '../../data/telemetry_event.dart';
import 'analytics_sink.dart';

class FirebaseAnalyticsSink implements AnalyticsSink {
  final FirebaseAnalytics _analytics;

  const FirebaseAnalyticsSink(this._analytics);

  @override
  Future<void> track(TelemetryEvent event) {
    final parameters = <String, Object>{
      for (final entry in event.properties.entries)
        if (entry.value != null) entry.key: entry.value as Object,
    };

    return _analytics.logEvent(
      name: event.name,
      parameters: parameters.isEmpty ? null : parameters,
    );
  }
}