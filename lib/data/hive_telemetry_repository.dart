import 'dart:developer' as developer;

import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import 'telemetry_event.dart';
import 'telemetry_repository.dart';

class HiveTelemetryRepository implements TelemetryRepository {
  static const String defaultBoxName = 'telemetry_event_box';

  final String boxName;
  final int maxEvents;
  final Uuid _uuid;

  Box<dynamic>? _box;

  HiveTelemetryRepository({
    this.boxName = defaultBoxName,
    this.maxEvents = 500,
    Uuid? uuid,
  }) : _uuid = uuid ?? const Uuid();

  @override
  Future<void> init() async {
    if (_box?.isOpen ?? false) return;
    try {
      _box = await Hive.openBox<dynamic>(boxName);
    } catch (error, stackTrace) {
      developer.log(
        'Failed to open telemetry box: $error',
        name: 'telemetry.hive_repository',
        level: 900,
        error: error,
        stackTrace: stackTrace,
      );
      _box = null;
    }
  }

  @override
  Future<void> record(TelemetryEvent event) async {
    await init();
    final box = _box;
    if (box == null) return;

    try {
      await box.put(_storageKey(event), event.toJson());
      await _pruneIfNeeded();
    } catch (error, stackTrace) {
      developer.log(
        'Failed to record telemetry event: $error',
        name: 'telemetry.hive_repository',
        level: 900,
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<List<TelemetryEvent>> readAll() async {
    await init();
    final box = _box;
    if (box == null) return const [];

    final events = box.toMap().entries.map((entry) {
      final raw = entry.value;
      if (raw is! Map) {
        throw const FormatException('Telemetry payload must be a map');
      }
      return MapEntry(
        entry.key.toString(),
        TelemetryEvent.fromJson(Map<dynamic, dynamic>.from(raw)),
      );
    }).toList();

    events.sort((left, right) {
      final timestampCompare = left.value.timestamp.compareTo(right.value.timestamp);
      if (timestampCompare != 0) return timestampCompare;
      return left.key.compareTo(right.key);
    });

    return events.map((entry) => entry.value).toList(growable: false);
  }

  @override
  Future<void> clear() async {
    await init();
    final box = _box;
    if (box == null) return;
    await box.clear();
  }

  String _storageKey(TelemetryEvent event) {
    return '${event.timestamp.microsecondsSinceEpoch}_${_uuid.v4()}';
  }

  Future<void> _pruneIfNeeded() async {
    final box = _box;
    if (box == null || box.length <= maxEvents) return;

    final orderedEntries = box.toMap().entries.map((entry) {
      final raw = entry.value;
      if (raw is! Map) {
        throw const FormatException('Telemetry payload must be a map');
      }
      return MapEntry(
        entry.key.toString(),
        TelemetryEvent.fromJson(Map<dynamic, dynamic>.from(raw)),
      );
    }).toList()
      ..sort((left, right) {
        final timestampCompare = left.value.timestamp.compareTo(right.value.timestamp);
        if (timestampCompare != 0) return timestampCompare;
        return left.key.compareTo(right.key);
      });

    final excess = orderedEntries.length - maxEvents;
    for (var i = 0; i < excess; i++) {
      await box.delete(orderedEntries[i].key);
    }
  }
}