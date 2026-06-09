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
  --host=arm-apple-darwin \
  --enable-static

make -j$(sysctl -n hw.ncpu)
make install

touch $DEPS/x264.built
cd ..

# libvpx
git clone https://chromium.googlesource.com/webm/libvpx
cd libvpx

./configure \
  --target=arm64-darwin-gcc \
  --enable-vp9

make -j$(sysctl -n hw.ncpu)
make install

touch $DEPS/vpx.built
cd ..
