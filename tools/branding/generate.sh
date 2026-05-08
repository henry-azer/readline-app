#!/usr/bin/env bash
#
# Renders all iOS + Android icon and splash assets from the SVG sources in
# this directory. Re-run this whenever the SVG sources change.
#
# Requires: rsvg-convert (brew install librsvg)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
IOS_ICON_DIR="$PROJECT_ROOT/ios/Runner/Assets.xcassets/AppIcon.appiconset"
IOS_SPLASH_DIR="$PROJECT_ROOT/ios/Runner/Assets.xcassets/LaunchSplash.imageset"
ANDROID_RES="$PROJECT_ROOT/android/app/src/main/res"

command -v rsvg-convert >/dev/null 2>&1 || { echo "rsvg-convert not found. brew install librsvg"; exit 1; }

render() {
  local src="$1" px="$2" out="$3"
  rsvg-convert -w "$px" -h "$px" "$src" -o "$out"
}

render_w() {
  local src="$1" w="$2" h="$3" out="$4"
  rsvg-convert -w "$w" -h "$h" "$src" -o "$out"
}

# ─── iOS App Icons ───────────────────────────────────────────────────
mkdir -p "$IOS_ICON_DIR"

# (size_name, pixel_size)
ios_sizes=(
  "20x20@2x:40"
  "20x20@3x:60"
  "29x29@2x:58"
  "29x29@3x:87"
  "38x38@2x:76"
  "38x38@3x:114"
  "40x40@2x:80"
  "40x40@3x:120"
  "60x60@2x:120"
  "60x60@3x:180"
  "64x64@2x:128"
  "76x76@2x:152"
  "83.5x83.5@2x:167"
  "1024x1024@1x:1024"
)

echo "→ iOS app icons (light)"
for entry in "${ios_sizes[@]}"; do
  name="${entry%%:*}"
  px="${entry##*:}"
  render "$SCRIPT_DIR/icon-light.svg" "$px" "$IOS_ICON_DIR/Icon-App-${name}.png"
done

echo "→ iOS app icons (dark)"
for entry in "${ios_sizes[@]}"; do
  name="${entry%%:*}"
  px="${entry##*:}"
  render "$SCRIPT_DIR/icon-dark.svg" "$px" "$IOS_ICON_DIR/Icon-App-Dark-${name}.png"
done

# ─── iOS Launch Splash ───────────────────────────────────────────────
# Logical size 240×184; rendered at @2x (480×368) and @3x (720×552).
# The SVG content matches SplashScreen widget proportions exactly.
mkdir -p "$IOS_SPLASH_DIR"
echo "→ iOS launch splash"
render_w "$SCRIPT_DIR/splash-light.svg" 480 368 "$IOS_SPLASH_DIR/launch_splash_light@2x.png"
render_w "$SCRIPT_DIR/splash-light.svg" 720 552 "$IOS_SPLASH_DIR/launch_splash_light@3x.png"
render_w "$SCRIPT_DIR/splash-dark.svg"  480 368 "$IOS_SPLASH_DIR/launch_splash_dark@2x.png"
render_w "$SCRIPT_DIR/splash-dark.svg"  720 552 "$IOS_SPLASH_DIR/launch_splash_dark@3x.png"

# ─── Android Icons ───────────────────────────────────────────────────
# (dpi:legacy_px:adaptive_px) — adaptive layers are 1.5× legacy
android_buckets=(
  "mdpi:48:108"
  "hdpi:72:162"
  "xhdpi:96:216"
  "xxhdpi:144:324"
  "xxxhdpi:192:432"
)

echo "→ Android icons (light)"
for entry in "${android_buckets[@]}"; do
  IFS=':' read -r dpi legacy_px adaptive_px <<< "$entry"
  dir="$ANDROID_RES/mipmap-$dpi"
  mkdir -p "$dir"
  render "$SCRIPT_DIR/icon-light.svg"          "$legacy_px"   "$dir/ic_launcher.png"
  render "$SCRIPT_DIR/adaptive-back-light.svg" "$adaptive_px" "$dir/ic_launcher_adaptive_back.png"
  render "$SCRIPT_DIR/adaptive-fore-light.svg" "$adaptive_px" "$dir/ic_launcher_adaptive_fore.png"
done

echo "→ Android icons (dark)"
for entry in "${android_buckets[@]}"; do
  IFS=':' read -r dpi legacy_px adaptive_px <<< "$entry"
  dir="$ANDROID_RES/mipmap-night-$dpi"
  mkdir -p "$dir"
  render "$SCRIPT_DIR/icon-dark.svg"          "$legacy_px"   "$dir/ic_launcher.png"
  render "$SCRIPT_DIR/adaptive-back-dark.svg" "$adaptive_px" "$dir/ic_launcher_adaptive_back.png"
  render "$SCRIPT_DIR/adaptive-fore-dark.svg" "$adaptive_px" "$dir/ic_launcher_adaptive_fore.png"
done

echo "✓ Done."
