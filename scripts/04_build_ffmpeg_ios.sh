set -e

git clone https://github.com/FFmpeg/FFmpeg.git
cd FFmpeg

./configure \
--target-os=darwin \
--arch=arm64 \
--enable-cross-compile \
--cc="xcrun -sdk iphoneos clang" \
--sysroot="$(xcrun -sdk iphoneos --show-sdk-path)" \
--prefix=$PREFIX/ios \
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
--enable-videotoolbox

make -j$(sysctl -n hw.ncpu)
make install
