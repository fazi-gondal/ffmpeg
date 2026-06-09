#!/bin/bash
set -e

source scripts/common.sh

git clone https://github.com/FFmpeg/FFmpeg.git
cd FFmpeg

./configure \
--target-os=darwin \
--arch=arm64 \
--enable-cross-compile \
--cc="xcrun -sdk iphoneos clang" \
--sysroot="$(xcrun -sdk iphoneos --show-sdk-path)" \
--prefix=$BUILD/ios \
\
--enable-gpl \
--enable-version3 \
\
--enable-libx264 \
--enable-libvpx \
--enable-libopus \
--enable-libmp3lame \
--enable-libass \
\
--enable-videotoolbox

make -j$(sysctl -n hw.ncpu)
make install
