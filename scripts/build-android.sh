#!/bin/bash
set -e

source scripts/common.sh

git clone https://github.com/FFmpeg/FFmpeg.git
cd FFmpeg

CROSS=$NDK/toolchains/llvm/prebuilt/linux-x86_64/bin/aarch64-linux-android-
SYSROOT=$NDK/toolchains/llvm/prebuilt/linux-x86_64/sysroot

./configure \
--target-os=android \
--arch=aarch64 \
--enable-cross-compile \
--cross-prefix=$CROSS \
--sysroot=$SYSROOT \
--prefix=$BUILD/android \
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
--enable-mediacodec

make -j$(nproc)
make install
