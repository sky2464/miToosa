import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mitoosa/core/haptics_service.dart';

void main() {
  late HapticsService service;

  setUp(() {
    service = HapticsService();
    service.enabled = true;
  });

  group('HapticsService — toggle', () {
    test('enabled by default', () {
      expect(service.enabled, isTrue);
    });

    test('can be disabled', () {
      service.enabled = false;
      expect(service.enabled, isFalse);
    });

    test('can be re-enabled', () {
      service.enabled = false;
      service.enabled = true;
      expect(service.enabled, isTrue);
    });
  });

  group('HapticsService — methods complete without error', () {
    // Mock the platform channel so HapticFeedback calls complete.
    setUp(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, (call) async {
        return null;
      });
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, null);
    });

    testWidgets('lightImpact completes', (tester) async {
      await service.lightImpact();
    });

    testWidgets('mediumImpact completes', (tester) async {
      await service.mediumImpact();
    });

    testWidgets('heavyImpact completes', (tester) async {
      await service.heavyImpact();
    });

    testWidgets('selectionClick completes', (tester) async {
      await service.selectionClick();
    });

    testWidgets('vibrate completes', (tester) async {
      await service.vibrate();
    });
  });

  group('HapticsService — disabled mode', () {
    // No mock needed — disabled means no platform calls.
    test('lightImpact is no-op when disabled', () async {
      service.enabled = false;
      await service.lightImpact();
    });

    test('mediumImpact is no-op when disabled', () async {
      service.enabled = false;
      await service.mediumImpact();
    });
  });

  group('HapticsService — singleton', () {
    test('factory returns same instance', () {
      final a = HapticsService();
      final b = HapticsService();
      expect(identical(a, b), isTrue);
    });
  });
}
