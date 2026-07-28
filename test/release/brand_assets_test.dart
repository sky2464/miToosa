import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';

/// Known stock Flutter 1024px marketing icon (pre-BL-33).
const _stockFlutterIconSha256 =
    '7770183009e914112de7d8ef1d235a6a30c5834424858e0d2f8253f6b8d31926';

/// Approved BL-33 master mark SHA-256.
const _approvedMasterSha256 =
    '73b9311978402b502c59a09acae114cfdb9bff0ee61d758768eadf95a28a7c05';

String _sha256File(String path) {
  final bytes = File(path).readAsBytesSync();
  return sha256.convert(bytes).toString();
}

void main() {
  final repoRoot = Directory.current.path;

  group('BL-33 brand assets @smoke T-002', () {
    test('iOS AppIcon slots are populated from custom master', () {
      final iconDir = Directory('$repoRoot/ios/Runner/Assets.xcassets/AppIcon.appiconset');
      expect(iconDir.existsSync(), isTrue);

      final contents = File('${iconDir.path}/Contents.json').readAsStringSync();
      final json = jsonDecode(contents) as Map<String, dynamic>;
      final images = json['images'] as List<dynamic>;
      expect(images, isNotEmpty);

      for (final entry in images) {
        final map = entry as Map<String, dynamic>;
        final filename = map['filename'] as String?;
        expect(filename, isNotNull, reason: 'Every slot needs a filename');
        expect(File('${iconDir.path}/$filename').existsSync(), isTrue);
      }

      final marketing = _sha256File('${iconDir.path}/Icon-App-1024x1024@1x.png');
      expect(marketing, isNot(equals(_stockFlutterIconSha256)));
      expect(marketing, isNot(equals(_approvedMasterSha256))); // iOS strips alpha
    });

    test('Android launcher mipmaps exist', () {
      for (final density in ['mdpi', 'hdpi', 'xhdpi', 'xxhdpi', 'xxxhdpi']) {
        final file = File('$repoRoot/android/app/src/main/res/mipmap-$density/ic_launcher.png');
        expect(file.existsSync(), isTrue, reason: 'Missing $density launcher icon');
        expect(file.lengthSync(), greaterThan(100));
      }
    });
  });

  group('BL-33 launch surface @smoke T-003', () {
    test('LaunchImage assets are non-trivial branded PNGs', () {
      final launchDir = Directory(
        '$repoRoot/ios/Runner/Assets.xcassets/LaunchImage.imageset',
      );
      for (final name in ['LaunchImage.png', 'LaunchImage@2x.png', 'LaunchImage@3x.png']) {
        final file = File('${launchDir.path}/$name');
        expect(file.existsSync(), isTrue);
        expect(file.lengthSync(), greaterThan(500), reason: '$name must not be 1px placeholder');
      }

      final storyboard = File('$repoRoot/ios/Runner/Base.lproj/LaunchScreen.storyboard')
          .readAsStringSync();
      expect(storyboard, contains('LaunchImage'));
      expect(storyboard, contains('0.039')); // Aetheric Pulse dark background
    });
  });

  group('BL-33 provenance @smoke T-004', () {
    test('manifest records master hash and generation command', () {
      final manifest = File('$repoRoot/docs/brand/launch-asset-manifest.md').readAsStringSync();
      expect(manifest, contains(_approvedMasterSha256));
      expect(manifest, contains('tool/generate_brand_assets.py'));
      expect(manifest, contains('flutter_launcher_icons'));
      expect(manifest, contains(_stockFlutterIconSha256));
    });

    test('master source file matches manifest hash', () {
      final master = '$repoRoot/assets/brand/aetheric_pulse_mark_1024.png';
      expect(File(master).existsSync(), isTrue);
      expect(_sha256File(master), equals(_approvedMasterSha256));
    });
  });

  group('BL-33 placeholder regression @smoke T-006', () {
    test('marketing icon is not stock Flutter artwork', () {
      final path = '$repoRoot/ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-1024x1024@1x.png';
      expect(_sha256File(path), isNot(equals(_stockFlutterIconSha256)));
    });
  });
}
