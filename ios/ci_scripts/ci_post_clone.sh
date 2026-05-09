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

# ── Git network hardening ────────────────────────────────────────────────────
# CocoaPods clones some pods (SwiftyGif under DKPhotoGallery) directly from
# GitHub instead of the CocoaPods CDN. On the Xcode Cloud runner those clones
# can pick up a stale proxy config and silently fail with
#   "Failed to connect to 172.16.x.x port 8088"
# or get URL-rewritten from https:// → http://, which in turn 404s. Strip any
# inherited proxy config and force GitHub URLs to HTTPS before pod install
# runs — this only affects this shell session, never the runner image.
git config --global --unset-all http.proxy 2>/dev/null || true
git config --global --unset-all https.proxy 2>/dev/null || true
git config --global --unset-all url."http://github.com/".insteadOf 2>/dev/null || true
git config --global --unset-all url."https://github.com/".insteadOf 2>/dev/null || true
git config --global --add url."https://github.com/".insteadOf "git://github.com/"
git config --global --add url."https://github.com/".insteadOf "ssh://git@github.com/"
git config --global --add url."https://github.com/".insteadOf "http://github.com/"
unset http_proxy HTTP_PROXY https_proxy HTTPS_PROXY all_proxy ALL_PROXY

# Print effective git config so the next failure (if any) lands a diagnostic
# in the build log instead of guessing what the runner inherited.
echo "── effective git config (network) ──"
git config --global --get-all http.proxy 2>/dev/null || echo "  http.proxy: <unset>"
git config --global --get-regexp 'url\..*\.insteadof' 2>/dev/null || true
echo "── end git config ──"

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

# Install CocoaPods dependencies. Retry once on transient failures —
# SwiftyGif and other git-sourced pods occasionally hit network blips.
cd ios
pod install --repo-update || pod install --repo-update || pod install --repo-update

exit 0
