set -e

cd FFmpeg || git clone https://github.com/FFmpeg/FFmpeg.git && cd FFmpeg

export CROSS=aarch64-linux-android-
export SYSROOT=$NDK/toolchains/llvm/prebuilt/linux-x86_64/sysroot

./configure \
--target-os=android \
--arch=aarch64 \
--enable-cross-compile \
--cross-prefix=$CROSS \
--sysroot=$SYSROOT \
--prefix=$PREFIX/android \
\
--enable-gpl \
--enable-version3 \
\
--enable-libx264 \
--enable-libx265 \
--enable-libvpx \
--enable-libopus \
--enable-libmp3lame \
--enable-libflac \
--enable-libass \
\
--enable-mediacodec \
--enable-jni

make -j$(nproc)
make install
