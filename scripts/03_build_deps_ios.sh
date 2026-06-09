set -e

mkdir -p src
cd src

# x264 iOS
git clone https://code.videolan.org/videolan/x264.git
cd x264
./configure --host=arm-apple-darwin --enable-static
make -j$(sysctl -n hw.ncpu)
make install
cd ..

# libvpx iOS
git clone https://chromium.googlesource.com/webm/libvpx
cd libvpx
./configure --target=arm64-darwin20-gcc --enable-vp9
make -j$(sysctl -n hw.ncpu)
make install
cd ..
