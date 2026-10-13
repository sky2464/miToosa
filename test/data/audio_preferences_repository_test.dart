import 'package:flutter_test/flutter_test.dart';
import 'package:mitoosa/data/audio_preferences_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('SharedPreferencesAudioPreferencesRepository', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('defaults all toggles to enabled when unset', () async {
      final repo = await SharedPreferencesAudioPreferencesRepository.create();
      final prefs = await repo.load();
      expect(prefs.soundEnabled, isTrue);
      expect(prefs.musicEnabled, isTrue);
      expect(prefs.hapticsEnabled, isTrue);
    });

    test('persists toggles independently and survives reload', () async {
      final repo = await SharedPreferencesAudioPreferencesRepository.create();
      await repo.setSoundEnabled(false);
      await repo.setMusicEnabled(false);
      await repo.setHapticsEnabled(true);

      final reloaded =
          await SharedPreferencesAudioPreferencesRepository.create();
      final prefs = await reloaded.load();
      expect(prefs.soundEnabled, isFalse);
      expect(prefs.musicEnabled, isFalse);
      expect(prefs.hapticsEnabled, isTrue);
    });

    test('re-enabling a toggle persists true', () async {
      final repo = await SharedPreferencesAudioPreferencesRepository.create();
      await repo.setSoundEnabled(false);
      await repo.setSoundEnabled(true);

      final reloaded =
          await SharedPreferencesAudioPreferencesRepository.create();
      expect((await reloaded.load()).soundEnabled, isTrue);
    });
  });

  group('FakeAudioPreferencesRepository', () {
    test('defaults to all enabled and records writes', () async {
      final repo = FakeAudioPreferencesRepository();
      expect((await repo.load()).soundEnabled, isTrue);

      await repo.setHapticsEnabled(false);
      final prefs = await repo.load();
      expect(prefs.hapticsEnabled, isFalse);
      // Untouched toggles keep their values.
      expect(prefs.soundEnabled, isTrue);
      expect(prefs.musicEnabled, isTrue);
    });
  });
}
