#!/bin/sh
# Builds all targets and runs tests.

alias pod='bundle exec pod'
alias xcpretty='bundle exec xcpretty'

# Defined default derived data location
DERIVED_DATA=${1:-/tmp/LayoutKit}
echo "Derived data location: $DERIVED_DATA"

# Fail on error
set -e

echo "Run tests on iOS..."
rm -rf $DERIVED_DATA
set -o pipefail && time xcodebuild clean test \
    -project LayoutKit.xcodeproj \
    -scheme LayoutKit-iOS \
    -sdk iphonesimulator11.2 \
    -derivedDataPath $DERIVED_DATA \
    -destination 'platform=iOS Simulator,name=iPhone 6,OS=10.3.1' \
    -destination 'platform=iOS Simulator,name=iPhone 6 Plus,OS=10.3.1' \
    -destination 'platform=iOS Simulator,name=iPhone 7,OS=11.2' \
    -destination 'platform=iOS Simulator,name=iPhone 7 Plus,OS=11.2' \
    OTHER_SWIFT_FLAGS='-Xfrontend -debug-time-function-bodies' \
    | tee build.log \
    | xcpretty
cat build.log | sh debug-time-function-bodies.sh

echo "Building sample app..." 
rm -rf $DERIVED_DATA
set -o pipefail && time xcodebuild clean build \
    -project LayoutKit.xcodeproj \
    -scheme LayoutKitSampleApp \
    -sdk iphonesimulator11.2 \
    -derivedDataPath $DERIVED_DATA \
    -destination 'platform=iOS Simulator,name=iPhone 6,OS=10.3.1' \
    -destination 'platform=iOS Simulator,name=iPhone 6 Plus,OS=10.3.1' \
    -destination 'platform=iOS Simulator,name=iPhone 7,OS=11.2' \
    -destination 'platform=iOS Simulator,name=iPhone 7 Plus,OS=11.2' \
    OTHER_SWIFT_FLAGS='-Xfrontend -debug-time-function-bodies' \
    | tee ../build.log \
    | xcpretty
cat build.log | sh debug-time-function-bodies.sh

# Test Cocopods, Carthage, Swift Package Management

echo "Building an iOS empty project with cocoapods..."
rm -rf $DERIVED_DATA
cd Tests/cocoapods/ios
pod install
set -o pipefail && time xcodebuild clean build \
    -workspace LayoutKit-iOS.xcworkspace \
    -scheme LayoutKit-iOS \
    -sdk iphonesimulator11.2 \
    -derivedDataPath $DERIVED_DATA \
    -destination 'platform=iOS Simulator,name=iPhone 7,OS=11.2' \
    OTHER_SWIFT_FLAGS='-Xfrontend -debug-time-function-bodies' \
    | tee ../../../build.log \
    | xcpretty
cd ../../.. 
cat build.log | sh debug-time-function-bodies.sh
