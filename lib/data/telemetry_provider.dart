import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'hive_telemetry_repository.dart';
import 'telemetry_repository.dart';
import 'telemetry_session_controller.dart';

final telemetryRepositoryProvider = Provider<TelemetryRepository>((ref) {
  return HiveTelemetryRepository();
});

final telemetrySessionControllerProvider =
    Provider<TelemetrySessionController>((ref) {
  return TelemetrySessionController(ref.read(telemetryRepositoryProvider));
});