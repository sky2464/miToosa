import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:uuid/uuid.dart';

import 'telemetry_event.dart';
import 'telemetry_repository.dart';

class TelemetrySessionController {
  final TelemetryRepository repository;
  final String source;

  final Uuid _uuid;
  String? _activeSessionId;
  DateTime? _sessionStartedAt;

  TelemetrySessionController(
    this.repository, {
    this.source = 'main_app_shell',
    Uuid? uuid,
  }) : _uuid = uuid ?? const Uuid();

  bool get isSessionActive => _activeSessionId != null;

  Future<void> handleLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.resumed:
        await startSession();
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        await endSession();
        break;
      case AppLifecycleState.inactive:
        break;
    }
  }

  Future<void> startSession({DateTime? now}) async {
    if (_activeSessionId != null) return;

    final startedAt = (now ?? DateTime.now()).toUtc();
    final sessionId = _uuid.v4();
    _activeSessionId = sessionId;
    _sessionStartedAt = startedAt;

    await repository.record(
      TelemetryEvent.sessionStart(
        sessionId: sessionId,
        timestamp: startedAt,
        source: source,
      ),
    );
  }

  Future<void> endSession({DateTime? now}) async {
    final sessionId = _activeSessionId;
    final startedAt = _sessionStartedAt;
    if (sessionId == null || startedAt == null) return;

    final endedAt = (now ?? DateTime.now()).toUtc();
    _activeSessionId = null;
    _sessionStartedAt = null;

    final duration = endedAt.difference(startedAt);
    await repository.record(
      TelemetryEvent.sessionEnd(
        sessionId: sessionId,
        duration: duration,
        timestamp: endedAt,
        source: source,
      ),
    );
  }
}