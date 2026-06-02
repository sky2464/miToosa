import 'telemetry_event.dart';

abstract class TelemetryRepository {
  Future<void> init();
  Future<void> record(TelemetryEvent event);
  Future<List<TelemetryEvent>> readAll();
  Future<void> clear();
}
