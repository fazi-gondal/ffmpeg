#!/bin/bash

set -e

# ==========================================
# LOAD ENVIRONMENT
# ==========================================

source scripts/common.sh

log "VALIDATING BUILD CONFIGURATION"

# ==========================================
# REQUIRED FILES CHECK
# ==========================================

REQUIRED_FILES=(
  "configs/ffmpeg.conf"
  "configs/codecs.conf"
  "configs/containers.conf"
  "configs/filters.conf"
  "configs/subtitles.conf"
)

for file in "${REQUIRED_FILES[@]}"; do
  if [ ! -f "$PROJECT_ROOT/$file" ]; then
    echo "❌ Missing required config: $file"
    exit 1
  fi
done

echo "✅ All config files exist"

# ==========================================
# ANDROID NDK CHECK
# ==========================================

if [ -z "$NDK" ]; then
  echo "❌ ANDROID NDK not set"
  exit 1
fi

if [ ! -d "$NDK" ]; then
  echo "❌ Invalid NDK path"
  exit 1
fi

echo "✅ NDK found: $NDK"

# ==========================================
# TOOLCHAIN CHECK
# ==========================================

TOOLCHAIN="$NDK/toolchains/llvm/prebuilt/linux-x86_64"

if [ ! -d "$TOOLCHAIN" ]; then
  echo "❌ Missing toolchain"
  exit 1
fi

echo "✅ Toolchain available"

# ==========================================
# CRITICAL FEATURE VALIDATION
# ==========================================

# Subtitle stack dependency check
if [ "$ENABLE_LIBASS" = "yes" ]; then

  if [ "$ENABLE_FREETYPE" != "yes" ]; then
    echo "❌ libass requires FreeType"
    exit 1
  fi

  if [ "$ENABLE_HARFBUZZ" != "yes" ]; then
    echo "❌ libass requires HarfBuzz"
    exit 1
  fi

  if [ "$ENABLE_FRIBIDI" != "yes" ]; then
    echo "❌ libass requires FriBidi (RTL support)"
    exit 1
  fi

fi

echo "✅ Subtitle dependency chain valid"

# ==========================================
# CODEC CONFLICT CHECKS
# ==========================================

if [ "$CODEC_X264" = "yes" ] && [ "$MEDIACODEC_H264" = "yes" ]; then
  echo "⚠ WARNING: Both x264 and MediaCodec H264 enabled"
fi

if [ "$CODEC_X265" = "yes" ] && [ "$MEDIACODEC_HEVC" = "yes" ]; then
  echo "⚠ WARNING: Both x265 and MediaCodec HEVC enabled"
fi

# ==========================================
# PERFORMANCE CHECKS
# ==========================================

if [ "$ENABLE_LTO" = "yes" ]; then
  echo "ℹ LTO enabled (longer build time, smaller binary)"
fi

# ==========================================
# EDITOR FEATURE CHECK
# ==========================================

if [ "$ENABLE_SUBTITLE_BURN" = "yes" ] && [ "$ENABLE_LIBASS" != "yes" ]; then
  echo "❌ Subtitle burn requires libass"
  exit 1
fi

# ==========================================
# FINAL SUMMARY
# ==========================================

echo ""
echo "=========================================="
echo "CONFIG VALIDATION PASSED"
echo "=========================================="
echo "Target: $ABI"
echo "API Level: $ANDROID_API"
echo "MediaCodec: ENABLED"
echo "Subtitles: $ENABLE_LIBASS"
echo "Output: libffmpeg.so"
echo "=========================================="