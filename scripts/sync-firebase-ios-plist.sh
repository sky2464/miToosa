#!/usr/bin/env bash
# Sync ios/Runner/GoogleService-Info.plist from Firebase and verify GA4 linkage.
# DebugView stays empty when MEASUREMENT_ID (G-XXXXXXXX) is missing from the plist.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PLIST="$ROOT/ios/Runner/GoogleService-Info.plist"
PROJECT_ID="mitoosa-2121b"
IOS_APP_ID="1:567413645788:ios:03903b33a13cb4f4fc6f19"

patch_measurement_id() {
  local mid="${MEASUREMENT_ID:-}"
  [[ -n "$mid" ]] || { echo "Set MEASUREMENT_ID=G-XXXXXXXX"; exit 2; }
  python3 - "$PLIST" "$mid" <<'PY'
import plistlib, sys
path, mid = sys.argv[1], sys.argv[2]
with open(path, "rb") as f:
    data = plistlib.load(f)
data["MEASUREMENT_ID"] = mid
data["IS_ANALYTICS_ENABLED"] = True
data["IS_MEASUREMENT_ENABLED"] = True
with open(path, "wb") as f:
    plistlib.dump(data, f)
print(f"Patched {path} with MEASUREMENT_ID={mid}")
PY
}

if [[ "${1:-}" == "--patch" ]]; then
  patch_measurement_id
  exit 0
fi

echo "→ Downloading iOS SDK config from Firebase ($PROJECT_ID)..."
TMP="$(mktemp)"
firebase apps:sdkconfig IOS "$IOS_APP_ID" --project "$PROJECT_ID" --out "$TMP"
mv "$TMP" "$PLIST"

if grep -q '<key>MEASUREMENT_ID</key>' "$PLIST"; then
  MID="$(python3 -c "import plistlib; d=plistlib.load(open('$PLIST','rb')); print(d.get('MEASUREMENT_ID',''))")"
  echo "✅ MEASUREMENT_ID present: $MID"
  echo "   Rebuild: flutter run --dart-define=FIREBASE_ENABLED=true"
  echo "   Then open Firebase Console → Analytics → DebugView"
  exit 0
fi

echo ""
echo "❌ MEASUREMENT_ID still missing from GoogleService-Info.plist."
echo "   Copy Measurement ID from Google Analytics → Admin → Data streams → mitoosa (ios)"
echo "   Then run: MEASUREMENT_ID=G-XXXXXXXX $0 --patch"
exit 1
