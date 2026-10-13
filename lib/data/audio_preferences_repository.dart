import 'package:shared_preferences/shared_preferences.dart';

/// Bound at app startup from [main]; tests may rebind with a fake.
IAudioPreferencesRepository? _boundAudioPreferencesRepository;

void bindAudioPreferencesRepository(IAudioPreferencesRepository repository) {
  _boundAudioPreferencesRepository = repository;
}

IAudioPreferencesRepository get boundAudioPreferencesRepository {
  final bound = _boundAudioPreferencesRepository;
  if (bound == null) {
    throw StateError(
      'Audio preferences repository not bound — call bindAudioPreferencesRepository in main()',
    );
  }
  return bound;
}

/// Persisted Sound FX / Music / Haptics toggles (all default enabled).
///
/// BL-34: settings must survive a cold relaunch. Uses SharedPreferences —
/// durable on iOS and directly unit-testable via `setMockInitialValues` —
/// mirroring the existing privacy-preferences repository pattern.
abstract class IAudioPreferencesRepository {
  Future<AudioPreferences> load();

  Future<void> setSoundEnabled(bool enabled);

  Future<void> setMusicEnabled(bool enabled);

  Future<void> setHapticsEnabled(bool enabled);
}

class AudioPreferences {
  const AudioPreferences({
    required this.soundEnabled,
    required this.musicEnabled,
    required this.hapticsEnabled,
  });

  final bool soundEnabled;
  final bool musicEnabled;
  final bool hapticsEnabled;
}

class SharedPreferencesAudioPreferencesRepository
    implements IAudioPreferencesRepository {
  SharedPreferencesAudioPreferencesRepository(this._prefs);

  static const soundEnabledKey = 'audio_sound_enabled';
  static const musicEnabledKey = 'audio_music_enabled';
  static const hapticsEnabledKey = 'audio_haptics_enabled';

  final SharedPreferences _prefs;

  static Future<SharedPreferencesAudioPreferencesRepository> create() async {
    final prefs = await SharedPreferences.getInstance();
    return SharedPreferencesAudioPreferencesRepository(prefs);
  }

  @override
  Future<AudioPreferences> load() async {
    return AudioPreferences(
      soundEnabled: _prefs.getBool(soundEnabledKey) ?? true,
      musicEnabled: _prefs.getBool(musicEnabledKey) ?? true,
      hapticsEnabled: _prefs.getBool(hapticsEnabledKey) ?? true,
    );
  }

  @override
  Future<void> setSoundEnabled(bool enabled) async {
    await _prefs.setBool(soundEnabledKey, enabled);
  }

  @override
  Future<void> setMusicEnabled(bool enabled) async {
    await _prefs.setBool(musicEnabledKey, enabled);
  }

  @override
  Future<void> setHapticsEnabled(bool enabled) async {
    await _prefs.setBool(hapticsEnabledKey, enabled);
  }
}

/// In-memory fake for unit tests.
class FakeAudioPreferencesRepository implements IAudioPreferencesRepository {
  AudioPreferences stored = const AudioPreferences(
    soundEnabled: true,
    musicEnabled: true,
    hapticsEnabled: true,
  );

  @override
  Future<AudioPreferences> load() async => stored;

  @override
  Future<void> setSoundEnabled(bool enabled) async {
    stored = AudioPreferences(
      soundEnabled: enabled,
      musicEnabled: stored.musicEnabled,
      hapticsEnabled: stored.hapticsEnabled,
    );
  }

  @override
  Future<void> setMusicEnabled(bool enabled) async {
    stored = AudioPreferences(
      soundEnabled: stored.soundEnabled,
      musicEnabled: enabled,
      hapticsEnabled: stored.hapticsEnabled,
    );
  }

  @override
  Future<void> setHapticsEnabled(bool enabled) async {
    stored = AudioPreferences(
      soundEnabled: stored.soundEnabled,
      musicEnabled: stored.musicEnabled,
      hapticsEnabled: enabled,
    );
  }
}
