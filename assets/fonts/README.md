This folder should contain font assets used as fallbacks for missing glyphs (emoji, symbols, and CJK).

Place the following font files here (suggested filenames):

- NotoSans-Regular.ttf
- NotoSans-Bold.ttf
- NotoSansSymbols-Regular.ttf
- NotoColorEmoji.ttf

Recommended sources:
- https://fonts.google.com/ (Noto Sans)
- https://www.google.com/get/noto/ (Noto emoji/symbols)

After adding the files, register them in `pubspec.yaml` under the `flutter:` -> `fonts:` section. Example:

```yaml
flutter:
  fonts:
    - family: 'Noto Sans'
      fonts:
        - asset: assets/fonts/NotoSans-Regular.ttf
        - asset: assets/fonts/NotoSans-Bold.ttf
          weight: 700
    - family: 'Noto Sans Symbols'
      fonts:
        - asset: assets/fonts/NotoSansSymbols-Regular.ttf
    - family: 'Noto Color Emoji'
      fonts:
        - asset: assets/fonts/NotoColorEmoji.ttf
```

Once the fonts are placed and `pubspec.yaml` updated, run:

```bash
flutter pub get
dart pub run build_runner build --delete-conflicting-outputs
flutter run -d chrome
```

If you prefer not to bundle fonts, ensure target platforms supply adequate fallback fonts for the glyphs your app needs.

Optional fonts (not bundled by default):

- Roboto (Roboto-Regular.ttf, Roboto-Bold.ttf)
- MaterialIcons (MaterialIcons-Regular.ttf)

These provide additional glyph coverage but must be placed in `assets/fonts/` and registered in `pubspec.yaml` before uncommenting the example entries. The included `scripts/download_noto_fonts.sh` attempts to download Roboto/MaterialIcons, but availability may vary; you can manually download from Google Fonts or the material-design-icons repo and add the TTFs to this folder.

Script notes:
- `scripts/download_noto_fonts.sh` now attempts multiple sources. If direct raw TTFs are unavailable it falls back to the Google Fonts CSS API and downloads the referenced `fonts.gstatic.com` files.
- When possible the script will map the downloaded hashed filenames to conventional names used in `pubspec.yaml`:
  - `Roboto-Regular.ttf`, `Roboto-Bold.ttf`, `MaterialIcons-Regular.ttf`.
- If the script cannot obtain a TTF (or only retrieves `woff2`), you'll need to provide a TTF manually or convert the web font to TTF with a font tool.

