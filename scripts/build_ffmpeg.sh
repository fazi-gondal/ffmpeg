#!/bin/bash

set -e

# ==========================================
# LOAD ENVIRONMENT
# ==========================================

source scripts/common.sh

log "BUILDING FFMPEG CORE"

# ==========================================
# SOURCE DIRECTORY
# ==========================================

FFMPEG_SRC="$PROJECT_ROOT/ffmpeg_sources/ffmpeg"
BUILD_DIR="$PROJECT_ROOT/build/ffmpeg"

DEPS_PREFIX="$PROJECT_ROOT/deps/android/$ABI"

mkdir -p "$BUILD_DIR"

bash scripts/prepare_sources.sh

export PKG_CONFIG_PATH="$DEPS_PREFIX/lib/pkgconfig"
export PATH="$DEPS_PREFIX/bin:$PATH"

cd "$FFMPEG_SRC"

# ==========================================
# CLEAN PREVIOUS BUILD
# ==========================================

make distclean || true

# ==========================================
# BASE CONFIGURE FLAGS
# ==========================================

CONFIGURE_FLAGS="\
--prefix=$BUILD_DIR \
--target-os=android \
--arch=$ARCH \
--cpu=$CPU \
--enable-cross-compile \
--cross-prefix=$TOOLCHAIN/bin/aarch64-linux-android- \
--sysroot=$SYSROOT \
--disable-shared \
--enable-static \
--enable-pic \
--disable-doc \
--pkg-config-flags=--static \
"

if [ "$BUILD_FFMPEG" = "yes" ]; then
  CONFIGURE_FLAGS="$CONFIGURE_FLAGS --enable-ffmpeg"
else
  CONFIGURE_FLAGS="$CONFIGURE_FLAGS --disable-ffmpeg"
fi

if [ "$BUILD_FFPROBE" = "yes" ]; then
  CONFIGURE_FLAGS="$CONFIGURE_FLAGS --enable-ffprobe"
else
  CONFIGURE_FLAGS="$CONFIGURE_FLAGS --disable-ffprobe"
fi

CONFIGURE_FLAGS="$CONFIGURE_FLAGS --disable-ffplay"

# ==========================================
# VIDEO CODECS
# ==========================================

if [ "$ENABLE_MEDIACODEC" = "yes" ]; then
  CONFIGURE_FLAGS="$CONFIGURE_FLAGS --enable-jni --enable-mediacodec"
fi

if [ "$MEDIACODEC_H264" = "yes" ]; then
  CONFIGURE_FLAGS="$CONFIGURE_FLAGS --enable-decoder=h264_mediacodec --enable-encoder=h264_mediacodec"
fi

if [ "$MEDIACODEC_HEVC" = "yes" ]; then
  CONFIGURE_FLAGS="$CONFIGURE_FLAGS --enable-decoder=hevc_mediacodec --enable-encoder=hevc_mediacodec"
fi

if [ "$MEDIACODEC_VP8" = "yes" ]; then
  CONFIGURE_FLAGS="$CONFIGURE_FLAGS --enable-decoder=vp8_mediacodec"
fi

if [ "$MEDIACODEC_VP9" = "yes" ]; then
  CONFIGURE_FLAGS="$CONFIGURE_FLAGS --enable-decoder=vp9_mediacodec"
fi

# ==========================================
# SOFTWARE CODECS
# ==========================================

CONFIGURE_FLAGS="$CONFIGURE_FLAGS --enable-gpl --enable-version3"

if [ "$CODEC_X264" = "yes" ]; then
  CONFIGURE_FLAGS="$CONFIGURE_FLAGS --enable-libx264"
fi

if [ "$CODEC_X265" = "yes" ]; then
  CONFIGURE_FLAGS="$CONFIGURE_FLAGS --enable-libx265"
fi

# ==========================================
# SUBTITLES STACK
# ==========================================

CONFIGURE_FLAGS="$CONFIGURE_FLAGS \
--enable-libass \
--enable-libfreetype \
--enable-libharfbuzz \
--enable-libfribidi \
--enable-libfontconfig \
"

# ==========================================
# FILTERS
# ==========================================

CONFIGURE_FLAGS="$CONFIGURE_FLAGS \
--enable-filter=scale \
--enable-filter=crop \
--enable-filter=overlay \
--enable-filter=rotate \
--enable-filter=fade \
--enable-filter=zoompan \
--enable-filter=subtitles \
"

# ==========================================
# MUXERS / DEMUXERS
# ==========================================

CONFIGURE_FLAGS="$CONFIGURE_FLAGS \
--enable-muxer=mp4 \
--enable-muxer=matroska \
--enable-muxer=mov \
--enable-muxer=webm \
--enable-muxer=mp3 \
--enable-muxer=wav \
--enable-muxer=flac \
--enable-demuxer=mp4 \
--enable-demuxer=matroska \
--enable-demuxer=mov \
--enable-demuxer=webm \
--enable-demuxer=mp3 \
--enable-demuxer=wav \
--enable-demuxer=flac \
"

# ==========================================
# MEDIA FEATURES
# ==========================================

CONFIGURE_FLAGS="$CONFIGURE_FLAGS \
--enable-protocol=file \
--enable-protocol=http \
--enable-protocol=https \
--enable-zlib \
--enable-avfilter \
--enable-avformat \
--enable-avcodec \
--enable-avutil \
--enable-swscale \
--enable-swresample \
"

# ==========================================
# LINK DEPENDENCIES
# ==========================================

CONFIGURE_FLAGS="$CONFIGURE_FLAGS \
--extra-cflags=-I$DEPS_PREFIX/include \
--extra-ldflags=-L$DEPS_PREFIX/lib \
--extra-libs=-llog \
"

# ==========================================
# RUN CONFIGURE
# ==========================================

log "Configuring FFmpeg"

./configure $CONFIGURE_FLAGS

check_error "FFmpeg configure"

# ==========================================
# BUILD
# ==========================================

log "Compiling FFmpeg"

make -j$(nproc)

check_error "FFmpeg build"

# ==========================================
# INSTALL
# ==========================================

make install

check_error "FFmpeg install"

# CREATE SINGLE LIB (OPTIONAL MERGE STEP)
# ==========================================

log "Creating final libffmpeg.so"

$CC -shared \
  -o "$BUILD_DIR/libffmpeg.so" \
  -Wl,--whole-archive \
  "$BUILD_DIR/lib/"*.a \
  "$DEPS_PREFIX/lib/"*.a \
  -Wl,--no-whole-archive \
  -llog -lm -lz

# ==========================================
# DONE
# ==========================================

log "FFMPEG BUILD COMPLETED"

echo "Final output: $BUILD_DIR/libffmpeg.so"
