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
--enable-shared \
--disable-static \
--enable-pic \
--disable-doc \
--disable-programs \
"

# ==========================================
# VIDEO CODECS
# ==========================================

if [ "$MEDIACODEC_H264" = "yes" ]; then
  CONFIGURE_FLAGS="$CONFIGURE_FLAGS --enable-h264_mediacodec"
fi

if [ "$MEDIACODEC_HEVC" = "yes" ]; then
  CONFIGURE_FLAGS="$CONFIGURE_FLAGS --enable-hevc_mediacodec"
fi

if [ "$MEDIACODEC_VP8" = "yes" ]; then
  CONFIGURE_FLAGS="$CONFIGURE_FLAGS --enable-vp8_mediacodec"
fi

if [ "$MEDIACODEC_VP9" = "yes" ]; then
  CONFIGURE_FLAGS="$CONFIGURE_FLAGS --enable-vp9_mediacodec"
fi

# ==========================================
# SOFTWARE CODECS
# ==========================================

CONFIGURE_FLAGS="$CONFIGURE_FLAGS \
--enable-gpl \
--enable-version3 \
--enable-libx264 \
--enable-libx265 \
--enable-libvpx \
--enable-libopus \
--enable-libmp3lame \
"

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
--enable-muxer=mkv \
--enable-muxer=mov \
--enable-muxer=webm \
--enable-muxer=mp3 \
--enable-muxer=wav \
--enable-muxer=flac \
--enable-demuxer=mp4 \
--enable-demuxer=mkv \
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
--extra-cflags=\"-I$DEPS_PREFIX/include\" \
--extra-ldflags=\"-L$DEPS_PREFIX/lib\" \
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

# ==========================================
# COPY OUTPUT
# ==========================================

mkdir -p "$BUILD_DIR/output"

cp "$BUILD_DIR/lib/libavcodec.so" "$BUILD_DIR/output/"
cp "$BUILD_DIR/lib/libavformat.so" "$BUILD_DIR/output/"
cp "$BUILD_DIR/lib/libavfilter.so" "$BUILD_DIR/output/"
cp "$BUILD_DIR/lib/libavutil.so" "$BUILD_DIR/output/"
cp "$BUILD_DIR/lib/libswscale.so" "$BUILD_DIR/output/"
cp "$BUILD_DIR/lib/libswresample.so" "$BUILD_DIR/output/"

# ==========================================
# CREATE SINGLE LIB (OPTIONAL MERGE STEP)
# ==========================================

log "Creating final libffmpeg.so"

$CC -shared \
  -o "$BUILD_DIR/libffmpeg.so" \
  -Wl,--whole-archive \
  "$BUILD_DIR/output/"*.so \
  -Wl,--no-whole-archive \
  -llog -lm -lz

# ==========================================
# DONE
# ==========================================

log "FFMPEG BUILD COMPLETED"

echo "Final output: $BUILD_DIR/libffmpeg.so"