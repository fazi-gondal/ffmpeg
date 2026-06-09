#!/bin/bash
set -e

CONFIG=$1

echo "🔍 Validating: $CONFIG"

if [ ! -f "$CONFIG" ]; then
  echo "❌ Config not found"
  exit 1
fi

TEXT=$(cat "$CONFIG")

# ❌ invalid FFmpeg flags
INVALID=(
  "--enable-libflac"
  "--enable-libaac"
  "--enable-libh264"
  "--enable-libmp4"
)

for f in "${INVALID[@]}"; do
  if echo "$TEXT" | grep -q "$f"; then
    echo "❌ INVALID FLAG: $f"
    exit 1
  fi
done

# ❌ platform mismatch
if echo "$TEXT" | grep -q "videotoolbox" && echo "$TEXT" | grep -q "android"; then
  echo "❌ iOS-only feature in Android config"
  exit 1
fi

if echo "$TEXT" | grep -q "mediacodec" && echo "$TEXT" | grep -q "darwin"; then
  echo "❌ Android-only feature in iOS config"
  exit 1
fi

echo "✅ Config valid"
