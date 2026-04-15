Assets: UI sound effects
------------------------

This folder should contain short UI sound effects used by the app:

- `pop.mp3` — success / positive feedback sound
- `buzzer.mp3` — error / negative feedback sound

Recommended source: Google (YouTube) Audio Library or other permissive sound libraries. Examples:

- YouTube Audio Library: https://studio.youtube.com/audiolibrary/music
- Google Developer sample sounds / Material Design sound suggestions

Local test files:
- `assets/audio/pop.wav` and `assets/audio/buzzer.wav` have been generated in the repository as short test tones (sine-wave) to allow local testing on web. If you prefer MP3 files, convert these with `ffmpeg` or replace them with your chosen assets.

License and attribution
- Prefer assets that allow redistribution in source (no restrictive license). If attribution is required, add a one-line credit here and in `README.md`.

To add files:
1. Download `pop.mp3` and `buzzer.mp3` into this folder.
2. Run `flutter pub get` (assets are already declared in `pubspec.yaml`).
3. Run the app and trigger UI audio from a user gesture.

If you prefer not to commit binaries, host the files on a CDN and update `AudioService` to play network URLs.
