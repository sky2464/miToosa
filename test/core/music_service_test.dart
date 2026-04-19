import 'package:flutter_test/flutter_test.dart';
import 'package:mitoosa/core/music_service.dart';

void main() {
  late MusicService service;

  setUp(() {
    service = MusicService();
    service.enabled = true;
  });

  group('MusicService — toggle', () {
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

  group('MusicService — volume', () {
    test('default volume is 0.5', () {
      expect(service.volume, 0.5);
    });

    test('setVolume clamps to 0.0–1.0 range', () async {
      await service.setVolume(1.5);
      expect(service.volume, 1.0);

      await service.setVolume(-0.5);
      expect(service.volume, 0.0);
    });

    test('setVolume accepts valid values', () async {
      await service.setVolume(0.7);
      expect(service.volume, 0.7);
    });
  });

  group('MusicService — state', () {
    test('no track playing initially', () {
      expect(service.currentTrack, isNull);
      expect(service.isPlaying, isFalse);
    });

    test('play with missing asset returns false', () async {
      final result = await service.play('nonexistent_track');
      expect(result, isFalse);
    });

    test('play when disabled stores track name but returns false', () async {
      service.enabled = false;
      final result = await service.play('some_track');
      expect(result, isFalse);
      expect(service.currentTrack, 'some_track');
    });

    test('stop clears current track', () async {
      service.enabled = false;
      await service.play('some_track'); // sets currentTrack
      await service.stop();
      expect(service.currentTrack, isNull);
    });
  });

  group('MusicService — singleton', () {
    test('factory returns same instance', () {
      final a = MusicService();
      final b = MusicService();
      expect(identical(a, b), isTrue);
    });
  });
}
