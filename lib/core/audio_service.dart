import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  static const List<String> _extensions = ['.ogg', '.wav'];
  final AudioPlayer _player = AudioPlayer();

  Future<bool> _playByBaseName(String baseName) async {
    for (final ext in _extensions) {
      final candidate = 'assets/audio/$baseName$ext';
      try {
        final data = await rootBundle.load(candidate);

        await _player.stop();

        if (kIsWeb) {
          final webPath = candidate.replaceFirst('assets/', '');
          await _player.play(AssetSource(webPath));
        } else {
          await _player.play(BytesSource(data.buffer.asUint8List()));
        }
        return true;
      } catch (_) {
        // asset not found or failed to load; try next extension
        continue;
      }
    }
    return false;
  }

  Future<void> playSuccessPop() async {
    await _playByBaseName('pop');
  }

  Future<void> playErrorBuzzer() async {
    // Try buzzer first, then fall back to boing if missing.
    if (await _playByBaseName('buzzer')) return;
    await _playByBaseName('boing');
  }
}
