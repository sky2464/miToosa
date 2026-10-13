import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/audio_service.dart';
import '../../core/haptics_service.dart';
import '../../core/music_service.dart';
import '../../data/audio_preferences_repository.dart';

/// Orchestrates persisted Sound FX / Music / Haptics preferences and applies
/// them to the playback singletons, so Settings toggles survive cold restart.
///
/// BL-34: the singletons alone are in-memory only; this controller is the
/// preference-aware boundary every toggle routes through.
class AudioPreferencesController {
  AudioPreferencesController({
    required IAudioPreferencesRepository preferences,
  }) : _preferences = preferences;

  final IAudioPreferencesRepository _preferences;

  /// Loads persisted values and applies them to the playback services.
  Future<AudioPreferences> loadAndApply() async {
    final prefs = await _preferences.load();
    AudioService().enabled = prefs.soundEnabled;
    MusicService().enabled = prefs.musicEnabled;
    HapticsService().enabled = prefs.hapticsEnabled;
    return prefs;
  }

  Future<void> setSoundEnabled(bool enabled) async {
    await _preferences.setSoundEnabled(enabled);
    AudioService().enabled = enabled;
  }

  Future<void> setMusicEnabled(bool enabled) async {
    await _preferences.setMusicEnabled(enabled);
    MusicService().enabled = enabled;
  }

  Future<void> setHapticsEnabled(bool enabled) async {
    await _preferences.setHapticsEnabled(enabled);
    HapticsService().enabled = enabled;
  }
}

final audioPreferencesRepositoryProvider =
    Provider<IAudioPreferencesRepository>((ref) {
      return boundAudioPreferencesRepository;
    });

final audioPreferencesControllerProvider =
    Provider<AudioPreferencesController>((ref) {
      return AudioPreferencesController(
        preferences: ref.watch(audioPreferencesRepositoryProvider),
      );
    });
