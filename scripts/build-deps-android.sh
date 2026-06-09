#!/bin/bash
set -e

source scripts/common.sh

mkdir -p src
mkdir -p build/deps

cd src

# =========================
# x264 (FIXED)
# =========================
git clone https://code.videolan.org/videolan/x264.git
cd x264

./configure \
  --prefix=$BUILD/deps \
  --host=aarch64-linux-android \
  --cross-prefix=$NDK_TOOLCHAIN/bin/aarch64-linux-android- \
  --sysroot=$SYSROOT \
  --enable-static \
  --disable-cli \
  --extra-cflags="$CFLAGS" \
  --extra-ldflags="$LDFLAGS"

make -j$(nproc)
make install

touch $BUILD/deps/x264.built
cd ..

# =========================
# libvpx (FIXED)
# =========================
git clone https://chromium.googlesource.com/webm/libvpx
cd libvpx

./configure \
  --target=arm64-android-gcc \
  --enable-vp9 \
  --disable-examples \
  --disable-tools \
  --extra-cflags="$CFLAGS"

make -j$(nproc)
make install

touch $BUILD/deps/vpx.built
cd ..
