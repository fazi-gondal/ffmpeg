#!/bin/bash
set -e

source scripts/common.sh

mkdir -p $SRC
mkdir -p $DEPS

cd $SRC

# x264
git clone https://code.videolan.org/videolan/x264.git
cd x264

./configure \
  --prefix=$DEPS \
  --host=aarch64-linux-android \
  --enable-static \
  --disable-cli \
  --extra-cflags="-march=armv8-a+simd -O3"

make -j$(nproc)
make install

touch $DEPS/x264.built
cd ..

# libvpx
git clone https://chromium.googlesource.com/webm/libvpx
cd libvpx

./configure \
  --target=arm64-android-gcc \
  --enable-vp9 \
  --disable-examples \
  --disable-tools

make -j$(nproc)
make install

touch $DEPS/vpx.built
cd ..
