#!/usr/bin/env bash
# Run the app on the booted iOS simulator with Firebase Analytics DebugView enabled.
#
# Usage:  scripts/firebase-debug-run.sh [--no-build]
#
# 'flutter run' does not forward Xcode-scheme launch arguments to the simulator
# process, so -FIRDebugEnabled never reaches the Firebase measurement SDK.
# This script builds (optional), installs, and re-launches with the flag
# explicitly passed to xcrun simctl launch so DebugView registers the device.
set -euo pipefail

BUNDLE_ID="dev.atoosa.mitoosa"
APP_PATH="build/ios/iphonesimulator/Runner.app"
DART_DEFINES="FIREBASE_ENABLED=true"

cd "$(dirname "$0")/.."

NO_BUILD=false
for arg in "$@"; do
  [[ "$arg" == "--no-build" ]] && NO_BUILD=true
done

if [[ "$NO_BUILD" == false ]]; then
  echo "▶ Building debug iOS app for simulator…"
  flutter build ios --debug --simulator \
    --dart-define="$DART_DEFINES" 2>&1 | tail -4
else
  echo "▶ Skipping build (--no-build)"
fi

echo "▶ Installing on booted simulator…"
xcrun simctl install booted "$APP_PATH"

echo "▶ Launching with -FIRDebugEnabled…"
xcrun simctl launch --terminate-running-process booted "$BUNDLE_ID" \
  -FIRDebugEnabled -FIRAnalyticsDebugEnabled -FIRAnalyticsVerboseLoggingEnabled

echo ""
echo "✅ App launched with Firebase debug mode active."
echo "   Open Firebase Console → Analytics → DebugView"
echo "   Device instance ID is printed in the simulator logs."
echo ""
echo "   To stream logs:  xcrun simctl spawn booted log stream \\"
echo "     --predicate 'process BEGINSWITH \"Runner\"' --style compact | grep -i firebase"
