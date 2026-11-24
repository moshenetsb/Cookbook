#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
if [ "$#" -ne 1 ]; then
    xcrun simctl list devices available
    printf '\nPodaj UDID symulatora: bash Scripts/verify_on_mac.sh UDID\n'
    exit 2
fi
run="TestResults/$(date +%Y%m%d-%H%M%S)"
mkdir -p "$run"
xcodebuild -version | tee "$run/xcode-version.txt"
xcodebuild -project CookBook.xcodeproj -scheme CookBook \
    -configuration Debug -destination "platform=iOS Simulator,id=$1" \
    -derivedDataPath "$run/DerivedData" -resultBundlePath "$run/Tests.xcresult" \
    -parallel-testing-enabled NO CODE_SIGNING_ALLOWED=NO test 2>&1 | tee "$run/tests.log"
xcodebuild -project CookBook.xcodeproj -scheme CookBook \
    -configuration Release -destination 'generic/platform=iOS Simulator' \
    -derivedDataPath "$run/DerivedData" CODE_SIGNING_ALLOWED=NO build 2>&1 | tee "$run/release-build.log"
printf '\nWyniki zapisano w %s\n' "$run"
