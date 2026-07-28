# miToosa Launch Brand Asset Manifest

> **Story:** BL-33 — Production brand assets  
> **Master source:** `assets/brand/aetheric_pulse_mark_1024.png`

| Field | Value |
|-------|-------|
| Source | Original constellation/spark mark (Aetheric Pulse identity) |
| Creator | miToosa project — generated for BL-33 |
| License | Proprietary — miToosa / EP-01 launch readiness |
| Derivative status | Original artwork (no third-party mark) |
| Dimensions | 1024×1024 PNG (RGBA master) |
| SHA-256 (master) | `73b9311978402b502c59a09acae114cfdb9bff0ee61d758768eadf95a28a7c05` |
| SHA-256 (iOS 1024 marketing, alpha stripped) | `987924b5e6af8201579a985bf4b95d3e27605dac5e403b5813e9dc0e493481ad` |
| Generation command | `python3 tool/generate_brand_assets.py` then `dart run flutter_launcher_icons` |
| iOS icons | `ios/Runner/Assets.xcassets/AppIcon.appiconset/` |
| Android icons | `android/app/src/main/res/mipmap-*/` |
| Launch surface | `ios/Runner/Assets.xcassets/LaunchImage.imageset/` + `LaunchScreen.storyboard` (#0A0C1C) |
| Stock Flutter icon SHA-256 (rejected) | `7770183009e914112de7d8ef1d235a6a30c5834424858e0d2f8253f6b8d31926` |

## Regeneration

```bash
python3 tool/generate_brand_assets.py
dart run flutter_launcher_icons
flutter test test/release/brand_assets_test.dart
```
