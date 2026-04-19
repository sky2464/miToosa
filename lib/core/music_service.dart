import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

/// Background music service with volume control, looping, and enable/disable toggle.
///
/// Uses a dedicated [AudioPlayer] separate from [AudioService] SFX player.
class MusicService {
  static final MusicService _instance = MusicService._internal();
  factory MusicService() => _instance;
  MusicService._internal();

  static const List<String> _extensions = ['.ogg', '.mp3', '.wav', '.m4a'];

  AudioPlayer? _player;
  AudioPlayer get _audioPlayer => _player ??= AudioPlayer();
  bool _enabled = true;
  double _volume = 0.5;
  String? _currentTrack;

  bool get enabled => _enabled;
  double get volume => _volume;
  String? get currentTrack => _currentTrack;
  bool get isPlaying => _player?.state == PlayerState.playing;

  set enabled(bool value) {
    _enabled = value;
    if (!_enabled) {
      _player?.pause();
    } else if (_currentTrack != null) {
      _player?.resume();
    }
  }

  /// Sets volume (0.0 – 1.0) and applies immediately if player exists.
  Future<void> setVolume(double v) async {
    _volume = v.clamp(0.0, 1.0);
    await _player?.setVolume(_volume);
  }

  /// Plays the track with the given [baseName] from assets/audio/ on loop.
  ///
  /// If the same track is already playing, this is a no-op.
  /// Tries each extension in order until one loads.
  Future<bool> play(String baseName) async {
    if (_currentTrack == baseName && isPlaying) return true;
    if (!_enabled) {
      _currentTrack = baseName;
      return false;
    }

    for (final ext in _extensions) {
      final candidate = 'assets/audio/$baseName$ext';
      try {
        await rootBundle.load(candidate); // verify asset exists

        await _audioPlayer.stop();
        await _audioPlayer.setReleaseMode(ReleaseMode.loop);
        await _audioPlayer.setVolume(_volume);

        if (kIsWeb) {
          final webPath = candidate.replaceFirst('assets/', '');
          await _audioPlayer.play(AssetSource(webPath));
        } else {
          final data = await rootBundle.load(candidate);
          await _audioPlayer.play(BytesSource(data.buffer.asUint8List()));
        }
        _currentTrack = baseName;
        return true;
      } catch (_) {
        continue;
      }
    }
    return false;
  }

  /// Pauses the current track (can be resumed).
  Future<void> pause() async {
    await _player?.pause();
  }

  /// Resumes the current track if music is enabled.
  Future<void> resume() async {
    if (!_enabled || _currentTrack == null) return;
    await _player?.resume();
  }

  /// Stops playback and clears the current track.
  Future<void> stop() async {
    await _player?.stop();
    _currentTrack = null;
  }

  /// Releases the player resources.
  Future<void> dispose() async {
    await _player?.dispose();
    _player = null;
    _currentTrack = null;
  }
}
