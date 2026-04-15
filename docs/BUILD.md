# Build Guide

## Prerequisites

Before building, ensure dependencies are generated:

```bash
flutter pub get
dart pub run build_runner build --delete-conflicting-outputs
```

## Platform-Specific Build Commands

### iOS Release Build

```bash
flutter build ios --release --no-codesign --no-tree-shake-icons
```

**Note**: The `--no-tree-shake-icons` flag is required due to a Flutter font subsetting issue with custom fonts. Without it, the build will fail with "Font subsetting failed with exit code 255."

### Android Release Build

```bash
flutter build apk --release --no-tree-shake-icons
```

Or for App Bundle:

```bash
flutter build appbundle --release --no-tree-shake-icons
```

### Web Release Build

```bash
flutter build web --release --no-tree-shake-icons
```

### macOS Release Build

```bash
flutter build macos --release --no-tree-shake-icons
```

## Known Issues

### Font Subsetting Error

**Problem**: `IconTreeShakerException: Font subsetting failed with exit code 255`

**Solution**: Use `--no-tree-shake-icons` flag for all build commands.

**Explanation**: This is a known Flutter tooling issue that occurs when using custom fonts (Noto Sans fonts downloaded via `scripts/download_noto_fonts.sh`). Icon tree shaking attempts to subset the font file but fails on certain codepoint ranges.

**Status**: Workaround is to disable icon tree shaking globally. Long-term solution would be to:
1. Migrate to Google Fonts package (which handles subsetting differently)
2. Or upgrade to newer Flutter versions that fix this issue
3. Or manually pre-subset the fonts

## Development Builds

For development/debug builds (faster iteration):

```bash
flutter run -d <device>
# or
flutter build apk --debug
flutter build ios --debug
flutter build web --debug
```

Debug builds do not use tree shaking and build significantly faster.
