#!/bin/bash

set -e

# ==========================================
# LOAD COMMON ENVIRONMENT
# ==========================================

source scripts/common.sh

log "STARTING FFmpeg FULL BUILD PIPELINE"

# ==========================================
# CLEAN PREVIOUS OUTPUT
# ==========================================

rm -rf "$OUTPUT_DIR"
mkdir -p "$OUTPUT_DIR"

# ==========================================
# STEP 1: BUILD DEPENDENCIES
# ==========================================

log "STEP 1: Building dependencies (libass, freetype, etc.)"

bash scripts/build_deps.sh
check_error "Dependency build"

# ==========================================
# STEP 2: BUILD FFMPEG
# ==========================================

log "STEP 2: Building FFmpeg core"

bash scripts/build_ffmpeg.sh
check_error "FFmpeg build"

# ==========================================
# STEP 3: PACKAGE OUTPUT
# ==========================================

log "STEP 3: Packaging final output"

FFMPEG_BUILD_DIR="$PROJECT_ROOT/build/ffmpeg"

mkdir -p "$OUTPUT_DIR/libs"

# Copy main shared library
cp "$FFMPEG_BUILD_DIR/libffmpeg.so" "$OUTPUT_DIR/libs/"
check_error "Copy libffmpeg.so"

# Copy tools if enabled
if [ "$BUILD_FFPROBE" = "yes" ]; then
  cp "$FFMPEG_BUILD_DIR/ffprobe" "$OUTPUT_DIR/"
fi

if [ "$BUILD_FFMPEG" = "yes" ]; then
  cp "$FFMPEG_BUILD_DIR/ffmpeg" "$OUTPUT_DIR/"
fi

# ==========================================
# STEP 4: META INFO
# ==========================================

cat > "$OUTPUT_DIR/build-info.txt" <<EOF
FFmpeg Build Info
==================

ABI: $ABI
ARCH: $ARCH
API: $ANDROID_API

Video Codecs:
- H.264 (MediaCodec)
- H.265 (MediaCodec)
- VP8 / VP9

Audio Codecs:
- AAC, MP3, FLAC, Opus

Subtitles:
- libass enabled
- FreeType + HarfBuzz + FriBidi
- RTL support (Urdu/Arabic)

Filters:
- scale, crop, overlay, trim
- audio mixing, volume control

Output:
- single libffmpeg.so

Build Mode:
- Android 13+ optimized
EOF

# ==========================================
# STEP 5: STRIP BINARY (OPTIMIZATION)
# ==========================================

if [ "$STRIP_BINARIES" = "yes" ]; then
  log "Stripping binaries for size optimization"
  $STRIP "$OUTPUT_DIR/libs/libffmpeg.so"
fi

# ==========================================
# DONE
# ==========================================

log "BUILD COMPLETED SUCCESSFULLY"
echo "📦 Output available in: $OUTPUT_DIR"