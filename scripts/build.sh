#!/bin/bash

set -e

# ==========================================
# LOAD COMMON ENVIRONMENT
# ==========================================

source scripts/common.sh

log "STARTING FFmpeg FULL BUILD PIPELINE"

bash scripts/validate_config.sh

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

# Copy tools if enabled and produced by FFmpeg
if [ "$BUILD_FFPROBE" = "yes" ] && [ -f "$FFMPEG_BUILD_DIR/bin/ffprobe" ]; then
  cp "$FFMPEG_BUILD_DIR/bin/ffprobe" "$OUTPUT_DIR/"
fi

if [ "$BUILD_FFMPEG" = "yes" ] && [ -f "$FFMPEG_BUILD_DIR/bin/ffmpeg" ]; then
  cp "$FFMPEG_BUILD_DIR/bin/ffmpeg" "$OUTPUT_DIR/"
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
FFmpeg: $FFMPEG_VERSION
Output: $OUTPUT_NAME
Single shared library: $OUTPUT_SINGLE_SO
LTO: $ENABLE_LTO
Stripped: $STRIP_BINARIES

Core Libraries:
- libavcodec
- libavformat
- libavfilter
- libavutil
- libswscale
- libswresample

Hardware Decoders:
- h264_mediacodec
- hevc_mediacodec
- vp8_mediacodec
- vp9_mediacodec

Hardware Encoders:
- h264_mediacodec
- hevc_mediacodec

Software Video Codecs:
- H.264
- H.265 / HEVC
- VP8
- VP9
- MPEG-4 Part 2
- MJPEG

Software Audio Codecs:
- AAC
- MP3
- FLAC
- Opus
- PCM / WAV

Muxers:
- MP4
- MOV
- MKV / Matroska
- WebM
- MP3
- WAV
- FLAC

Demuxers:
- MP4
- MOV
- MKV / Matroska
- WebM
- MP3
- WAV
- FLAC

Protocols:
- file
- http
- https

Filters:
- scale
- crop
- overlay
- rotate
- fade
- zoompan
- subtitles

Subtitles:
- libass
- FreeType
- HarfBuzz
- FriBidi
- FontConfig
- Expat
- SRT / ASS / SSA / WebVTT
- UTF-8
- RTL and bidirectional text support

Runtime Tools:
- ffmpeg: $BUILD_FFMPEG
- ffprobe: $BUILD_FFPROBE
- ffplay: $BUILD_FFPLAY
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
