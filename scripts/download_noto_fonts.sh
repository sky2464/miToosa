#!/usr/bin/env bash
set -euo pipefail

DEST_DIR="assets/fonts"
mkdir -p "$DEST_DIR"

download_candidates() {
  local dest="$1"; shift
  for url in "$@"; do
    echo "Trying: $url"
    if curl -fSL "$url" -o "$dest"; then
      echo "Downloaded: $dest"
      return 0
    else
      echo "Failed: $url"
    fi
  done
  echo "All candidates failed for $dest" >&2
  return 1
}

echo "Downloading Noto font assets into $DEST_DIR"

download_candidates "$DEST_DIR/NotoSans-Regular.ttf" \
  "https://github.com/google/fonts/raw/main/ofl/notosans/NotoSans-Regular.ttf" \
  "https://github.com/googlefonts/noto-fonts/raw/main/hinted/ttf/NotoSans/NotoSans-Regular.ttf"

download_candidates "$DEST_DIR/NotoSans-Bold.ttf" \
  "https://github.com/google/fonts/raw/main/ofl/notosans/NotoSans-Bold.ttf" \
  "https://github.com/googlefonts/noto-fonts/raw/main/hinted/ttf/NotoSans/NotoSans-Bold.ttf"

download_candidates "$DEST_DIR/NotoSansSymbols-Regular.ttf" \
  "https://github.com/googlefonts/noto-fonts/raw/main/hinted/ttf/NotoSansSymbols/NotoSansSymbols-Regular.ttf" \
  "https://github.com/google/fonts/raw/main/ofl/notosanssymbols/NotoSansSymbols-Regular.ttf"

download_candidates "$DEST_DIR/NotoColorEmoji.ttf" \
  "https://github.com/googlefonts/noto-emoji/raw/main/fonts/NotoColorEmoji.ttf" \
  "https://github.com/googlefonts/noto-emoji/raw/main/fonts/ttf/NotoColorEmoji.ttf"

download_candidates "$DEST_DIR/Roboto-Regular.ttf" \
  "https://github.com/google/fonts/raw/main/apache/roboto/Roboto-Regular.ttf" \
  "https://github.com/google/fonts/raw/main/ofl/roboto/Roboto-Regular.ttf" \
  "https://raw.githubusercontent.com/google/fonts/main/apache/roboto/Roboto-Regular.ttf" \
  "https://raw.githubusercontent.com/google/fonts/main/ofl/roboto/Roboto-Regular.ttf" || true

download_candidates "$DEST_DIR/Roboto-Bold.ttf" \
  "https://github.com/google/fonts/raw/main/apache/roboto/Roboto-Bold.ttf" \
  "https://github.com/google/fonts/raw/main/ofl/roboto/Roboto-Bold.ttf" \
  "https://raw.githubusercontent.com/google/fonts/main/apache/roboto/Roboto-Bold.ttf" \
  "https://raw.githubusercontent.com/google/fonts/main/ofl/roboto/Roboto-Bold.ttf" || true

download_candidates "$DEST_DIR/MaterialIcons-Regular.ttf" \
  "https://github.com/google/material-design-icons/raw/master/iconfont/MaterialIcons-Regular.ttf" \
  "https://github.com/google/material-design-icons/raw/main/iconfont/MaterialIcons-Regular.ttf" \
  "https://raw.githubusercontent.com/google/material-design-icons/main/iconfont/MaterialIcons-Regular.ttf" \
  "https://raw.githubusercontent.com/google/material-design-icons/master/iconfont/MaterialIcons-Regular.ttf" || true

# Fallback: try fetching fonts via Google Fonts CSS API and download referenced fonts.gstatic.com URLs
download_from_google_fonts_css() {
  local family="$1" # e.g. Roboto or Material+Icons
  local weights="$2" # e.g. 400;700
  echo "Attempting Google Fonts CSS fallback for $family (weights: $weights)"
  css=$(curl -s -A "Mozilla/5.0" "https://fonts.googleapis.com/css2?family=${family}:wght@${weights}&display=swap" || true)
  if [ -z "${css}" ]; then
    echo "No CSS returned for ${family}" >&2
    return 1
  fi
  # Extract URLs (woff2/ttf/woff) and download them
  echo "$css" | grep -oE 'https://fonts.gstatic.com[^)\"]+' | while read -r url; do
    fname=$(basename "$url")
    # prefer naming by family/weight when possible
    if echo "$fname" | grep -qiE "woff2|woff"; then
      dest="$DEST_DIR/${family//+/}-${fname}"
    else
      dest="$DEST_DIR/$fname"
    fi
    echo "Downloading (css fallback): $url -> $dest"
    if curl -fSL "$url" -o "$dest"; then
      echo "Downloaded via CSS: $dest"
    else
      echo "Failed to download via CSS: $url" >&2
    fi
  done
}

# Try the Google Fonts CSS fallback for Roboto and Material Icons
download_from_google_fonts_css "Roboto" "400;700" || true
download_from_google_fonts_css "Material+Icons" "400" || true

# Map CSS-downloaded hashed filenames to conventional names for Flutter's pubspec
map_css_downloads() {
  local family="$1"
  local weights_csv="$2" # comma separated weights e.g. "400,700"
  css=$(curl -s -A "Mozilla/5.0" "https://fonts.googleapis.com/css2?family=${family}:wght@${weights_csv//,/;}" || true)
  if [ -z "${css}" ]; then
    return 1
  fi
  # iterate blocks and find weight + url
  # crude parser: for each font-weight line, remember weight then pick the next url(...) occurrence
  echo "$css" | awk '/font-weight/ { w=$2 } /src:/ { match($0, /https:\/\/fonts.gstatic.com[^)]+/); if (RSTART) { url=substr($0,RSTART,RLENGTH); gsub(/\)/, "", url); print w " " url } }' | while read -r weight url; do
    if [ -z "$weight" ] || [ -z "$url" ]; then
      continue
    fi
    base=$(basename "$url")
    case "$family" in
      Roboto)
        if [ "$weight" = "400;" ] || [ "$weight" = "400" ]; then
          mv -n "$DEST_DIR/$base" "$DEST_DIR/Roboto-Regular.ttf" 2>/dev/null || true
        elif [ "$weight" = "700;" ] || [ "$weight" = "700" ]; then
          mv -n "$DEST_DIR/$base" "$DEST_DIR/Roboto-Bold.ttf" 2>/dev/null || true
        fi
        ;;
      "Material+Icons")
        # Material Icons only needs a single regular weight
        mv -n "$DEST_DIR/$base" "$DEST_DIR/MaterialIcons-Regular.ttf" 2>/dev/null || true
        ;;
    esac
  done
}

# Attempt mapping so pubspec can reference predictable filenames
map_css_downloads "Roboto" "400,700" || true
map_css_downloads "Material+Icons" "400" || true

echo "Done. Please update pubspec.yaml if needed and run 'flutter pub get'"
