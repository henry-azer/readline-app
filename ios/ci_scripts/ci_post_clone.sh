#!/bin/sh

# Fail this script if any subcommand fails.
set -e

# The default execution directory of this script is the ci_scripts directory.
cd $CI_PRIMARY_REPOSITORY_PATH # change working directory to the root of your cloned repo.

# Auto-bump CFBundleVersion from the Xcode Cloud workflow counter so every
# upload to App Store Connect gets a unique build number — otherwise repeat
# CI runs reuse pubspec's build number and fail at "Prepare Build for App
# Store Connect" with a duplicate-build-number rejection.
if [ -n "$CI_BUILD_NUMBER" ]; then
  sed -i '' "s/^\(version: [^+]*\)+[0-9][0-9]*$/\1+${CI_BUILD_NUMBER}/" pubspec.yaml
fi

# Install Flutter using git.
git clone https://github.com/flutter/flutter.git --depth 1 -b stable $HOME/flutter
export PATH="$PATH:$HOME/flutter/bin"

# Install Flutter artifacts for iOS (--ios), or macOS (--macos) platforms.
flutter precache --ios

# Install Flutter dependencies.
flutter pub get

# Install CocoaPods using Homebrew.
HOMEBREW_NO_AUTO_UPDATE=1 # disable homebrew's automatic updates.
brew install cocoapods

# Install CocoaPods dependencies.
cd ios && pod install # run `pod install` in the `ios` directory.

exit 0
